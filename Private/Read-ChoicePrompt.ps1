Function Read-ChoicePrompt{

    [CmdletBinding()]
    param(
        [array]$array,
        [string]$Prompt
    )
    $i = 1
    $menu = ($array | ForEach-Object { "$i - $_"; $i++ }) -join ([Environment]::NewLine)
    $Selection = Read-Host "`n$($menu)`n$($Prompt)"
    if (-not [string]::IsNullOrEmpty($Selection)) {
        $d = 0
        if ([int]::TryParse($Selection, [ref]$d)) {
            if ($d -lt $i) {
                $Selection = @($array)[$Selection - 1]
            }
        }
    }
    $Selection

}
