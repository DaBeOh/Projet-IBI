# lenovo@mffellah

#! /usr/bin/env python3
# coding: utf-8

import subprocess as sp
# import subprocess             #test 1
import ftplib
import hashlib      # POUR MD5sum des fichiers


def main():
    pass

main()


# import wget

url = "https://www.ebi.ac.uk/ena/browser/view/PRJEB24932"         # test 1     --act
# wget.download(url)

# Test 1
# subprocess.call (["wget", "r", "-np", "-nd", "-A.tsv.gz", url])       #si fichier json -> json.gz    

#Test 2
sp.call(['wget', 'ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR229/006/ERR2299966/ERR2299966_1.fastq.gz'])       


##############################################  MD5 

# user = input("Enter ")        # si on entre l'url
user = url                      #sinon renvoie md5 fichiers déjà telecharger.
h = hashlib.md5(user.encode())
h2 = h.hexdigest()
with open("encrypted.txt","w") as e:
    print(h2,file=e)


with open("encrypted.txt","r") as e:
    p = e.readline().strip()
    print(p)