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
    Write-Host "Q: Quit"
    Write-Host
    Write-Host "==================$title=================="

}

function get-data {
    try {
        Write-Host "`nRetrieving VM Information...`n" -ForegroundColor Green
        
        $vms = Get-VM | Select-Object Name, State,
            @{Name="IP Address";Expression={
                $ips = (Get-VMNetworkAdapter -VMName $_.Name).IPAddresses
                if ($ips) {
                    $ips -join ", "
                } else {
                    "N/A"
                }
            }}
        
        if ($vms) {
            $vms | Format-Table -AutoSize | Out-Host
        } else {
            Write-Host "No VMs found." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error retrieving VM data: $_" -ForegroundColor Red
        Write-Host "Make sure you're running as Administrator and Hyper-V is installed." -ForegroundColor Yellow
    }
}

function get-info {
    param (
        [string]$Name
    )
    try {
        Write-Host "`nRetrieving detailed info for VM: $Name`n" -ForegroundColor Green
        
        $vm = Get-VM -Name $Name -ErrorAction Stop
        
        $vmInfo = [PSCustomObject]@{
            Name = $vm.Name
            ComputerName = $vm.ComputerName
            State = $vm.State
            Version = $vm.Version
            Uptime = $vm.Uptime
            'CPU Usage' = "$($vm.CPUUsage)%"
            'Assigned Memory (MB)' = [math]::Round($vm.MemoryAssigned / 1MB, 2)
            'Startup Memory (MB)' = [math]::Round($vm.MemoryStartup / 1MB, 2)
            ProcessorCount = $vm.ProcessorCount
        }
        
        $vmInfo | Format-List | Out-Host
    }
    catch {
        Write-Host "Error retrieving VM info: $_" -ForegroundColor Red
        Write-Host "Make sure the VM name is correct and you have permissions." -ForegroundColor Yellow
    }
}

function restore-snapshot {
    param (
        [string]$Name
    )
    try {
        Write-Host "`nSearching for snapshots for VM: $Name" -ForegroundColor Green
        
        $latest_snapshot = Get-VMSnapshot -VMName $Name -ErrorAction Stop |
        Sort-Object CreationTime -Descending | Select-Object -First 1
        
        if ($latest_snapshot) {
            Write-Host "Found snapshot: $($latest_snapshot.Name) (Created: $($latest_snapshot.CreationTime))" -ForegroundColor Cyan
            $confirm = Read-Host "Do you want to restore this snapshot? (Y/N)"
            
            if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                Restore-VMSnapshot -Name $latest_snapshot.Name -VMName $Name -Confirm:$false
                Write-Host "Successfully restored to snapshot: $($latest_snapshot.Name)" -ForegroundColor Green
            } else {
                Write-Host "Restore cancelled." -ForegroundColor Yellow
            }
        } else {
            Write-Host "No snapshots found for VM: $Name" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error restoring snapshot: $_" -ForegroundColor Red
    }
}

function clone-vm {
    <#
    .SYNOPSIS
        Creates a new VM clone using differencing disks
    .DESCRIPTION
        Prompts for source VM name, shuts it down if running, prompts for clone name,
        and creates a new VM using differencing disks for efficient cloning
    #>
    
    try {
        Write-Host "`n=== VM Cloning Wizard ===" -ForegroundColor Green
        
        # Step 1: Get source VM name
        Write-Host "`nAvailable VMs:" -ForegroundColor Cyan
        Get-VM | Format-Table Name, State, Path -AutoSize | Out-Host
        
        $sourceName = Read-Host "`nEnter the source VM name to clone"
        
        # Step 2: Verify source VM exists
        $sourceVM = Get-VM -Name $sourceName -ErrorAction Stop
        Write-Host "`nSource VM found: $sourceName" -ForegroundColor Green
        Write-Host "  State: $($sourceVM.State)" -ForegroundColor Cyan
        Write-Host "  Memory: $([math]::Round($sourceVM.MemoryStartup / 1GB, 2)) GB" -ForegroundColor Cyan
        Write-Host "  Processors: $($sourceVM.ProcessorCount)" -ForegroundColor Cyan
        
        # Step 3: Shutdown VM if running
        if ($sourceVM.State -eq 'Running') {
            Write-Host "`nWarning: Source VM is currently running." -ForegroundColor Yellow
            Write-Host "The VM must be shut down to create a safe clone." -ForegroundColor Yellow
            $shutdownConfirm = Read-Host "Shut down the VM now? (Y/N)"
            
            if ($shutdownConfirm -eq 'Y' -or $shutdownConfirm -eq 'y') {
                Write-Host "Shutting down VM..." -ForegroundColor Cyan
                Stop-VM -Name $sourceName -Force
                
                # Wait for VM to fully stop
                $timeout = 30
                $elapsed = 0
                while ((Get-VM -Name $sourceName).State -ne 'Off' -and $elapsed -lt $timeout) {
                    Start-Sleep -Seconds 1
                    $elapsed++
                    Write-Host "." -NoNewline
                }
                Write-Host ""
                
                if ((Get-VM -Name $sourceName).State -eq 'Off') {
                    Write-Host "VM successfully shut down." -ForegroundColor Green
                } else {
                    Write-Host "Warning: VM did not shut down within timeout." -ForegroundColor Yellow
                }
            } else {
                Write-Host "Clone cancelled. VM must be shut down first." -ForegroundColor Yellow
                return
            }
        }
        
        # Step 4: Get clone name
        $cloneName = Read-Host "`nEnter the name for the new cloned VM"
        
        # Check if clone name already exists
        $existingVM = Get-VM -Name $cloneName -ErrorAction SilentlyContinue
        if ($existingVM) {
            Write-Host "Error: A VM with the name '$cloneName' already exists!" -ForegroundColor Red
            return
        }
        
        Write-Host "`n=== Starting Clone Process ===" -ForegroundColor Green
        
        # Step 5: Get source VM's VHD
        $sourceVHDs = Get-VMHardDiskDrive -VMName $sourceName
        if (-not $sourceVHDs -or $sourceVHDs.Count -eq 0) {
            throw "No virtual hard disks found for source VM"
        }
        
        $sourceVHD = $sourceVHDs[0].Path
        Write-Host "Source VHD: $sourceVHD" -ForegroundColor Cyan
        
        # Step 6: Set up paths for clone
        $vhdFolder = Split-Path $sourceVHD -Parent
        $cloneVHDPath = Join-Path $vhdFolder "$cloneName.vhdx"
        
        # Check if VHD already exists
        if (Test-Path $cloneVHDPath) {
            Write-Host "Error: VHD file already exists at: $cloneVHDPath" -ForegroundColor Red
            return
        }
        
        # Step 7: Make parent VHD read-only for safety
        Write-Host "Setting source VHD to read-only..." -ForegroundColor Cyan
        $parentVHD = Get-Item $sourceVHD
        if (-not ($parentVHD.Attributes -band [System.IO.FileAttributes]::ReadOnly)) {
            $parentVHD.Attributes = $parentVHD.Attributes -bor [System.IO.FileAttributes]::ReadOnly
            Write-Host "Source VHD set to read-only for safety." -ForegroundColor Green
        }
        
        # Step 8: Create differencing disk
        Write-Host "Creating differencing disk..." -ForegroundColor Cyan
        New-VHD -Path $cloneVHDPath -ParentPath $sourceVHD -Differencing | Out-Null
        Write-Host "Differencing disk created: $cloneVHDPath" -ForegroundColor Green
        
        # Step 9: Get source VM settings
        $sourceSwitch = (Get-VMNetworkAdapter -VMName $sourceName)[0].SwitchName
        $sourceGeneration = $sourceVM.Generation
        $vmPath = Split-Path (Split-Path $sourceVM.Path -Parent) -Parent
        
        # Step 10: Create new VM with same settings as source
        Write-Host "Creating new VM with source settings..." -ForegroundColor Cyan
        
        $newVM = New-VM -Name $cloneName `
            -MemoryStartupBytes $sourceVM.MemoryStartup `
            -BootDevice VHD `
            -VHDPath $cloneVHDPath `
            -Path $vmPath `
            -Generation $sourceGeneration
        
        # Set processor count
        Set-VMProcessor -VMName $cloneName -Count $sourceVM.ProcessorCount
        
        # Connect to network switch if source had one
        if ($sourceSwitch) {
            Get-VMNetworkAdapter -VMName $cloneName | Connect-VMNetworkAdapter -SwitchName $sourceSwitch
            Write-Host "Connected to network switch: $sourceSwitch" -ForegroundColor Cyan
        }
        
        # Copy firmware settings if Generation 2
        if ($sourceGeneration -eq 2) {
            $sourceFirmware = Get-VMFirmware -VMName $sourceName
            Set-VMFirmware -VMName $cloneName -EnableSecureBoot $sourceFirmware.SecureBoot
            Write-Host "Firmware settings copied." -ForegroundColor Cyan
        }
        
        # Step 11: Success!
        Write-Host "`n=== Clone Created Successfully! ===" -ForegroundColor Green
        Write-Host "Clone Name: $cloneName" -ForegroundColor Green
        Write-Host "VHD Location: $cloneVHDPath" -ForegroundColor Cyan
        Write-Host "Type: Differencing Disk (space-efficient)" -ForegroundColor Cyan
        
        # Display the new VM details
        Write-Host "`nNew VM Details:" -ForegroundColor Cyan
        Get-VM -Name $cloneName | Format-Table Name, State, MemoryStartup, ProcessorCount, Generation -AutoSize | Out-Host
        
        # Ask if user wants to start the clone
        $startConfirm = Read-Host "`nWould you like to start the cloned VM now? (Y/N)"
        if ($startConfirm -eq 'Y' -or $startConfirm -eq 'y') {
            Start-VM -Name $cloneName
            Write-Host "VM '$cloneName' has been started." -ForegroundColor Green
        }
        
    }
    catch {
        Write-Host "`nError during cloning process: $_" -ForegroundColor Red
        Write-Host "`nTroubleshooting tips:" -ForegroundColor Yellow
        Write-Host "  - Ensure the source VM exists and is accessible" -ForegroundColor Yellow
        Write-Host "  - Verify you have enough disk space" -ForegroundColor Yellow
        Write-Host "  - Make sure you're running as Administrator" -ForegroundColor Yellow
        Write-Host "  - Check that the VM name doesn't already exist" -ForegroundColor Yellow
        Write-Host "  - Ensure the source VM is shut down" -ForegroundColor Yellow
    }
}

function set-memory {
    param (
        [string]$Name
    )
    try {
        # Get current memory info
        $vm = Get-VM -Name $Name -ErrorAction Stop
        $currentMemoryGB = [math]::Round($vm.MemoryStartup / 1GB, 2)
        
        Write-Host "`nCurrent startup memory for $Name : $currentMemoryGB GB" -ForegroundColor Cyan
        
        $memoryGB = Read-Host "Enter new memory size in GB"
        $memoryBytes = [int64]$memoryGB * 1GB
        
        # Check if VM is running
        if ($vm.State -eq 'Running') {
            Write-Host "Warning: VM is currently running. It must be stopped to change startup memory." -ForegroundColor Yellow
            $confirm = Read-Host "Do you want to stop the VM and change memory? (Y/N)"
            
            if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                Stop-VM -Name $Name -Force
                Write-Host "VM stopped." -ForegroundColor Cyan
            } else {
                Write-Host "Memory change cancelled." -ForegroundColor Yellow
                return
            }
        }
        
        Set-VMMemory -VMName $Name -StartupBytes $memoryBytes
        Write-Host "`nMemory successfully set to $memoryGB GB for VM: $Name" -ForegroundColor Green
        
        # Show updated info
        $updatedVM = Get-VM -Name $Name
        Write-Host "New startup memory: $([math]::Round($updatedVM.MemoryStartup / 1GB, 2)) GB" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Error setting memory: $_" -ForegroundColor Red
    }
}

