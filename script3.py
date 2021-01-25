# lenovo@mffellah

#! /usr/bin/env python3
# coding: utf-8

import subprocess as sp
# import subprocess             #test 1
import ftplib


def main():
    pass

main()

# path = "pub/Health_Statistics/NCHS/nhanes/2001-2002/"
# path = "debian"
# filename = "L28POC_B.xpt"

# ftp = ftplib.FTP("ftp.us.debian.org")       #connect au port par deffaut.
# ftp.login("anonymous", "anonymous@")
# ftp.cwd(path)
# ftp.retrbinary("RETR README " + filename ,open(filename, "wb").write)
# ftp.quit()



# import wget

url = "https://www.ebi.ac.uk/ena/browser/view/PRJEB24932"         # test 1
# wget.download(url)


########################################################################
#Tests...

# Test 1
# subprocess.call (["wget", "r", "-np", "-nd", "-A.tsv.gz", url])       #si fichier json -> json.gz    

#Test 2
sp.call(['wget', 'ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR229/006/ERR2299966/ERR2299966_1.fastq.gz'])