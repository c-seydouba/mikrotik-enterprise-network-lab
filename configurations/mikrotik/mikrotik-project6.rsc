# 2026-11-07 13:53:19 by RouterOS 7.23.8
# system id = 565mIkA4w8F
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface wireguard
add listen-port=13231 mtu=1420 name=wg-remote
/interface vlan
add interface=ether3 name=vlan10-admin vlan-id=10
add interface=ether3 name=vlan20-users vlan-id=20
add interface=ether3 name=vlan30-servers vlan-id=30
/ip pool
add name=dhcp_pool2 ranges=192.168.10.100-192.168.10.200
add name=pool-admin ranges=192.168.20.100-192.168.20.200
add name=pool-users ranges=192.168.30.100-192.168.30.200
add name=pool-servers ranges=192.168.40.100-192.168.40.200
/ip dhcp-server
add address-pool=dhcp_pool2 interface=ether2 lease-time=10m name=dhcp1
add address-pool=pool-admin interface=vlan10-admin name=dhcp-admin
add address-pool=pool-users interface=vlan20-users name=dhcp-users
add address-pool=pool-servers interface=vlan30-servers name=dhcp-servers
/ip neighbor discovery-settings
set discover-interface-list=none
/interface wireguard peers
add allowed-address=10.10.10.2/32 comment=Windows-Client1 interface=wg-remote \
    name=peer2 public-key="pPOwzNbuEr2SbAqEqB0LE6iLu4sKjwhLTGUFqOWSLnk="
/ip address
add address=192.168.10.1/24 interface=ether2 network=192.168.10.0
add address=192.168.20.1/24 interface=vlan10-admin network=192.168.20.0
add address=192.168.30.1/24 interface=vlan20-users network=192.168.30.0
add address=192.168.40.1/24 interface=vlan30-servers network=192.168.40.0
add address=10.10.10.1/24 comment="WireGuard VPN" interface=wg-remote \
    network=10.10.10.0
/ip dhcp-client
add interface=ether1 name=client1
/ip dhcp-server network
add address=192.168.10.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=192.168.10.1
add address=192.168.20.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=192.168.20.1
add address=192.168.30.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=192.168.30.1
add address=192.168.40.0/24 dns-server=1.1.1.1,8.8.8.8 gateway=192.168.40.1
/ip firewall filter
add action=accept chain=input dst-port=67 in-interface=vlan10-admin protocol=\
    udp
add action=accept chain=input dst-port=67 in-interface=vlan20-users protocol=\
    udp
add action=accept chain=input dst-port=67 in-interface=vlan30-servers \
    protocol=udp
add action=accept chain=input connection-state=established,related
add action=drop chain=input comment="BLOCK USERS TO ROUTER" in-interface=\
    vlan20-users
add action=drop chain=input comment="BLOCK SERVERS TO ROUTER" in-interface=\
    vlan30-servers
add action=accept chain=input in-interface=ether2
add action=accept chain=input comment=ALLOW-WIREGUARD dst-port=13231 \
    in-interface=ether1 protocol=udp
add action=drop chain=input connection-state=new in-interface=ether1
add action=accept chain=forward comment="FORWARD - Established Related" \
    connection-state=established,related
add action=drop chain=forward comment="FORWARD - Drop Invalid" \
    connection-state=invalid
add action=accept chain=forward comment="ADMIN - Access All" in-interface=\
    vlan10-admin
add action=drop chain=forward comment="USERS - Block ADMIN" in-interface=\
    vlan20-users out-interface=vlan10-admin
add action=drop chain=forward comment="USERS - Block SERVERS" in-interface=\
    vlan20-users out-interface=vlan30-servers
add action=drop chain=forward comment="SERVERS - Block ADMIN" in-interface=\
    vlan30-servers out-interface=vlan10-admin
add action=drop chain=forward comment="SERVERS - Block USERS" in-interface=\
    vlan30-servers out-interface=vlan20-users
add action=accept chain=forward comment="USERS - Internet" in-interface=\
    vlan20-users out-interface=ether1
add action=accept chain=forward comment="SERVERS - Internet" in-interface=\
    vlan30-servers out-interface=ether1
add action=drop chain=forward comment="WAN - Block New Forward" \
    connection-state=new in-interface=ether1
add action=drop chain=forward comment="BLOCK ALL TO VPN" out-interface=\
    wg-remote
add action=accept chain=forward comment="VPN ACCESS ALL" in-interface=\
    wg-remote
add action=accept chain=forward comment="MGMT ACCESS ALL" in-interface=ether2
add action=drop chain=forward comment="DROP ALL OTHER FORWARD"
add action=accept chain=input comment="ADMIN ACCESS ROUTER" in-interface=\
    vlan10-admin
add action=accept chain=input comment="VPN ACCESS ROUTER" in-interface=\
    wg-remote
add action=drop chain=input comment="DROP ALL OTHER INPUT"
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/ip service
set ftp disabled=yes
set ssh address=192.168.10.0/24,192.168.20.0/24,10.10.10.0/24
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox address=192.168.10.0/24,192.168.20.0/24,10.10.10.0/24
set api disabled=yes
set api-ssl disabled=yes
/system identity
set name=MT-R1
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
