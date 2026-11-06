# Network Topology

## Architecture Overview

The lab implements a segmented enterprise network using a MikroTik CHR router and a Cisco Layer 2 switch.

The infrastructure is deployed in a virtualized environment using VMware Workstation and GNS3.

## Main Components

- **MikroTik CHR:** Routing, inter-VLAN routing, DHCP, NAT, firewall and WireGuard VPN.
- **Cisco IOU Layer 2 Switch:** VLAN management, 802.1Q trunking and Layer 2 security.
- **Windows Client:** Used to test network connectivity and remote VPN access.
- **GNS3 and VMware Workstation:** Virtual lab environment.

## Logical Network Flow

1. The WAN interface (`ether1`) connects to the upstream network.
2. The MikroTik router provides routing and security between network segments.
3. The trunk link carries VLAN traffic between the MikroTik router and Cisco switch.
4. The switch connects devices to their assigned VLANs.
5. Remote access is provided through a WireGuard VPN tunnel.

## Network Segments

- VLAN 10 — ADMIN
- VLAN 20 — USERS
- VLAN 30 — SERVERS
- VLAN 100 — UNUSED
- VLAN 999 — NATIVE

## Remote Access

The WireGuard VPN allows a remote Windows client to reach the MikroTik router and the internal VLAN networks.

The VPN uses split tunneling: Internet traffic continues to use the client's regular Internet connection.
