require 'spec_helper'

describe 'strongswan::presets::pam_authed_vpn', :type => 'class' do

  context 'default params' do
    it do
      should compile.with_all_deps
      should contain_class('strongswan')
      should contain_firewall('020 vpn-client inbound udp').with(
        'source' => '0.0.0.0/0')
      should contain_firewall('020 vpn-client masquerading').with(
        'source' => '192.168.0.0/24')
      should contain_firewall('021 vpn-client ipsec routing policy').with(
        'source' => '192.168.0.0/24')
      should contain_strongswan__conn('vpn')
    end
  end

  context 'client_source_ip => UNITTEST' do
    let(:params) {{ :client_source_ip => 'UNITTEST' }}
    it do
      should contain_firewall('020 vpn-client inbound udp').with(
        'source' => 'UNITTEST')
    end
  end

  context 'dns => [UNITTEST, UNITTEST2]' do
    let(:params) {{ :dns => ['UNITTEST', 'UNITTEST2'] }}
    it do
      should contain_strongswan__conn('vpn').with(
        'params' => /rightdns.*UNITTEST.*UNITTEST2/)
    end
  end

  context 'routed_ip_cidr => UNITTEST' do
    let(:params) {{ :routed_ip_cidr => 'UNITTEST' }}
    it do
      should contain_strongswan__conn('vpn').with(
        'params' => /leftsubnet.*UNITTEST/)
    end
  end

  context 'private_ip_cidr => UNITTEST' do
    let(:params) {{ :private_ip_cidr => 'UNITTEST' }}
    it do
      should contain_firewall('020 vpn-client masquerading').with(
        'source' => 'UNITTEST')
      should contain_firewall('021 vpn-client ipsec routing policy').with(
        'source' => 'UNITTEST')
      should contain_strongswan__conn('vpn').with(
        'params' => /rightsubnet.*UNITTEST/)
    end
  end

  context 'private_ip => UNITTEST' do
    let(:params) {{ :private_ip => 'UNITTEST' }}
    it do
      should contain_strongswan__conn('vpn').with(
        'params' => /rightsourceip.*UNITTEST/)
    end
  end
end
