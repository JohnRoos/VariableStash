<#
.SYNOPSIS
   Pops a variable stash.
.DESCRIPTION
   Pops a variable stash. This command restores all variables from a variable stash and then removes the stash from storage. The stash can optionally be kept using the -Keep parameter.
.EXAMPLE
   Pop-VarStash

   Pops the variables from the top of the stash (latest stash, index 0).
.EXAMPLE
   Pop-VarStash -Name MyStash

   Pops the variables from the stash with name 'MyStash'.

.EXAMPLE
   Pop-VarStash -Index 2

   Pops the variables from the stash with index position 2 (lates stash has index 0).

.EXAMPLE
    Pop-VarStash -Keep

    Pops the variables from the top of the stash (latest stash, index 0). When using parameter -Keep, the stash will not be removed from storage (and the verb pop does not make any sense :) ).
#>
function Pop-VarStash {
    [CmdletBinding(DefaultParameterSetName = 'Keep')]
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
        [int]$Index,

        [parameter(ParameterSetName = 'Name')]
        [parameter(ParameterSetName = 'Index')]
        [parameter(ParameterSetName = 'Keep')]
        [switch]$Keep
    )

    Process {

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
                try {
                    $null = Get-Variable -Name $var.Name -Scope 2 -ErrorAction Stop
                    Write-Verbose "Scope 2: Variable '$($var.Name)' will be overwritten."
                }
                catch [System.Management.Automation.PSArgumentOutOfRangeException] {
                    # If we get here, the scope number 2 exceeds the number of active scopes
                    # This can happen if the function is not executing within a module.
                    # (This probably only happens during development)
                    # In that case we use Scope 1 instead
                    try {
                        $null = Get-Variable -Name $var.Name -Scope 1 -ErrorAction Stop
                        Write-Verbose "Scope 1: Variable '$($var.Name)' will be overwritten."
                        Set-Variable -Name $var.Name -Scope 1 -Value $var.Value
                    }
                    catch [System.Management.Automation.PSArgumentOutOfRangeException] {
                        Throw "Unable to get current variables. Have tried both scope 2 and 1. Error: $_"
                    }
                    catch [System.Management.Automation.ItemNotFoundException] {
                        # Scope works. Variable not found in current session
                        Write-Verbose "Scope 1: Variable '$($var.Name)' will be created."
                        Set-Variable -Name $var.Name -Scope 1 -Value $var.Value
                    }
                    catch {
                        Throw "Unable to get current variables in scope 1. Unhandled error. Error: $_"
                    }
                }
                catch {
                    # Scope works. Variable not found in current session
                    Write-Verbose "Scope 2: Variable '$($var.Name)' will be created."
                    Set-Variable -Name $var.Name -Scope 2 -Value $var.Value
                }
            }

            if (-not $Keep.IsPresent) {
                Remove-VarStash -Name $Stash.Name
            }
        }
        else {
            Write-Error -Category ObjectNotFound -Message 'Stash not found.'
        }

    }
}