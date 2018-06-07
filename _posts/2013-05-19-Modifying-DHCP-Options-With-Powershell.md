---
layout: post
title: Modifying DHCP options with Powershell
author: David Midlo
tags: [ Powershell, Windows Server, Active Directory, DHCP]
categories: [ fieldnotes, Engineering, Infrastructure]
---
# Problem:
If you run medium or large network with many sites, you’ll have a lot of DHCP scopes or a lot of DHCP servers because you’ll have a lot of vlans and therefore a lot of subnets. Most of which require DHCP services. Also,  If you’re running a windows domain, you’re using a windows DHCP server, well, because it just makes sense (due to Dynamic DNS updating.)

We recently virtualized one of our linux based PXE servers and need to update a bunch of scope’s PXE options (66 and 67.)  Here is an example of how to approach the problem using only powershell cmdlets (none of that ‘netsh’ stuff!)

It is important to note that DHCP stores different options as different types of values, so this will work with ‘string’ type options.  To work with other types of DHCP options the principles outlined here still apply, just be sure your inputs correspond with value type of the DHCP option your working with.

# Solution:
{% highlight Powershell %}
#############################################################################
#  ScriptName:  Set_DHCP_Options.ps1
#  Author:  @dmidlo Twitter) david@axisux.com
#
#  This is an example of script that collects All authorized DHCP servers 
#  in a windows domain and changes values.  This script also contains an 
#  example of excluding a set of addresses. Read through the comments within
#  the script for more information.  This is using PXE related options to 
#  illustrate the syntax of the cmdlets, be sure to modify the script to 
#  suite your needs
 
#### Change this value to PXE server's network location
$ipaddress = "10.1.0.1"  # this also can be a FQDN
 
#### This is the name of the file located on the PXE server the client should look for
#### if you use a linux based PXE server, often the bootfile name is "pxelinux.0"
#### the present value is if your running a WDS or MDT server for PXE boot.  SCCM does
#### not recommend the use of boot options for establishing PXE sessions, instead you 
#### would configure broadcast forwarders on your networking equipment to your SCCM
#### server.
$bootfileName = "boot\x86\wdsnbp.com"
 
#### Capture authorized DHCP servers and store them
$dhcpServers = Get-DhcpServerInDC
 
#### Begin Labor Loop for each authorized DHCP server in the domain
foreach($dhcpServer in $dhcpServers){
 
    # get the scopes from current DHCP server
    $scopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer.DnsName
 
    # for each scope in the DHCP server set options PXE options 66 and 67
    foreach($scope in $scopes){
        $bootServerValue = Get-DhcpServerv4OptionValue -ComputerName $dhcpServer.DnsName -ScopeId $scope.ScopeId -OptionId 66
 
        # Exclude any Scope that begins with "10.20"
        #### DHCP stores these values as strings, so we do the exclusion using string evaluation.
        #### if you wanted to exclude multipe ranges you would use the '-or' operator with enclosing parentheses
        #### example (($bootServerValue.Value -notlike "10.20*" ) -or ($bootServerValue.Value -notlike "10.32*" ))
        #### you could also use "-like" instead of "-notlike" if you wanted to catch just a subset of scopes. Think 'Top-Down' vs 'Bottom-Up'
        if($bootServerValue.Value -notlike "10.20*" ){
 
            # Set value 66 with the network location defined above
            Set-DhcpServerv4OptionValue -ComputerName $dhcpServer.DnsName -ScopeId $scope.ScopeId -OptionId 66 -Value "$IPadddress"
 
            # Set value 67 with the bootfile name defined above
            Set-DhcpServerv4OptionValue -ComputerName $dhcpServer.DnsName -ScopeId $scope.ScopeId -OptionId 67 -Value "$bootfileName"
        }
    }
}
{% endhighlight %}