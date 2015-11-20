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
#      { 'auth' => 'RSA', 'key' => "${::fqdn}.pem" },
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

  file { "${_conn_conf_path}/ipsec.${title}.conf":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('strongswan/ipsec.conn.conf.erb'),
    notify  => Class['strongswan::service'],
    require => Class['strongswan::config'];
  }

  $secrets_conf = "${_secrets_conf_path}/ipsec.${title}.secrets"
  if count($secrets) > 0 {
    $secrets_ensure = 'file'
  } else {
    $secrets_ensure = 'absent'
  }

  file { $secrets_conf:
    ensure    => $secrets_ensure,
    owner     => 'root',
    group     => 'root',
    mode      => '0600',
    backup    => false,
    show_diff => false,
    content   => template('strongswan/ipsec.conn.secrets.erb'),
    notify    => Class['strongswan::service'],
    require   => Class['strongswan::config'];
  }

}
