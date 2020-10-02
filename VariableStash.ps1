
function Get-VarStashBlackList {
    [CmdletBinding()]
    param()

    # Static list: https://ss64.com/ps/syntax-automatic-variables.html
    $static = '$',
    '?',
    '^',
    '_',
    'Allnodes',
    'Args',
    'ConsoleFileName',
    'Error',
    'Event',
    'EventArgs',
    'EventSubscriber',
    'ExecutionContext',
    'False',
    'ForEach',
    'Home',
    'Host',
    'Input',
    'LastExitCode',
    'Matches',
    'MyInvocation',
    'NestedPromptLevel',
    'NULL',
    'OFS',
    'PID',
    'Profile',
    'PSBoundParameters',
    'PsCmdlet',
    'PSCommandPath',
    'PsCulture',
    'PSDebugContext',
    'PsHome',
    'PSitem',
    'PSScriptRoot',
    'PSSenderInfo',
    'PsUICulture',
    'PsVersionTable',
    'Pwd',
    'Sender',
    'ShellID',
    'SourceArgs',
    'SourceEventArgs',
    'StackTrace',
    'This',
    'True'
    
    # Variables from inital session state
    $RunspaceSessionState = (Get-Runspace).InitialSessionState.Variables.Name

    # Mash them together
    $BlackList = [System.Collections.Generic.HashSet[String]]::new()
    foreach ($item in $static) {
        $null = $BlackList.Add($item)
    }
    foreach ($item in $RunspaceSessionState) {
        $null = $BlackList.Add($item)
    }

    # Done
    Write-Output $BlackList
}

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

function Pop-VarStash {
    [CmdletBinding()]
    param ()

    # Check if we have a file to import
    if (Test-Path -Path "$env:APPDATA\VariableStash\VariableStash.xml" -PathType 'Leaf') {  
        # Import the variables
        $ImportedVariables = Import-Clixml -Path "$env:APPDATA\VariableStash\VariableStash.xml"
        # Set each variable in parent scope
        foreach ($var in $ImportedVariables) {
            if (Get-Variable -Name $var.Name -Scope 1 -ErrorAction SilentlyContinue) {
                Write-Verbose "$($var.Name) exist"
            }
            else {
                Write-Verbose "$($var.Name) missing"
            }
            Set-Variable -Name $var.Name -Scope 1 -Value $var.Value
        }
    }
    else {
        Write-Error "Stash not found"
    }
}

function Get-VarStash {
    param()

    $stashes = Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_*.xml"  | Sort-Object -Property lastwritetime -Descending
    foreach ($stash in $stashes) {
        $props = @{
            Name = $stash.Name.Replace('VariableStash_','').Replace('.xml','')
            Date = $stash.LastWriteTime
        }
        New-Object -TypeName psobject -Property $props
    }

}
