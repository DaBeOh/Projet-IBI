ref=S288C_reference_sequence_R64-2-1_20150113.fsa
bwa index ${ref}
for fastqfile in *.fastq.gz
do
	bwa mem ${ref} ${fastqfile} > bwa_mem_test_1.sam
done