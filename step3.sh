#-----------------------------------------------------------------------------------#
# MOUDEN Hugo																		#
# Projet IBI - L3 MIAGE																#
# Etape 3 - Identification des variants												#
# Dernière modif : 10/04/2021														#
#-----------------------------------------------------------------------------------#

# On lance le nettoyage des données et mapping - Etape 2 - Nettoyages des donnees
# ATTENTION : mettre en commentaire la ligne si Etape 2 déjà exécutée
#./cleaning.sh

#lacement d'un timer pour compter le temps d'exécution
begin=$(date +%s.%N)

#suppression des fichiers restants d'éventuelles exécutions précédentes (tests)
rm -f step3.log *.fasta*


tirets="
\n--------------------------------------------------------------------------------\n"

echo -e $tirets

#-----------------------------------------------------------------------------------#
echo -e "Etape 3 - Identification des variants\n"
#-----------------------------------------------------------------------------------#

#fichier fsa du genome de référence
#COmmenter si Etape 2 exécutée auparavant - même fichier de référence
refinit=S288C_reference_sequence_R64-2-1_20150113.fsa
cp $refinit  S288C_reference_sequence_R64-2-1_20150113.fasta
ref=S288C_reference_sequence_R64-2-1_20150113.fasta
/usr/local/bin/gatk-4.1.9.0/gatk CreateSequenceDictionary -R $ref
samtools faidx $ref
i=0

for mdfile in marked_duplicates_*.bam
do

	samtools index ${mdfile}
	echo -e $tirets
	echo -e $tirets >> step3.log
	#assignation du même nom de fichier que le bam en supprimant l'extension
	file=${mdfile%.bam}
	#logs description des actions effectuees
	i=$((i+1))
	message="file $i : $file\n"
	echo -e $message && echo -e $message >> step3.log

	#Single-sample GVCF calling with allele-specific annotations
	#Appel des variants par echantillon
	echo -e "appel variants : $file\n"
	/usr/local/bin/gatk-4.1.9.0/gatk --java-options "-Xmx4g" HaplotypeCaller  \
		-R ${ref} \
		-I ${mdfile} \
		-O ${file}.g.vcf.gz \
		-ERC GVCF
done

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

echo "FIN Etape 3"

#-FIN Etape 3-----------------------------------------------------------------------#