function Pause-Script {
    Write-Host "`nPress Enter to continue..." -ForegroundColor Yellow
    $null = Read-Host
}

function main {
    # Check if running as Administrator
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "`n========================================" -ForegroundColor Red
        Write-Host "WARNING: NOT RUNNING AS ADMINISTRATOR" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "This script requires Administrator privileges." -ForegroundColor Yellow
        Write-Host "Please right-click and select 'Run as Administrator'" -ForegroundColor Yellow
        Pause-Script
        return
    }

    while($true) {
        Show-Menu
        $choice = Read-Host "Please select an option"
        
        switch ($choice) {
            '1' {
                Write-Host "`n=== Display VM Information ===" -ForegroundColor Cyan
                get-data
            }
            '2' {
                Write-Host "`n=== Display VM Details ===" -ForegroundColor Cyan
                $vmName = Read-Host "Please Enter a VM Name"
                get-info -Name $vmName
            }
            '3' {
                Write-Host "`n=== Restore To Latest Snapshot ===" -ForegroundColor Cyan
                $vmName = Read-Host "Please Enter a VM Name"
                restore-snapshot -Name $vmName
            }
            '4' {
                Write-Host "`n=== Creating Full Clone ===" -ForegroundColor Cyan
                clone-vm
            }
            '5' {
                Write-Host "`n=== Change VM Memory ===" -ForegroundColor Cyan
                $vmName = Read-Host "Enter a VM Name"
                set-memory -Name $vmName
            }
            'q' {
                Write-Host "`nExiting ..." -ForegroundColor Green
                return
            }
            default {
                Write-Host "`nInvalid option, please try again." -ForegroundColor Red
            }
        }
        
        Pause-Script
    }
}

# Run the main function with error handling
try {
    main
}
catch {
    Write-Host "`nFatal error occurred: $_" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
}
finally {
    # Ensure the window doesn't close immediately
    Write-Host "`nScript completed. Press Enter to exit..."
    $null = Read-Host
}
