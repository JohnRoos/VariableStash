function Remove-VarStash {
    param(
        [parameter(ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [parameter(ParameterSetName = 'Index')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Index,

        [parameter(ParameterSetName = 'Name')]
        [parameter(ParameterSetName = 'Index')]
        [switch]$WhatIf
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'Name' { 
            $Stash = Get-VarStash -Name $Name
        }
        'Index' { 
            $Stash = Get-VarStash -Index $Index
        }
    }

    try {
        Remove-Item -Path "$env:APPDATA\VariableStash\VariableStash_$($Stash.Name).xml" -WhatIf:$WhatIf
    }
    catch {
        Throw "Unable to remove stash. Error: $_"
    }
}