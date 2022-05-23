Install-Module -Name SqlServer

$SchemaScriptPath = '$(System.DefaultWorkingDirectory)/_build/sql_scripts/schema'
$ScriptPath = '$(System.DefaultWorkingDirectory)/_build/sql_scripts/scripts'

$ConnectionString = "$(DefaultConnectionString)"

$global:failedCount = 0

function Execute-SqlScript {
    param ($scripts)
    foreach ($script in $scripts) {   
        Write-Host "Running Script : " $script.Name  " " -NoNewline
        try {
            Invoke-SqlCmd -ConnectionString $ConnectionString -inputfile $script.fullname -erroraction 'stop' -querytimeout 6000
            Write-Host " Succees " -BackgroundColor green -ForegroundColor white
        }
        catch {
            Write-Host " Failed " -BackgroundColor red -ForegroundColor white
            $global:failedCount = $global:failedCount + 1
            Write-Warning $Error[0]
        }
    }
}

$schemaScripts = Get-ChildItem $SchemaScriptPath -filter *.sql -Recurse
$fnFuncScripts = Get-ChildItem $ScriptPath -filter *fn_*.sql -Recurse
$procScripts = Get-ChildItem $ScriptPath -filter *sp_*.sql -Recurse
$otherScripts = Get-ChildItem $ScriptPath -filter *.sql -Recurse

Execute-SqlScript $schemaScripts
Execute-SqlScript $fnFuncScripts
Execute-SqlScript $procScripts
Execute-SqlScript $otherScripts

Write-Host $failedCount
if ($global:failedCount -gt 0) {
    throw "One or more scripts failed to execute" 
}