---
layout: post
title: "Update ESXi 6.0 to 6.7 via CLI"
author: David Midlo
tags: [ ESXi Server, VMware, CLI ]
categories: [ fieldnotes, Engineering, Infrastructure]
---
# Problem:
ESXi version is out of date, Need to update ESXi from 6.0 to 6.7

# Solution:
#### Check Version

Checking the version is easy as pie.  Just open your vSphere client and you'll see it persisently along the top.

To enable ssh, go to the configuration tab

![Check ESX Version]({{ "assets/images/posts/update-esxi-6.0-to-6.7-via-cli/check-version-and-enable-ssh.png" | absolute_url }})

#### Enable SSH

Under Software settings select Security Profile

![Enable SSH on ESXi]({{ "assets/images/posts/update-esxi-6.0-to-6.7-via-cli/enable-ssh.png" | absolute_url }})

#### Open Security Profile Properties

![Open ESXi Security Profile Properties]({{ "assets/images/posts/update-esxi-6.0-to-6.7-via-cli/open-security-profile-properties.png" | absolute_url }})

#### Located the SSH service

Locate the SSH service and click 'Options'

![Locate ESXi SSH Service and Click Options]({{ "assets/images/posts/update-esxi-6.0-to-6.7-via-cli/located-the-ssh-service.png" | absolute_url }})

#### Start the SSH Service 

![Start the ESXi SSH Service]({{ "assets/images/posts/update-esxi-6.0-to-6.7-via-cli/start-the-ssh-service-.png" | absolute_url }})

#### Connect to SSH
{% highlight shell %}
{% raw %}
$ ssh -l root 192.168.100.14

The authenticity of host '192.168.100.14 (192.168.100.14)' can not be established.
RSA key fingerprint is SHA256:rPLqIVf4ns1u1T+t1Q9/STC4lubU50HiU8ccc2G5TJ0.
Are you sure you want to continue connecting (yes/no)? yes
Password: {enter you password}
{% endraw %}
{% endhighlight %}


#### Check the Version via CLI

