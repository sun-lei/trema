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


require File.join( File.dirname( __FILE__ ), "..", "..", "spec_helper" )
require "trema/dsl/runner"


module Trema
  module DSL
    describe Runner do
      before :each do
        ::Process.stub!( :fork ).and_yield
        ::Process.stub!( :waitpid )
      end

      
      context "when running" do
        it "should run tremashark" do
          tremashark = mock
          tremashark.should_receive( :run ).once

          config = mock(
            "config",
            :tremashark => tremashark,
            :switch_manager => nil,
            :packetin_filter => nil,
            :links => [],
            :hosts => [],
            :switches => [],
            :apps => []
          )

          Runner.new( config ).run
        end


        it "should run switch_manager" do
          switch_manager = mock
          switch_manager.should_receive( :run ).once

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => switch_manager,
            :packetin_filter => nil,
            :links => [],
            :hosts => [],
            :switches => [],
            :apps => []
          )

          Runner.new( config ).run
        end


        it "should run packetin_filter" do
          packetin_filter = mock
          packetin_filter.should_receive( :run ).once

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => nil,
            :packetin_filter => packetin_filter,
            :links => [],
            :hosts => [],
            :switches => [],
            :apps => []
          )

          Runner.new( config ).run
        end


        it "should create links" do
          link0 = mock( "link0" )
          link0.should_receive( :down! ).once.ordered
          link0.should_receive( :up! ).once.ordered

          link1 = mock( "link1" )
          link1.should_receive( :down! ).once.ordered
          link1.should_receive( :up! ).once.ordered

          link2 = mock( "link2" )
          link2.should_receive( :down! ).once.ordered
          link2.should_receive( :up! ).once.ordered

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => nil,
            :packetin_filter => nil,
            :links => [ link0, link1, link2 ],
            :hosts => [],
            :switches => [],
            :apps => []
          )

          Runner.new( config ).run
        end


        it "should run vhosts" do
          host0 = mock( "host0" )
          host1 = mock( "host1" )
          host2 = mock( "host2" )

          host0.should_receive( :run ).once.ordered
          host0.should_receive( :add_arp_entry ).with( [ host1, host2 ] ).once.ordered

          host1.should_receive( :run ).once.ordered
          host1.should_receive( :add_arp_entry ).with( [ host0, host2 ] ).once.ordered

          host2.should_receive( :run ).once.ordered
          host2.should_receive( :add_arp_entry ).with( [ host0, host1 ] ).once.ordered

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => nil,
            :packetin_filter => nil,
            :links => [],
            :hosts => [ host0, host1, host2 ],
            :switches => [],
            :apps => []
          )

          Runner.new( config ).run
        end


        it "should run switches" do
          switch0 = mock( "switch0" )
          switch0.should_receive( :run ).once.ordered

          switch1 = mock( "switch1" )
          switch1.should_receive( :run ).once.ordered

          switch2 = mock( "switch2" )
          switch2.should_receive( :run ).once.ordered

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => nil,
            :packetin_filter => nil,
            :links => [],
            :hosts => [],
            :switches => [ switch0, switch1, switch2 ],
            :apps => []
          )

          Runner.new( config ).run
        end


        it "should run apps" do
          app0 = mock( "app0" )
          app0.should_receive( :daemonize ).once.ordered

          app1 = mock( "app1" )
          app1.should_receive( :daemonize ).once.ordered

          app2 = mock( "app2" )
          app2.should_receive( :run ).once.ordered

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => nil,
            :packetin_filter => nil,
            :links => [],
            :hosts => [],
            :switches => [],
            :apps => [ app0, app1, app2 ]
          )

          Runner.new( config ).run
        end


        it "should daemonize apps" do
          app0 = mock( "app0" )
          app0.should_receive( :daemonize ).once.ordered

          app1 = mock( "app1" )
          app1.should_receive( :daemonize ).once.ordered

          app2 = mock( "app2" )
          app2.should_receive( :daemonize ).once.ordered

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => nil,
            :packetin_filter => nil,
            :links => [],
            :hosts => [],
            :switches => [],
            :apps => [ app0, app1, app2 ]
          )

          Runner.new( config ).daemonize
        end
      end


      context "on tear-down" do
        it "should delete links" do
          link0 = mock( "link0" )
          link0.should_receive( :down! ).once.ordered

          link1 = mock( "link1" )
          link1.should_receive( :down! ).once.ordered

          link2 = mock( "link2" )
          link2.should_receive( :down! ).once.ordered

          config = mock(
            "config",
            :tremashark => nil,
            :switch_manager => nil,
            :packetin_filter => nil,
            :links => [ link0, link1, link2 ],
            :hosts => [],
            :switches => [],
            :apps => []
          )

          Runner.new( config ).tear_down
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
