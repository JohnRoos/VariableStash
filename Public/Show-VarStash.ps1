<#
.SYNOPSIS
   Shows the content of a variable stash.
.DESCRIPTION
   Shows the content of a variable stash. Returns objects of type PSVariable.
.EXAMPLE
   Show-VarStash

   Shows the content of the latest stash (from top of stash, index 0)
.EXAMPLE
   Show-VarStash -Name MyStash

   Shows the content of the stash named MyStash.
.EXAMPLE
   Show-VarStash -Index 2

   Shows the content of the stash with index position 2 (lates stash has index 0).
#>
function Show-VarStash {
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        [parameter(ParameterSetName = 'Name',
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [parameter(ParameterSetName = 'Index',
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Index
    )
    
    Process {

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
}