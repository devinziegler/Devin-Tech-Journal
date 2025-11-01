import json
import getpass
import ssl
from pyVim.connect import SmartConnect

with open('vcenter-conf.json', 'r') as file:
    loginData = json.load(file)

login = loginData['vcenter'][0]
passw = getpass.getpass()
s=ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
s.verify_mode=ssl.CERT_NONE
si= SmartConnect(host=login['vcenterhost'], user=login['vcenteradmin'], pwd=passw, sslContext=s)
aboutInfo=si.content.about

def getCurrentSession ():
    content = si.RetrieveContent()
    currentSession = content.sessionManager.currentSession
    print("Domain & Username:", currentSession.userName)
    print("vcenter Server:", login['vcenterhost'])
    print("Source IP:", currentSession.ipAddress)

#def getVM(str):


def menu():
    print("[1]Get Session Details")
    print("[2]VM Search")
    print("[0] Exit program.")

menu()
option = int(input("Enter your option: "))

while option != 0:
    if option == 1:
        getCurrentSession()
        print()
    elif option == 2:
        vmName = str(input("Enter a VM Name or leave blank to return all VMs: "))
        #getVM(vmName)
        getallvms()

    else:
        print("Invalid Option.")

    menu()
    option = int(input("Enter your option"))
    





