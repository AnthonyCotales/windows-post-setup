<#
.NOTES
    Script: Windows-Post-Setup.ps1
    Author: Anthony Cotales
    Date:   26/12/2025
    Version: 1.0
#>

function Backup-Registry {
    <#
    .SYNOPSIS
        Backup the entire Windows registry (all main hives).
    #>
    [CmdletBinding()]
    param(
        [string]$Path = "C:\RegistryBackup"
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $backupPath = Join-Path $Path $timestamp
    try {
        Write-Verbose "Creating registry backup directory '$backupPath'"
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

        $hives = @{
            HKLM = 'HKLM.reg'
            HKCU = 'HKCU.reg'
            HKCR = 'HKCR.reg'
            HKU  = 'HKU.reg'
            HKCC = 'HKCC.reg'
        }

        foreach ($hive in $hives.Keys) {
            $file = Join-Path $backupPath $hives[$hive]
            Write-Verbose "Exporting $hive to $file"
            reg export $hive $file /y | Out-Null

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to export registry hive $hive"
            }
        }
        Write-Verbose "Registry backup successfull '$backupPath'"
        return $backupPath
    }
    catch {
        Write-Error "Backup-Registry failed: $_"
        throw
    }
}
