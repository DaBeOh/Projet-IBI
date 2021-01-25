import ftplib

# path = "pub/Health_Statistics/NCHS/nhanes/2001-2002/"
path = "debian"
filename = "L28POC_B.xpt"

ftp = ftplib.FTP("ftp.us.debian.org")       #connect au port par deffaut.
ftp.login("anonymous", "anonymous@")
ftp.cwd(path)
ftp.retrbinary("RETR README " + filename ,open(filename, "wb").write)
ftp.quit()