#R script pour faire des distributions
#!/usr/bin/env Rscript
#install.packages("VennDiagram")
library(lattice)
library(vcfR)
library(VennDiagram)
# vcf <- read.vcfR( vcf_file, verbose = FALSE )

# LECTURE DU FICHIER
annot.file = "C:/cygwin/home/lenovo/L3/ProjetIBI/Filtration/filtre2/marked_duplicates_ERR2299966.g.vcf"
annotations = read.table(annot.file, h=TRUE, na.strings=".")
# vcf <- read.vcfR("C:/cygwin/home/lenovo/L3/ProjetIBI/Filtration/Filtre_test/table.vcf.gz", verbose = FALSE )

# INITIALISATION DES SEUILS
lim.QD = 2
lim.FS = 10
lim.MQ = 10
lim.MQRankSum = 0
lim.ReadPosRankSum = 3.0  #☺-8.0
lim.SOR = 0

# CREATION DES FIGURES
## FIGURE DE QD
pdf(paste(annot.file,"Filtres_QD.pdf",sep=" "))
## FIGURE DE QD
prop.QD=length(which(annotations$QD >lim.QD)) / nrow(annotations)
plot(density(annotations$QD,na.rm=T),main="QD", sub = paste("Filtre: QD >",lim.QD,"( = ", signif(prop.QD,3),"% des SNP) " ,sep="") ) 
abline(v=lim.QD, col="red")

dev.off()

## FIGURE DE FS
# CREATION DES FIGURES
pdf(paste(annot.file,"Filtre_FS.pdf",sep=" "))
prop.FS=length(which(annotations$FS >lim.FS)) / nrow(annotations)
plot(density(annotations$FS,na.rm=T),main="FS", sub = paste("Filtre: FS >",lim.FS,"( = ", signif(prop.FS,3),"% des SNP) " ,sep="") ) 
abline(v=lim.FS, col="red")

dev.off()

## FIGURE DE MQ
# CREATION DES FIGURES
pdf(paste(annot.file,"Filtre_MQ.pdf",sep=" "))
prop.MQ=length(which(annotations$MQ >lim.MQ)) / nrow(annotations)
plot(density(annotations$MQ,na.rm=T),main="MQ", sub = paste("Filtre: MQ >",lim.MQ,"( = ", signif(prop.MQ,3),"% des SNP) " ,sep="") ) 
abline(v=lim.MQ, col="red")

dev.off()

## FIGURE DE MQRankSum
# CREATION DES FIGURES
pdf(paste(annot.file,"Filtre_MQRankSum.pdf",sep=" "))
prop.MQRankSum=length(which(annotations$MQRankSum >lim.MQRankSum)) / nrow(annotations)
plot(density(annotations$MQRankSum,na.rm=T),main="MQRankSum", sub = paste("Filtre: MQRankSum >",lim.MQRankSum,"( = ", signif(prop.MQRankSum,3),"% des SNP) " ,sep="") ) 
abline(v=lim.MQRankSum, col="red")

dev.off()


## FIGURE DE ReadPosRankSum
# CREATION DES FIGURES
pdf(paste(annot.file,"Filtre_ReadPosRankSum.pdf",sep=" "))
prop.ReadPosRankSum=length(which(annotations$ReadPosRankSum >lim.ReadPosRankSum)) / nrow(annotations)
plot(density(annotations$ReadPosRankSum,na.rm=T),main="ReadPosRankSum", sub = paste("Filtre: ReadPosRankSum >",lim.ReadPosRankSum,"( = ", signif(prop.ReadPosRankSum,3),"% des SNP) " ,sep="") ) 
abline(v=lim.ReadPosRankSum, col="red")

dev.off()


## FIGURE DE SOR
# CREATION DES FIGURES
pdf(paste(annot.file,"Filtre_SOR.pdf",sep=" "))
prop.SOR=length(which(annotations$SOR >lim.SOR)) / nrow(annotations)
plot(density(annotations$SOR,na.rm=T),main="SOR", sub = paste("Filtre: SOR >",lim.SOR,"( = ", signif(prop.SOR,3),"% des SNP) " ,sep="") ) 
abline(v=lim.SOR, col="red")

dev.off()


# Le diagramme de Venn pouvant prendre au max 5 filtres, nous avons fait 2 figures.

# DIAGRAMME DE VENN 11
qd.pass = which(annotations$QD>lim.QD)
fs.pass = which(annotations$FS>lim.FS)
sor.pass = which(annotations$SOR > lim.SOR)
mq.pass = which(annotations$MQ < lim.MQ)
#mqrs.pass= which(annotations$MQRankSum > lim.MQRankSum)
#rprs.pass= which(annotations$ReadPosRankSum > lim.ReadPosRankSum)

venn.diagram(
  x=list(qd.pass, fs.pass,sor.pass,mq.pass),
  category.names = c("QD" , "FS" ," SOR","MQ"),
  fill = c("blue","darkgreen","orange","yellow"),
  output=TRUE,
  filename = "filtre_Venn11"
)


# DIAGRAMME DE VENN 22
# qd.pass = which(annotations$QD>lim.QD)
# fs.pass = which(annotations$FS>lim.FS)
# sor.pass = which(annotations$SOR > lim.SOR) ---------------------------------------
# mq.pass = which(annotations$MQ < lim.MQ)-------------------------------------------sans ces 2 filtres
# mqrs.pass= which(annotations$MQRankSum > lim.MQRankSum)
# rprs.pass= which(annotations$ReadPosRankSum > lim.ReadPosRankSum)

# venn.diagram(
  # x=list(qd.pass, fs.pass,mqrs.pass,rprs.pass),
  # category.names = c("QD" , "FS" ," MQRankSum","ReadPosRankSum"),
  # fill = c("blue","darkgreen","orange","yellow"),
  # output=TRUE,
  # filename = "filtre_Venn22"
# )