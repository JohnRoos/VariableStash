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