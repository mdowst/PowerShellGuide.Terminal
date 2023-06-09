# Get all the ps1 files in the Public folder
$Functions = Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' -Recurse

# Loop through each ps1 file
Foreach ($import in $Functions) {
    Try {
        Write-Verbose "dot-sourcing file '$($import.fullname)'"
        # Execute each ps1 file to load the function into memory
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.name)"
    }
}

$script:LocalizedDirectory = Join-Path -Path $PSScriptRoot -ChildPath 'Localization'
