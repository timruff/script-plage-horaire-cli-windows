<#
    .Synopsis
    Script qui permet de modifier les plages d'acc�s d'horraire des utilisateurs/

    .Notes
    Auteur : Timoth�e RUFFENACH
    Version : 2. 0
    Date : 12/08/2022
    Fonctionne sur windows 2019/2022 server et powershell 5.1
    Codage : ISO 8859-1 CRLF
    
    Param�tres : aucun
 

    .Example
    Plage horaire.

    .Link
#>

<#
    .Description
    setDirectoryExist : Teste si un r�pertoire existe, si il existe pas cr�ation du r�pertoire

    .Parameter path
    chemin de r�p�rtoire � tester
#>

# Variable de Debugage
$global:DEBUG = $false

# D�finition des valeurs de configuration
$global:logDirectoryPath = "C:\temp\"            # r�pertoire temporaire
$global:logFilePath = "C:\temp\script01.log"     # Chemin du fichier de trace d'execution

<#
    .Description
    setDirectoryExist : V�rifie si un r�pertoire existe, si il existe alors le cr�e

    .Parameter level
    path : chemin du r�pertoire
#>

function setDirectoryExist 
{
    Param
    (
        [Parameter(Mandatory)][string]$path
    )

    # V�rifie si le r�pertoire existe
    if( -Not (Test-Path $path))
    {
        New-Item $path -itemType Directory | Out-Null # cr�ation du r�pertoire
        setLog "INFO" "Cr�ation du r�pertoire $path" $global:logFilePath
    }

}

<#
    .Description
    setLog : Trace l'ex�cution du script dans la console et un fichier sp�cifique

    .Parameter level
    Niveau de la trace [INFO, WARN, ERROR]

    .Parameter message
    Message � afficher/enregistrer

    .Link
    https:/www.tutos.eu/3600
#>

function setLog 
{
    Param 
    (   
        [Parameter(Mandatory)][string]$level,
        [Parameter(Mandatory)][string]$message,
        [Parameter(Mandatory)][string]$logFilePath
    )

    # D�finition de la date et l'heure actuelle et formatage ici c'es ann�e mois jour heure minute seconde
    $formatedActualTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    # Constitution de l'information qui va �tre affich�e
    $logLine = "$formatedActualTime [" + $level.ToUpper() + "] " + $message
    # Enregistrement de l'information
    $logLine | Add-Content $global:logFilePath
    # Affichage de l'information

    # On met un peu der couleurs suivant le message dans $level

    if($level.ToUpper() -eq "INFO")
    {
        Write-Host "$logLine" -ForegroundColor Green
    }
    elseif($level.ToUpper() -eq "WARN")
    {
        Write-Host $logLine -ForegroundColor Yellow
    }
    elseif($level.ToUpper() -eq "ERROR")
    {
        Write-Host $logLine -ForegroundColor Red
        exit 1 # une error est toujours fatals il faut retourner exit 1
    }
    else
    {
        Write-Host $logLine 
    }
}

<#
    .Description
    inputFormattedChoiceList cr�ation d'une entr�e format�e avec un choix num�rique.

    .Parameter listChoice, $question
    listChoice : donne les choix disponnibles que l'on peut selectionner
    question : indique la phrase qui pose la question

    .Return choice
    Retourne le choix utilisateur et num�ro du choix utilisateur
#>

Function inputFormattedChoiceList
{
    Param
    (
        [Parameter(Mandatory)]$listChoice,
        [Parameter(Mandatory)]$question,
        $beginChoice = 0 # param�tre qui permet de d�caler le choix
    )

    $choice = -1

    # rentre dans une boucle tant que le choix n'est pas bon redemander la question
    do
    {
        # Affiche le resultat
        for($i=$beginChoice;$i -lt $listChoice.length;$i++)
        {
            Write-host("{0,2}" -f $i + " :" , $listChoice[$i].toString())
        }
        [int]$choice = Read-Host($question) # demande la question la question

        if($choice -lt $beginChoice -Or $choice -ge $listChoice.length)
        {
            Write-Host "Saisie hors limite" -ForegroundColor Red
        }
    
    }
    while(($choice -lt $beginChoice) -Or ($choice -ge $listChoice.length))

    return $listChoice[$choice], $choice
}

