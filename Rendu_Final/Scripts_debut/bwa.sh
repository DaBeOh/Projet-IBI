# Script basch pour avoir des fichiers en sam et pouvoir ainsi utiliser l'algo bwa 
# qui a partir des flags de nos fichiers SAM va donner une qualité d’alignement de 0 à 
# des lectures qui s’alignent à plus d’une position

ref=S288C_reference_sequence_R64-2-1_20150113.fsa
bwa index ${ref}
for fastqfile in *.fastq.gz
do
	bwa mem ${ref} ${fastqfile} > bwa_mem_test_1.sam
done

