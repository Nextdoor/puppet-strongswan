# == Define: strongswan::presets:aws_vpc
#
# Creates a connection to an Amazon VPC through the AWS VPN Connection/Customer
# Gateway endpoints. Expects that you have already created the CGW/VPN
# endpoints, and assigned your instance an ElasticIP (or your server has a
# static public IP from wherever its network provider is).
#
# === Required Parameters
#
# [*title*]
#   The title of the connection. Suggest the name of the VPC.
#
# [*customer_gateway_ip*]
#   (Line 77 of the Generic VPC Configuration from Amazon)
#
# [*customer_subnet*]
#   The subnet on the 'left' (client) side of the tunnel. Can be as small as a
#   /32, or as large as you want. Should match whatever static route you have
#   configured in your VPN Connection endpoint in Amazon.
#
# [*ipsec_1_vpg_ip*]
#   (Line 78 of the Generic VPC Configuration from Amazon)
#
# [*ipsec_1_psk*]
#   (Line 25 of the Generic VPC Configuration from Amazon)
#
# [*ipsec_2_vpg_ip*]
#   (Line 162 of the Generic VPC Configuration from Amazon)
#
# [*ipsec_2_psk*]
#   (Line 109 of the Generic VPC Configuration from Amazon)

# [*vpc_subnet*]
#   VPC Subnet CIDR
#
# === Authors
#
# Matt Wise <matt@nextdoor.com>
#
define strongswan::presets::aws_vpc (
  $customer_gateway_ip,
  $customer_subnet,
  $ipsec_1_vpg_ip,
  $ipsec_1_psk,
  $ipsec_2_vpg_ip,
  $ipsec_2_psk,
  $vpc_subnet,
) {
  # First, make sure that strongswan has been configured. In general, this
  # should be done ahead of time if you want any custom settings.
  include strongswan

  # Common VPC connection settings reused by both connections
  $_aws_params = {
    'esp'         => 'aes128-sha1-modp1024',
    'ikelifetime' => '28800s',
    'keylife'     => '3600s',
    'rekey'       => 'no',
    'reauth'      => 'no',
    'keyexchange' => 'ikev2',
    'auto'        => 'start',
    'authby'      => 'secret',
    'dpdaction'   => 'restart',
    'rightsubnet' => $vpc_subnet,
  }
  $_ipsec_1_params = merge($_aws_params,
    { 'leftid'      => $customer_gateway_ip,
      'leftsubnet'  => $customer_subnet,
      'right'       => $ipsec_1_vpg_ip,
      'rightid'     => $ipsec_1_vpg_ip})
  $_ipsec_1_secrets = [
    { 'left_id' => '%any', 'right_id' => $ipsec_1_vpg_ip,
      'auth'    => 'PSK', 'key' => $ipsec_1_psk } ]

  $_ipsec_2_params = merge($_aws_params,
    { 'leftid'      => $customer_gateway_ip,
      'leftsubnet'  => $customer_subnet,
      'right'       => $ipsec_2_vpg_ip,
      'rightid'     => $ipsec_2_vpg_ip})
  $_ipsec_2_secrets = [
    { 'left_id' => '%any', 'right_id' => $ipsec_2_vpg_ip,
      'auth'    => 'PSK', 'key' => $ipsec_2_psk } ]

  # Now create the two tunnels
  strongswan::conn {
    "${title}-1":
    params  => $_ipsec_1_params,
    secrets => $_ipsec_1_secrets;

    "${title}-2":
    params  => $_ipsec_2_params,
    secrets => $_ipsec_2_secrets;
  }
}
