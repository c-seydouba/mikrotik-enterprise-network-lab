# MikroTik Enterprise Network Lab

An enterprise network infrastructure lab built with MikroTik CHR and Cisco Layer 2 switching, featuring VLAN segmentation, DHCP, firewall policies, network security mechanisms, and remote access through WireGuard VPN.

## Project Overview

This project demonstrates the design and implementation of a segmented enterprise network using MikroTik RouterOS and a Cisco Layer 2 switch in a virtualized environment.

The lab focuses on network administration, traffic segmentation, access control, infrastructure security, and secure remote connectivity.

## Objectives

- Design and implement a segmented enterprise network.
- Configure VLANs and 802.1Q trunking.
- Deploy DHCP services for multiple VLANs.
- Configure NAT and Internet connectivity.
- Implement firewall filtering policies between network segments.
- Apply Layer 2 security mechanisms.
- Establish secure remote access using WireGuard VPN.
- Validate network connectivity and security policies.

## Lab Environment

| Component | Technology |
|---|---|
| Router | MikroTik CHR |
| Switching | Cisco IOU Layer 2 |
| Virtualization | VMware Workstation |
| Network simulation | GNS3 |
| VPN | WireGuard |
| Client OS | Windows |

## Network Segmentation

| VLAN ID | Name | Purpose |
|---|---|---|
| 10 | ADMIN | Network administration |
| 20 | USERS | User devices |
| 30 | SERVERS | Server infrastructure |
| 100 | UNUSED | Unused switch ports |
| 999 | NATIVE | Native VLAN for trunking |

## Key Implementations

- MikroTik RouterOS configuration
- VLAN interfaces and inter-VLAN routing
- DHCP services
- NAT and Internet access
- Firewall filtering and network segmentation
- Cisco 802.1Q trunk configuration
- DHCP Snooping
- Port Security
- BPDU Guard
- WireGuard remote-access VPN

## Project Validation

Connectivity and routing were tested between the VPN client and the MikroTik router, including access to the three network segments.

Additional validation covered DHCP operation, Internet connectivity, and firewall policies.

## Project Status

**Implementation completed — documentation in progress.**

## Author

**Seydou BA**

- GitHub: [c-seydouba](https://github.com/c-seydouba)
- LinkedIn: [Seydou BA](https://linkedin.com/in/seydouba-infra)
