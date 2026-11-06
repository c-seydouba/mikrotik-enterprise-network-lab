
# MikroTik Enterprise Network Lab

A hands-on enterprise network infrastructure lab built with MikroTik CHR and Cisco Layer 2 switching, using VMware Workstation and GNS3.

This project demonstrates the design, implementation, configuration, and validation of an enterprise network with VLAN segmentation, inter-VLAN routing, DHCP services, firewall policies, Layer 2 security, and secure remote access through WireGuard VPN.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Objectives](#objectives)
- [Lab Environment](#lab-environment)
- [Network Architecture](#network-architecture)
- [VLAN and IP Addressing](#vlan-and-ip-addressing)
- [Key Implementations](#key-implementations)
- [WireGuard VPN](#wireguard-vpn)
- [Security Implementation](#security-implementation)
- [Testing and Validation](#testing-and-validation)
- [Screenshots](#screenshots)
- [Repository Structure](#repository-structure)
- [Documentation](#documentation)
- [Limitations](#limitations)
- [Project Status](#project-status)
- [Author](#author)

---

## Project Overview

The purpose of this lab is to simulate a small enterprise network environment where different departments and infrastructure services are isolated into separate VLANs.

The MikroTik CHR router provides Layer 3 services, including inter-VLAN routing, DHCP, NAT, firewall filtering, and WireGuard VPN access.

The Cisco Layer 2 switch provides VLAN segmentation, trunk connectivity, and Layer 2 security features.

The lab combines virtualization and network simulation to reproduce a realistic enterprise network environment.

## Objectives

- Design a segmented enterprise network architecture.
- Configure VLANs and IEEE 802.1Q trunking.
- Implement inter-VLAN routing.
- Deploy DHCP services for multiple VLANs.
- Configure NAT for Internet access.
- Apply firewall policies to control traffic between network segments.
- Implement Layer 2 security mechanisms.
- Deploy secure remote access using WireGuard VPN.
- Test connectivity, network isolation, and VPN functionality.
- Document configurations, architecture, and validation results.

## Lab Environment

| Component | Technology |
|---|---|
| Router | MikroTik CHR |
| RouterOS Version | 7.23.8 |
| Layer 2 Switch | Cisco IOU |
| Virtualization | VMware Workstation |
| Network Simulation | GNS3 |
| VPN Protocol | WireGuard |
| VPN Client | Windows |
| Router Architecture | x86_64 |

## Network Architecture

The network is organized around a MikroTik CHR router connected to a Cisco Layer 2 switch through an IEEE 802.1Q trunk.

The MikroTik router handles routing, addressing, firewall filtering, Internet access, and VPN services.

The Cisco switch provides Layer 2 connectivity and separates devices into different VLANs.

### Network Topology

The logical network architecture and connectivity between devices are documented in:

[Network Topology Diagram](docs/topology-diagram.md)

[Network Topology Documentation](docs/network-topology.md)

## VLAN and IP Addressing

The internal network is segmented into three functional VLANs, along with dedicated VLANs for unused ports and native trunk traffic.

| VLAN ID | Name | Network | Gateway | Purpose |
|---|---|---|---|---|
| 10 | ADMIN | 192.168.20.0/24 | 192.168.20.1 | Administration |
| 20 | USERS | 192.168.30.0/24 | 192.168.30.1 | User devices |
| 30 | SERVERS | 192.168.40.0/24 | 192.168.40.1 | Server infrastructure |
| 100 | UNUSED | — | — | Unused switch ports |
| 999 | NATIVE | — | — | Native VLAN on trunk |

### DHCP Configuration

DHCP services are configured on the MikroTik router for VLANs 10, 20, and 30.

| VLAN | DHCP Pool |
|---|---|
| ADMIN | 192.168.20.100–192.168.20.200 |
| USERS | 192.168.30.100–192.168.30.200 |
| SERVERS | 192.168.40.100–192.168.40.200 |

For the complete addressing plan, see [IP Addressing](docs/ip-addressing.md).

## Key Implementations

### 1. MikroTik CHR Configuration

The MikroTik router is responsible for the main Layer 3 and security services.

Implemented features:

- WAN connectivity through DHCP.
- VLAN interfaces.
- Inter-VLAN routing.
- DHCP pools and DHCP servers.
- NAT masquerading.
- Firewall input and forward filtering.
- WireGuard VPN server.

See [MikroTik Configuration](configurations/mikrotik/README.md).

### 2. Cisco Layer 2 Switching

The Cisco IOU switch is configured to provide Layer 2 segmentation and security.

Implemented features:

- VLAN creation and management.
- IEEE 802.1Q trunking.
- Native VLAN configuration.
- DHCP Snooping.
- Port Security.
- BPDU Guard.
- Unused switch port isolation.

See [Cisco Switch Configuration](configurations/cisco-switch/README.md).

## WireGuard VPN

WireGuard was deployed to provide secure remote access to the internal network.

### VPN Configuration

| Parameter | Value |
|---|---|
| Interface | wg-remote |
| VPN Server Address | 10.10.10.1/24 |
| Windows Client Address | 10.10.10.2/32 |
| UDP Port | 13231 |
| MTU | 1420 |
| VPN Mode | Split Tunneling |

### Validation

The VPN connection was successfully established between the Windows client and MikroTik CHR.

The following connectivity tests were performed:

- WireGuard handshake.
- Ping to VPN gateway `10.10.10.1`.
- Ping to ADMIN gateway `192.168.20.1`.
- Ping to USERS gateway `192.168.30.1`.
- Ping to SERVERS gateway `192.168.40.1`.
- Internet connectivity test using `1.1.1.1`.

Split tunneling was used, meaning Internet traffic from the Windows client continues through its normal Internet connection rather than being routed through the VPN tunnel.

## Security Implementation

### Firewall Policies

Firewall rules were implemented on the MikroTik router to enforce network segmentation and control traffic.

The policies include:

- Allowing established and related connections.
- Dropping invalid connections.
- Allowing ADMIN to access internal network segments.
- Blocking USERS from accessing ADMIN and SERVERS.
- Blocking SERVERS from accessing ADMIN and USERS.
- Allowing permitted Internet access.
- Restricting unsolicited WAN access to the router.
- Allowing the WireGuard UDP port.

### Layer 2 Security

The following mechanisms were implemented on the Cisco switch:

- DHCP Snooping.
- Port Security.
- BPDU Guard.

These features help protect the Layer 2 infrastructure against rogue DHCP servers, unauthorized device connections, and unwanted spanning-tree events.

## Testing and Validation

The lab was validated through practical connectivity and configuration tests.

| Test | Expected Result |
|---|---|
| DHCP on VLAN 10 | Address assigned successfully |
| DHCP on VLAN 20 | Address assigned successfully |
| DHCP on VLAN 30 | Address assigned successfully |
| Inter-VLAN routing | Routing according to firewall policies |
| ADMIN access | Access to internal VLANs |
| USERS isolation | No access to ADMIN and SERVERS |
| SERVERS isolation | No access to ADMIN and USERS |
| WireGuard handshake | Successful |
| VPN gateway connectivity | Successful |
| Internal gateway connectivity through VPN | Successful |
| Internet connectivity | Successful |

Detailed results are available in [Testing and Validation](docs/testing-and-validation.md).

## Screenshots

Screenshots provide visual evidence of the implementation and validation process.

### VLAN Configuration

- MikroTik VLAN interfaces: [View Screenshot](screenshots/vlan/mikrotik-vlan-interfaces.png)
- Cisco VLAN and trunk configuration: [View Screenshot](screenshots/vlan/cisco-layer2-vlan-trunk.png)

### Firewall

- MikroTik firewall rules: [View Screenshot](screenshots/firewall/mikrotik-firewall-rules.png)

### WireGuard VPN

- WireGuard handshake: [View Screenshot](screenshots/wireguard/wireguard-handshake.png)
- VPN connectivity tests: [View Screenshot](screenshots/wireguard/wireguard-connectivity-tests.png)

### Testing

- MikroTik DHCP leases: [View Screenshot](screenshots/testing/mikrotik-dhcp-leases.png)

### Layer 2 Security

- Cisco DHCP Snooping: [View Screenshot](screenshots/security/cisco-layer2-dhcp-snooping.png)
- Cisco Layer 2 security: [View Screenshot](screenshots/security/cisco-layer2-security.png)

## Repository Structure

```text
mikrotik-enterprise-network-lab/
│
├── configurations/
│   ├── mikrotik/
│   │   └── README.md
│   │
│   └── cisco-switch/
│       └── README.md
│
├── docs/
│   ├── ip-addressing.md
│   ├── network-topology.md
│   ├── topology-diagram.md
│   ├── testing-and-validation.md
│   └── troubleshooting.md
│
├── screenshots/
│   ├── vlan/
│   │   ├── mikrotik-vlan-interfaces.png
│   │   └── cisco-layer2-vlan-trunk.png
│   │
│   ├── firewall/
│   │   └── mikrotik-firewall-rules.png
│   │
│   ├── wireguard/
│   │   ├── wireguard-handshake.png
│   │   └── wireguard-connectivity-tests.png
│   │
│   ├── testing/
│   │   └── mikrotik-dhcp-leases.png
│   │
│   └── security/
│       ├── cisco-layer2-dhcp-snooping.png
│       └── cisco-layer2-security.png
│
└── README.md
```

## Documentation

Additional technical documentation:

- [IP Addressing Plan](docs/ip-addressing.md)
- [Network Topology](docs/network-topology.md)
- [Topology Diagram](docs/topology-diagram.md)
- [Testing and Validation](docs/testing-and-validation.md)
- [Troubleshooting](docs/troubleshooting.md)
- [MikroTik Configuration](configurations/mikrotik/README.md)
- [Cisco Switch Configuration](configurations/cisco-switch/README.md)

## Limitations

Some features could not be implemented due to limitations of the available Cisco IOU image:

- Dynamic ARP Inspection (DAI) was not supported.
- SSH management on the switch was not available.

These limitations are documented transparently and do not affect the successful validation of the implemented network features.

## Project Status

**Core implementation completed. Documentation and validation evidence are included in this repository.**

## Author

**Seydou BA**

- GitHub: [c-seydouba](https://github.com/c-seydouba)
- LinkedIn: [Seydou BA](https://linkedin.com/in/seydouba-infra)
