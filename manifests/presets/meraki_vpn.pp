# == Define: strongswan::presets::meraki_vpn
#
# Sets up Strongswan to accept inbound VPN connection requests from Meraki
# MX-series security appliances. Configured to accept the 'default'
# _IPSec policies_ as described on the _Site-to-site VPN_ management page.
#
# === Required Parameters
#
# [*meraki_public_ip*]
#   The Public IPv4 address that your Meraki has on the Internet. Used to
#   configure inbound access through the Firewall to the network.
#
# [*meraki_subnet*]
#   The IP CIDR that your Meraki is hosting behind it. Likely matches the range
#   described in the 'Local networks' section of the site-to-site VPN page.
#
# [*swan_public_ip*]
#   The public IP address of the strongSwan server -- used to help handle
#   NAT-Traversal issues.
#
# [*swan_subnet*]
#   The IP CIDR that you want your strongSwan server to provide access to your
#   Merakis. Should exactly match the _Private subnets_ configuration option in
#   the Meraki site-to-site VPN page.
#
# [*psk*]
#   Pre-shared-key configured in the Meraki site-to-site VPN page.
#
# === Optional Parameters
#
# [*masquerade*]
#   Present/Absent: Whether or not to masquerade traffic to the
#   _private_subnet_ from the Meraki IPs.
#   (default: True)
#
# === Authors
#
# Matt Wise
#
define strongswan::presets::meraki_vpn (
  $meraki_public_ip,
  $meraki_subnet,
  $swan_public_ip,
  $swan_subnet,
  $psk,
  $masquerade = present,
) {
  # This configuration works with the 'default' IPSec policies defined in
  # Meraki MX-series security appliances.
  $_params = {
    'authby'        => 'secret',
    'auto'          => 'add',
    'ikelifetime'   => '8h',
    'keyexchange'   => 'ikev1',
    'ike'           => '3des-sha1-modp11024!',
    'esp'           => 'aes256-sha1-noesn',
    'keylife'       => '8h',
    'rekey'         => 'no',
    'reauth'        => 'no',

    'left'          => $::ipaddress,
    'leftid'        => $swan_public_ip,
    'leftsubnet'    => $swan_subnet,
    'right'         => $meraki_public_ip,
    'rightsubnet'   => $meraki_subnet,
  }

  $_secrets = [
  # All employees are given this PSK. This PSK is the first authenticator
  # before they move into the Phase2 (PAM) auth.
    { 'left_id'  => $::ipaddress,
      'right_id' => $meraki_public_ip,
      'auth'     => 'PSK',
      'key'      => $psk }
  ]

  # Make sure the strongswan service has been configured
  include strongswan
  include strongswan::env

  # Ensure that inbound VPN requests are allowed
  firewall {
    "020 ${title} inbound udp":
    proto  => 'udp',
    action => 'accept',
    source => $meraki_public_ip,
    dport  => $strongswan::env::ports;

    "020 ${title} masquerading":
    ensure   => $masquerade,
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    proto    => all,
    outiface => 'eth0',
    source   => $meraki_subnet,
    table    => 'nat';

    "021 ${title} ipsec routing policy":
    chain        => 'POSTROUTING',
    action       => 'accept',
    proto        => all,
    outiface     => 'eth0',
    source       => $meraki_subnet,
    ipsec_policy => 'ipsec',
    ipsec_dir    => 'out',
    table        => 'nat';
  }

  # Now set up the actual Strongswan configuration
  strongswan::conn { $title:
    params  => $_params,
    secrets => $_secrets,
  }
}
