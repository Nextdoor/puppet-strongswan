require 'spec_helper'

describe 'strongswan::presets::meraki_vpn', :type => 'define' do
  let(:facts) { FACTS }
  let(:title) { 'UNITTEST' }

  context 'main test' do
    let(:params) {{
      :meraki_public_ip => '123.123.123.123',
      :meraki_subnet    => '192.168.0.0/24',
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
        'source' => '123.123.123.123')
      should contain_firewall('020 UNITTEST masquerading').with(
        'ensure' => 'present',
        'source' => '192.168.0.0/24')
      should contain_firewall('021 UNITTEST ipsec routing policy').with(
        'source' => '192.168.0.0/24')

      should contain_strongswan__conn('UNITTEST').with(
        'params'  => /123.123.123.123/,
        'secrets' => /PSK/)
    end
  end
end
