---
layout: post
title: "Dual-Delivery: Powershell For Google Apps Mail Forwarding From Exchange"
author: David Midlo
tags: [ Exchange Server, Powershell, Google Apps, Dual-Delivery ]
categories: [ fieldnotes, Engineering, Infrastructure]
---
# Problem:
When Setting up Dual-Delivery between an exchange and Google Apps Environment only limited co-existence is possible.  It's even further away from possibility to syncronize mailbox contents and state between the two environments.  

Within those confines, a limited level of co-existence is possible in as far as dual-delivery.  Dual Delivery configurations strickly apply recieved email, and does not syncronize folder contents, delete/archived state, or anything else.

This method fits into a larger migration strategy in which an organization is moving to google apps from microsoft exchange and serves as a stop-gap differential to be put in place once GSMME has migrated email, contacts, and calendars to G Suite services.  This stop gap allows a small grace-period to users as they transition to G Suite Services by delievering mail to the respective "duplicate" mailboxes in each environment. 

This method creates a mail contact within the exchange org.  Mail is recieved and delivered first at the exchange mailbox, then forwarded to the G Suite Mailbox via a mail-enabled exchange contact. 

# Solution:
{% highlight powershell %}
### Create Mail contacts for all users within an organization unit and
### apply Mail Forwarding to User Mailboxes for Delievery to Exchange
### and Google Apps Mail and hide contacts from global address book
#### David Midlo

### Run this from a domain joined computer. Must Have Exchange
### management shell installed.
### Make sure you have rights to perform required operations 
### manually within your Active Directory and Exchange Environments.

### Import Required Modules. Sometimes script will fail if Exchange
# Snap-in is already loaded, comment out Add-PSSnaping in this event
import-module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin

### User Defined Variables
# Define Base Disinguished Name and Destination DN for created contacts
$rootDN = "OU=HRAccounts,OU=StaffUsers,DC=your,DC=domain,DC=com"
$contactsDN = "OU=GoogleForwadingContacts,DC=your,DC=domain,DC=com"

## Define naming convention
# Google root nickname DN for filling contact mail attribute
$GoogleNickname = "domain.com.test-google-a.com"
# AD Contact Name prefix for creating contact CN result would be
#   google.john
$ContactPrefix = "google"

### Define Active Directory Attributes to Act on. 
# Remove empty entries from the Get-AdUser's line 'Properties' and 'select' flags
# ObjectGuid and CN are added as reference for CSV output
$Attribute01 = "sAMAccountName"
$Attribute02 = "mail"
$Attribute03 = "ObjectGUID"
$Attribute04 = "cn"
$Attribute05 = "proxyAddress"
$Attribute06 = "targetAddress"

#######################################################################
# Reset Arrays for multiple runs
$ADUsers = $null
$NewContacts = $null

# Capture Active Directory Users w/ attributes and place into an array
# Remeber to remove undefined attributes from this line
Get-ADUser -Filter * -SearchBase "$rootDN" -Properties $Attribute01,$Attribute02,$Attribute03,$Attribute04 | select $Attribute01,$Attribute02,$Attribute03,$Attribute04 | ForEach-Object {[array]$ADUsers += $_} 

# Create contacts for each entry in array
foreach ($ADUser in $ADUsers) {

  # Variables Defined by Array $ADUsers
  $UserAccount = $ADUser.sAMAccountName
  $Mail = $ADUser.mail 

  # Create contact email based on AD user's current email
  $ContactName = "$ContactPrefix.$UserAccount"
  $Name = $Mail.Split("@")[0]
  $ForwardingEmail = "$Name@$GoogleNickname"

  # Action Cmdlets
  New-MailContact -ExternalEmailAddress $ForwardingEmail -Name $ContactName -OrganizationalUnit "$contactsDN"
  Set-MailContact -Identity $ForwardingEmail -HiddenFromAddressListsEnabled $true
  Set-Mailbox -Identity $UserAccount -ForwardingAddress $ForwardingEmail -DeliverToMailboxAndForward $true

  } 

# Collect Contacts from $contactsDN
Get-ADObject -LDAPFilter "objectClass=Contact" -SearchBase "$contactsDN" -Properties $Attribute04,$Attribute02,$Attribute05,$Attribute06,$Attribute03 | select $Attribute04,$Attribute02,$Attribute05,$Attribute06,$Attribute03 | ForEach-Object {[array]$NewContacts += $_}

 # Export CSVs
 $ADUsers | Export-Csv ADUsers.csv
 $NewContacts | Export-Csv ForwardingContacts.csv
{% endhighlight %}


# Additonal Notes:
- Other possible solutions might include scripted delgation, but that would have many considerations to unpack.


# References:
- [Migrate From Microsoft Exchange](https://support.google.com/a/answer/180898?hl=en)

# Possible Enhancements:
- [SMTP Coesxistance as a Possiblity](https://mymicrosoftexchange.wordpress.com/2015/06/21/how-to-configure-mail-flow-coexistence-between-gapps-and-o365-using-internal-relay-domains-and-mail-users/)
- [Single Domain Split Delivery](https://community.spiceworks.com/how_to/38537-ms-exchange-and-google-apps-split-delivery-for-single-domain-name-k-12-school-sample-shown)
