# == Class: strongswan
#
# Installs and manages Strongswan on Ubuntu.
#
# === Optional Parameters
#
# [*charon_options*]
#   A hash of custom options for the /etc/strongswan.d/charon.conf file
#   (default: {})
#
# [*conn_conf_path*]
#   Directory to store individual IPSec Connection configuration files in.
#   (default: /etc/ipsec.d/connfs)
#
# [*ipsec_options*]
#   A hash of settings for the 'config settings' section of the /etc/ipsec.conf
#   file.
#   (default: {})
#
# [*secrets_conf_path*]
#   Directory to store individual IPSec Connection secret files in.
#   (default: /etc/ipsec.d/secrets)
#
# [*service_name*]
#   Name of the StrongSwan service daemon.
#   (default: strongswan)
#
# [*service_ensure*]
#   Whether to ensure the service is running or not.
#   (default: running)
#
# [*service_enable*]
#   Whether to enable the strongswan service on system startup.
#   (default: true)
#
# [*strongswan_package*]
#   Name of the Strongswan package to install.
#   (default: strongswan)
#
# [*strongswan_version*]
#   Version of the Strongswan packages to install.
#   (default: installed)
#
# [*strongswan_plugins*]
#   (default: [ strongswan-plugin-unity, strongswan-plugin-xauth-pam ])
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
class strongswan (
  $charon_options     = {},
  $conn_conf_path     = $strongswan::env::conn_conf_path,
  $ipsec_options      = {},
  $secrets_conf_path  = $strongswan::env::secrets_conf_path,
  $service_name       = $strongswan::env::service_name,
  $service_ensure     = $strongswan::env::service_ensure,
  $service_enable     = $strongswan::env::service_enable,
  $strongswan_package = $strongswan::env::strongswan_package,
  $strongswan_version = $strongswan::env::strongswan_version,
  $strongswan_plugins = $strongswan::env::strongswan_plugins
) inherits strongswan::env {
  class { 'strongswan::install':
    package => $strongswan_package,
    version => $strongswan_version,
    plugins => $strongswan_plugins,
  }
  contain strongswan::install


  # Now, begin configuring the strongswan service.
  class { 'strongswan::config':
    ipsec_options     => $ipsec_options,
    charon_options    => $charon_options,
    conn_conf_path    => $conn_conf_path,
    secrets_conf_path => $secrets_conf_path,
    require           => Class['strongswan::install'];
  }
  contain strongswan::config

  # Manage the service. If its not running, this will take care of starting it.
  class { 'strongswan::service':
    ensure    => $service_ensure,
    service   => $service_name,
    enable    => $service_enable,
    subscribe => Class['strongswan::config'],
    require   => Class['strongswan::config'];
  }
}
