# MikroTik CHR Configuration

Configuration of the `MT-R1` router (MikroTik CHR, RouterOS 7.23.8). The full exported script is [`mikrotik-project6.rsc`](mikrotik-project6.rsc), generated with `/export hide-sensitive` so it contains no private keys or passwords.

## Table of Contents

- [Role of the Router](#role-of-the-router)
- [Interfaces and Addressing](#interfaces-and-addressing)
- [DHCP](#dhcp)
- [NAT](#nat)
- [Firewall](#firewall)
- [WireGuard VPN](#wireguard-vpn)
- [Management Hardening](#management-hardening)

## Role of the Router

`MT-R1` provides all Layer 3 services of the lab: inter-VLAN routing, DHCP, NAT to the Internet, a default-deny firewall and the WireGuard VPN server. The Cisco switch only handles Layer 2 (see [Cisco Switch Configuration](../cisco-switch/README.md)).

## Interfaces and Addressing

| Interface | Role | Address |
|---|---|---|
| `ether1` | WAN | DHCP client |
| `ether2` | Management LAN | 192.168.10.1/24 |
| `ether3` | 802.1Q trunk to the Cisco switch | No IP address, carries the VLAN interfaces |
| `vlan10-admin` | ADMIN (VLAN 10) | 192.168.20.1/24 |
| `vlan20-users` | USERS (VLAN 20) | 192.168.30.1/24 |
| `vlan30-servers` | SERVERS (VLAN 30) | 192.168.40.1/24 |
| `wg-remote` | WireGuard VPN | 10.10.10.1/24 |

The VLAN interfaces are created on `ether3` with VLAN IDs 10, 20 and 30. The subnet numbering is intentionally independent of the VLAN IDs.

## DHCP

| DHCP server | Interface | Pool | Network |
|---|---|---|---|
| `dhcp1` | `ether2` | 192.168.10.100 - 200 | 192.168.10.0/24 |
| `dhcp-admin` | `vlan10-admin` | 192.168.20.100 - 200 | 192.168.20.0/24 |
| `dhcp-users` | `vlan20-users` | 192.168.30.100 - 200 | 192.168.30.0/24 |
| `dhcp-servers` | `vlan30-servers` | 192.168.40.100 - 200 | 192.168.40.0/24 |

Each network hands out its own router as gateway and `1.1.1.1` / `8.8.8.8` as DNS servers. The WAN address is obtained by a DHCP client on `ether1`.

## NAT

A single source NAT rule masquerades all outgoing traffic on `ether1`, which gives the internal networks Internet access.

## Firewall

The firewall is default-deny in both chains. **Rule order matters**: RouterOS applies the first matching rule, so specific accepts come before the broad drops.

### Input chain (traffic to the router)

In order:

1. Accept DHCP requests (UDP 67) from the ADMIN, USERS and SERVERS interfaces. This comes first so clients can still get a lease even though USERS and SERVERS are blocked afterwards.
2. Accept established and related connections.
3. Drop all traffic from USERS and SERVERS to the router.
4. Accept everything from `ether2` (management LAN).
5. Accept the WireGuard port (UDP 13231) from `ether1`.
6. Drop new connections arriving from `ether1` (WAN).
7. Accept traffic from the ADMIN VLAN and from `wg-remote`.
8. Final `drop` for everything else.

### Forward chain (traffic through the router)

In order:

1. Accept established and related connections.
2. Drop invalid connections.
3. Accept all traffic from ADMIN.
4. Drop USERS to ADMIN and USERS to SERVERS.
5. Drop SERVERS to ADMIN and SERVERS to USERS.
6. Accept USERS and SERVERS to the Internet (`ether1`).
7. Drop new connections arriving from `ether1` (WAN).
8. Drop everything going out through `wg-remote`. ADMIN traffic and replies to VPN-initiated connections are already accepted above, so only ADMIN can open connections towards the VPN client.
9. Accept all traffic from `wg-remote` (VPN client, same privileges as ADMIN).
10. Accept all traffic from `ether2` (management LAN).
11. Final `drop` for everything else, which blocks USERS and SERVERS from reaching the management LAN and the VPN client.

Resulting policy:

| From \ To | ADMIN | USERS | SERVERS | Mgmt LAN | VPN | Internet | Router |
|---|---|---|---|---|---|---|---|
| ADMIN | n/a | Allowed | Allowed | Allowed | Allowed | Allowed | Allowed |
| USERS | Blocked | n/a | Blocked | Blocked | Blocked | Allowed | Blocked |
| SERVERS | Blocked | Blocked | n/a | Blocked | Blocked | Allowed | Blocked |
| Mgmt LAN | Allowed | Allowed | Allowed | n/a | Blocked | Allowed | Allowed |
| VPN client | Allowed | Allowed | Allowed | Allowed | n/a | Allowed | Allowed |

## WireGuard VPN

| Parameter | Value |
|---|---|
| Interface | `wg-remote` |
| Listen port | UDP 13231 |
| MTU | 1420 |
| Server address | 10.10.10.1/24 |
| Peer | `peer2` (Windows-Client1), allowed address 10.10.10.2/32 |

Only the peer public key appears in the export. The interface private key is never included by `hide-sensitive`.

## Management Hardening

- `ftp`, `telnet`, `www`, `reverse-proxy`, `api` and `api-ssl` services disabled.
- `winbox` and `ssh` restricted to 192.168.10.0/24 (management LAN), 192.168.20.0/24 (ADMIN) and 10.10.10.0/24 (VPN).
- MAC-Server and MAC-Winbox disabled on all interfaces.
- Neighbor discovery disabled on all interfaces.
- Router identity set to `MT-R1`.
