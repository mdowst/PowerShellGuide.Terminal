Function Get-AllTopicsMenu {
    [CmdletBinding()]
    param(
        $Topics = $null,
        $Parent = ''
    )
    Function GetPath {
        param(
            $RelativePath,
            $Parent
        )
        $path = (Split-Path $RelativePath) -Replace ("^$([regex]::Escape($Parent))", '')
        if ($path.IndexOf('\') -eq 0) {
            $path = $path.Substring(1)
        }
        $path.Split('\')[0]
    }

    if(-not $Topics){
        $Topics = Get-AllTopics
    }

    $Spacer = ' ' * (($Parent.Split('\').Count - 1) * 2)
    $TopicGroups = $Topics | Group-Object { (GetPath $_.RelativePath $Parent) } | Sort-Object Name
    $TopicGroups | Where-Object { [string]::IsNullOrEmpty($_.Name) } | ForEach-Object {
        [pscustomobject]@{Spacer = $Spacer; Title = $($Parent.Split('\')[-1]); Type = 'Category'; SearchRanking = $_.SearchRanking }
        $_.Group | ForEach-Object {
            [pscustomobject]@{Spacer = $Spacer; Title = $_.TopicName; Type = 'Topic'; SearchRanking = $_.SearchRanking }
        }
    }
    $TopicGroups | Where-Object { -not [string]::IsNullOrEmpty($_.Name) } | ForEach-Object {
        $NewParent = $_.Name
        if (-not [string]::IsNullOrEmpty($Parent)) {
            $NewParent = $Parent + '\' + $_.Name
        }
        Get-AllTopicsMenu -Topics $_.Group -Parent $NewParent
    }
}