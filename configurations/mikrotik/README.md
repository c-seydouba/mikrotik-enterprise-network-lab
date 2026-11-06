# MikroTik CHR Configuration

## Device Information

- Platform: MikroTik CHR
- Operating System: RouterOS 7.23.8
- Role: Main router and security gateway

## Interface Overview

| Interface | Role |
|---|---|
| ether1 | WAN — DHCP client |
| ether2 | Management LAN — 192.168.10.1/24 |
| VLAN interfaces | ADMIN, USERS and SERVERS |
| wg-remote | WireGuard VPN interface |

## VLAN Configuration

| VLAN ID | Name | Gateway |
|---|---|---|
| 10 | ADMIN | 192.168.20.1/24 |
| 20 | USERS | 192.168.30.1/24 |
| 30 | SERVERS | 192.168.40.1/24 |

VLAN 100 is reserved for unused switch ports, while VLAN 999 is used as the native VLAN on the trunk.

## Network Services

- DHCP server configured for VLANs 10, 20 and 30.
- Inter-VLAN routing enabled on MikroTik.
- NAT masquerading configured for Internet access.
- DNS servers: 1.1.1.1 and 8.8.8.8.
- WAN connectivity obtained dynamically through DHCP.

## Firewall and Security

Firewall policies include:

- Established and related connection handling.
- Invalid connection filtering.
- Access restrictions between VLANs.
- Administrative access to internal network segments.
- Restrictions on access to the router from user and server networks.
- Blocking unsolicited WAN traffic, with an exception for WireGuard.

## WireGuard VPN

- Interface: `wg-remote`
- UDP port: `13231`
- Router VPN address: `10.10.10.1/24`
- Remote Windows client: `10.10.10.2/32`
- VPN mode: Split tunneling

The VPN client was tested successfully against the router and the three internal VLAN gateways.

## Configuration Backup

A RouterOS export (`.rsc`) and a binary backup (`.backup`) were generated.

**Security note:** The binary backup and any configuration containing passwords, private keys, or sensitive information must not be published in this repository. Review and sanitize configuration exports before sharing them.
