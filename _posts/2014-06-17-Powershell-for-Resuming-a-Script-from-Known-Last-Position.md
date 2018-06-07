---
layout: post
title: Powershell for Resuming a Script from Known Last Position
author: David Midlo
tags: [ Powershell ]
categories: [ fieldnotes, Engineering, Infrastructure]
---
# Problem:
I’ve been working on some powershell that will completely automate the user account provisioning process for my organization.  Currently the script is in beta, and being tested at a limited scope with great success.

There are some other moving parts required to get this off the ground.  When dealing with a directory that has 7500 real users in it, you have to make sure you’re only handling the accounts as much as you have to.  One of the mechanisms of doing that is picking up where you left off even if you stop the script for debugging.  The following is a proof-of-concept script that can be turned into a function or used as a wrapper around any script that is going through a large list using a for-each loop.   I’ve commented the code at each step so you can keep track of what the script is doing and to express some of the thought behind my decisions.   You’ll also notice that you can download this script or view it in a raw format using the links at the top right of script block.

# Solution:
{% highlight Powershell %}
#############################################################################
##  ScriptName: last_session.ps1
##  author: @dmidlo (twitter)    david@axisux.com
## 
## Purpose:  a Proof of Concept script that stores the current progress of a foreach
##   loop to a file to enable the script to resume from where it left off
##
##
## Disclaimer:  No warranty and all that! This is a proof of concept script only! There is no 
##   error handling or anything that would potentially obscure how this operation is functioning.
##   (Except for "write-progress" which is vital to not going insane while waiting for hours for
##   a process to complete.)
 
#######################################################################################
## clean up the variables for consecutive runs from ISE
Import-Module activedirectory
Clear-Host
$user = $null
$users = $null
$ClixmlUsers = $null
$rootDN = $null
$ImportedUserHash = $null
$CurrentSessionUserHash = $null
#######################################################################################
 
## Define the OU
$rootDN = "OU=Users,DC=your,DC=com"
 
## Initilize HashTables $importeduserhash is the datasource, $CurrentSessionUserHash is a post-run diagnostics variable
$ImportedUserHash = @{}
$CurrentSessionUserHash = @{}
 
## Import Previous Runs
$ImportedUserHash = Import-Clixml .\USERS.clixml -ErrorAction SilentlyContinue
 
## Get List of Users From Active Directory
$Users = @(Get-ADUser -filter * -SearchScope subtree -SearchBase "$rootDN" -Properties sAMAccountName,distinguishedName,homedirectory)
 
## Setup Variables for Write-Progress
$a = $users.Count
$b = $ImportedUserHash.count
 
## Notify Host of Current Progress Numbers
write-host "imported completed user count is:" $b
write-host "Active Directory user count is:" $a 
 
## Begin Labor Loop
foreach($user in $Users){
    ## Check to see if User was completed in a previous run
    if($ImportedUserHash.Contains($user.SamAccountName)){
        ## Notify Host that user has already been run in a previous session 
        Write-Host $user.SamAccountName "completed in previous session" -ForegroundColor Yellow
        ## Add to diagnostics variable with value set at "imported from previous session.
        $CurrentSessionUserHash.add($user.SamAccountName,"Imported From Previous Session")
    }
    ## If user has not been run previously, take action now
        Else{
            ## wait just to give the script something to do to waste time for a demo
            Start-Sleep -Seconds 3
            ## add user completed user to hashtable for export. This should always be the last functinal step in the foreach...
            $ImportedUserHash.add($user.SamAccountName,$user.DistinguishedName)
            ## Export hashtable to clixml.  I chose clixml instead of csv for two reasons; one, it imports as the variable as it was 
            ## exported as. Two, it will be less likely to be deleted by some other admin.
            $ImportedUserHash | Export-Clixml .\USERS.clixml
 
            ## add user to diagnostics variable with value set to "current session"
            $CurrentSessionUserHash.add($user.SamAccountName,"Current Session")
 
            ## notify host things went well
            write-host $user.sAMAccountName "has been added to User Hashtable"-ForegroundColor Green
 
            ## +1 to the write-progress count        
            $B++
        }
 
    ## percent of whole calculator for write-progress
    $c = ($b / $a) * 100
 
    ## update progress bar with current statistics.
    write-progress -activity Updating -status 'Progress-&gt;' -percentcomplete $c -currentOperation "Profiles Completed: $b of $a Percent Complete: $c Current Accout: $user.sAMAccoutname"
}
{% endhighlight %}