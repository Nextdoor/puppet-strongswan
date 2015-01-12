require 'spec_helper'

describe 'strongswan::presets::meraki_vpn', :type => 'define' do
  let(:title) { 'UNITTEST' }

  context 'main test' do
    let(:params) {{
      :meraki_public_ip => 'MERAKI_PUBLIC_IP',
      :meraki_subnet    => 'MERAKI_SUBNET',
      :swan_public_ip   => 'SWAN_PUBLIC_IP',
      :swan_subnet      => 'SWAN_SUBNET',
      :psk              => 'PSK',
      :masquerade       => 'present',
    }}
    it do
      should compile.with_all_deps
      should contain_class('strongswan')
      should contain_class('strongswan::env')

      should contain_firewall('020 UNITTEST inbound udp').with(
        'source' => 'MERAKI_SUBNET')
      should contain_firewall('020 UNITTEST masquerading').with(
        'ensure' => 'present',
        'source' => 'MERAKI_SUBNET')
      should contain_firewall('020 UNITTEST ipsec routing policy').with(
        'source' => 'MERAKI_SUBNET')

      should contain_strongswan__conn('UNITTEST').with(
        'params'  => /MERAKI_PUBLIC_IP/,
        'secrets' => /PSK/)
    end
  end
end
