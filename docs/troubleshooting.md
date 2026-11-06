# Troubleshooting Guide

This document records some of the issues encountered during the implementation of the MikroTik enterprise network lab and their resolutions.

## 1. WinBox Access Problem

**Issue:** WinBox access was unavailable when the PC was connected through the initial network configuration.

**Resolution:** The PC was connected to the appropriate LAN segment to restore access to the MikroTik router.

## 2. WireGuard Handshake Failure

**Issue:** The WireGuard tunnel did not establish a successful handshake.

**Cause:** The peer public key configured on the MikroTik router was incorrect.

**Resolution:** The incorrect peer configuration was replaced with the correct Windows client public key.

**Result:** The WireGuard handshake succeeded and traffic was exchanged between the peers.

## 3. VPN Connectivity to Internal VLANs

**Issue:** Internal network reachability needed to be verified after establishing the VPN tunnel.

**Resolution:** Connectivity was tested using ping from the Windows VPN client to the MikroTik VPN address and the three VLAN gateways.

**Result:** All tested gateway addresses responded successfully.

## 4. Internet Routing Through WireGuard

**Observation:** Internet traffic from the Windows client continued to use the normal Internet connection.

**Cause:** The WireGuard client configuration uses split tunneling rather than routing all traffic through the VPN.

**Result:** Internal network access is provided through WireGuard, while normal Internet traffic follows the client's default route.

## 5. Cisco IOU Feature Limitations

**Issue:** Some management and security features were unavailable in the selected Cisco IOU image.

**Resolution:**
- Dynamic ARP Inspection was not implemented.
- SSH management was not configured.

These features require an image that supports the corresponding commands.
