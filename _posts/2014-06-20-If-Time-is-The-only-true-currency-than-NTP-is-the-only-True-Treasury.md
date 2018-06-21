---
layout: post
title: "If Time is the Only True Currency, Than NTP is the Only True Treasury"
author: David Midlo
tags: [ NTP, Active Directory, Windows Server ]
categories: [ fieldnotes, Engineering, Infrastructure]
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

Here you can see that instead of using a standard string for the shared-secret, Microsoft uses the Kerberos session ticket for NTP authentication.  It is really an elegant solution, but is unfortunately causes interoperability issues with standard NTP systems. Microsoft has a wonderful write up on their implementation of the ([NTP Authentication Extensions]({{ "assets/documents/pdfs/posts/If-Time-is-The-only-true-currency-than-NTP-is-the-only-True-Treasury/%5BMS-SNTP%5D.pdf" | absolute_url }})) but further reading reveals no mention of NTP authentication configuration using an external time server leveraging a string as the shared-secret.  Given the impact it has on most organizations, the fact that AD seems to not be interoperable with external services will definitely have an impact on our design.

## Two, Define a reliable common time server (or server pool) for all systems to reference.

Right, this stuff is pretty simple. There is really two ways to approach this;  One, install hardware clocks that reference common NTP servers.  In the US, typically these hardware clocks will point to the two secure NTP servers provided by NIST, ntp-a.boulder.nst.gov and ntp-b.nist.gov.  Two, use existing internal systems as NTP servers for the enterprise.  We will be exploring this second option a bit further.

Many will simply use Active Directory Domain Controllers as the common time keeping pool within an organization.  Since however AD NTP authentication can not interoperate either as a client or a server with other systems (as it does not provide a mechanism to provide a sting based shared-secret,) it is not suitable to act in a central role in an NTP design as it is especially susceptible to man-in-the-middle attacks.

Here is an example NTP topology with a consideration of the limitations of Active Directory’s use of NTP authentication:

![NTP Architeture]({{ "assets/images/posts/If-Time-is-The-only-true-currency-than-NTP-is-the-only-True-Treasury/NTP-Architecture.jpg" | absolute_url }})

NIST actually provides access to NTP authentication services to the general public for free.  [You can find out how here](https://www.nist.gov/pml/time-and-frequency-division/time-services/nist-authenticated-ntp-service).  The two NIST NTP servers that provide authentication are  ntp-a.boulder.nst.gov and ntp-b.nist.gov, the same two servers that most hardware clocks use (that I’ve had experience with anyway.)

In the design above a Cisco ASA550 and a Cisco Catalyst 4510 as redundant internal NTP servers.  This is because both support NTP authentication natively.  All systems that natively support NTP authentication and are not part of a Windows domain will reference these two nodes for timekeeping, which in turn securely reference NIST servers over the public WAN.  The Windows domain is situated in the rear of this design as it is the weakest link in the security chain.  A way to fortify NTP communications to the windows domain could be to utilize IPSec to tunnel NTP communications  between the Core Nodes and out-of-band management interfaces on the Domain Controllers.  Assuming multiple DCs, this would be easily accomplished in a virtualized environment either by terminating the tunnel at physical interface adjacent to a dedicated virtual switch used for OOB network management traffic, or by implementing a third-party virtual firewall that supports IPSec tunneling such as Cisco’s Nexus 1000v cloud firewall.  The idea is to not secure to a specific domain controller as it adds an unnecessary level of complexity when the PDC Emulator role migrates to a different DC.  Instead sending unsecured NTP through the common secured OOB management network is indifferent to which DC holds the PDC Emulator role.

Microsoft’s implementation of NTP authentication within a Windows Domain is solid enough to be trusted and it is unfortunate that is isn’t very interoperable.  That being said, there are many benefits to integrate systems with Active Directory aside from secured NTP communications, even OS X, UNIX, and Linux systems.  The rule is, if you can join it to AD you should do so (unless you have an overwhelming reason to not.)

## Three, Leverage NTP authentication in any systems that will support it.

If the small hints of the catastrophe mentioned above are not enough to convince you that NTP can pose a serious risk to your environment if left unmanaged, the Cheshire Cat (from the 2600 community if I’m not mistaken) has written a [nice security analysis of NTP found here.](https://www.eecis.udel.edu/~mills/security.html)

If you’re looking at your NTP design now, I hope this post has pointed out some often unconsidered design issues and helps you to spend time more securely.  I may follow up with a post on device specific configurations; Cisco, HP Procurve L2/L3 device configs, ASA configurations, OS X & Linux configs, and Windows batch, powershell, and group policy scripts and settings.  All of these are easily googled for, so then again, I may not.

There are also considerations that need to be made regarding time services in virtualized environments, in as far as hypervisor and guest timekeeping.  For a good article regarding timekeeping in Microsoft’s Hyper-V see [this blog post by Ben Armstrong](https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/11/19/time-synchronization-in-hyper-v/), the Hyper-V program manager.  The problems outlined by Ben are applicable not only to hyper-v, but VMware, Citrix, Xen or any other virtualization platform as well.