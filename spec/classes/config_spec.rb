require 'spec_helper'

describe 'strongswan::config', :type => 'class' do
  let(:facts) { FACTS }

  context 'default params' do
    it do
      should compile.with_all_deps
      should contain_file('/etc/ipsec.secrets').with(
        'content' => /include \/etc\/ipsec.d\/secrets\/ipsec.\*.secrets/)
      should contain_file('/etc/ipsec.conf').with(
        'content' => /config setup\n  cachecrls = no/)
      should contain_file('/etc/ipsec.conf').with(
        'content' => /include \/etc\/ipsec.d\/conns\/ipsec.\*.conf/)
      should contain_file('/etc/ipsec.d')
      should contain_file('/etc/ipsec.d/conns')
      should contain_file('/etc/ipsec.d/secrets')
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /charon {\n  cisco_unity = yes/)
    end
  end

  context 'ipsec_options => {foo=>bar}' do
    let(:params) {{
      :ipsec_options => {'foo'=>'bar'}
    }}
    it do
      should compile.with_all_deps
      should contain_file('/etc/ipsec.conf').with(
        'content' => /foo = bar/)
    end
  end

  context 'charon_options => {lots of custom options}' do
    let(:params) {{
      :charon_options    => {
        'foo'            => 'bar',
        'baz'            => 'bat',
        'crypto_test'    => { 'crypto_foo' => 'crypto_bar' },
        'host_resolver'  => { 'host_foo' => 'host_bar', 'host_foo_2' => 'host_bar_2' },
        'leak_detective' => { 'leak_foo' => 'leak_bar' },
        'processor'      => { 'processor_foo' => 'processor_bar',
                             'priority_threads' => { 'priority_thread_foo' => 'priority_thread_bar' } },
        'tls'            => { 'tls_foo' => 'tls_bar' },
        'x509'           => { 'x509_foo' => 'x509_bar' },
        'syslog'         => { 'daemon' => { 'a_test' => '1' }, 'auth' => { 'a_test' => '2' } },
      }
    }}
    it do
      should compile.with_all_deps
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /charon {\n  baz = bat\n  cisco_unity = yes\n  foo = bar/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /crypto_test {\n    crypto_foo = crypto_bar\n/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /host_resolver {\n    host_foo = host_bar\n    host_foo_2 = host_bar_2/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /leak_detective {\n    leak_foo = leak_bar\n/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /priority_threads {\n      priority_thread_foo = priority_thread_bar\n/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /tls {\n    tls_foo = tls_bar\n/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /x509 {\n    x509_foo = x509_bar\n/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /daemon {\n      a_test = 1\n/)
      should contain_file('/etc/strongswan.d/charon.conf').with(
        'content' => /auth {\n      a_test = 2\n/)
    end
  end
end
