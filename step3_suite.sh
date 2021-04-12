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
echo "Creation Base de Données $tirets"
gatk --java-options "-Xmx4g -Xms4g" \
       GenomicsDBImport \
       --genomicsdb-workspace-path database \
       --batch-size 50 \
       -L chr1:1000-10000 \
       --sample-name-map sample.map \
       --tmp-dir=tmp \
       --reader-threads 5

echo "Base de données créée"

 #-----------------------------------------------------------------------------------#

#on utilise la bd générée par GenomicsDBImport
 gatk --java-options "-Xmx4g" GenotypeGVCFs \
   -R $ref \
   -V gendb://my_database \
   -O genome.vcf.gz

#-----------------------------------------------------------------------------------#
gatk SelectVariants \
     -R $ref \
     -V genome.vcf.gz \
     --select-type-to-include SNP \
     -O selected_variants.vcf