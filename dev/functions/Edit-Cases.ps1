function Edit-Cases {
    param (
        [PSCustomObject]$item,
        [PSCustomObject[]]$replacementsPath
    )

    $replacements = Get-Content -Path $replacementsPath | ConvertFrom-Json

    foreach ($rule in $replacements) {
        if ($item.case -eq $rule.case -and $item.date -eq $rule.date) {
            foreach ($property in $rule.PSObject.Properties) {
                if ($property.Name -ne "case" -and $property.Name -ne "date") {
                    $item | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value -Force
                }
            }
            Write-Host "[$(Get-Date)] Updated: $($item.case)" -ForegroundColor "green"
        }
    }

    return $item
}