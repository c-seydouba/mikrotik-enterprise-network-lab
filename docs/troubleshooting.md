# Troubleshooting

Problems met while building and validating the lab, with their cause, fix and verification.

## Table of Contents

- [1. USERS and SERVERS could reach the VPN client and the management LAN](#1-users-and-servers-could-reach-the-vpn-client-and-the-management-lan)
- [2. The input chain had no final drop rule](#2-the-input-chain-had-no-final-drop-rule)
- [3. Misleading VLAN interface names](#3-misleading-vlan-interface-names)
- [4. SSH test impossible from VPCS hosts](#4-ssh-test-impossible-from-vpcs-hosts)
- [5. Features not supported by the Cisco IOU image](#5-features-not-supported-by-the-cisco-iou-image)
- [6. Firewall screenshot too long for one image](#6-firewall-screenshot-too-long-for-one-image)

---

## 1. USERS and SERVERS could reach the VPN client and the management LAN

**Symptom**

Hosts in the USERS and SERVERS VLANs could ping the VPN client (`10.10.10.2`). Only ADMIN was supposed to have that privilege.

**Cause**

The `forward` chain only contained explicit drops between specific pairs of interfaces (USERS and SERVERS towards ADMIN and each other) and a drop for new connections from the WAN. Traffic from USERS or SERVERS towards `wg-remote` or `ether2` matched no rule, and RouterOS accepts a packet that matches no rule. The chain had no final `drop`.

**Diagnosis**

Reading the exported rules showed that no rule matched traffic towards `wg-remote` or `ether2`. A ping from a USERS host to `10.10.10.2` confirmed the gap.

**Fix**

Rules added at the end of the `forward` chain:

```text
/ip firewall filter
add chain=forward action=drop out-interface=wg-remote comment="BLOCK ALL TO VPN"
add chain=forward action=accept in-interface=wg-remote comment="VPN ACCESS ALL"
add chain=forward action=accept in-interface=ether2 comment="MGMT ACCESS ALL"
add chain=forward action=drop comment="DROP ALL OTHER FORWARD"
```

The rule order matters:

- ADMIN is accepted by an earlier rule, so it can still reach the VPN client.
- Replies to connections opened by the VPN client are accepted by the established/related rule at the top of the chain.
- The final `drop` blocks everything that no earlier rule allowed.

**Verification**

- USERS and SERVERS: ping to the ADMIN VLAN, the other VLAN, the VPN client and the management LAN times out; Internet access still works.
- ADMIN and the VPN client keep their access.
- The drop rules show non-zero hit counters with `/ip firewall filter print stats where chain=forward`.

Evidence: [USERS isolation](../screenshots/testing/users-isolation-blocked.png), [SERVERS isolation](../screenshots/testing/servers-isolation-blocked.png), [forward rules](../screenshots/firewall/mikrotik-forward-rules.png).

**Lesson**

A firewall that allows by exception needs an explicit final `drop`. A rule set that looks complete can leave paths open, so isolation must also be tested with negative tests (traffic that should fail), not only with traffic that should work.

---

## 2. The input chain had no final drop rule

**Symptom**

Traffic to the router from interfaces other than USERS, SERVERS and the WAN was accepted by default.

**Cause**

Same root cause as problem 1, in the `input` chain: only specific drops existed (USERS, SERVERS, new connections from the WAN).

**Fix**

```text
/ip firewall filter
add chain=input action=accept in-interface=vlan10-admin comment="ADMIN ACCESS ROUTER"
add chain=input action=accept in-interface=wg-remote comment="VPN ACCESS ROUTER"
add chain=input action=drop comment="DROP ALL OTHER INPUT"
```

The two accepts come before the final `drop` so that ADMIN and the VPN keep their management access. DHCP requests are accepted earlier in the chain, so clients still receive leases.

**Verification**

Winbox from the management LAN, DHCP on every VLAN and the VPN keep working after the change.

Evidence: [input rules](../screenshots/firewall/mikrotik-input-rules.png).

---

## 3. Misleading VLAN interface names

**Symptom**

The USERS interface was named `vlan10-users` although it carries VLAN 20, and the SERVERS interface was named `vlan10-servers` although it carries VLAN 30. This made the firewall rules confusing to read.

**Fix**

```text
/interface vlan set vlan10-users name=vlan20-users
/interface vlan set vlan10-servers name=vlan30-servers
```

RouterOS updates the firewall rules and DHCP servers that reference the renamed interfaces.

**Verification**

The VLAN interface list and the firewall rules show the new names: [VLAN interfaces](../screenshots/vlan/mikrotik-vlan-interfaces.png).

**Lesson**

Name interfaces after the VLAN ID they carry (`vlan<ID>-<name>`).

---

## 4. SSH test impossible from VPCS hosts

**Symptom**

The test hosts are VPCS nodes, which do not support SSH. The restriction of router access from USERS and SERVERS could not be tested with an SSH connection.

**Resolution**

The restriction is validated by the `input` chain rules and their hit counters: [input rules](../screenshots/firewall/mikrotik-input-rules.png). A full SSH test would require a host with an SSH client in the USERS VLAN.

---

## 5. Features not supported by the Cisco IOU image

**Symptom**

- Dynamic ARP Inspection (DAI) could not be enabled.
- SSH management was not available on the switch.

**Cause**

Both features are not supported by the Cisco IOU image used in GNS3.

**Resolution**

The switch is managed from the console. DHCP Snooping, Port Security and BPDU Guard, which the image supports, were implemented and validated: see [Layer 2 security evidence](testing-and-validation.md#7-layer-2-security-evidence).

---

## 6. Firewall screenshot too long for one image

**Symptom**

The complete list of firewall rules did not fit in a single screenshot.

**Resolution**

The evidence is split by chain, each with its hit counters:

```text
/ip firewall filter print stats where chain=forward
/ip firewall filter print stats where chain=input
```

- [Forward rules](../screenshots/firewall/mikrotik-forward-rules.png)
- [Input rules](../screenshots/firewall/mikrotik-input-rules.png)
