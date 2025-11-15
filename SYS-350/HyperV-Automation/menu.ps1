function Show-Menu {
    param(
        [string]$title = "Main Menu"
    )

    Clear-Host
    Write-Host "==================$title=================="
    Write-Host "1: Option 1"
    Write-Host "2: Option 2"
    Write-Host "3: Option 3"
    Write-Host "4: Option 4"
    Write-Host "5: Option 5"
    Write-Host
    Write-Host "==================$title=================="

}

function main {
    while($true) {
        Show-Menu
        $input = Read-Host "Please select an option"
        switch ($input) {
            '1' {
                Write-Host "option 1"
            }
            '2' {
                Write-Host "option 2"
            }
            '3' {
                Write-Host "option 3"
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