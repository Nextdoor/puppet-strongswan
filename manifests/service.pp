# == Class: strongswan::service
#
# Manages the StrongSwan daemon, ensuring that its running.
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
class strongswan::service (
  $service  = $strongswan::env::service_name,
  $ensure   = $strongswan::env::service_ensure,
  $enable   = $strongswan::env::service_enable,
) inherits strongswan::env {
  service { 'strongswan':
    ensure     => $ensure,
    name       => $service,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }
}
