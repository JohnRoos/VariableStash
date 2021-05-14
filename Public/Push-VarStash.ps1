<#
.SYNOPSIS
   Pushes variables to the variable stash.
.DESCRIPTION
   Pushes variables to the variable stash. The pushed variables will be stored on the top of the stash (index 0).
.EXAMPLE
   Push-VariableStash

   Pushes variables to the variable stash. Since the -Name parameter is omitted, a default name will be set (a guid). 
.EXAMPLE
   Push-VariableStash -Name MyStash

   Pushes variables to the variable stash with name MyStash.
#>
function Push-VarStash {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                $_.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars() + [char]'_') -eq -1
            },
            ErrorMessage = 'Name must have valid file name characters and cannot contain underscore.')]
        [string]$Name
    )

    Process {

        # Get variables
        # Scope need to be 2 when running as a function inside a module.
        # Scope need to be 1 when running as a function not part of a module.
        try {
            $AllVariables = Get-Variable -Scope 2
        }
        catch [System.Management.Automation.PSArgumentOutOfRangeException] {
            try {
                Write-Verbose "Using scope 1"
                $AllVariables = Get-Variable -Scope 1
            }
            catch {
                Throw $_
            }
        }
        catch {
            Throw "Unable to get variables. Error: $_" 
        }

        # Get blacklist
        $Blacklist = Get-VarStashBlackList

        # Remove blacklisted variables
        $ApprovedVariables = $AllVariables.Where({$_.Name -notin $Blacklist})
        
        # Remove variables which are read only, constants or private
        # https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.scopeditemoptions?view=powershellsdk-7.0.0
        $WritableApprovedVariables = $ApprovedVariables.Where({$_.Options -notin 1, 2, 9, 10})
        
        # Any variables left?
        if ($WritableApprovedVariables.Count -eq 0) {
            Write-Error -Message 'No variables to stash.' -Category ObjectNotFound 
        }
        else {
            # Generate filename
            if ([string]::IsNullOrEmpty($Name)) {
                $FileName = "VariableStash_$((New-Guid).Guid).xml"
            }
            else {
                $FileName = "VariableStash_$Name.xml"
            }

            # Prepare folder if needed
            if (-not (Test-Path -Path "$env:APPDATA\VariableStash" -PathType 'Container')) {
                $null = New-Item -Path $env:APPDATA -Name 'VariableStash' -ItemType 'Container'
            }

            # Write to disk
            Export-Clixml -InputObject $WritableApprovedVariables -Path "$env:APPDATA\VariableStash\$FileName"
        }

    }
}