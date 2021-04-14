if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("gdsfmt")
BiocManager::install("SNPRelate")
BiocManager::install("SeqArray")

install.packages("ape")
install.packages("RColorBrewer")
install.packages("gdsfmt")
install.packages("SNPRelate")


library(gdsfmt)
library(SNPRelate) 
library(ape)
library(RColorBrewer)


file="snp_flter"
ofile=paste(file,".gds",sep="")
ifile=paste(file,".vcf.gz",sep="")
snpgdsVCF2GDS(ifile, ofile,verbose=TRUE)


# chargement de la table --> fonctionne aussi avec import depuis RStudio
genofile <- snpgdsOpen(ofile)
## A propos des échantillons ##
sample.id <- read.gdsn(index.gdsn(genofile, "sample.id"))


# Différenciation des 26 echantillons
n <- 26
qual.col.pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col.vector = unlist(mapply(brewer.pal, qual.col.pals$maxcolors, rownames(qual_col_pals)))[1:n]


# Déterminer les groupes par permutation:
ibs.hc <- snpgdsHCluster(snpgdsIBS(genofile, num.thread=2, autosome.only=FALSE))

## On peut indiquer des groupes prédéfinis comme dans le papier avec l'option samp.group=
rv <- snpgdsCutTree(ibs.hc ,col.list=col.vector)


# importation de la figure en PDF:
pdf(paste(file,"_Arbre.pdf",sep=""),height=250)
 plot(rv$dendogram, main="Arbre selon IBS", horiz=T)

  legend("topright", 
         legend=sample.id, 
         col=col.vector, 
         pch=19, 
         ncol=2) # associe le nom de l'échantillon à la couleur du vecteur, on la place en haut à droite
dev.off()

