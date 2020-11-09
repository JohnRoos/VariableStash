function Pop-VarStash {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [parameter(ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [parameter(ParameterSetName = 'Index')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Index,

        [parameter(ParameterSetName = 'Name')]
        [parameter(ParameterSetName = 'Index')]
        [parameter(ParameterSetName = 'Default')]
        [switch]$Keep
    )

    switch ($PSCmdlet.ParameterSetName) {
        'Name' { 
            $Stash = Get-VarStash -Name $Name
        }
        'Index' { 
            $Stash = Get-VarStash -Index $Index
        }
        Default {
            $Stash = Get-VarStash -Index 0
        }
    }

    $StashPath = "$env:APPDATA\VariableStash\VariableStash_$($Stash.Name).xml"
    # Check if we have a file to import
    if (Test-Path -Path $StashPath -PathType 'Leaf') {  
        # Import the variables
        $ImportedVariables = Import-Clixml -Path $StashPath
        # Set each variable in parent scope
        foreach ($var in $ImportedVariables) {
            if (Get-Variable -Name $var.Name -Scope 1 -ErrorAction SilentlyContinue) {
                Write-Verbose "Variable '$($var.Name)' will be overwritten."
            }
            else {
                Write-Verbose "Variable '$($var.Name)' will be created."
            }
            Set-Variable -Name $var.Name -Scope 1 -Value $var.Value
        }
        if (-not $Keep.IsPresent) {
            Remove-VarStash -Name $Stash.Name
        }
    }
    else {
        Write-Error "Stash not found."
    }
}