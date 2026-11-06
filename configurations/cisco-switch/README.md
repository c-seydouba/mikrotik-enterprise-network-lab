# Cisco Layer 2 Switch Configuration

## Device Information

- Platform: Cisco IOU Layer 2
- Environment: GNS3
- Role: VLAN switching and Layer 2 security

## VLAN Configuration

| VLAN ID | Name | Purpose |
|---|---|---|
| 10 | ADMIN | Administrative devices |
| 20 | USERS | User devices |
| 30 | SERVERS | Server infrastructure |
| 100 | UNUSED | Unused switch ports |
| 999 | NATIVE | Native VLAN on trunk |

## Trunk Configuration

An IEEE 802.1Q trunk connects the Cisco switch to the MikroTik CHR router.

The trunk carries the required VLAN traffic between the switching and routing devices.

- Encapsulation: IEEE 802.1Q
- Native VLAN: 999
- Allowed VLANs: 10, 20, 30, 999

## Layer 2 Security

### DHCP Snooping

DHCP Snooping was enabled globally and for VLANs 10, 20 and 30.

The uplink interface connected to the MikroTik router was configured as trusted.

### Port Security

Port Security was configured to restrict unauthorized device connections on access ports.

### BPDU Guard

BPDU Guard was configured to protect access ports against unexpected Spanning Tree BPDUs.

## Configuration Limitations

- Dynamic ARP Inspection (DAI) was not implemented because the available Cisco IOU image did not support the required ARP inspection commands.
- SSH management was not configured because the available switch image did not support the required SSH functionality.

## Configuration Persistence

The switch configuration was saved using:

```text
copy running-config startup-config
```

This saves the running configuration to startup-config.
