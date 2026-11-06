# IP Addressing Plan

## VLAN Networks

| VLAN | Name | Network | Gateway | DHCP Range |
|---|---|---|---|---|
| 10 | ADMIN | 192.168.20.0/24 | 192.168.20.1 | 192.168.20.100–192.168.20.200 |
| 20 | USERS | 192.168.30.0/24 | 192.168.30.1 | 192.168.30.100–192.168.30.200 |
| 30 | SERVERS | 192.168.40.0/24 | 192.168.40.1 | 192.168.40.100–192.168.40.200 |

## Other Networks

| Interface / Network | Address | Purpose |
|---|---|---|
| ether2 | 192.168.10.1/24 | Original LAN / management access |
| WireGuard | 10.10.10.1/24 | VPN tunnel |
| Windows VPN Client | 10.10.10.2/32 | Remote VPN endpoint |
| ether1 | DHCP assigned | WAN connectivity |

## DNS Configuration

- Primary DNS: 1.1.1.1
- Secondary DNS: 8.8.8.8

## Notes

- VLAN gateways are configured on MikroTik CHR.
- DHCP services are provided by MikroTik.
- VLAN 100 is reserved for unused switch ports.
- VLAN 999 is used as the native VLAN on the trunk.
- The WAN address is dynamically assigned by the upstream network.
