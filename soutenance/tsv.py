import hashlib

url = "https://github.com/DaBeOh/Projet-IBI/blob/main/filereport_read_run_PRJEB24932.tsv"

# user = input("Enter ")
user = url 
# = "https://www.ebi.ac.uk/ena/browser/view/PRJEB24932"

h = hashlib.md5(user.encode())
h2 = h.hexdigest()
with open("encrypted.txt","w") as e:
    print(h2,file=e)


with open("encrypted.txt","r") as e:
    p = e.readline().strip()
    print(p)