require 'spec_helper'

describe 'strongswan', :type => 'class' do
  let(:facts) { FACTS }

  context 'default params' do
    it do
      should compile.with_all_deps
      should contain_class('strongswan::install')
      should contain_class('strongswan::config')
    end
  end

  context 'strongswan_package => custom_package, strongswan_version => 1.0, strongswan_plugins => [a, b]' do
    let(:params) {{
      :strongswan_package => 'custom_package',
      :strongswan_version => '1.0',
      :strongswan_plugins => ['a', 'b' ] }}
    it do
      should compile.with_all_deps
      should contain_class('strongswan::install').with(
        'package' => 'custom_package',
        'version' => '1.0',
        'plugins' => ['a', 'b'])
    end
  end

  context 'charon_options => {foo=>bar}' do
    let(:params) {{
      :charon_options => {'foo' => 'bar' }
    }}
    it do
      should compile.with_all_deps
      should contain_class('strongswan::config').with(
        'charon_options' => {'foo'=>'bar'})
    end
  end

  context 'ipsec_options => {foo=>bar}' do
    let(:params) {{
      :ipsec_options => {'foo' => 'bar' }
    }}
    it do
      should compile.with_all_deps
      should contain_class('strongswan::config').with(
        'ipsec_options' => {'foo'=>'bar'})
    end
  end
end
