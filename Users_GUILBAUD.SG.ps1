# Import active directory 
Import-Module activedirectory
$Infosdomaine = Get-ADDomain
$DN = $infosdomaine.DistinguishedName
$DNSRoot = $Infosdomaine.DNSRoot


#Importer les utilisateur du fichier csv dans la variable $ADUsers 
$ADUsers = Import-csv .\Users_GUILBAUD.SG.csv -Delimiter ";" 

#On va variabiliser chaque colonne du fichier csv 
foreach ($User in $ADUsers)
{
			
	$Username = $User.EmployeeID
	#$Password = $User.password
	$Firstname = $User.firstname
	$Lastname = $User.lastname
	$OU = $User.OU
    $Dpt = $User.Department
    $Function = $User.Department
    #$Compagny = $User.company
    $samaccountname = $user.EmployeeID
    $Des = $user.Description
    $Titlle = $user.Title
    $fullname = $user."$Firstname" + "$Lastname"

if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#Si l'utilisateur n'existe pas ou va le créer
		
        #On va récupérer les information dans les variables créées ci-dessus
        New-ADUser -Name "$fullname" -SamAccountName "$Username" -Surname "$Lastname" -GivenName "$Firstname" -AccountPassword (convertto-securestring "Passw0rd" -AsPlainText -Force) -UserPrincipalName "$Username@$DNSRoot" -Department "$Dpt" -Title "$Titlle" -Path "$OU" -Enabled $true -ChangePasswordAtLogon $false -Description "$Des" -EmailAddress "$Username@$DNSRoot" -Instance $Function -DisplayName "$fullname" 
		
                    
}
}

$userdis = (Get-ADUser -Filter * -Properties * | select name,department,samaccountname | where {$_.department -Like "Du-Mal" -or $_.department -like "Maléfiques"} )
[System.Collections.ArrayList]$test = ($userdis | select samaccountname)

foreach ($line in $test)
{
			
	$Useradis= $line.samaccountname

Set-ADUser -Identity "$Useradis" -Enabled $false
}

