ref=S288C_reference_sequence_R64-2-1_20150113.fsa
bwa index ${ref}
i=0
for fastqfile in *.fastq.gz
do
	file=${fastqfile%%.*}
	bwa mem -R '@RG\tID:'S288C'\tPL:ILLUMINA\tPI:0\tSM:'${file}'\tLB:1' ${ref} ${fastqfile} > bwa_${file}.sam
	samtools view -bS bwa_${file}.sam > bwa_${file}.bam
	gatk MarkDuplicatesSpark \
			-I bwa_${file}.bam \
            -O marked_duplicates_${file}.bam
done

