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