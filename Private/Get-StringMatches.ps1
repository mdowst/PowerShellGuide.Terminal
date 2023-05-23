Function Get-StringMatches{

    [CmdletBinding()]
    param(
        [string]$String,
        [string]$SearchTerm
    )

    ([Regex]::Matches($String.ToLower(), $SearchTerm.ToLower()) | Measure-Object).Count

}
