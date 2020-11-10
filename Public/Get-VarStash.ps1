<#
.SYNOPSIS
   Gets one or more variable stashes.
.DESCRIPTION
   Gets one or more variable stashes. Returns the name and the created date for each stash.
.EXAMPLE
   Get-VarStash

   Gets all available variable stashes.
.EXAMPLE
   Get-VarStash -Name MyStash

   Gets the variable stash called MyStash.

.EXAMPLE
   Get-VarStash -Name My*

   Gets variable stashes with names starting with 'My'.

.EXAMPLE
    Get-VarStash -Index 2

    Gets the variable stash on index position 2 in the stash. Index starts with 0.
#>
function Get-VarStash {
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
                $stashes = @(Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_$Name.xml" | Sort-Object -Property lastwritetime -Descending)
                if ($stashes.count -eq 0) {
                    Write-Error -Category ObjectNotFound -Message "Cannot find stash with name $Name."
                }
            }
            'Index' { 
                $stashes = @(Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_*.xml" | Sort-Object -Property lastwritetime -Descending | Select-Object -First 1 -Skip $Index)  
                if ($stashes.count -eq 0) {
                    Write-Error -Category ObjectNotFound -Message "Cannot find stash with index $Index."
                }
            }
            Default {
                $stashes = @(Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_*.xml" | Sort-Object -Property lastwritetime -Descending)
                if ($stashes.count -eq 0) {
                    Write-Error -Category ObjectNotFound -Message 'No stash found. Use Push-VarStash to create a stash.'
                }
            }
        }

        foreach ($stash in $stashes) {
            $props = @{
                Name = $stash.Name.Replace('VariableStash_','').Replace('.xml','')
                Date = $stash.LastWriteTime
            }
            New-Object -TypeName psobject -Property $props
        }

    }
}