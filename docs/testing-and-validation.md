# Testing and Validation

This document describes how the lab was validated: test environment, method, expected behavior, results and evidence.

All tests were run after the firewall hardening (default-deny `input` and `forward` chains) was applied. The matching router configuration is available in [`configurations/mikrotik/mikrotik-project6.rsc`](../configurations/mikrotik/mikrotik-project6.rsc).

## Table of Contents

- [Test Environment](#test-environment)
- [Method](#method)
- [1. DHCP Services](#1-dhcp-services)
- [2. ADMIN Access](#2-admin-access)
- [3. USERS Isolation](#3-users-isolation)
- [4. SERVERS Isolation](#4-servers-isolation)
- [5. WireGuard VPN](#5-wireguard-vpn)
- [6. Firewall Evidence](#6-firewall-evidence)
- [7. Layer 2 Security Evidence](#7-layer-2-security-evidence)
- [8. Router Hardening Evidence](#8-router-hardening-evidence)
- [Summary](#summary)
- [Scope and Notes](#scope-and-notes)

## Test Environment

| Item | Value |
|---|---|
| Router | MikroTik CHR `MT-R1`, RouterOS 7.23.8 |
| Switch | Cisco IOU Layer 2 |
| Test hosts | VPCS hosts, one per VLAN |
| VPN client | Windows host with WireGuard |
| Simulation | GNS3 on VMware Workstation |

## Method

- One test host per segment (ADMIN, USERS, SERVERS) receives its address by DHCP.
- Connectivity is tested with `ping` between segments, towards the VPN client, towards the management LAN and towards the Internet (`8.8.8.8`).
- A test is **Pass** when the observed result matches the expected policy: reachable where allowed, timeout where blocked.
- Firewall behavior is confirmed on the router with the rule hit counters of the `input` and `forward` chains.

## 1. DHCP Services

| Segment | Expected | Result |
|---|---|---|
| Management LAN | Address from 192.168.10.100 - 200 | Pass |
| VLAN 10 - ADMIN | Address from 192.168.20.100 - 200 | Pass |
| VLAN 20 - USERS | Address from 192.168.30.100 - 200 | Pass |
| VLAN 30 - SERVERS | Address from 192.168.40.100 - 200 | Pass |

Evidence: [`mikrotik-dhcp-leases.png`](../screenshots/testing/mikrotik-dhcp-leases.png)

## 2. ADMIN Access

ADMIN has full access to the internal network.

| Source | Destination | Expected | Result |
|---|---|---|---|
| ADMIN | USERS | Reachable | Pass |
| ADMIN | SERVERS | Reachable | Pass |
| ADMIN | VPN client (10.10.10.2) | Reachable | Pass |

Evidence: [`admin-access-all.png`](../screenshots/testing/admin-access-all.png)

## 3. USERS Isolation

USERS may only reach the Internet.

| Source | Destination | Expected | Result |
|---|---|---|---|
| USERS | ADMIN | Blocked (timeout) | Pass |
| USERS | SERVERS | Blocked (timeout) | Pass |
| USERS | VPN client (10.10.10.2) | Blocked (timeout) | Pass |
| USERS | Management LAN (192.168.10.0/24) | Blocked (timeout) | Pass |
| USERS | Internet (8.8.8.8) | Reachable | Pass |

Evidence: [`users-isolation-blocked.png`](../screenshots/testing/users-isolation-blocked.png)

## 4. SERVERS Isolation

SERVERS may only reach the Internet.

| Source | Destination | Expected | Result |
|---|---|---|---|
| SERVERS | ADMIN | Blocked (timeout) | Pass |
| SERVERS | USERS | Blocked (timeout) | Pass |
| SERVERS | VPN client (10.10.10.2) | Blocked (timeout) | Pass |
| SERVERS | Management LAN (192.168.10.0/24) | Blocked (timeout) | Pass |
| SERVERS | Internet (8.8.8.8) | Reachable | Pass |

Evidence: [`servers-isolation-blocked.png`](../screenshots/testing/servers-isolation-blocked.png)

## 5. WireGuard VPN

| Test | Expected | Result |
|---|---|---|
| WireGuard handshake (Windows client to CHR) | Established | Pass |
| Access to internal segments from the VPN client | Reachable, same privileges as ADMIN | Pass |

Evidence:

- [`wireguard-handshake.png`](../screenshots/wireguard/wireguard-handshake.png)
- [`vpn-access-all.png`](../screenshots/wireguard/vpn-access-all.png)

The VPN client uses split tunneling: only the internal networks are routed through the tunnel.

## 6. Firewall Evidence

The rule sets and their hit counters are captured from the router:

```text
/ip firewall filter print stats where chain=forward
/ip firewall filter print stats where chain=input
```

- Forward chain: [`mikrotik-forward-rules.png`](../screenshots/firewall/mikrotik-forward-rules.png)
- Input chain: [`mikrotik-input-rules.png`](../screenshots/firewall/mikrotik-input-rules.png)
- NAT: [`mikrotik-nat.png`](../screenshots/firewall/mikrotik-nat.png)

What the evidence shows:

- The inter-VLAN `drop` rules and the final `drop` rule of the `forward` chain have non-zero counters after the isolation tests.
- The `input` chain accepts only established traffic, DHCP, the management LAN, the ADMIN VLAN, the VPN and the WireGuard port from the WAN, then drops everything else.
- NAT masquerade applies on the WAN interface only.

## 7. Layer 2 Security Evidence

- VLANs and trunk: [`cisco-layer2-vlan-trunk.png`](../screenshots/vlan/cisco-layer2-vlan-trunk.png)
- DHCP Snooping: [`cisco-layer2-dhcp-snooping.png`](../screenshots/security/cisco-layer2-dhcp-snooping.png)
- Port Security and BPDU Guard: [`cisco-layer2-security.png`](../screenshots/security/cisco-layer2-security.png)
- MikroTik VLAN interfaces: [`mikrotik-vlan-interfaces.png`](../screenshots/vlan/mikrotik-vlan-interfaces.png)

## 8. Router Hardening Evidence

- Services (insecure services disabled, Winbox and SSH restricted): [`mikrotik-services-hardening.png`](../screenshots/security/mikrotik-services-hardening.png)
- Users, MAC-Server and neighbor discovery: [`mikrotik-hardening-users-mac-neighbors.png`](../screenshots/security/mikrotik-hardening-users-mac-neighbors.png)

## Summary

| Area | Result |
|---|---|
| DHCP on all segments | Pass |
| ADMIN full access | Pass |
| USERS isolation | Pass |
| SERVERS isolation | Pass |
| WireGuard handshake and access | Pass |
| Default-deny firewall in place | Verified on the router |
| Layer 2 and router hardening | Verified on the devices |

## Scope and Notes

- VPCS hosts do not support SSH, so access to the router from USERS and SERVERS was validated by the `input` chain rules and their counters rather than by an SSH attempt.
- DAI could not be tested: it is not supported by the Cisco IOU image (see the README limitations).
- A first version of the firewall had no final `drop` rule: USERS and SERVERS could still reach the VPN client and the management LAN. This was found during review, fixed by adding the final `drop` rules and the VPN protection, and all isolation tests above were run again afterwards. See [Troubleshooting](troubleshooting.md).
