#-----------------------------------------------------------------------------------#
# MOUDEN Hugo																		#
# Projet IBI - L3 MIAGE																#
# Etape 2 - Nettoyages des donnees													#
# Dernière modif : 14/04/2021														#
#-----------------------------------------------------------------------------------#

#initialisation d'un compteur
begin=$(date +%s.%N)

#suppression des fichiers restants d'éventuelles exécutions précédentes (tests)
rm -f marked_dup* *.bam *.sam

#tirets de séparation pour affichage plus propre
tirets="
\n--------------------------------------------------------------------------------\n"

#-----------------------------------------------------------------------------------#
echo -e "$tirets Etape 2 - Nettoyages des donnees\n"
#-----------------------------------------------------------------------------------#

#fichier fsa du genome de référence
ref=S288C_reference_sequence_R64-2-1_20150113.fsa
bwa index ${ref}
i=0

#parcours de l'ensemble des fastq
for fastqfile in *.fastq.gz
do
	echo -e $tirets
	echo -e $tirets >> marked_dup_metrics.txt
	echo -e $tirets >> marked_duplicates.txt

	#assignation du même nom de fichier que le fastq
	file=${fastqfile%%.*}

	#logs description des actions effectuees
	i=$((i+1))
	message="file $i : $file\n"
	echo -e $message
	echo -e $message >> marked_duplicates.txt

	#----mapping au genome de reference---------------------------------------------#
	#transformation du fastq en sam
	message="mapping du fichier $file\n"
	echo -e $message

	#permet de vérifier si le fichier est un paired-end
	if [ ${file: -2} == "_1" ]
	then
		echo "fastqfile : $fastqfile"
		file=${file%??}
		echo -e "---- fichier en paired end ----\n"
		file2=${file}_2.fastq.gz
		bwa mem -R '@RG\tID:'S288C'\tPL:ILLUMINA\tPI:0\tSM:'${file}'\tLB:1'\
					${ref} ${fastqfile} ${file2} > ${file}.sam
		rm ${fastqfile}
		echo -e "${fastqfile} supprimé\n$"
	else
		if [ ${file: -2} == "_2" ]
		then
			rm ${file2}
			echo "${file2} supprimé"
		else
			echo "---- fichier en single end ----\n"
			bwa mem -R '@RG\tID:'S288C'\tPL:ILLUMINA\tPI:0\tSM:'${file}'\tLB:1'\
						${ref} ${fastqfile} > ${file}.sam
			rm ${fastqfile}
			echo -e "${fastqfile} supprimé"
		fi
	fi
	
done

#----Fin boucle Fastq---------------------------------------------------------------#
echo -e "$tirets FIN boucle fastq $tirets"

ls *.sam
for samfile in *.sam
do
	file=${samfile%.*}
	#transformation du sam en bam
	samtools view -bS ${file}.sam > ${file}.bam
	rm ${file}.sam
	echo -e "${file}.sam supprimé\n"

	#----marquage des reads avec gatk-----------------------------------------------#
	message="marquage des reads du fichier $file\n"
	echo -e $message
	/usr/local/bin/gatk-4.1.9.0/gatk MarkDuplicatesSpark \
			-I ${file}.bam \
            -O marked_duplicates_${file}.bam \
            -M marked_dup_metrics_${file}.txt

    cat marked_dup_metrics_${file}.txt >> marked_dup_metrics.txt
    rm marked_dup_metrics_${file}.txt

    rm ${file}.bam
    echo -e "${file}.bam supprimé\n"

    #marquage des duplicats
    message="marquage des duplicats du fichier $file\n"
	echo -e $message
	echo -e $message >> marked_duplicates.txt
    samtools flagstat marked_duplicates_${file}.bam >> marked_duplicates.txt

    # IMPORTANT : Conserver les fichiers marked_duplicates_${file}.bam même après   
    # Utilisation car réutilisés dans l'étape 3 pour GatK HaplotypeCaller

    #suppression fichiers inutiles
    rm *.sbi
    echo -e "fichiers et sbi supprimés\n"
done

rm ${ref}.amb ${ref}.ann ${ref}.bwt ${ref}.pac ${ref}.sa
echo -e "fichiers annexes ref supprimés\n"

# Comptabilisation temps total écoulé
end=$(date +%s.%N)
dt=$(echo "$end - $begin" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)

LC_NUMERIC=C 
printf "Total runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
printf "\nTotal runtime: %d:%02d:%02d:%02.4f\n" \
		$dd $dh $dm $ds >> marked_duplicates.txt

echo "FIN Etape 2 - Nettoyage"

#-FIN Etape 2-----------------------------------------------------------------------#