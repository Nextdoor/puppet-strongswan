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

  # Common VPC connection settings reused by both connections. These parameters
  # are described in detail in your VPN Connection configuration file that can
  # be downloaded from Amazon, but are also described in their documentation
  # here:
  #
  #   http://docs.aws.amazon.com/AmazonVPC/latest/NetworkAdminGuide/Introduction.html#CGRequirements
  #
  $_aws_params = {
    # VPCs use IKEv2 as their key exchange model.
    'keyexchange' => 'ikev2',
    'esp'         => 'aes128-sha1-modp1024',

    # Expected key-lifetimes
    'ikelifetime' => '28800s',
    'keylife'     => '3600s',

    # Amazon will initiate re-keying on its own, but will not respond to our
    # own request to re-key. Thus, we disable client-side re-keying.
    'rekey'       => 'no',
    'reauth'      => 'no',

    # Use the pre-shared-secret model to authenticate with the endpoints.
    'authby'      => 'secret',

    # Amazon closes VPC Tunnels after 5-10 minutes of "inactivity" (as defined
    # by amazon, its "interesting traffic" ... DPD traffic does not apply).
    # This tells strongSwan to automatically restart the connection the second
    # its closed by Amazon.
    'closeaction' => 'restart',

    # Dead Peer Detection settings.
    'dpddelay'    => '10s',
    'dpdtimeout'  => '30s',

    # In the event that the DPD timeout occurs, we are the ones re-initiating
    # the connection.
    'dpdaction'   => 'restart',

    # The VPC CIDR that we will be routing traffic to. This is common between
    # both the primary and failover ipsec tunnels.
    'rightsubnet' => $vpc_subnet,
  }
  $_ipsec_1_params = merge($_aws_params,
    { 'auto'        => 'start',
      'leftid'      => $customer_gateway_ip,
      'leftsubnet'  => $customer_subnet,
      'right'       => $ipsec_1_vpg_ip,
      'rightid'     => $ipsec_1_vpg_ip})
  $_ipsec_1_secrets = [
    { 'left_id' => '%any', 'right_id' => $ipsec_1_vpg_ip,
      'auth'    => 'PSK', 'key' => $ipsec_1_psk } ]

  $_ipsec_2_params = merge($_aws_params,
    { 'auto'        => 'start',
      'leftid'      => $customer_gateway_ip,
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
