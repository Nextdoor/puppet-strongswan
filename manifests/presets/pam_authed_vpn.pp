# == Class: strongswan::presets::pam_authed_vpn
#
# Sets up Strongswan to accept inbound VPN connection requests from standard
# Cisco IPSEC Clients (Mac OSX, iOS, Android, Windows) using IKEv1 PSK for
# Phase1 and XAUTH-PAM for Phase2 authentication. Users are validated against
# your local PAM configuration of the host ... so if you want to do LDAP
# authentication, you set it up in the PAM auth on the host.
#
# === Optional Parameters
#
# [*client_source_ip*]
#   IP CIDR to accept VPN connection requests from.
#   (default: 0.0.0.0/0)
#
# [*dns*]
#   A list of DNS servers to pass to the VPN clients.
#   (default: [ 8.8.8.8, 8.8.4.4 ]
#
# [*routed_ip_cidr*]
#   The IP range thats passed to the VPN clients as the 'routed' range.
#   Defaults to 0.0.0.0/0, which means to pass *all* traffic through the VPN
#   client. Narrowing this down to some other range (like 10.0.0.0/8) will
#   cause split-tunneling, allowing the client to go directly to the internet
#   for most traffic, but over the VPN for specific traffic.
#   (default: 0.0.0.0/0)
#
# [*private_ip_cidr*]
#   Private IP CIDR range to hand addresses out to VPN clients.
#   (default: 192.168.0.0/22)
#
# [*private_ip*]
#   Private IP that the VPN server will use for routing VPN client data.
#   (default: 192.168.0.1/22)
#
# === Authors
#
# Matt Wise
#
class strongswan::presets::pam_authed_vpn (
  $client_source_ip = '0.0.0.0/0',
  $dns              = [ '8.8.8.8', '8.8.4.4' ],
  $routed_ip_cidr   = '0.0.0.0/0',
  $private_ip_cidr  = '192.168.0.0/24',
  $private_ip       = '192.168.0.1/24',
  $psk              = 'Your-Pre-Shared-Key',
) {
  # Standard parameters for an IPSEC and PAM-Authed VPN. This works with Mac
  # OSX and iOS clients. Moderately secure, but in the future should include
  # SSL-Cert based authentication
  # rather than PSK.
  $_left_id  = $::ipaddress_eth0
  $_right_id = '%any'
  $_params = {
    'keyexchange'   => 'ikev1',
    'authby'        => 'secret',
    'xauth'         => 'server',
    'leftauth'      => 'psk',
    'rightauth'     => 'psk',
    'rightauth2'    => 'xauth-pam',
    'auto'          => 'add',
    'dpdaction'     => 'clear',
    'left'          => $_left_id,
    'leftsubnet'    => $routed_ip_cidr,
    'leftfirewall'  => 'yes',
    'right'         => $_right_id,
    'rightsubnet'   => $private_ip_cidr,
    'rightsourceip' => $private_ip,
    'rightdns'      => join($dns, ','),
    }

  $_secrets = [
  # All employees are given this PSK. This PSK is the first authenticator
  # before they move into the Phase2 (PAM) auth.
    { 'left_id'  => $_left_id,
      'right_id' => $_right_id,
      'auth'     => 'PSK',
      'key'      => $psk }
  ]

  # Make sure the strongswan service has been configured
  include strongswan
  include strongswan::env

  # Ensure that inbound VPN requests are allowed
  firewall {
    '020 vpn-client inbound udp':
    proto  => 'udp',
    action => 'accept',
    source => $client_source_ip,
    dport  => $strongswan::env::ports;

    '020 vpn-client masquerading':
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    proto    => all,
    outiface => 'eth0',
    source   => $private_ip_cidr,
    table    => 'nat';

    '021 vpn-client ipsec routing policy':
    chain        => 'POSTROUTING',
    action       => 'accept',
    proto        => all,
    outiface     => 'eth0',
    source       => $private_ip_cidr,
    ipsec_policy => 'ipsec',
    ipsec_dir    => 'out',
    table        => 'nat';
    }

  # Now set up the actual Strongswan configuration
  strongswan::conn { 'vpn':
    params  => $_params,
    secrets => $_secrets,
  }

}
