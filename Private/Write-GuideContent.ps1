Function Write-GuideContent {
    [CmdletBinding()]
    param(
        [object]$GuideEntry
    )
    Write-Host $GuideEntry.TopicName -ForegroundColor Yellow
    $lines = $GuideEntry.Content.Split("`n")
    
    # Break the markdown down into sections of text and code blocks
    $SectionNumber = 1
    $SectionType = 'Text'
    $sections = for ($j = 0; $j -lt $lines.Count; $j++) {
        if ($lines[$j] -match '^~~~PowerShell') {
            $SectionNumber++
            $SectionType = 'StartCodeBlock'
        }
        elseif ($SectionType -eq 'CodeBlock' -and $lines[$j] -match '^~~~' -and $lines[$j] -notmatch '^~~~PowerShell') {
            $SectionType = 'EndCodeBlock'
        }
    
        [PSCustomObject]@{
            Text          = $lines[$j]
            Number        = $j
            Type          = $SectionType
            SectionNumber = $SectionNumber
        }
        if ($SectionType -eq 'StartCodeBlock') {
            $SectionType = 'CodeBlock'
        }
        elseif ($SectionType -eq 'EndCodeBlock') {
            $SectionNumber++
            $SectionType = 'Text'
        }
    }

    # Remove any blank lines from the end
    while ([string]::IsNullOrWhiteSpace($sections[-1].Text)) {
        $sections = $sections | Where-Object { $_.Number -lt $sections[-1].Number }
    }

    # Group the line for each sections together
    $displayGroups = $sections | Group-Object SectionNumber | Select-Object Count, Name, @{l = 'EndLine'; e = { $_.Group[-1].Number } }, 
    @{l = 'Type'; e = { $_.Group[0].Type } }, @{l = 'Displayed'; e = { $false } }, Group

    # Get the console height to calculate the length of content to show
    $Height = [Console]::WindowHeight
    if ($Height -lt 2) {
        $Height = 10
    }
    $i = 0
    $linesDisplayed = 0
    while ($displayGroups | Where-Object { -not $_.Displayed }) {
        $i = ($linesDisplayed + $Height - 1)

        $toDisplay = $displayGroups | Where-Object { $_.EndLine -lt $i -and -not $_.Displayed }
        if (-not $toDisplay) {
            $toDisplay = $displayGroups | Where-Object { -not $_.Displayed } | Select-Object -First 1
        }

        $linesToDisplay = @($toDisplay | ForEach-Object { $_.Group.Text })
        $output = ($linesToDisplay -join ("`n")).Trim()
        try {
            Show-Markdown -InputObject $output -ErrorAction Stop
        }
        catch {
            Write-Host $output
        }
        if($linesToDisplay.Count -lt $Height){
            $breaks = $Height - $linesToDisplay.Count - 1
            Write-Host ("`n" * $breaks)
        }
        Write-Debug "linesDisplayed : $linesDisplayed - i : $i"
        $toDisplay | Foreach-Object { $_.Displayed = $true }
        $linesDisplayed = $toDisplay[-1].EndLine
        if ($displayGroups | Where-Object { -not $_.Displayed }) {
            Write-SleepAndPause -Seconds $linesToDisplay.Count
        }
    }
}