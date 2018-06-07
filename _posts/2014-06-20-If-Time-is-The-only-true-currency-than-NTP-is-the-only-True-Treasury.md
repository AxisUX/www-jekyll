---
layout: post
title: "If Time is the Only True Currency, Than NTP is the Only True Treasury"
author: David Midlo
tags: [ NTP, Active Directory, Windows Server ]
categories: [ fieldnotes, Engineering, infrastructure]
---
Good timekeeping is essential in enterprise IT infrastructure. If left unattended, inaccurate or out of sync time can cause all sorts of issues. On the mundane side, it can be tough to compare syslog messages when the timestamps can not be trusted. On the more extreme side, with enough drift between clocks could result in a complete work stoppage as users may not be able to authenticate against a directory server to get logged in in the morning.

Thankfully, Good NTP design is pretty difficult to screw up. Essentially, there are three simple rules to follow in order to get timekeeping right; One, understand the needs and capabilities of the systems that require time services. Two, Define a reliable common time server (or server pool) for all systems to reference. Three, Leverage NTP authentication in any systems that will support it.

## One, understand the capabilities of the systems that require time services

In a typical enterprise there are any number of systems that require accurate timekeeping.  We IT folk often think of things like directory services requiring Kerberos based authentication, card access systems, remote access services, IPS & IDS log analysis, etc.  Often the simpler things are overlooked; HVAC systems, parking lot lights, even the simple wall clock often use NTP based time services.

In the past, there has been other timekeeping protocols in use, but fortunately they are now artifacts of history and will be omitted from this discussion.  This allows us to work from a simple assumption:  If a system requires network based time keeping it will do so using NTP.

Different systems support NTP to various levels, specifically in regard to NTP authentication.  We’ll get into a few attacks involving NTP when we look at rule three, but for now just know that some systems support NTP authentication and some systems ‘claim’ to support NTP authentication.  Most ‘infrastructure’ devices support NTP authentication; L2-L3 equipment, Application Firewalls and Proxies, HVAC systems, etc. In other words, systems that are generally considered to be network ‘appliances’ will typically support NTP authentication.

For design considerations, there is only one system that stands out.  Microsoft Active Directory.

Active Directory incorporates NTP in much the same way it has with DNS, DHCP, MIT Kerberos, HPFS Permissions, etc into the Windows ecosystem.  Unfortunately, just like when attempting to integrate Microsoft DNS and BIND, certain issues arise when working towards interoperability.   Here is a quick description from technet describing AD’s usage of NTP authentication:

> *”Within an AD DS forest, the Windows Time service relies on standard domain security features to enforce the authentication of time data. The security of NTP packets that are sent between a domain member computer and a local domain controller that is acting as a time server is based on shared key authentication. The Windows Time service uses the computer’s Kerberos session key to create authenticated signatures on NTP packets that are sent across the network. NTP packets are not transmitted inside the Net Logon secure channel. Instead, when a computer requests the time from a domain controller in the domain hierarchy, the Windows Time service requires that the time be authenticated. The domain controller then returns the required information in the form of a 64-bit value that has been authenticated with the session key from the Net Logon service. If the returned NTP packet is not signed with the computer’s session key or is signed incorrectly, the time is rejected. All such authentication failures are logged in the Event Log. In this way, the Windows Time service provides security for NTP data in an AD DS forest.”* 

~ [How the Windows Time Service Works](https://docs.microsoft.com/en-us/windows-server/networking/windows-time-service/how-the-windows-time-service-works)

Here you can see that instead of using a standard string for the shared-secret, Microsoft uses the Kerberos session ticket for NTP authentication.  It is really an elegant solution, but is unfortunately causes interoperability issues with standard NTP systems. Microsoft has a wonderful write up on their implementation of the [NTP Authentication Extensions](MS-SNTP.pdf) but further reading reveals no mention of NTP authentication configuration using an external time server leveraging a sting as the shared-secret.  Given the impact it has on most organizations, the fact that AD seems to not be interoperable with external services will definitely have an impact on our design.