Function Get-SearchResults{

    [CmdletBinding()]
    param(
        $SearchTerm
    )
    $AllTopics = Get-AllTopics
    $ReturnData = [pscustomobject]@{
        Value   = $null
        Type    = 'Search'
        Related = $null
        Parent  = $null
    }
    $foundTopics = $AllTopics | Where-Object { $_.TopicName -match "^$($SearchTerm)$" }

    if ($foundTopics.Count -eq 1) {
        $ReturnData.Value = $foundTopics
        $ReturnData.Parent = (Split-Path $foundTopics.RelativePath).Split([IO.Path]::DirectorySeparatorChar)[-1]
        $ReturnData.Type = 'Content'
        $ReturnData.Related = @($AllTopics | Where-Object { (Split-Path $_.RelativePath) -eq (Split-Path $foundTopics.RelativePath) -and 
                $_.TopicName -ne $foundTopics.TopicName }).TopicName
    }
    else {
        $foundTopics = $AllTopics | Select-Object @{l = 'SearchRanking'; e = { Get-SearchRanking $_ $SearchTerm } }, * | 
        Sort-Object SearchRanking -Descending | Where-Object { $_.SearchRanking -gt 0 }

        if ($foundTopics) {
            $ReturnData.Value = Get-AllTopicsMenu -Topics $foundTopics
        }
        else {
            $ReturnData.Value = "No topics found"
        }
    }
    $ReturnData

}
