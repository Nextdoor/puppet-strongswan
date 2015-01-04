require 'spec_helper'

describe 'strongswan::install', :type => 'class' do
  let(:facts) { FACTS }

  context 'default params' do
    it do
      should compile.with_all_deps
      should contain_package('strongswan')
      should contain_package('strongswan-plugin-unity')
      should contain_package('strongswan-plugin-xauth-pam')
    end
  end

  context 'version => 1.0' do
    let(:params) {{ :version => '1.0' }}
    it do
      should compile.with_all_deps
      should contain_package('strongswan').with(
        'ensure' => '1.0')
      should contain_package('strongswan-plugin-unity').with(
        'ensure' => '1.0')
    end
  end

  context 'package => some_other_name' do
    let(:params) {{ :package => 'some_other_name' }}
    it do
      should compile.with_all_deps
      should contain_package('some_other_name')
    end
  end

  context 'plugins => [] 'do
    let(:params) {{ :plugins => [] }}
    it do
      should compile.with_all_deps
      should_not contain_package('strongswan-plugin-unity')
    end
  end
end
