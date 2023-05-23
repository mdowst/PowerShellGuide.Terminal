Function Write-SleepAndPause {
    [CmdletBinding()]
    param(
        $Seconds
    )
    $display = $true
    $timer = [system.diagnostics.stopwatch]::StartNew()
    while ( (-not [console]::KeyAvailable) ) {
        if($timer.Elapsed.TotalSeconds -gt $Seconds -and $display){
            Write-Host "Display is paused - press any key to resume"
            $display = $false
        }
        elseif($timer.Elapsed.TotalSeconds -gt 300){
            break
        }
    }
    if([console]::KeyAvailable){
        [System.Console]::ReadKey($true) | Out-Null
    }

}