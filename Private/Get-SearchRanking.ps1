Function Get-SearchRanking{

    [CmdletBinding()]
    param(
        [object]$Topic,
        [string]$SearchTerm
    )
    $alias = Get-ArraySearch $Topic.Aliases $SearchTerm
    $categories = Get-ArraySearch $Topic.RelativePath.Split('\') $SearchTerm
    $topicName = Get-StringSearch $Topic.TopicName $SearchTerm
    $content = Get-StringMatches $topic.Content $SearchTerm
    $alias + $categories + $topicName + $content

}
