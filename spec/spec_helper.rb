require 'rubygems'
#require 'simplecov'
#require 'simplecov-csv'
require 'puppetlabs_spec_helper/module_spec_helper'

# Configure the coverage reporter
#SimpleCov.start do
#  add_filter '/spec/'
#end
#SimpleCov.refuse_coverage_drop
#SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
#  SimpleCov::Formatter::HTMLFormatter,
#  SimpleCov::Formatter::CSVFormatter,
#]

# Facts mocked up for unit testing
FACTS = {
  :osfamily => 'Debian',
  :operatingsystem => 'Ubuntu',
  :operatingsystemrelease => '12',
  :lsbdistid => 'Ubuntu',
  :lsbdistcodename => 'precise',
  :lsbdistrelease => '12.04',
  :lsbmajdistrelease => '12',
  :kernel => 'linux',
  :ipaddress_eth0 => '127.0.0.1',
  :ipaddress => '127.0.0.1',
  :os => {
    :name => 'Ubuntu',
    :release => {
      :full => '12.04'
    }
  }
}
