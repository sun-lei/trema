#
# Author: Yasuhito Takamiya <yasuhito@gmail.com>
#
# Copyright (C) 2008-2011 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


Given /^I terminated all trema services$/ do
  run "sudo ./trema kill"
end


Given /^I terminate all trema services$/ do
  Given "I terminated all trema services"
end


When /^I try to run "([^"]*)"$/ do | command |
  if / > /=~ command
    # redirected
    run command
  else
    @log = `mktemp`.chomp
    run "#{ command } > #{ @log }"
  end
end


When /^I try to run "([^"]*)" \(log = "([^"]*)"\)$/ do | command, log_name |
  log = File.join( Trema.log_directory, log_name )
  run "#{ command } > #{ log }"
end


When /^I try to run "([^"]*)" with following configuration:$/ do | command, config |
  @trema_log = `mktemp`.chomp

  Tempfile.open( "trema.conf" ) do | conf |
    conf.puts config
    conf.flush
    run "#{ command } -c #{ conf.path } > #{ @trema_log } 2>&1"
  end
end


When /^\*\*\* sleep (\d+) \*\*\*$/ do | sec |
  sleep sec.to_i
end


When /^wait until "([^"]*)" is up$/ do | process |
  loop do
    break if FileTest.exists?( File.join( Trema.tmp, "#{ process }.pid" ) )
    sleep 1
  end
end


Then /^the output should be:$/ do | string |
  IO.read( @log ).chomp.should == string.chomp
end


Then /^the output of trema should be:$/ do | string |
  IO.read( @trema_log ).chomp.should == string.chomp
end


Then /^the output of trema should include:$/ do | string |
  string.chomp.split( "\n" ).each do | each |
    IO.read( @trema_log ).split( "\n" ).should include( each )
  end
end


Then /^"([^"]*)" should be executed with option = "([^"]*)"$/ do | executable, options |
  IO.read( @trema_log ).should match( Regexp.new "#{ executable } #{ options }" )
end


Then /^the log file "([^"]*)" should be:$/ do | log_name, string |
  log = File.join( Trema.log_directory, log_name )
  IO.read( log ).chomp.should == string.chomp
end


Then /^the log file "([^"]*)" should include:$/ do | log_name, string |
  log = File.join( Trema.log_directory, log_name )
  IO.read( log ).split( "\n" ).should include( string )
end


Then /^the log file "([^"]*)" should include "([^"]*)" x (\d+)$/ do | log, message, n |
  IO.read( log ).split( "\n" ).inject( 0 ) do | matched, each |
    matched += 1 if each.include?( message )
    matched
  end.should == n.to_i
end


Then /^the content of "([^"]*)" and "([^"]*)" should be identical$/ do | log1, log2 |
  IO.read( log1 ).size.should > 0
  IO.read( log2 ).size.should > 0
  IO.read( log1 ).chomp.should == IO.read( log2 ).chomp
end


Then /^([^\s]*) is terminated$/ do | name |
  ps_entry_of( name ).should be_empty
end


Then /^([^\s]*) is started$/ do | name |
  ps_entry_of( name ).should_not be_empty
end


Then /^switch_manager should be killed$/ do
  IO.read( @trema_log ).should match( /^Terminating switch_manager/ )
end


Then /^the total number of tx packets should be:$/ do | table |
  table.hashes[ 0 ].each_pair do | host, n |
    stats = `./trema show_stats #{ host } --tx`
    next if stats.split.size <= 1
    `./trema show_stats #{ host } --tx`.split[ 1..-1 ].inject( 0 ) do | sum, each |
      # ip_dst,tp_dst,ip_src,tp_src,n_pkts,n_octets
      sum += each.split( "," )[ 4 ].to_i
    end.should == n.to_i
  end
end


Then /^the total number of rx packets should be:$/ do | table |
  table.hashes[ 0 ].each_pair do | host, n |
    stats = `./trema show_stats #{ host } --rx`
    next if stats.split.size <= 1
    stats.split[ 1..-1 ].inject( 0 ) do | sum, each |
      if each.split( "," )[ 0 ].split( "." ).last == host.split( // ).last
        sum += each.split( "," )[ 4 ].to_i
      end
      sum
    end.should == n.to_i
  end
end
