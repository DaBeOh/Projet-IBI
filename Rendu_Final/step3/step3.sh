#-----------------------------------------------------------------------------------#
# MOUDEN Hugo																		#
# Projet IBI - L3 MIAGE																#
# Etape 3 - Identification des variants												#
# Dernière modif : 14/04/2021														#
#-----------------------------------------------------------------------------------#

# On lance le nettoyage des données et mapping - Etape 2 - Nettoyages des donnees
# ATTENTION : mettre en commentaire la ligne si Etape 2 déjà exécutée
#./../step2_cleaning/mapping.sh

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

#transformation du fsa en fasta pour le rendre compatible avec HaplotypeCaller
refinit=S288C_reference_sequence_R64-2-1_20150113.fsa
cp $refinit  S288C_reference_sequence_R64-2-1_20150113.fasta
ref=S288C_reference_sequence_R64-2-1_20150113.fasta

#indexation et création d'un dictionnaire
/usr/local/bin/gatk-4.1.9.0/gatk CreateSequenceDictionary -R $ref
samtools faidx $ref
i=0

#-----------------------------------------------------------------------------------#
#Generation d'un fichier GVCF par fichier bam obtenu en étape 2
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
	message="appel variants : $file\n"
	echo -e $message && echo -e $message >> step3.log

	/usr/local/bin/gatk-4.1.9.0/gatk --java-options "-Xmx4g" HaplotypeCaller \
		-R ${ref} \
		-I ${mdfile} \
		-O ${file}.g.vcf.gz \
		-ERC GVCF
done

#-----------------------------------------------------------------------------------#
#Concaténation des noms des gvcf dans un seul fichier pour simplifier l'appel
echo "Concaténation GVCF"
echo -e "$index fin génération GVCF $index"
for gvcf_file in *.vcf.gz
do
	file=${gvcf_file%%.*}
	echo -e "${file}\t${gvcf_file}"
	echo -e "${file}\t${gvcf_file}" >> sample.map
done

echo "FIN Concaténation $tirets"

#Création bd
#sample.map : mapping de l'ensemble des path des gvcf dans un fichier
#intervals.list : liste des ref dans le fichier de reference
echo "Creation Base de Données $tirets"
/usr/local/bin/gatk-4.1.9.0/gatk --java-options "-Xmx4g -Xms4g" \
       GenomicsDBImport \
       --genomicsdb-workspace-path database \
       --batch-size 50 \
       -L intervals.list \
       --sample-name-map sample.map \
       --tmp-dir tmp \
       --reader-threads 5

echo "Base de données créée"

#-Création table VCF----------------------------------------------------------------#

#on utilise la bd générée par GenomicsDBImport
 /usr/local/bin/gatk-4.1.9.0/gatk --java-options "-Xmx4g" GenotypeGVCFs \
   -R $ref \
   -V gendb://database \
   -O genome.vcf.gz

echo "Table VCF créée"

#-----------------------------------------------------------------------------------#

#On sélectionne les variants de SNP

/usr/local/bin/gatk-4.1.9.0/gatk SelectVariants \
		-R $ref \
	 	-V genome.vcf.gz \
	 	--select-type-to-include SNP \
	 	-O select_snp.vcf.gz


##Filtration des SNP selon les paramètres recommandés par GATK
/usr/local/bin/gatk-4.1.9.0/gatk VariantFiltration \
	 	-R $ref \
	 	-V select_snp.vcf.gz \
	 	--genotype-filter-expression "QD < 2.0 || FS > 60.0 || MQ < 40.0 ||
	 								  MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
 		--genotype-filter-name "filtered_snp" \
 		-O filtered_snp.vcf.gz



##Sélectionner uniquement les variants qui ont passé le filtre:
# Cela va nous permettre de garder uniquement les variants qui ont 
# le tag 'PASS' dans le champ 'FILTER' de notre fichier vcf.

/usr/local/bin/gatk-4.1.9.0/gatk SelectVariants \
		-R $ref \
		-V filtered_snp.vcf.gz \
		-O filtered_variants.vcf.gz \
		--exclude-filtered

#-----------------------------------------------------------------------------------#

#Comptabilisation temps total écoulé
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
printf "\nTotal runtime: %d:%02d:%02d:%02.4f\n" $dd $dh $dm $ds >> step3.log

echo "FIN Etape 3"

#-FIN Etape 3-----------------------------------------------------------------------#