# VariableStash
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/VariableStash)](https://www.powershellgallery.com/packages/VariableStash)

Like git stash but for variables, kinda.

## Examples

Stash your current variables on the top of the stash:

```powershell
Push-VarStash
```

Restore variables in your current session from top of stash:

```powershell
Pop-VarStash
```

Name your stash

```powershell
Push-VarStash -Name 'MyStash'
```

List available stashes:

```powershell
Get-VarStash

<#
Date                   Name
----                   ----
2020-11-09 12:39:39 PM bddec36d-6335-45e6-b2bf-d2f5cff3a567
2020-11-09 12:30:23 PM MyStash
2020-11-09 12:27:24 PM 1b53d3fa-5e42-4510-b72b-2ba3e748b534
#>
```

Pop the named stash:

```powershell
Pop-VarStash -Name 'MyStash'
```

Or Pop using index:

```powershell
Pop-VarStash -Index 1
```

Want to keep the stash after you pop it? Here's how:

```powershell
Pop-VarStash -Index 1 -Keep
```

Peek inside and show the variables inside a stash:

```powershell
Show-VarStash -Name MyStash

<#
Name                           Value
----                           -----
MyInt                          40
mystring                       This is a string
#>
```

More examples will come.