{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli system version get

   Product: VMware ESXi
   Version: 6.0.0
   Build: Releasebuild-3029758
   Update: 1
   Patch: 17
{% endraw %}
{% endhighlight %}


#### Enable HTTP Client Firewall Rule

{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli network firewall ruleset set -e true -r httpClient
{% endraw %}
{% endhighlight %}

#### Check VMware Repository for available versions

{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli software sources profile list -d https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml | grep -i ESXi-6
{% endraw %}
{% endhighlight %}

- Current Release is ESXi 6.7 GA

check the release notes: [vSphere ESXii vCenter Server 6.7 Release Notes](https://docs.vmware.com/en/VMware-vSphere/6.7/rn/vsphere-esxi-vcenter-server-67-release-notes.html#installupgrade) 

- *release notes state there are a number of unsupported CPU processors as compared to ESXi 6.5*

#### Check The CPU Model against the list

{% highlight shell %}
{% raw %}
[root@ESXi:~] vim-cmd hostsvc/hostsummary | grep cpuModel

      cpuModel = "Intel(R) Xeon(R) CPU E31220 @ 3.10GHz",
{% endraw %}
{% endhighlight %}
- Looks like we're in the clear

#### Check Repo for Available 6.7 profiles

{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli software sources profile list -d https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml | grep -i ESXi-6.7

ESXi-6.7.0-8169922-no-tools       VMware, Inc.  PartnerSupported
ESXi-6.7.0-8169922-standard       VMware, Inc.  PartnerSupported
{% endraw %}
{% endhighlight %}

- we're going to go with the standard profile

#### Install the latest Profile
{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli software profile update -p ESXi-6.7.0-8169922-standard -d https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml
{% endraw %}
{% endhighlight %}


- *There's no progress bar here or anything to indicate forward momentum. Remeber that this is being downloaded and then installed, this can take some time. Be patient.*

#### Review Update Logged Output
{% highlight shell %}
{% raw %}
Update Result

   Message: The update completed successfully, but the system needs to be rebooted for the changes to be effective.

   Reboot Required: true

   VIBs Installed: VMW_bootbank_ata-libata-92_3.00.9.2-16vmw.670.0.0.8169922, VMW_bootbank_ata-pata-amd_0.3.10-3vmw.670.0.0.8169922, VMW_bootbank_ata-pata-atiixp_0.4.6-4vmw.670.0.0.8169922, VMW_bootbank_ata-pata-cmd64x_0.2.5-3vmw.670.0.0.8169922, VMW_bootbank_ata-pata-hpt3x2n_0.3.4-3vmw.670.0.0.8169922, VMW_bootbank_ata-pata-pdc2027x_1.0-3vmw.670.0.0.8169922, VMW_bootbank_ata-pata-serverworks_0.4.3-3vmw.670.0.0.8169922, VMW_bootbank_ata-pata-sil680_0.4.8-3vmw.670.0.0.8169922, VMW_bootbank_ata-pata-via_0.3.3-2vmw.670.0.0.8169922, VMW_bootbank_block-cciss_3.6.14-10vmw.670.0.0.8169922, VMW_bootbank_bnxtnet_20.6.101.7-11vmw.670.0.0.8169922, VMW_bootbank_brcmfcoe_11.4.1078.0-8vmw.670.0.0.8169922, VMW_bootbank_char-random_1.0-3vmw.670.0.0.8169922, VMW_bootbank_ehci-ehci-hcd_1.0-4vmw.670.0.0.8169922, VMW_bootbank_elxiscsi_11.4.1174.0-2vmw.670.0.0.8169922, VMW_bootbank_elxnet_11.4.1094.0-5vmw.670.0.0.8169922, VMW_bootbank_hid-hid_1.0-3vmw.670.0.0.8169922, VMW_bootbank_i40en_1.3.1-18vmw.670.0.0.8169922, VMW_bootbank_iavmd_1.2.0.1011-2vmw.670.0.0.8169922, VMW_bootbank_igbn_0.1.0.0-15vmw.670.0.0.8169922, VMW_bootbank_ima-qla4xxx_2.02.18-1vmw.670.0.0.8169922, VMW_bootbank_ipmi-ipmi-devintf_39.1-4vmw.670.0.0.8169922, VMW_bootbank_ipmi-ipmi-msghandler_39.1-4vmw.670.0.0.8169922, VMW_bootbank_ipmi-ipmi-si-drv_39.1-4vmw.670.0.0.8169922, VMW_bootbank_iser_1.0.0.0-1vmw.670.0.0.8169922, VMW_bootbank_ixgben_1.4.1-11vmw.670.0.0.8169922, VMW_bootbank_lpfc_11.4.33.1-6vmw.670.0.0.8169922, VMW_bootbank_lpnic_11.4.59.0-1vmw.670.0.0.8169922, VMW_bootbank_lsi-mr3_7.702.13.00-4vmw.670.0.0.8169922, VMW_bootbank_lsi-msgpt2_20.00.04.00-4vmw.670.0.0.8169922, VMW_bootbank_lsi-msgpt35_03.00.01.00-10vmw.670.0.0.8169922, VMW_bootbank_lsi-msgpt3_16.00.01.00-1vmw.670.0.0.8169922, VMW_bootbank_misc-cnic-register_1.78.75.v60.7-1vmw.670.0.0.8169922, VMW_bootbank_misc-drivers_6.7.0-0.0.8169922, VMW_bootbank_mtip32xx-native_3.9.6-1vmw.670.0.0.8169922, VMW_bootbank_ne1000_0.8.3-4vmw.670.0.0.8169922, VMW_bootbank_nenic_1.0.11.0-1vmw.670.0.0.8169922, VMW_bootbank_net-bnx2_2.2.4f.v60.10-2vmw.670.0.0.8169922, VMW_bootbank_net-bnx2x_1.78.80.v60.12-2vmw.670.0.0.8169922, VMW_bootbank_net-cdc-ether_1.0-3vmw.670.0.0.8169922, VMW_bootbank_net-cnic_1.78.76.v60.13-2vmw.670.0.0.8169922, VMW_bootbank_net-e1000_8.0.3.1-5vmw.670.0.0.8169922, VMW_bootbank_net-e1000e_3.2.2.1-2vmw.670.0.0.8169922, VMW_bootbank_net-enic_2.1.2.38-2vmw.670.0.0.8169922, VMW_bootbank_net-fcoe_1.0.29.9.3-7vmw.670.0.0.8169922, VMW_bootbank_net-forcedeth_0.61-2vmw.670.0.0.8169922, VMW_bootbank_net-igb_5.0.5.1.1-5vmw.670.0.0.8169922, VMW_bootbank_net-ixgbe_3.7.13.7.14iov-20vmw.670.0.0.8169922, VMW_bootbank_net-libfcoe-92_1.0.24.9.4-8vmw.670.0.0.8169922, VMW_bootbank_net-mlx4-core_1.9.7.0-1vmw.670.0.0.8169922, VMW_bootbank_net-mlx4-en_1.9.7.0-1vmw.670.0.0.8169922, VMW_bootbank_net-nx-nic_5.0.621-5vmw.670.0.0.8169922, VMW_bootbank_net-tg3_3.131d.v60.4-2vmw.670.0.0.8169922, VMW_bootbank_net-usbnet_1.0-3vmw.670.0.0.8169922, VMW_bootbank_net-vmxnet3_1.1.3.0-3vmw.670.0.0.8169922, VMW_bootbank_nhpsa_2.0.22-1vmw.670.0.0.8169922, VMW_bootbank_nmlx4-core_3.17.9.12-1vmw.670.0.0.8169922, VMW_bootbank_nmlx4-en_3.17.9.12-1vmw.670.0.0.8169922, VMW_bootbank_nmlx4-rdma_3.17.9.12-1vmw.670.0.0.8169922, VMW_bootbank_nmlx5-core_4.17.9.12-1vmw.670.0.0.8169922, VMW_bootbank_nmlx5-rdma_4.17.9.12-1vmw.670.0.0.8169922, VMW_bootbank_ntg3_4.1.3.0-1vmw.670.0.0.8169922, VMW_bootbank_nvme_1.2.1.34-1vmw.670.0.0.8169922, VMW_bootbank_nvmxnet3-ens_2.0.0.21-1vmw.670.0.0.8169922, VMW_bootbank_nvmxnet3_2.0.0.27-1vmw.670.0.0.8169922, VMW_bootbank_ohci-usb-ohci_1.0-3vmw.670.0.0.8169922, VMW_bootbank_pvscsi_0.1-2vmw.670.0.0.8169922, VMW_bootbank_qcnic_1.0.2.0.4-1vmw.670.0.0.8169922, VMW_bootbank_qedentv_2.0.6.4-8vmw.670.0.0.8169922, VMW_bootbank_qfle3_1.0.50.11-9vmw.670.0.0.8169922, VMW_bootbank_qfle3f_1.0.25.0.2-14vmw.670.0.0.8169922, VMW_bootbank_qfle3i_1.0.2.3.9-3vmw.670.0.0.8169922, VMW_bootbank_qflge_1.1.0.11-1vmw.670.0.0.8169922, VMW_bootbank_sata-ahci_3.0-26vmw.670.0.0.8169922, VMW_bootbank_sata-ata-piix_2.12-10vmw.670.0.0.8169922, VMW_bootbank_sata-sata-nv_3.5-4vmw.670.0.0.8169922, VMW_bootbank_sata-sata-promise_2.12-3vmw.670.0.0.8169922, VMW_bootbank_sata-sata-sil24_1.1-1vmw.670.0.0.8169922, VMW_bootbank_sata-sata-sil_2.3-4vmw.670.0.0.8169922, VMW_bootbank_sata-sata-svw_2.3-3vmw.670.0.0.8169922, VMW_bootbank_scsi-aacraid_1.1.5.1-9vmw.670.0.0.8169922, VMW_bootbank_scsi-adp94xx_1.0.8.12-6vmw.670.0.0.8169922, VMW_bootbank_scsi-aic79xx_3.1-6vmw.670.0.0.8169922, VMW_bootbank_scsi-bnx2fc_1.78.78.v60.8-1vmw.670.0.0.8169922, VMW_bootbank_scsi-bnx2i_2.78.76.v60.8-1vmw.670.0.0.8169922, VMW_bootbank_scsi-fnic_1.5.0.45-3vmw.670.0.0.8169922, VMW_bootbank_scsi-hpsa_6.0.0.84-3vmw.670.0.0.8169922, VMW_bootbank_scsi-ips_7.12.05-4vmw.670.0.0.8169922, VMW_bootbank_scsi-iscsi-linux-92_1.0.0.2-3vmw.670.0.0.8169922, VMW_bootbank_scsi-libfc-92_1.0.40.9.3-5vmw.670.0.0.8169922, VMW_bootbank_scsi-megaraid-mbox_2.20.5.1-6vmw.670.0.0.8169922, VMW_bootbank_scsi-megaraid-sas_6.603.55.00-2vmw.670.0.0.8169922, VMW_bootbank_scsi-megaraid2_2.00.4-9vmw.670.0.0.8169922, VMW_bootbank_scsi-mpt2sas_19.00.00.00-2vmw.670.0.0.8169922, VMW_bootbank_scsi-mptsas_4.23.01.00-10vmw.670.0.0.8169922, VMW_bootbank_scsi-mptspi_4.23.01.00-10vmw.670.0.0.8169922, VMW_bootbank_scsi-qla4xxx_5.01.03.2-7vmw.670.0.0.8169922, VMW_bootbank_shim-iscsi-linux-9-2-1-0_6.7.0-0.0.8169922, VMW_bootbank_shim-iscsi-linux-9-2-2-0_6.7.0-0.0.8169922, VMW_bootbank_shim-libata-9-2-1-0_6.7.0-0.0.8169922, VMW_bootbank_shim-libata-9-2-2-0_6.7.0-0.0.8169922, VMW_bootbank_shim-libfc-9-2-1-0_6.7.0-0.0.8169922, VMW_bootbank_shim-libfc-9-2-2-0_6.7.0-0.0.8169922, VMW_bootbank_shim-libfcoe-9-2-1-0_6.7.0-0.0.8169922, VMW_bootbank_shim-libfcoe-9-2-2-0_6.7.0-0.0.8169922, VMW_bootbank_shim-vmklinux-9-2-1-0_6.7.0-0.0.8169922, VMW_bootbank_shim-vmklinux-9-2-2-0_6.7.0-0.0.8169922, VMW_bootbank_shim-vmklinux-9-2-3-0_6.7.0-0.0.8169922, VMW_bootbank_smartpqi_1.0.1.553-10vmw.670.0.0.8169922, VMW_bootbank_uhci-usb-uhci_1.0-3vmw.670.0.0.8169922, VMW_bootbank_usb-storage-usb-storage_1.0-3vmw.670.0.0.8169922, VMW_bootbank_usbcore-usb_1.0-3vmw.670.0.0.8169922, VMW_bootbank_vmkata_0.1-1vmw.670.0.0.8169922, VMW_bootbank_vmkfcoe_1.0.0.0-1vmw.670.0.0.8169922, VMW_bootbank_vmkplexer-vmkplexer_6.7.0-0.0.8169922, VMW_bootbank_vmkusb_0.1-1vmw.670.0.0.8169922, VMW_bootbank_vmw-ahci_1.2.0-6vmw.670.0.0.8169922, VMW_bootbank_xhci-xhci_1.0-3vmw.670.0.0.8169922, VMware_bootbank_cpu-microcode_6.7.0-0.0.8169922, VMware_bootbank_elx-esx-libelxima.so_11.4.1184.0-0.0.8169922, VMware_bootbank_esx-base_6.7.0-0.0.8169922, VMware_bootbank_esx-dvfilter-generic-fastpath_6.7.0-0.0.8169922, VMware_bootbank_esx-ui_1.25.0-7872652, VMware_bootbank_esx-xserver_6.7.0-0.0.8169922, VMware_bootbank_lsu-hp-hpsa-plugin_2.0.0-13vmw.670.0.0.8169922, VMware_bootbank_lsu-lsi-lsi-mr3-plugin_1.0.0-12vmw.670.0.0.8169922, VMware_bootbank_lsu-lsi-lsi-msgpt3-plugin_1.0.0-8vmw.670.0.0.8169922, VMware_bootbank_lsu-lsi-megaraid-sas-plugin_1.0.0-9vmw.670.0.0.8169922, VMware_bootbank_lsu-lsi-mpt2sas-plugin_2.0.0-7vmw.670.0.0.8169922, VMware_bootbank_native-misc-drivers_6.7.0-0.0.8169922, VMware_bootbank_qlnativefc_3.0.1.0-5vmw.670.0.0.8169922, VMware_bootbank_rste_2.0.2.0088-7vmw.670.0.0.8169922, VMware_bootbank_vmware-esx-esxcli-nvme-plugin_1.2.0.32-0.0.8169922, VMware_bootbank_vsan_6.7.0-0.0.8169922, VMware_bootbank_vsanhealth_6.7.0-0.0.8169922, VMware_locker_tools-light_10.2.0.7253323-8169922

   VIBs Removed: VMWARE_bootbank_mtip32xx-native_3.8.5-1vmw.600.0.0.2494585, VMware_bootbank_ata-pata-amd_0.3.10-3vmw.600.0.0.2494585, VMware_bootbank_ata-pata-atiixp_0.4.6-4vmw.600.0.0.2494585, VMware_bootbank_ata-pata-cmd64x_0.2.5-3vmw.600.0.0.2494585, VMware_bootbank_ata-pata-hpt3x2n_0.3.4-3vmw.600.0.0.2494585, VMware_bootbank_ata-pata-pdc2027x_1.0-3vmw.600.0.0.2494585, VMware_bootbank_ata-pata-serverworks_0.4.3-3vmw.600.0.0.2494585, VMware_bootbank_ata-pata-sil680_0.4.8-3vmw.600.0.0.2494585, VMware_bootbank_ata-pata-via_0.3.3-2vmw.600.0.0.2494585, VMware_bootbank_block-cciss_3.6.14-10vmw.600.0.0.2494585, VMware_bootbank_cpu-microcode_6.0.0-0.0.2494585, VMware_bootbank_ehci-ehci-hcd_1.0-3vmw.600.0.0.2494585, VMware_bootbank_elxnet_10.2.309.6v-1vmw.600.0.0.2494585, VMware_bootbank_emulex-esx-elxnetcli_10.2.309.6v-0.0.2494585, VMware_bootbank_esx-base_6.0.0-1.17.3029758, VMware_bootbank_esx-dvfilter-generic-fastpath_6.0.0-0.0.2494585, VMware_bootbank_esx-tboot_6.0.0-0.0.2494585, VMware_bootbank_esx-xserver_6.0.0-0.0.2494585, VMware_bootbank_ima-qla4xxx_2.02.18-1vmw.600.0.0.2494585, VMware_bootbank_ipmi-ipmi-devintf_39.1-4vmw.600.0.0.2494585, VMware_bootbank_ipmi-ipmi-msghandler_39.1-4vmw.600.0.0.2494585, VMware_bootbank_ipmi-ipmi-si-drv_39.1-4vmw.600.0.0.2494585, VMware_bootbank_lpfc_10.2.309.8-2vmw.600.0.0.2494585, VMware_bootbank_lsi-mr3_6.605.08.00-7vmw.600.1.17.3029758, VMware_bootbank_lsi-msgpt3_06.255.12.00-8vmw.600.1.17.3029758, VMware_bootbank_lsu-hp-hpsa-plugin_1.0.0-1vmw.600.0.0.2494585, VMware_bootbank_lsu-lsi-lsi-mr3-plugin_1.0.0-2vmw.600.0.11.2809209, VMware_bootbank_lsu-lsi-lsi-msgpt3-plugin_1.0.0-1vmw.600.0.0.2494585, VMware_bootbank_lsu-lsi-megaraid-sas-plugin_1.0.0-2vmw.600.0.11.2809209, VMware_bootbank_lsu-lsi-mpt2sas-plugin_1.0.0-4vmw.600.1.17.3029758, VMware_bootbank_misc-cnic-register_1.78.75.v60.7-1vmw.600.0.0.2494585, VMware_bootbank_misc-drivers_6.0.0-1.17.3029758, VMware_bootbank_net-bnx2_2.2.4f.v60.10-1vmw.600.0.0.2494585, VMware_bootbank_net-bnx2x_1.78.80.v60.12-1vmw.600.0.0.2494585, VMware_bootbank_net-cnic_1.78.76.v60.13-2vmw.600.0.0.2494585, VMware_bootbank_net-e1000_8.0.3.1-5vmw.600.0.0.2494585, VMware_bootbank_net-e1000e_2.5.4-6vmw.600.0.0.2494585, VMware_bootbank_net-enic_2.1.2.38-2vmw.600.0.0.2494585, VMware_bootbank_net-forcedeth_0.61-2vmw.600.0.0.2494585, VMware_bootbank_net-igb_5.0.5.1.1-5vmw.600.0.0.2494585, VMware_bootbank_net-ixgbe_3.7.13.7.14iov-20vmw.600.0.0.2494585, VMware_bootbank_net-mlx4-core_1.9.7.0-1vmw.600.0.0.2494585, VMware_bootbank_net-mlx4-en_1.9.7.0-1vmw.600.0.0.2494585, VMware_bootbank_net-nx-nic_5.0.621-5vmw.600.0.0.2494585, VMware_bootbank_net-tg3_3.131d.v60.4-1vmw.600.0.0.2494585, VMware_bootbank_net-vmxnet3_1.1.3.0-3vmw.600.0.0.2494585, VMware_bootbank_nmlx4-core_3.0.0.0-1vmw.600.0.0.2494585, VMware_bootbank_nmlx4-en_3.0.0.0-1vmw.600.0.0.2494585, VMware_bootbank_nmlx4-rdma_3.0.0.0-1vmw.600.0.0.2494585, VMware_bootbank_nvme_1.0e.0.35-1vmw.600.1.17.3029758, VMware_bootbank_ohci-usb-ohci_1.0-3vmw.600.0.0.2494585, VMware_bootbank_qlnativefc_2.0.12.0-5vmw.600.0.0.2494585, VMware_bootbank_rste_2.0.2.0088-4vmw.600.0.0.2494585, VMware_bootbank_sata-ahci_3.0-22vmw.600.1.17.3029758, VMware_bootbank_sata-ata-piix_2.12-10vmw.600.0.0.2494585, VMware_bootbank_sata-sata-nv_3.5-4vmw.600.0.0.2494585, VMware_bootbank_sata-sata-promise_2.12-3vmw.600.0.0.2494585, VMware_bootbank_sata-sata-sil24_1.1-1vmw.600.0.0.2494585, VMware_bootbank_sata-sata-sil_2.3-4vmw.600.0.0.2494585, VMware_bootbank_sata-sata-svw_2.3-3vmw.600.0.0.2494585, VMware_bootbank_scsi-aacraid_1.1.5.1-9vmw.600.0.0.2494585, VMware_bootbank_scsi-adp94xx_1.0.8.12-6vmw.600.0.0.2494585, VMware_bootbank_scsi-aic79xx_3.1-5vmw.600.0.0.2494585, VMware_bootbank_scsi-bnx2fc_1.78.78.v60.8-1vmw.600.0.0.2494585, VMware_bootbank_scsi-bnx2i_2.78.76.v60.8-1vmw.600.0.11.2809209, VMware_bootbank_scsi-fnic_1.5.0.45-3vmw.600.0.0.2494585, VMware_bootbank_scsi-hpsa_6.0.0.44-4vmw.600.0.0.2494585, VMware_bootbank_scsi-ips_7.12.05-4vmw.600.0.0.2494585, VMware_bootbank_scsi-megaraid-mbox_2.20.5.1-6vmw.600.0.0.2494585, VMware_bootbank_scsi-megaraid-sas_6.603.55.00-2vmw.600.0.0.2494585, VMware_bootbank_scsi-megaraid2_2.00.4-9vmw.600.0.0.2494585, VMware_bootbank_scsi-mpt2sas_19.00.00.00-1vmw.600.0.0.2494585, VMware_bootbank_scsi-mptsas_4.23.01.00-9vmw.600.0.0.2494585, VMware_bootbank_scsi-mptspi_4.23.01.00-9vmw.600.0.0.2494585, VMware_bootbank_scsi-qla4xxx_5.01.03.2-7vmw.600.0.0.2494585, VMware_bootbank_uhci-usb-uhci_1.0-3vmw.600.0.0.2494585, VMware_bootbank_vsanhealth_6.0.0-3000000.2.0.1.17.2972216, VMware_bootbank_xhci-xhci_1.0-2vmw.600.1.17.3029758, VMware_locker_tools-light_6.0.0-1.17.3029758

   VIBs Skipped:
{% endraw %}
{% endhighlight %}


#### Disable the HTTP Client Firewall Rule
{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli network firewall ruleset set -e false -r httpClient
{% endraw %}
{% endhighlight %}


#### List Running Guest VMs
{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli vm process list

DC
   World ID: 35264
   Process ID: 0
   VMX Cartel ID: 35263
   UUID: 56 4d c9 46 97 55 57 80-8b 19 a6 30 88 ba 84 59
   Display Name: Camp-DC
   Config File: /vmfs/volumes/4faac78b-87d2b646-3436-001018da65d2/DC/DC.vmx

Unifi-Controller
   World ID: 35508
   Process ID: 0
   VMX Cartel ID: 35507
   UUID: 56 4d 47 03 43 e4 53 09-f4 79 cc 49 ac 7f ae c4
   Display Name: Unifi-Controller
   Config File: /vmfs/volumes/4faac78b-87d2b646-3436-001018da65d2/Unifi-Controller/Unifi-Controller.vmx
{% endraw %}
{% endhighlight %}


#### Gracefully Shutdown Running Guest VMs
{% highlight shell %}
{% raw %}
[root@ESXi:~] esxcli vm process kill --type=soft --world-id=35508

[root@ESXi:~] esxcli vm process kill --type=soft --world-id=35264
{% endraw %}
{% endhighlight %}


#### Reboot ESXi host
{% highlight shell %}
{% raw %}
[root@ESXi:~] reboot
{% endraw %}
{% endhighlight %}


#### Reconnect Via HTTPS in a browser

`https://192.168.100.14`
![Reconnect to ESXi via HTTPs in a Browser]({{ "assets/images/posts/update-esxi-6.0-to-6.7-via-cli/reconnect-via-https-in-a-browser.png" | absolute_url }})

#### Update VMware tools on Virtual Machines
This is the next step in the process, but will be convered in a separate field note.

# References:
- [Downloading and licensing vSphere Hypervisor](https://kb.vmware.com/s/article/2107518)
- [How to Upgrade ESXi 6.0 to 6.5 via CLI](https://www.vladan.fr/how-to-upgrade-esxi-6-0-to-6-5-via-cli-on-line/)
- [Determining VMware Software Version and Build Number ](https://kb.vmware.com/s/article/392)
- [esxcli system Commands](https://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.vcli.ref.doc_50%2Fesxcli_system.html)
- [Build numbers and versions of VMware ESXi/ESX](https://kb.vmware.com/s/article/2143832)
- [vSphere 6.7 Release Notes](https://docs.vmware.com/en/VMware-vSphere/6.7/rn/vsphere-esxi-vcenter-server-67-release-notes.html#installupgrade)
- [How to get ESXi CPU model through command line??](https://communities.vmware.com/thread/565296)
- [VMware Compatibility Guide](https://www.vmware.com/resources/compatibility/detail.php?deviceCategory=cpu&productid=110&vcl=true)
- [Powering on a virtual machine from the command line when the host cannot be managed using vSphere Client](https://kb.vmware.com/s/article/1038043)
- [Unable to power off the virtual machine in an ESXi host](https://kb.vmware.com/s/article/1014165)
- [how to reboot esx host from the command line ?](https://community.spiceworks.com/topic/633646-how-to-reboot-esx-host-from-the-command-line)
