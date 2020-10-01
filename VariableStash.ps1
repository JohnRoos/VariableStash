
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
    param ()

    # Create blacklist
    $Blacklist = Get-VarStashBlackList
    # Get variables from parent scope not in blacklist
    $AllVariables = (Get-Variable -Scope 1).Where({$_.Name -notin $Blacklist})
    # Remove variables which are read only, constants or private
    # https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.scopeditemoptions?view=powershellsdk-7.0.0
    $WritableVariables = $AllVariables.Where({$_.Options -notin 1, 2, 9, 10})
    # Write to disk
    Export-Clixml -InputObject $WritableVariables -Path '.\VariableStash.xml' -Force
}

function Pop-VarStash {
    [CmdletBinding()]
    param ()

    # Import the variables
    $ImportedVariables = Import-Clixml -Path '.\VariableStash.xml'
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