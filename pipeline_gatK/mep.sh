cd ../mkdir filtration
cd filtration
mkdir Hard_Filtering
cd Hard_Filtering

## 2- Filtrer avec les outils de la suite GATK:
## permet de sélectionner uniquement les variants de SNP:

gatk SelectVariants \
		-R ../../genome/fichier.fa \
	 	-V ../../part2_var_calling/fichier.vcf \
	 	-selectType SNP \
	 	-O fichier.vcf


##Filtrer nos SNP selon les paramètres de seuils recommandés par GATK:

# Bos_taurus.UMD3.1.dna.toplevel.6.fa -- 
gatk VariantFiltration \
	 	-R ../../genome/fichier.fa \
	 	-V fichier.vcf \
	 	--filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || 
	 					 	MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
 		--filterName "hard_filtering_snp" \
 		-O fichier.vcf



##Sélectionner uniquement les variants qui ont passé le filtre:
# Cela va nous permettre de garder uniquement les variants qui ont 
# le tag 'PASS' dans le champ 'FILTER' de notre fichier vcf.

gatk SelectVariants \
		-R ../../genome/fichier.fa \
		-V fichier.vcf \
		-O fichier.vcf \
		--excludeFiltered


#------------------------------------------------------SNPSIFT

# FILTRE SNPSIFT
cd ..
mkdir Filtre_snpsift
cd Filtre_snpsift

# Garder les variants qui ont une profondeur de couverture >= 20 et ceux ayant une qualité >= 30
cat ../Hard_Filtering/fichier.vcf | java 
-jar /data/softwares/snpEff/4.3/SnpSift.jar 
filter "( DP >= 20 ) & (QUAL >= 30)" > fichier.vcf

less -S fichier.vcf


# Sélectionner les mutations qui sont hétérozygotes.
cat fichier.vcf | java -jar /data/softwares/snpEff/4.3/SnpSift.jar 
filter "isHet(GEN[1])" > fichier.vcf



#---------------------------------------------------------------------------------------
#  Haplotype Caller GatK
#---------------------------------------------------------------------------------------

# cd ..
# mkdir variants 
# cd variants 

# Variants détectés:
# grep -vc "#" ../../var/fichier.vcf