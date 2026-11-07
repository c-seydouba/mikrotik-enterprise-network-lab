# Cisco Switch Configuration

Configuration of the `SW1` Layer 2 switch (Cisco IOU, IOS 15.1). The switch provides VLAN segmentation, the 802.1Q trunk to the MikroTik router and Layer 2 security. All Layer 3 services are handled by the router (see [MikroTik Configuration](../mikrotik/README.md)).

A sanitized copy of the running configuration is available in [`sw1-running-config.txt`](sw1-running-config.txt). Secrets are replaced by `<redacted>`.

## Table of Contents

- [VLANs](#vlans)
- [Port Plan](#port-plan)
- [Trunk Configuration](#trunk-configuration)
- [Access Ports](#access-ports)
- [Layer 2 Security](#layer-2-security)
- [Management](#management)
- [Verification Commands](#verification-commands)
- [Limitations](#limitations)

## VLANs

| VLAN ID | Name | Purpose |
|---|---|---|
| 10 | ADMIN | Administration |
| 20 | USERS | User devices |
| 30 | SERVERS | Server infrastructure |
| 100 | UNUSED | Shut down ports |
| 999 | NATIVE | Native VLAN of the trunk |

## Port Plan

| Port(s) | Mode | VLAN | Connected to |
|---|---|---|---|
| `Ethernet0/0` | Trunk | 10, 20, 30 (native 999) | MikroTik CHR (`ether3`) |
| `Ethernet0/1` | Access | 10 (ADMIN) | ADMIN test host |
| `Ethernet0/2` | Access | 20 (USERS) | USERS test host |
| `Ethernet0/3` | Access | 30 (SERVERS) | SERVERS test host |
| `Ethernet1/0` to `Ethernet3/3` | Access, shut down | 100 (UNUSED) | Nothing (12 ports) |

## Trunk Configuration

```text
interface Ethernet0/0
 switchport trunk encapsulation dot1q
 switchport trunk native vlan 999
 switchport trunk allowed vlan 10,20,30,999
 switchport mode trunk
 ip dhcp snooping trust
```

- IEEE 802.1Q encapsulation.
- Native VLAN 999, a dedicated VLAN that carries no user traffic.
- Only VLANs 10, 20, 30 and 999 are allowed on the trunk.
- The trunk is the only DHCP snooping trusted port, because the DHCP servers are on the router side.

## Access Ports

Each access port follows the same template (example for the ADMIN port):

```text
interface Ethernet0/1
 switchport access vlan 10
 switchport mode access
 switchport port-security maximum 3
 switchport port-security
 switchport port-security violation restrict
 switchport port-security mac-address sticky
 spanning-tree portfast
 spanning-tree bpduguard enable
 ip dhcp snooping limit rate 5
```

## Layer 2 Security

| Feature | Configuration |
|---|---|
| DHCP Snooping | Enabled for VLANs 10, 20 and 30. The trunk is trusted, access ports are untrusted. Option 82 insertion is disabled. |
| DHCP rate limiting | 5 packets per second on each access port |
| Port Security | Sticky MAC learning, maximum 3 MAC addresses per access port, violation mode `restrict` |
| BPDU Guard | Enabled on access ports together with PortFast |
| Unused ports | 12 ports administratively shut down and placed in VLAN 100 |
| Native VLAN | Dedicated VLAN 999 on the trunk, restricted allowed VLAN list |
| VLAN 1 interface | Shut down |
| HTTP server | Disabled |

These features protect the Layer 2 infrastructure against rogue DHCP servers, DHCP flooding, unauthorized devices on access ports and unexpected spanning-tree events.

## Management

- Console access protected by a line password; privileged mode protected by an `enable secret`.
- `service password-encryption` enabled.
- A login banner warns against unauthorized access.
- Logging to the local buffer.

## Verification Commands

```text
show vlan brief
show interfaces trunk
show ip dhcp snooping
show port-security
show port-security interface Ethernet0/1
show spanning-tree summary
```

- `show vlan brief`: VLANs and the ports assigned to them.
- `show interfaces trunk`: trunk state, native VLAN and allowed VLANs.
- `show ip dhcp snooping`: snooping status, protected VLANs, trusted ports and rate limits.
- `show port-security`: Port Security status of the access ports.
- `show port-security interface <port>`: details for one port (maximum, violation mode, learned MAC addresses).
- `show spanning-tree summary`: spanning-tree mode and protection features such as BPDU Guard.

Evidence:

- [VLANs and trunk](../../screenshots/vlan/cisco-layer2-vlan-trunk.png)
- [DHCP Snooping](../../screenshots/security/cisco-layer2-dhcp-snooping.png)
- [Layer 2 security](../../screenshots/security/cisco-layer2-security.png)

## Limitations

- Dynamic ARP Inspection (DAI) is not supported by the IOU image used.
- SSH is not available on this image, so the switch is managed from the console.
