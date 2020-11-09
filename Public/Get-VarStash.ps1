function Get-VarStash {
    param()

    $stashes = Get-ChildItem -Path "$env:APPDATA\VariableStash\VariableStash_*.xml"  | Sort-Object -Property lastwritetime -Descending
    foreach ($stash in $stashes) {
        $props = @{
            Name = $stash.Name.Replace('VariableStash_','').Replace('.xml','')
            Date = $stash.LastWriteTime
        }
        New-Object -TypeName psobject -Property $props
    }

}