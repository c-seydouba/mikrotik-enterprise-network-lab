# Testing and Validation

## 1. DHCP Validation

DHCP services were configured on the following VLANs:

- VLAN 10 — ADMIN
- VLAN 20 — USERS
- VLAN 30 — SERVERS

Clients were tested to verify dynamic IP address assignment.

## 2. Network Connectivity

Connectivity was tested between the WireGuard VPN client and the MikroTik router.

The following gateway addresses responded successfully to ping tests:

| Destination | Network |
|---|---|
| 10.10.10.1 | WireGuard VPN |
| 192.168.20.1 | ADMIN |
| 192.168.30.1 | USERS |
| 192.168.40.1 | SERVERS |

## 3. Internet Connectivity

Internet connectivity was verified from the VPN client.

- Test destination: `1.1.1.1`
- Result: Successful ping
- Routing mode: Split tunneling

Internet traffic continued to use the client's normal Internet connection rather than the WireGuard tunnel.

## 4. WireGuard VPN Validation

The WireGuard tunnel was successfully established between the MikroTik CHR router and the Windows client.

Validation included:

- Successful VPN handshake.
- Traffic exchange between the VPN peers.
- Successful ping to the MikroTik VPN address.
- Successful ping to the three VLAN gateways.

## 5. Firewall Validation

Firewall policies were configured to:

- Allow administrative access to internal network segments.
- Restrict communication from USERS to ADMIN and SERVERS.
- Restrict communication from SERVERS to ADMIN and USERS.
- Allow established and related connections.
- Block unsolicited incoming WAN traffic, except the WireGuard VPN port.

## 6. Layer 2 Security Validation

The following mechanisms were configured on the Cisco switch:

- DHCP Snooping
- Port Security
- BPDU Guard

Dynamic ARP Inspection and SSH management were not implemented due to limitations of the available Cisco IOU image.

## 7. Validation Summary

The main routing, VLAN, firewall and remote-access components were configured and tested.

Further testing can be added to document additional client-to-client connectivity and security-policy verification.
