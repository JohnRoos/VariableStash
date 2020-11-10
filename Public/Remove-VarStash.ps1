<#
.SYNOPSIS
   Removes a variable stash.
.DESCRIPTION
   Permanently removes a variable stash.
.EXAMPLE
   Remove-VarStash -Name MyStash

   Removes the stash named MyStash.
.EXAMPLE
   Remove-VarStash -Index 2

   Removes the stash with index position 2 (lates stash has index 0).
.EXAMPLE
   Remove-VarStash -Index 2 -WhatIf

   Shows what would have happened if this command would run without the -WhatIf parameter.
#>
function Remove-VarStash {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [parameter(Mandatory,
                   ParameterSetName = 'Name',
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [parameter(Mandatory,
                   ParameterSetName = 'Index',
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Index,

        [parameter(ParameterSetName = 'Name')]
        [parameter(ParameterSetName = 'Index')]
        [switch]$WhatIf
    )
    
    Process {
        
        switch ($PSCmdlet.ParameterSetName) {
            'Name' { 
                $Stash = Get-VarStash -Name $Name -ErrorAction Stop
            }
            'Index' { 
                $Stash = Get-VarStash -Index $Index -ErrorAction Stop
            }
        }

        try {
            Remove-Item -Path "$env:APPDATA\VariableStash\VariableStash_$($Stash.Name).xml" -WhatIf:$WhatIf
        }
        catch {
            Throw "Unable to remove stash. Error: $_"
        }

    }
}