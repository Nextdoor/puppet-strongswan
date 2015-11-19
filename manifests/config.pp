# == Class: strongswan::config
#
# Configures Strongswan itself -- all core configuration options, but no
# actual connections are defined.
#
# === Optional Parameters
#
# [*ipsec_options*]
#   Default set of options to put into the 'config setup' section of the
#   /etc/ipsec.conf file. Defaults can be found in the Strongswan::Env
#   class. Options are passed in the form of a hash.
#   (default: {})
#
# [*charon_options*]
#   Custom options to add to the /etc/strongswan.d/charon.conf file. Options
#   are passed in the form of a hash.
#   (default: {})
#
# [*conn_conf_path*]
#   Where we store custom connection configs.
#   (default: /etc/ipsec.d/conns)
#
# [*secrets_conf_path*]
#   Where we store custom connection configs.
#   (default: /etc/ipsec.d/secrets)
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
class strongswan::config (
  $ipsec_options     = {},
  $charon_options    = {},
  $conn_conf_path    = $strongswan::env::conn_conf_path,
  $secrets_conf_path = $strongswan::env::secrets_conf_path,
) inherits strongswan::env {
  validate_hash($ipsec_options, $charon_options)

  # Merge the supplied options with the default options and then manage the
  # /etc/ipsec.conf file defaults.
  $_ipsec_options = merge($strongswan::env::ipsec_options, $ipsec_options)
  file {
    '/etc/ipsec.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('strongswan/ipsec.conf.erb');

    '/etc/ipsec.d':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0750';

    $conn_conf_path:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    recurse => true,
    purge   => true,
    backup  => false,
    require => File['/etc/ipsec.d'];

    # Used to ensure that the 'include ..' line in the /etc/ipsec.conf file
    # doesn't throw an error saying there are no files to include.
    "${conn_conf_path}/ipsec.blank.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => '',
    require => File[$conn_conf_path];

    $secrets_conf_path:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    recurse => true,
    purge   => true,
    backup  => false,
    require => File['/etc/ipsec.d'];

    # Used to ensure that the 'include ..' line in the /etc/ipsec.secrets file
    # doesn't throw an error saying there are no files to include.
    "${secrets_conf_path}/ipsec.blank.secrets":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => '',
    require => File[$secrets_conf_path];

    # /etc/ipsec.secrets is not used, instead we create individual secret files
    # in /etc/ipsec.d when we create connections
    '/etc/ipsec.secrets':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    content   => template('strongswan/ipsec.secrets.erb');
  }

  $strongswan_d = '/etc/strongswan.d'
  $charon_conf = "${strongswan_d}/charon.conf"

  # Ensure settings from strongwan.d are included.
  file { $strongswan_d:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file_line { 'include-strongswan.d':
    ensure => present,
    path   => '/etc/strongswan.conf',
    line   => 'include strongswan.d/*.conf',
  }

  # Merge the supplied charon configuration options and generate the charon
  # config file.
  $_charon_options = merge($strongswan::env::charon_options, $charon_options)
  file { $charon_conf:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('strongswan/charon.conf.erb'),
  }
}