Function timeSlotsUsersHours
{
    Param
    (
        [Parameter(Mandatory)][int32[]]$timeSlots
    )

    do
    {
        $timeSlotsFormated=$()
        # cr�ation de cha�ne par rapport au r�sultat.
        for($i=0;$i -lt 24;$i++)
        {
            $timeSlotsFormated += [array](" heure $i" + " �tat" + "",$timeSlots[$i])
        }

        $change = inputFormattedChoiceList $timeSlotsFormated "Quel horaire voulez-vous changer ?"
        $index = $change[1]

        # changement de l'heure
        if($timeSlots[$index] -eq 0)
        {
            $timeSlots[$index] = 1
        }
        else
        {
            $timeSlots[$index] = 0
        }

        # r�affiche les horaires
        Write-Host("Les nouveaux horaires sont : ")  
        for($i=0;$i -lt 24;$i++)
        {
            Write-Host([array](" heure $i" + " �tat" + "",$timeSlots[$i]))
        }
    
        # demande si autre modification
        $otherChange = inputFormattedChoiceList @("oui", "non") "voulez-vous changer une autre plage horaire ?"
    }
    while($otherChange[1] -eq 0)

    return $timeSlots
}

Function timeSlotsUsersDays
{
    Param
    (
        [Parameter(Mandatory)][int32[]]$timeSlots
    )

    do
    {
        $day=$("Dimanche","Lundi","Mardi","Mecredi","Jeudi","Vendredi","Samedi")
        $timeSlotsFormated=$()
        # cr�ation de cha�ne par rapport au r�sultat.
        
        
        for($i=0;$i -lt 7;$i++)
        {
            $timeSlotsFormated += [array]("{0}" -f $day[$i] + " �tat",$timeSlots[$i])
        }

        $change = inputFormattedChoiceList $timeSlotsFormated "Quel journ�e voulez-vous changer ?"
        $index = $change[1]

        # changement de du jour
        if($timeSlots[$index] -eq 0)
        {
            $timeSlots[$index] = 1
        }
        else
        {
            $timeSlots[$index] = 0
        }

        # r�affiche les jours
        Write-Host("Les nouveaux horaires sont : ")  
        for($i=0;$i -lt 7;$i++)
        {
            Write-Host("{0}" -f $day[$i] + " �tat",$timeSlots[$i])
        }
    
        # demande si autre modification
        $otherChange = inputFormattedChoiceList @("oui", "non") "voulez-vous changer une autre plage journali�re ?"
    }
    while($otherChange[1] -eq 0)

    return $timeSlots
}

Function listOfUsers
{
    $listUsers = @()
    $listSamAccount = @() 

    # recup�ration des noms des utilisateurs.
    $name = Get-ADUser -filter * | Select-object name
    $name = $name.name

    # recup�ration des SamAccountNames 
    $samAccountName = Get-ADUser -filter * | Select-Object SamAccountName
    $samAccountName = $samAccountName.SamAccountName

    do
    {
        # choix
        $change = inputFormattedChoiceList $name "Quel utilisateur est concern� ?"
    
        # ajoute � la liste
        $listUsers += ($name[$change[1]])
        $listSamAccount += ($samAccountName[$change[1]])

        # Affiche les utilisateurs concern�s
        Write-Host("Les utilisateurs s�lectionn�s sont : ")
        
        for($i=0;$i -lt $listUsers.length;$i++)
        {
            Write-Host($listUsers[$i])
        }

        # demande si autre modification
        $otherChange = inputFormattedChoiceList @("oui", "non") "voulez-vous ajouter un autre utilisateurs ?"
    }
    while($otherChange[1] -eq 0)

    return [array]$listSamAccount
}

