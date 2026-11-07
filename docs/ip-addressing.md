# IP Addressing Plan

All gateways and DHCP services are provided by the MikroTik CHR `MT-R1`. The subnet numbering is intentionally independent of the VLAN IDs.

## Address Summary

| Interface | Network | Router address | Purpose |
|---|---|---|---|
| `ether1` | Assigned by the upstream network | DHCP client | WAN |
| `ether2` | 192.168.10.0/24 | 192.168.10.1 | Management LAN |
| `vlan10-admin` | 192.168.20.0/24 | 192.168.20.1 | VLAN 10 - ADMIN |
| `vlan20-users` | 192.168.30.0/24 | 192.168.30.1 | VLAN 20 - USERS |
| `vlan30-servers` | 192.168.40.0/24 | 192.168.40.1 | VLAN 30 - SERVERS |
| `wg-remote` | 10.10.10.0/24 | 10.10.10.1 | WireGuard VPN |

## VLANs

| VLAN | Name | Network | Gateway | DHCP Range |
|---|---|---|---|---|
| 10 | ADMIN | 192.168.20.0/24 | 192.168.20.1 | 192.168.20.100 - 192.168.20.200 |
| 20 | USERS | 192.168.30.0/24 | 192.168.30.1 | 192.168.30.100 - 192.168.30.200 |
| 30 | SERVERS | 192.168.40.0/24 | 192.168.40.1 | 192.168.40.100 - 192.168.40.200 |
| 100 | UNUSED | n/a | n/a | n/a |
| 999 | NATIVE | n/a | n/a | n/a |

VLAN 100 and VLAN 999 carry no IP traffic: VLAN 100 holds the shut down ports of the switch and VLAN 999 is the native VLAN of the trunk.

## Management LAN and VPN

| Network | Address | Details |
|---|---|---|
| Management LAN (`ether2`) | 192.168.10.1/24 | DHCP range 192.168.10.100 - 192.168.10.200, 10-minute lease |
| WireGuard server (`wg-remote`) | 10.10.10.1/24 | VPN gateway, UDP port 13231 |
| Windows VPN client | 10.10.10.2/32 | Remote VPN endpoint, static address |
| WAN (`ether1`) | DHCP assigned | Upstream connectivity |

## DHCP Servers

| DHCP server | Interface | Pool |
|---|---|---|
| `dhcp1` | `ether2` | 192.168.10.100 - 192.168.10.200 |
| `dhcp-admin` | `vlan10-admin` | 192.168.20.100 - 192.168.20.200 |
| `dhcp-users` | `vlan20-users` | 192.168.30.100 - 192.168.30.200 |
| `dhcp-servers` | `vlan30-servers` | 192.168.40.100 - 192.168.40.200 |

## DNS Configuration

The router hands out these DNS servers to DHCP clients on every network:

- Primary DNS: 1.1.1.1
- Secondary DNS: 8.8.8.8

## Notes

- The addresses below `.100` of each network are outside the DHCP pools.
- Each gateway is the router's own address on that segment.
- The WAN address is dynamically assigned by the upstream network.
- The firewall policy between these networks is described in the [MikroTik configuration](../configurations/mikrotik/README.md#firewall).
