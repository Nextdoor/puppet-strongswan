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
  $provider = $strongswan::env::service_provider,
  $ensure   = $strongswan::env::service_ensure,
  $enable   = $strongswan::env::service_enable,
) inherits strongswan::env {
  service { 'strongswan':
    ensure     => $ensure,
    provider   => $provider,
    name       => $service,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
  }
}
