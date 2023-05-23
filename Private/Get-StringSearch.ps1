Function Get-StringSearch{

    [CmdletBinding()]
    param(
        [string]$String,
        [string]$SearchTerm
    )

    $match = [Regex]::Match($String.ToLower(), $SearchTerm.ToLower())
    ($match.Length / $String.Length) * 100

}
