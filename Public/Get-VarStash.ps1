function Get-VarStash {
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
            $stashes = @(Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_$Name.xml"  | Sort-Object -Property lastwritetime -Descending)
        }
        'Index' { 
            $stashes = @(Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_*.xml"  | Sort-Object -Property lastwritetime -Descending | Select-Object -First 1 -Skip $Index)  
        }
        Default {
            $stashes = @(Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_*.xml"  | Sort-Object -Property lastwritetime -Descending)
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