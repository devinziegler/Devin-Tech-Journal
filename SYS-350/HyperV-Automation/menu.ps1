function Show-Menu {
    param(
        [string]$title = "Main Menu"
    )

    Clear-Host
    Write-Host "==================$title=================="
    Write-Host "1: VM Quick Info"
    Write-Host "2: VM 5 Details"
    Write-Host "3: Restore From Latest Snapshot"
    Write-Host "4: Create a Full Clone of a VM"
    Write-Host "5: Set VM Memory"
    Write-Host
    Write-Host "==================$title=================="

}

function get-data {
    Get-VM | Select-Object Name, State,
        @{Name="IP Address";Expression={(Get-VMNetworkAdapter -VMName $_.Name).IPAddresses}} | Format-Table -AutoSize
    
}
function get-info {
    param (
        [string]$Name
    )
    Get-VM -Name $Name | Select-Object Name, ComputerName, Version, Uptime,
        @{Name="CPU Usage";Expression={(Get-VM -Name $_.Name).CPUUsage}},
        @{Name="Assigned Memory";Expression={(Get-VM -Name $_.Name).MemoryAssigned}}
}
function restore-snapsot {
    param (
        [string]$Name
    )
    $latest_snapshot = Get-VMSnapshot -VMName $Name |
    Sort-Object CreationTime -Descending | Select-Object -First 1
    Restore-VMSnapshot -Name $latest_snapshot.Name -VMName $Name
}
function clone-vm {
    param (
        [string]$Name,
        [string]$CloneVMName
    )
    $ExportFolder = "C:\Exports"
    $CloneFolder = "C:\Clone VM Storage"

    If (Test-Path $CloneFolder) {
        Write-Warning "Clone Folder: $CloneFolder already exists. Aborting Script ..."
        Break
    }
    # Export the Source VM
    Export-VM $Name -Path $ExportFolder

    # Import Exported VM,
    Get-ChildItem -Path $ExportFolder -File -Name
    Import-VM -Path $ExportFolder -Copy -GenerateNewId |
        Rename-VM -NewName $CloneVMName
}
function set-memory {
    param (
        [string]$Name
        
    )
}

function main {
    while($true) {
        Show-Menu
        $choice = Read-Host "Please select an option"
        switch ($choice) {
            '1' {
                Write-Host "Display VM Information"
                get-data

            }
            '2' {
                Write-Host "Display VM Summary ..."
                $vmName = Read-Host "Please Enter a VM Name"
                get-info -Name $vmName
            }
            '3'{
                Write-Host "Restore To Latest Snapshot ..."
                $vmName = Read-Host "Please Enter a VM Name"
                restore-snapsot -Name $vmName
            }
            '4'{
                Write-host "Creating Full Clone ..."
                $vmName = Read-Host "Enter a VM Name"
                $CloneVMName = Read-Host "Enter a Vm Name for the Clone"
                clone-vm -Name $vmName -CloneVMName $CloneVMName
            }
            '5'{
                Write-host "Change Ram Count"
                $vmName = Read-Host "Enter a VM Name"
                set-memory -Name $vmName
            }

            'q' {
                Write-Host "Exiting ..."
                return
            }
            default {
                Write-Host "Invalid option, please try again."
            }

        }
        Write-Host "Press any key to continue ..."
        $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null

    }
}

main