Function setTimeSlots
{
    Param
    (
        [Parameter(Mandatory)]$timeSlotsHours,
        [Parameter(Mandatory)]$timeSlotsDay,
        [Parameter(Mandatory)]$concernedUsers
    )

    [byte[]]$hours = @()
    $binaryWeek = ""
 
    
    # offset du d�calage horaire
    $offset = (Get-TimeZone).baseutcoffset.hours
 
    # cr�ation des jours en binaire
    for($i=0;$i -lt 7;$i++)
    {
        if($timeSlotsDay[$i] -eq 1)
        {
            for($j=0;$j -lt 24;$j++)
            {
                $binaryWeek += $timeSlotsHours[$j];
            }
        }
        else
        {
            for($j=0;$j -lt 24;$j++)
            {
                $binaryWeek += 0;
            }
        }
    }
    
    
    # d�calage offset rotation.
    if($offset -gt 0)
    {
        $temp=$binaryWeek.Substring($offset,$binaryWeek.length-1)
        $temp+=$binaryWeek.Substring(0,$offset)
    }
    elseif($offset -lt 0)
    {
        $temp=$binaryWeek.Substring($binaryWeek.length-1-$offset,$binaryWeek.length-1)
        $temp+=$binaryWeek.Substring(0,$binaryWeek.length-2-$offset)        
    }

    
    # conversion en d�cimal
    $octet = $temp -split '(........)' -ne ''
    
    # que c'est compliqu� pour peut de choses
    for($i=0;$i -lt $octet.length;$i++)
    {
        $convertBinary1 = $octet[$i] # r�cup�re la valeur brut
        $convertBinary = $convertBinary1 -split "" # on est oblig� de couper en charact�re pour inverser 
        [array]::Reverse($convertBinary) # on inverse la cha�ne
        $convertBinary = $convertBinary -join '' # on remet comme avant
        $hours += [convert]::ToInt32($convertBinary,2) # conversion en binaire.
    }

    #Write-host($hours)

   # Application sur les utilisateurs
   for($i=0;$i -lt $concernedUsers.length;$i++)
   {   
        Get-ADUser -Identity $concernedUsers[$i] | Set-ADUser -Replace @{logonhours = $hours} 
   }

  
}


Function main
{
        #La premi�re chose � faire c'est d'�tre sure que l'on peut �crire les log
        setDirectoryExist $global:logDirectoryPath

        # On d�marre le script
        setLog "INFO" "D�marrage du script" $global:logDirectoryPath

        # Menu r�cup�ration de la plage horaire.    
        $timeSlotsHours = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        setLog "INFO" "Saisie de la plage horaire" $global:logDirectoryPath
        $timeSlotsHours = timeSlotsUsersHours $timeSlotsHours

        # Menu r�cup�ration de la plage journali�re.    
        $timeSlotsDay = @(0,0,0,0,0,0,0)
        setLog "INFO" "Saisie de la plage journali�re" $global:logDirectoryPath
        $timeSlotsDay = timeSlotsUsersDays $timeSlotsDay

        # Menu r�cup�ration des utilisateurs
        setLog "INFO" "Saisie des utilisateurs" $global:logDirectoryPath
        [array]$concernedUsers = listOfUsers

        # Application des droits sur les utilisateurs
        setlog "INFO" "Application des droits" $global:logDirectoryPath
        setTimeSlots $timeSlotsHours $timeSlotsDay $concernedUsers

    try 
    {
        # Fin du script 
        setLog "INFO" "Fin du script" $global:logDirectoryPath

        # Si tout des passe bien bon code de fin
        exit 0

    }
    catch
    {
        # Une erreur est survenue, on l'indique proprement dans la trace
        setLog "ERROR" $PSItem.ToString() $global:logDirectoryPath
        # On quitte le script avec un code de retour valant 1
        exit 1   
    }
}

main # Appel de la fonction principale