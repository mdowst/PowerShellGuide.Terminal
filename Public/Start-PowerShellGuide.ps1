Function Start-PowerShellGuide {
    <#
    .SYNOPSIS
    Provides a terminal interface for the PowerShell Guide
    
    .DESCRIPTION
    Provides a terminal interface for the PowerShell Guide
    
    .EXAMPLE
    Start-PowerShellGuide
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    [Alias('Start-PSGuide')]
    param()

    begin {
        Clear-Host
        Import-LocalizedData -BaseDirectory $LocalizedDirectory -BindingVariable menuTable -UICulture (Get-Culture)
        $banner = @'

DDDDDD  OOOOOOO N     N ''' TTTTTTT   PPPPPP     A    N     N III  CCCCC  
D     D O     O NN    N '''    T      P     P   A A   NN    N  I  C     C 
D     D O     O N N   N  '     T      P     P  A   A  N N   N  I  C       
D     D O     O N  N  N '      T      PPPPPP  A     A N  N  N  I  C       
D     D O     O N   N N        T      P       AAAAAAA N   N N  I  C       
D     D O     O N    NN        T      P       A     A N    NN  I  C     C 
DDDDDD  OOOOOOO N     N        T      P       A     A N     N III  CCCCC  

'@
        $ColorList = @("Red", "Blue", "Yellow", "White")
        
        $TopLeft = $host.ui.RawUI.CursorPosition
        1..2 | ForEach-Object {
            foreach ($c in $ColorList) {
                Write-Host $banner -ForegroundColor $C -NoNewline
                start-sleep -Milliseconds 200
                $host.ui.rawui.CursorPosition = $TopLeft
            }
        }
        Write-Host $banner

        $selection = '?'
        $options = @(
            [PSCustomObject]@{Char = 'R'; Value = $menuTable.RandomTopic }
            [PSCustomObject]@{Char = 'A'; Value = $menuTable.AllTopics }
            [PSCustomObject]@{Char = 'Q'; Value = $menuTable.Quit }
            [PSCustomObject]@{Char = '?'; Value = $menuTable.Help }
        )
        $optionsMenu = ($options | ForEach-Object {
                "$([char]0x001b)[93m[$($_.Char)]$([char]0x001b)[0m $($_.Value)"
            } ) -join (' ' * 4)
        #$optionsPrompt = "Enter a word to search all topics or enter one of the options"
        [Collections.Generic.List[PSObject]] $ReadTopics = @()
    }

    process {
        while ($selection -ne 'Q') {
            $Prompt = $menuTable.optionsPrompt
            if ($selection -eq 'A') {
                Write-Debug -Message 'A - Write-SelectionMenu'
                $selection = Write-SelectionMenu
            }
            elseif ($selection -eq 'R') {
                Write-Debug -Message 'R - Get-Random'
                $selection = (Get-AllTopics | Get-Random).TopicName
            }
            elseif ($selection -eq 'T' -and $data.Related) {
                Write-Debug -Message 'T - Related'
                Write-Host "$($data.Parent)" -ForegroundColor Yellow
                $i = 1
                $related = @($data.Related) + @($data.Value.TopicName)
                $related | ForEach-Object { 
                    $ForegroundColor = 'White'
                    if ($_ -in $ReadTopics) {
                        $ForegroundColor = 'DarkGray'
                    }
                    Write-Host "  $i - $_" -ForegroundColor $ForegroundColor
                    $i++ 
                }
                $Selection = Read-Host "Select another topic in this category"
                if (-not [string]::IsNullOrEmpty($Selection)) {
                    $d = 0
                    if ([int]::TryParse($Selection, [ref]$d)) {
                        if ($d -lt $i) {
                            $Selection = @($related)[$Selection - 1]
                        }
                    }
                }
            }
            elseif ($selection -notin '?', 'T' -and [regex]::Replace($selection, "[^0-9a-zA-Z\s]", "") -ne 'h' -and -not [string]::IsNullOrEmpty($selection)) {
                Write-Debug -Message "Else - Search : $($selection)"
                $data = Get-SearchResults $selection
                if ($data.Type -eq 'Content') {
                    $ReadTopics.Add($data.Value.TopicName)
                    Write-GuideContent -GuideEntry $data.Value
                    
                    if ($data.Related) {
                        Write-Host "$($optionsMenu)    $([char]0x001b)[93m[T]$([char]0x001b)[0m $($menuTable.optionsPrompt)"
                    }
                    else {
                        Write-Host $($optionsMenu)
                    }
                    $selection = Read-Host -Prompt $Prompt
                }
                elseif ($data.Value -eq 'No topics found') {
                    Write-Host "`n   $($data.Value)`n" -ForegroundColor Red
                    Write-Host $optionsMenu
                    $selection = Read-Host -Prompt $menuTable.optionsPrompt
                }
                else {
                    Write-Debug -Message "Data : $($data.Value | FL | Out-String)"
                    $selection = Write-SelectionMenu $data.Value
                    Write-Debug -Message "Data : $($selection | FL | Out-String)"
                }
            }
            else {
                Write-Debug -Message 'H - Help'
                Write-Host $optionsMenu
                $selection = Read-Host -Prompt $menuTable.optionsPrompt
            }
            if ($DebugPreference -in 'SilentlyContinue', 'Ignore') {
                Write-Host ("`n" * ([Console]::WindowHeight))
            }
            
        }
    }
}
