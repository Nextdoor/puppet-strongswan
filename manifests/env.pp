# == Class: strongswan::env
#
# Common environment/parameters for the strongswan class.
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
class strongswan::env {
  # Ports that Strongswon (and all IPSec Servers) listen on
  $ports = [500, 4500]

  # Default Strongswan Plugins and Version to install
  $strongswan_version = 'installed'
  $strongswan_package = 'strongswan'
  $strongswan_plugins = [ 'strongswan-plugin-unity',
                          'strongswan-plugin-xauth-pam' ]

  # Service configuration options
  $service_name   = 'strongswan'
  $service_ensure = 'running'
  $service_enable = true

  # Where do we store all of the custom connection configs?
  $conn_conf_path    = '/etc/ipsec.d/conns'
  $secrets_conf_path = '/etc/ipsec.d/secrets'

  # Global Configuration Settings. These simply match the defaults for
  # Strongswan to begin with.
  $ipsec_options = {
    'cachecrls'       => 'no',
    'strictcrlpolicy' => 'no',
    'uniqueids'       => 'yes',
  }
  $charon_options = {
    'cisco_unity'        => 'yes',
    'crypto_test'        => {},
    'host_resolver'      => {},
    'leak_detective'     => {},
    'processor'          => {
      'priority_threads' => {},
    },
    'tls'  => {},
    'x509' => {},
  }
}
