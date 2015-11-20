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

  context 'sample-pubkey-connection' do
    let(:params) {{
      :params => {
        'left'      => '1.2.3.4',
        'leftcert'  => 'foo.example.dev',
        'leftid'    => '@foo.example.dev.pem',
        'right'     => '2.3.4.5',
        'rightid'   => '@bar.example.dev',
      },
      :secrets => [
        { 'auth' => 'RSA', 'key' => 'foo.example.dev.pem' },
        { 'auth' => 'ECDSA', 'key' => 'bar.example.dev.pem',
          'passphrase' => 'foobar'}
      ],
    }}
    it do
      should compile.with_all_deps
      should contain_file('/etc/ipsec.d/secrets/ipsec.unittest.secrets').with(
        'content' => /: RSA foo.example.dev.pem/)
      should contain_file('/etc/ipsec.d/secrets/ipsec.unittest.secrets').with(
        'content' => /: ECDSA bar.example.dev.pem "foobar"/)
    end
  end
end
