function Show-VarStash {
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        [parameter(ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [parameter(ParameterSetName = 'Index')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Index
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'Name' { 
            $Stash = Get-VarStash -Name $Name
            if ($Stash -is [array]) {
                Throw 'Found more than one VarStash. Can only show one stash.'
            }
        }
        'Index' { 
            $Stash = Get-VarStash -Index $Index
        }
        Default {
            $Stash = Get-VarStash -Index 0
        }
    }

    $ImportedVariables = Import-Clixml -Path "$env:APPDATA\VariableStash\VariableStash_$($Stash.Name).xml"

    Write-Output -InputObject $ImportedVariables
}