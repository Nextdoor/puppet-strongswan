require 'spec_helper'

describe 'strongswan::service', :type => 'class' do

  context 'default params' do
    it do
      should compile.with_all_deps
      should contain_service('strongswan')
    end
  end

  context 'service => foo, ensure => stopped, enable => false' do
    let(:params) {{
      :service => 'foo',
      :ensure  => 'stopped',
      :enable  => 'false'
    }}
    it do
      should compile.with_all_deps
      should contain_service('strongswan').with(
        'ensure' => 'stopped',
        'name'   => 'foo',
        'enable' => 'false')
    end
  end
end
