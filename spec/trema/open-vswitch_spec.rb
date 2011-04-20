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


require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )
require "trema/dsl/vswitch"
require "trema/open-vswitch"


describe OpenVswitch, %[dpid = "0xabc"] do
  before :each do
    stanza = Trema::DSL::Vswitch.new
    stanza.dpid "0xabc"
    @vswitch = OpenVswitch.new( stanza, 1234 )
  end


  it "should return its name" do
    @vswitch.name.should == "0xabc"
  end


  it "should return dpid in long format" do
    @vswitch.dpid_long.should == "0000000000000abc"
  end


  it "should return dpid in short format" do
    @vswitch.dpid_short.should == "0xabc"
  end


  it "should execute ovs openflowd" do
    @vswitch.should_receive( :sh ).once

    @vswitch.add_interface "trema0-0"
    @vswitch.add_interface "trema0-1"
    @vswitch.run
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
