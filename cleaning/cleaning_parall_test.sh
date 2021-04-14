#-----------------------------------------------------------------------------------#
# MOUDEN Hugo																		#
# Projet IBI - L3 MIAGE																#
# Etape 2 - Nettoyages des donnees													#
# Dernière modif : 10/04/2021														#
#-----------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------------#
# NON FONCTIONNEL																	#
#-----------------------------------------------------------------------------------#

begin=$(date +%s.%N)
rm -f marked_duplicates.txt
message="Etape 2 - Nettoyages des donnees\n"
echo -e $message

clean () {
    echo -e "\n-----------------------------------------------------------------\n"
    local fastqfile=$1
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
    }

for fastqfile in *.fastq.gz; do clean "$fastqfile" & done

end=$(date +%s.%N)
dt=$(echo "$end - $begin" | bc)
dd=$(echo "$dt/86400" | bc)
dt2=$(echo "$dt-86400*$dd" | bc)
dh=$(echo "$dt2/3600" | bc)
dt3=$(echo "$dt2-3600*$dh" | bc)
dm=$(echo "$dt3/60" | bc)
ds=$(echo "$dt3-60*$dm" | bc)

LC_NUMERIC=C printf "Total runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds
echo $LC_NUMERIC >> marked_duplicates2.txt

#-FIN-------------------------------------------------------------------------------#