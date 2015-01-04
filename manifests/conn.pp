# == Define: strongswan::conn
#
# Creates a Strongswan connection configuration.
#
# === Parameters
#
# [*secrets*]
#   A list of hashes of secrets in the following format:
#    [
#      { 'left_id' => '10.0.0.1', 'right_id' => '%any',
#        'auth'    => 'PSK', 'key' => 'xYsdfkjkasd' },
#      { 'left_id' => '10.0.0.2', 'right_id' => '%any',
#        'auth'    => 'PSK', 'key' => 'xYsdfkjkasd' },
#    ]
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
define strongswan::conn (
  $params,
  $secrets
) {
  validate_hash($params)
  validate_array($secrets)

  # Include the (hopefully already instantiated and configured) classes so that
  # we can get access to a few critical variables.
  include strongswan
  include strongswan::config
  include strongswan::service

  $_conn_conf_path    = $strongswan::config::conn_conf_path
  $_secrets_conf_path = $strongswan::config::secrets_conf_path

  file { "${_conn_conf_path}/ipsec.${name}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('strongswan/ipsec.conn.conf.erb'),
    notify  => Class['strongswan::service'],
    require => Class['strongswan::config'];
  }

  file { "${_secrets_conf_path}/ipsec.${name}.secrets":
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    show_diff => false,
    content   => template('strongswan/ipsec.conn.secrets.erb'),
    notify    => Class['strongswan::service'],
    require   => Class['strongswan::config'];
  }

}
