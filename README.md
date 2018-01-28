#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#setup)
3. [Usage](#usage)
4. [Pre-defined Tunnel Types](#presets)

## Overview

This module installs and manages [strongSwan](https://www.strongswan.org/)
daemon on a host. For detailed information about strongSwan, please see its
website and the [wiki](http://wiki.strongswan.org).

## Setup

The initial setup of the module happens in the main
[strongswan](manifests/init.pp) puppet class. The defaults are relatively safe,
but we allow you to overwrite as many settings as you wish, as long as you
instantiate the main class before calling any of the resource definitions.

## Usage

### Class: strongswan

```puppet
class { 'strongswan':
  charon_options     => <charon options>,
  conn_conf_path     => <path to store connections>,
  ipsec_options      => <ipsec options>,
  secrets_conf_path  => <path to store secrets>,
  service_name       => <ipsec service name>,
  service_provider   => <init system name>,
  service_ensure     => <ipsec service ensure>,
  service_enable     => <ipsec service enable bool>,
  strongswan_package => <strongswan package name>,
  strongswan_version => <strongswan version num>,
  strongswan_plugins => <strongswan plugins list>,
}
```

#### `charon_options`
A hash of custom options for the /etc/strongswan.d/charon.conf file
(_default: {}_)

#### `conn_conf_path`
Directory to store individual IPSec Connection configuration files in.
(_default: /etc/ipsec.d/conns_)

#### `ipsec_options`
A hash of settings for the 'config settings' section of the /etc/ipsec.conf
file.
(_default: {}_)

#### `secrets_conf_path`
Directory to store individual IPSec Connection secret files in.
(_default: /etc/ipsec.d/secrets_)

#### `service_name`
Name of the StrongSwan service daemon.
(_default: strongswan_)

#### `service_provider`
Name of the init system to use e.g. 'upstart' or 'systemd'.
(_default: upstart_)

#### `service_ensure`
Whether to ensure the service is running or not.
(_default: running_)

#### `service_enable`
Whether to enable the strongswan service on system startup.
(_default: true_)

#### `strongswan_package`
Name of the Strongswan package to install.
(_default: strongswan_)

#### `strongswan_version`
Version of the Strongswan packages to install.
(_default: installed_)

#### `strongswan_plugins`
(_default: [ strongswan-plugin-unity, strongswan-plugin-xauth-pam ]_)

### Definition: strongswan::conn

```puppet
strongswan::conn { 'myconn':
  params  => <hash of custom connection parameters>
  secrets => <array of hashes of secrets>
}
```

Or through Hiera:

``` yaml
strongswan::conns:
  myconn:
    params: {}
    secrets: []
```

#### `params`
A hash that contains all of the `key`=>`value` parameters for your connection.
Expects that you know all of the parameters required, and it will fill them in
exactly as you've supplied.

```ruby
{ 'keyexchange' => 'ikev2',
  'auto'        => 'start',
  'esp'         => 'aes128-sha1-modp1024',
  'ikelifetime' => '28800s',
  'keylife'     => '3600s',
  'rekey'       => 'no',
  'reauth'      => 'no',
  'authby'      => 'secret',
  'closeaction' => 'restart',
  'dpddelay'    => '10s',
  'dpdtimeout'  => '30s',
  'dpdaction'   => 'restart',
  'rightsubnet' => $vpc_subnet,
  'leftid'      => $customer_gateway_ip,
  'leftsubnet'  => $customer_subnet,
  'right'       => $ipsec_1_vpg_ip,
  'rightid'     => $ipsec_1_vpg_ip
}
```

#### `secrets`
An array of hashes that list the secrets for the connection. Eg:

```ruby
[ { 'left_id' => '10.0.0.1', 'right_id' => '%any',
    'auth'    => 'PSK', 'key' => 'xYsdfkjkasd' },
  { 'left_id' => '10.0.0.2', 'right_id' => '%any',
    'auth'    => 'PSK', 'key' => 'xYsdfkjkasd' },
]
```

## Presets

### Class: strongswan::presets::pam\_authed\_vpn

Configures your server as a VPN endpoint for incoming _Cisco IPSEC_ VPN clients
(like iOS, Android, Mac OSX, etc). Uses simple local PAM for user authentication.

```puppet
class { 'strongswan::presets::pam_authed_vpn':
  client_source_ip => '0.0.0.0/0',
  dns              => [ '8.8.8.8', '8.8.4.4' ],
  routed_ip_cidr   => '10.0.0.0/8',
  private_ip_cidr  => '192.168.0.0/24',
  private_ip       => '192.168.0.1',
}
```

#### `client_source_ip`
IP CIDR to accept VPN connection requests from.
(_default: 0.0.0.0/0_)

#### `dns`
A list of DNS servers to pass to the VPN clients.
(_default: [ 8.8.8.8, 8.8.4.4 ]_)

#### `routed_ip_cidr`
The IP range thats passed to the VPN clients as the 'routed' range.
Defaults to 0.0.0.0/0, which means to pass *all* traffic through the VPN
client. Narrowing this down to some other range (like 10.0.0.0/8) will
cause split-tunneling, allowing the client to go directly to the internet
for most traffic, but over the VPN for specific traffic.
(_default: 0.0.0.0/0_)

#### `private_ip_cidr`
Private IP CIDR range to hand addresses out to VPN clients.
(_default: 192.168.0.0/22_)

#### `private_ip`
Private IP that the VPN server will use for routing VPN client data.
(_default: 192.168.0.1/22_)

### Definition: strongswan::presets::aws\_vpc

Configures a VPN connection into an Amazon VPC following their [Generic
Customer Gateway without Border Gateway
Protocol](http://docs.aws.amazon.com/AmazonVPC/latest/NetworkAdminGuide/GenericConfigNoBGP.html)
model. Creates two outbound, _policy based_ VPN tunnels to the Amazon VPN
endpoints. Only one tunnel can be used at any given moment, but automatic
failover happens when one of the AWS endpoints shuts down.

```puppet
strongswan::presets::aws_vpc { 'myVPC':
  customer_gateway_ip => <your servers eIP>,
  customer_subnet     => <your servers CIDR block>,
  ipsec_1_vpg_ip      => <AWS VPC IPSec #1 Endpoint>,
  ipsec_1_psk         => <PSK for IPSec #1 Endpoint>,
  ipsec_2_vpg_ip      => <AWS VPC IPSec #2 Endpoint>,
  ipsec_2_psk         => <PSK for IPSec #2 Endpoint>,
  vpc_subnet          => <your VPC CIDR block>,
}
```

#### `customer_gateway_ip`
(Line 77 of the Generic VPC Configuration from Amazon)

#### `customer_subnet`
The subnet on the 'left' (client) side of the tunnel. Can be as small as a
/32, or as large as you want. Should match whatever static route you have
configured in your VPN Connection endpoint in Amazon.

#### `ipsec_1_vpg_ip`
(Line 78 of the Generic VPC Configuration from Amazon)

#### `ipsec_1_psk`
(Line 25 of the Generic VPC Configuration from Amazon)

#### `ipsec_2_vpg_ip`
(Line 162 of the Generic VPC Configuration from Amazon)

#### `ipsec_2_psk`
(Line 109 of the Generic VPC Configuration from Amazon)

### Definition: strongswan::presets::meraki\_vpn

Configures an incoming VPN service for a Meraki MX-series router using IKEv1
per their
[documentation](https://kb.meraki.com/knowledge_base/troubleshooting-3rd-party-site-to-site-vpn).

```puppet
strongswan::presets::meraki_vpn { 'our-office':
  meraki_public_ip => <your meraki/office public ip address>,
  meraki_subnet    => <your internal office subnet>,
  swan_public_ip   => <your strongswan server public address>,
  swan_subnet      => <your strongswan server private subnet>,
  psk              => <pre-shared-key>
  masquerade       => <whether or not to enable ip masquerading>
}
```

#### `meraki_public_ip`
The Public IPv4 address that your Meraki has on the Internet. Used to
configure inbound access through the Firewall to the network

#### `meraki_subnet`
The IP CIDR that your Meraki is hosting behind it. Likely matches the range
described in the 'Local networks' section of the site-to-site VPN page.

#### `swan_public_ip`
The public IP address of the strongSwan server -- used to help handle
NAT-Traversal issues.

#### `swan_subnet`
The IP CIDR that you want your strongSwan server to provide access to your
Merakis. Should exactly match the _Private subnets_ configuration option in
the Meraki site-to-site VPN page.

#### `psk`
The pre-shared-key you've entered into your Meraki site-to-site VPN page.

#### `masquerade`
Either `present` or `absent`: Whether or not to enable IP masquerading on the
strongSwan host.