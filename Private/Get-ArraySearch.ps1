Function Get-ArraySearch{

    [CmdletBinding()]
    param(
        [array]$Array,
        [string]$SearchTerm
    )

    $matches = $Array | ForEach-Object {
        $match = [Regex]::Match($_.ToLower(), $SearchTerm.ToLower())
        ($match.Length / $_.Length) * 100
    }
    $matches | Sort-Object | Select-Object -Last 1

}
