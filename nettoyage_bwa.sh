#Etape 2 - Nettoyages des donnees

start='date +%s'

rm -f marked_duplicates.txt
message="Etape 2 - Nettoyages des donnees\n"
echo -e $message

#fichier fsa de référence
ref=S288C_reference_sequence_R64-2-1_20150113.fsa
bwa index ${ref}
i=0

for fastqfile in *.fastq.gz
do
	echo -e "---------------------------------------------------------------\n"
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
	#transformation du sam en bam
	samtools view -bS bwa_${file}.sam > bwa_${file}.bam

	#marquage des reads avec gatk
	message="marquage des reads du fichier $file\n"
	echo -e $message
	/usr/local/bin/gatk-4.1.9.0/gatk MarkDuplicatesSpark \
			-I bwa_${file}.bam \
            -O marked_duplicates_${file}.bam \
            -M marked_dup_metrics_${file}.txt

    message="marquage des duplicats du fichier $file\n"
	echo -e $message
	echo -e $message >> marked_duplicates.txt
    samtools flagstat marked_duplicates_${file}.bam >> marked_duplicates.txt
done

end='date +%s'
runtime=$((end-start))
echo -e "total runtime : $runtime"
echo -e "total runtime : $runtime" >> marked_duplicates.txt