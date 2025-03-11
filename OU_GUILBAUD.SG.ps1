# Importer le module Active Directory
Import-Module ActiveDirectory

# Chemin vers le fichier CSV
$csvPath = "OU_GUILBAUD.SG.csv"

# Importer les données du fichier CSV
$OUs = Import-Csv -Path $csvPath

# Créer l'OU principale si elle n'existe pas
$mainOUName = "_GUILBAUD.SG"
$mainOUPath = "DC=GUILBAUD,DC=SG"

if (-not (Get-ADOrganizationalUnit -Filter { Name -eq $mainOUName } -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $mainOUName -Path $mainOUPath
    Write-Host "OU principale '$mainOUName' créée."
} else {
    Write-Host "L'OU principale '$mainOUName' existe déjà."
}

# Créer un dictionnaire pour garder une trace des OUs créées
$createdOUs = @{}

# Créer les OUs en s'assurant que les parents existent
foreach ($OU in $OUs) {
    $parentOU = $OU.ParentOU
    $parentOUPath = $null

    if ($parentOU -ne "") {
        # Vérifier si l'OU parent a été créée
        if ($createdOUs.ContainsKey($parentOU)) {
            $parentOUPath = $createdOUs[$parentOU]
        } else {
            # Récupérer le chemin de l'OU parent
            $parentOUObj = Get-ADOrganizationalUnit -Filter { Name -eq $parentOU } -ErrorAction SilentlyContinue
            if ($parentOUObj) {
                $parentOUPath = $parentOUObj.DistinguishedName
            }
        }

        if ($parentOUPath) {
            try {
                # Créer l'OU si le parent existe
                New-ADOrganizationalUnit -Name $OU.OUName -Path $parentOUPath
                $createdOUs[$OU.OUName] = "OU=$($OU.OUName),$parentOUPath"
                Write-Host "OU '$($OU.OUName)' créée sous '$parentOU'."
            } catch {
                Write-Host "Erreur lors de la création de l'OU '$($OU.OUName)': $_"
            }
        } else {
            Write-Host "L'OU parent '$parentOU' n'existe pas. Impossible de créer '$($OU.OUName)'."
        }
    } else {
        # Cas où l'OU n'a pas de parent (par exemple, la principale)
        Write-Host "L'OU '$($OU.OUName)' n'a pas de parent défini."
    }
}

Write-Host "Création des unités d'organisation terminée."
