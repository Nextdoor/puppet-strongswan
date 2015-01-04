require 'spec_helper'

describe 'strongswan::conn', :type => 'define' do
  let(:title) { 'unittest' }

  context 'sample-vpc-connection' do
    let(:params) {{
      :params => {
        'foo'  => 'bar',
        'foo2' => 'bar2',
      },
      :secrets => [
        { 'left_id' => '1.2.3.4', 'right_id' => '%any',
          'auth'    => 'PSK', 'key' => 'Mykey' },
        { 'left_id' => '2.3.4.5', 'right_id' => '%any',
          'auth'    => 'PSK', 'key' => 'Mykey2' },
      ],
    }}
    it do
      should compile.with_all_deps
      should contain_file('/etc/ipsec.d/secrets/ipsec.unittest.secrets').with(
        'content' => /1.2.3.4 %any : PSK "Mykey"/)
      should contain_file('/etc/ipsec.d/secrets/ipsec.unittest.secrets').with(
        'content' => /2.3.4.5 %any : PSK "Mykey2"/)

      should contain_file('/etc/ipsec.d/conns/ipsec.unittest.conf').with(
        'content' => /foo=bar/)
      should contain_file('/etc/ipsec.d/conns/ipsec.unittest.conf').with(
        'content' => /foo2=bar2/)
    end
  end
end
