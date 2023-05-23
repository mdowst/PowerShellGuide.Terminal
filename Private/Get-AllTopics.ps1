Function Get-AllTopics{
    (Get-PowerShellGuide).AllTopics | Where-Object { $_.RelativePath -match '\\' }
}