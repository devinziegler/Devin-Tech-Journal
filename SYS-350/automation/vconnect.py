import json
import getpass
import ssl
from pyVim.connect import SmartConnect, vim

with open('vcenter-conf.json', 'r') as file:
    loginData = json.load(file)

login = loginData['vcenter'][0]
passw = getpass.getpass()
s=ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
s.verify_mode=ssl.CERT_NONE
si= SmartConnect(host=login['vcenterhost'], user=login['vcenteradmin'], pwd=passw, sslContext=s)
content = si.RetrieveContent()
aboutInfo=content.about


def getCurrentSession ():
    currentSession = content.sessionManager.currentSession
    print("Domain & Username:", currentSession.userName)
    print("vcenter Server:", login['vcenterhost'])
    print("Source IP:", currentSession.ipAddress)
    print("")

def print_vm_info(virtual_machine):
    summary = virtual_machine.summary
    print("Name       : ", summary.config.name)
    annotation = summary.config.annotation
    if annotation:
        print("Annotation : ", annotation)
    print("State      : ", summary.runtime.powerState)
    if summary.guest is not None:
        ip_address = summary.guest.ipAddress
        if ip_address:
            print("IP         : ", ip_address)
        else:
            print("IP         : None")
    if summary.runtime.question is not None:
        print("Question  : ", summary.runtime.question.text)
    print("")
    

def menu():
    print("[1]Get Session Details")
    print("[2]VM Search")
    print("[0] Exit program.")

menu()
option = int(input("Enter your option: "))

while option != 0:
    if option == 1:
        getCurrentSession()

    elif option == 2:
        vmName = str(input("Enter a VM name or leave blank for all"))
        container = content.rootFolder
        view_type = [vim.VirtualMachine]
        recursive = True

        container_view = content.viewManager.CreateContainerView(container, view_type, recursive)
        vms = container_view.view

        match_found = False
        for vm in vms:
            if vm.name == vmName:
                print_vm_info(vm)
                match_found = True
                break
        if not match_found:
            for vm in vms:
                print_vm_info(vm)

    else:
        print("Invalid Option.")

    menu()
    option = int(input("Enter your option"))
    
    





