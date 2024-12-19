<#
.Example 
$summary = Escape-SQLString $item.summary
#>
function Get-EscapeSQLString {
    param (
        [string]$Escape
    )
    return $Escape -replace "'", "''"
}