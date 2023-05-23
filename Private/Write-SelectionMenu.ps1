Function Write-SelectionMenu{

    [CmdletBinding()]
    param(
        $AllTopicsMenu = $null
    )

    if(-not $AllTopicsMenu){
        $AllTopicsMenu = Get-AllTopicsMenu
    }

    if($AllTopicsMenu | Where-Object { $_.SearchRanking -gt 1 }){
        $topRank = $AllTopicsMenu | Sort-Object -Property SearchRanking | Select-Object -Last 1 -ExpandProperty SearchRanking
    }
    else{
        $topRank = -1
    }
    $i = 1
    $menuItems = foreach ($item in $AllTopicsMenu) {
        if ($item.Type -eq 'Category') {
            Write-Host "$($item.Spacer)$($item.Title)" -ForegroundColor Yellow
        }
        else {
            $ForegroundColor = 'White'
            if($item.SearchRanking -eq $topRank -and $topRank -gt 0){
                $ForegroundColor = 'Green'
            }
            elseif($item.SearchRanking -ge ($topRank * .9) -and $topRank -gt 0){
                $ForegroundColor = 'Cyan'
            }
            Write-Host "$($item.Spacer) $($i) $($item.Title)$sr" -ForegroundColor $ForegroundColor
            $item
            $i++
        }
    }
    Write-Debug "$($menuItems | FL | Out-String)"
    $Selection = Read-Host -Prompt "Enter a number to select a topic"
    Write-Debug "Write-SelectionMenu - Selection $Selection"
    if (-not [string]::IsNullOrEmpty($Selection)) {
        $d = 0
        if ([int]::TryParse($Selection, [ref]$d)) {
            if ($d -lt $i) {
                $Selection = $menuItems[$Selection - 1].Title
            }
        }
    }
    Write-Debug "Write-SelectionMenu - $($Selection | Out-String)"
    $Selection
}
