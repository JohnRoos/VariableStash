
function Push-VarStash {
    [CmdletBinding()]
    param (
        [string]$Name
    )

    # Create blacklist
    $Blacklist = Get-VarStashBlackList
    # Get variables from parent scope not in blacklist
    $AllVariables = (Get-Variable -Scope 1).Where({$_.Name -notin $Blacklist})
    # Remove variables which are read only, constants or private
    # https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.scopeditemoptions?view=powershellsdk-7.0.0
    $WritableVariables = $AllVariables.Where({$_.Options -notin 1, 2, 9, 10})
    # Prepare folder if needed
    if (-not (Test-Path -Path "$env:APPDATA\VariableStash" -PathType 'Container')) {
        $null = New-Item -Path $env:APPDATA-Name 'VariableStash' -ItemType 'Container'
    }
    # Write to disk
    if ([string]::IsNullOrEmpty($Name)) {
        $FileName = "VariableStash_$((New-Guid).Guid).xml"
    }
    else {
        $FileName = "VariableStash_$Name.xml"
    }
    Export-Clixml -InputObject $WritableVariables -Path "$env:APPDATA\VariableStash\$FileName" -Force -Verbose
}