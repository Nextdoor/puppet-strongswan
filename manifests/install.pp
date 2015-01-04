# == Class: strongswan::install
#
# Handles installation of the StrongSwan suite.
#
# === Optional Parameters
#
# [*package*]
#   The name of the Strongswan package to install.
#   (default: strongswan)
#
# [*plugins*]
#   List of additional plugin packages to install.
#   (default: undef)
#
# [*version*]
#   Version of Strongswan to install.
#   (default: installed)
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
class strongswan::install (
  $package = $strongswan::env::strongswan_package,
  $plugins = $strongswan::env::strongswan_plugins,
  $version = $strongswan::env::strongswan_version,
) inherits strongswan::env {
  package { $package:
    ensure => $version,
  }

  package { $plugins:
    ensure  => $version,
    require => Package[$package]
  }
}
