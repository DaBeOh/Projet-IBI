#Etape 2 - Nettoyages des donnees

begin=$(date +%s.%N)

rm -f marked_dup*

echo -e "Etape 2 - Nettoyages des donnees\n"

#fichier fsa de référence
ref=S288C_reference_sequence_R64-2-1_20150113.fsa
bwa index ${ref}
i=0
tirets="
\n-------------------------------------------------------------------------------\n"

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

	#mapping
	#transformation du fastq en sam
	message="mapping du fichier $file\n"
	echo -e $message
	bwa mem -R '@RG\tID:'S288C'\tPL:ILLUMINA\tPI:0\tSM:'${file}'\tLB:1'\
				${ref} ${fastqfile} > bwa_${file}.sam
	rm ${fastqfile}
	echo -e "${fastqfile} supprimé\n"

	#transformation du sam en bam
	samtools view -bS bwa_${file}.sam > bwa_${file}.bam
	rm bwa_${file}.sam
	echo -e "bwa_${file}.sam supprimé\n"

	#marquage des reads avec gatk
	message="marquage des reads du fichier $file\n"
	echo -e $message
	/usr/local/bin/gatk-4.1.9.0/gatk MarkDuplicatesSpark \
			-I bwa_${file}.bam \
            -O marked_duplicates_${file}.bam \
            -M marked_dup_metrics_${file}.txt

    cat marked_dup_metrics_${file}.txt >> marked_dup_metrics.txt
    rm marked_dup_metrics_${file}.txt


    rm bwa_${file}.bam
    echo -e "bwa_${file}.bam supprimé\n"

    #marquage des duplicats
    message="marquage des duplicats du fichier $file\n"
	echo -e $message
	echo -e $message >> marked_duplicates.txt
    samtools flagstat marked_duplicates_${file}.bam >> marked_duplicates.txt

    rm marked_duplicates_${file}.bam
    echo -e "marked_duplicates_${file}.bam supprimé\n"

    #suppression fichiers inutiles
    rm *.bai *.sbi
    echo -e "fichiers bai et sbi supprimés\n"
done

rm ${ref}.amb ${ref}.ann ${ref}.bwt ${ref}.pac ${ref}.sa
echo -e "fichiers annexes ref supprimés\n"

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
printf "\nTotal runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds >> marked_duplicates.txt

echo "FIN"