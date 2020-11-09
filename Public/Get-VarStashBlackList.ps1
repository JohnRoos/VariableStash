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

    # Manually added
    $ManuallyAdded = 'MaximumHistoryCount',
        'PSDefaultParameterValues',
        'psEditor'

    
    # Variables from inital session state
    $RunspaceSessionState = (Get-Runspace).InitialSessionState.Variables.Name

    # Mash them together
    $BlackList = [System.Collections.Generic.HashSet[String]]::new()
    foreach ($item in $static) {
        $null = $BlackList.Add($item)
    }
    foreach ($item in $ManuallyAdded) {
        $null = $BlackList.Add($item)
    }
    foreach ($item in $RunspaceSessionState) {
        $null = $BlackList.Add($item)
    }

    # Done
    Write-Output $BlackList
}