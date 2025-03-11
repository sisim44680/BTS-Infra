# Import active directory 
Import-Module activedirectory
$Infosdomaine = Get-ADDomain$DN = $infosdomaine.DistinguishedName
$DNSRoot = $Infosdomaine.DNSRoot


$ADgrps = Import-csv .\GG_GUILBAUD.SG.csv -Delimiter ";" 

foreach ($grp in $ADgrps)
{
$OU = $grp.OU
$grpgg = $grp.groupe
$desgrp = $grp.description

try
{
Get-ADGroup -Identity $grpgg -ErrorAction Ignore | ft name -HideTableHeaders
Write-Warning "Le groupe $grpgg existe déjà" 
}
catch
{
New-ADGroup -Name "$grpgg" -GroupScope global -GroupCategory Security -Path "$OU" -Description "$desgrp" -ErrorAction SilentlyContinue
Write-Host "Le groupe $grpgg a bien été crée"
}
}
