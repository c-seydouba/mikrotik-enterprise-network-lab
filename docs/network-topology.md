# Network Topology

## Architecture Overview

The lab implements a segmented enterprise network using a MikroTik CHR router (`MT-R1`) and a Cisco Layer 2 switch (`SW1`).

The infrastructure is deployed in a virtualized environment using VMware Workstation and GNS3. The diagram is available in the [main README](../README.md#network-architecture) and in the [Topology Diagram](topology-diagram.md).

## Main Components

- **MikroTik CHR (`MT-R1`):** inter-VLAN routing, DHCP, NAT, firewall and WireGuard VPN.
- **Cisco IOU Layer 2 switch (`SW1`):** VLAN management, 802.1Q trunking and Layer 2 security.
- **VPCS hosts:** one test host per VLAN, used to validate DHCP, connectivity and isolation.
- **Windows client:** used to test remote VPN access.
- **GNS3 and VMware Workstation:** virtual lab environment.

## Connections

| From | To | Type |
|---|---|---|
| `MT-R1` `ether1` | Upstream network | WAN, addressed by DHCP, NAT masquerade |
| `MT-R1` `ether2` | Management LAN (192.168.10.0/24) | Management access |
| `MT-R1` `ether3` | `SW1` `Ethernet0/0` | 802.1Q trunk (VLANs 10, 20, 30, native 999) |
| `SW1` `Ethernet0/1` | ADMIN host | Access port, VLAN 10 |
| `SW1` `Ethernet0/2` | USERS host | Access port, VLAN 20 |
| `SW1` `Ethernet0/3` | SERVERS host | Access port, VLAN 30 |
| `SW1` `Ethernet1/0` to `Ethernet3/3` | Nothing | Shut down, VLAN 100 |
| Windows client | `MT-R1` `wg-remote` | WireGuard tunnel (UDP 13231) |

## Logical Network Flow

1. The WAN interface (`ether1`) connects to the upstream network and gives the internal networks Internet access through NAT.
2. The MikroTik router provides routing and security between network segments.
3. The trunk on `ether3` carries the VLAN traffic between the router and the switch. The router has one interface per VLAN on this trunk.
4. The switch connects devices to their assigned VLANs.
5. The management LAN on `ether2` is directly attached to the router.
6. Remote access is provided through a WireGuard VPN tunnel.

## Network Segments

| Segment | Network | Role |
|---|---|---|
| VLAN 10 - ADMIN | 192.168.20.0/24 | Administration, full access to the internal networks |
| VLAN 20 - USERS | 192.168.30.0/24 | User devices, Internet access only |
| VLAN 30 - SERVERS | 192.168.40.0/24 | Server infrastructure, Internet access only |
| Management LAN | 192.168.10.0/24 | Router management and lab access |
| VLAN 100 - UNUSED | n/a | Shut down switch ports |
| VLAN 999 - NATIVE | n/a | Native VLAN of the trunk |

USERS and SERVERS cannot reach each other, ADMIN, the management LAN, the VPN client or the router. See the [traffic matrix](../README.md#security-implementation) for the complete policy.

## Remote Access

The WireGuard VPN allows a remote Windows client (`10.10.10.2`) to reach the MikroTik router and the internal networks, with the same privileges as ADMIN.

The VPN uses split tunneling: Internet traffic continues to use the client's regular Internet connection.
