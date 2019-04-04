require 'spec_helper'

describe 'strongswan::presets::aws_vpc', :type => 'define' do
  let(:title) { 'UNITTEST' }
  let(:facts) { FACTS }

  context 'main test' do
    let(:params) {{
      :customer_gateway_ip => 'CGW_IP',
      :customer_subnet     => 'CGW_SN',
      :ipsec_1_vpg_ip      => 'IPS1_VPG_IP',
      :ipsec_1_psk         => 'IPS1_PSK',
      :ipsec_2_vpg_ip      => 'IPS2_VPG_IP',
      :ipsec_2_psk         => 'IPS2_PSK',
      :vpc_subnet          => 'VPC_SN'
    }}
    it do
      should compile.with_all_deps
      should contain_class('strongswan')

      # Test that the generic parameters made it into the merged hash
      should contain_strongswan__conn('UNITTEST-1').with(
        'params' => /ikelifetime.*28800s/)
      should contain_strongswan__conn('UNITTEST-2').with(
        'params' => /ikelifetime.*28800s/)

      # Test that the custom parameters made it into the merged hash
      should contain_strongswan__conn('UNITTEST-1').with(
        'params' => /CGW_IP/)
      should contain_strongswan__conn('UNITTEST-2').with(
        'params' => /CGW_IP/)

      should contain_strongswan__conn('UNITTEST-1').with(
        'params' => /CGW_SN/)
      should contain_strongswan__conn('UNITTEST-2').with(
        'params' => /CGW_SN/)


      should contain_strongswan__conn('UNITTEST-1').with(
        'params' => /IPS1_VPG_IP/)
      should contain_strongswan__conn('UNITTEST-2').with(
        'params' => /IPS2_VPG_IP/)

      should contain_strongswan__conn('UNITTEST-1').with(
        'secrets' => /IPS1_PSK/)
      should contain_strongswan__conn('UNITTEST-2').with(
        'secrets' => /IPS2_PSK/)

      should contain_strongswan__conn('UNITTEST-1').with(
        'params' => /VPC_SN/)
      should contain_strongswan__conn('UNITTEST-2').with(
        'params' => /VPC_SN/)
    end
  end
end
