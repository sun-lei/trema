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
require "trema/cli"


describe Cli do
  before :each do
    @cli = Cli.new
    @source = mock( "source", :interface => "trema-0", :ip => "192.168.0.1" )
    @dest = mock( "dest", :interface => "trema-1", :ip => "192.168.0.2" )
  end


  context "when sending packets" do
    it "should send packets (default)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22$/ )
      @cli.send_packets( @source, @dest )
    end


    it "should send packets (inc_ip_src)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_ip_src$/ )
      @cli.send_packets( @source, @dest, :inc_ip_src => true )
    end


    it "should send packets (inc_ip_src = 1)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_ip_src=1$/ )
      @cli.send_packets( @source, @dest, :inc_ip_src => 1 )
    end


    it "should send packets (inc_ip_dst)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_ip_dst$/ )
      @cli.send_packets( @source, @dest, :inc_ip_dst => true )
    end


    it "should send packets (inc_ip_dst = 1)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_ip_dst=1$/ )
      @cli.send_packets( @source, @dest, :inc_ip_dst => 1 )
    end


    it "should send_packets (tp_src = 60000)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 60000 --tp_dst 1 --pps 1 --duration 1 --length 22$/ )
      @cli.send_packets( @source, @dest, :tp_src => 60000 )
    end


    it "should send_packets (tp_dst = 10000)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 10000 --pps 1 --duration 1 --length 22$/ )
      @cli.send_packets( @source, @dest, :tp_dst => 10000 )
    end


    it "should send packets (inc_tp_src)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_tp_src$/ )
      @cli.send_packets( @source, @dest, :inc_tp_src => true )
    end


    it "should send packets (inc_tp_src = 1)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_tp_src=1$/ )
      @cli.send_packets( @source, @dest, :inc_tp_src => 1 )
    end


    it "should send_packets (pps = 100)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 100 --duration 1 --length 22$/ )
      @cli.send_packets( @source, @dest, :pps => 100 )
    end


    it "should send packets (duration = 10)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 10 --length 22$/ )
      @cli.send_packets( @source, @dest, :duration => 10 )
    end


    it "should send packets (length = 1000)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 1000$/ )
      @cli.send_packets( @source, @dest, :length => 1000 )
    end


    it "should send_packets (inc_tp_dst)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_tp_dst$/ )
      @cli.send_packets( @source, @dest, :inc_tp_dst => true )
    end


    it "should send_packets (inc_tp_dst = 65534)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_tp_dst=65534$/ )
      @cli.send_packets( @source, @dest, :inc_tp_dst => 65534 )
    end


    it "should send_packets (inc_payload)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_payload$/ )
      @cli.send_packets( @source, @dest, :inc_payload => true )
    end


    it "should send_packets (inc_payload = 1000)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --duration 1 --length 22 --inc_payload=1000$/ )
      @cli.send_packets( @source, @dest, :inc_payload => 1000 )
    end


    it "should send_packets (n_pkts = 10)" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 send_packets --ip_src 192.168.0.1 --ip_dst 192.168.0.2 --tp_src 1 --tp_dst 1 --pps 1 --length 22 --n_pkts=10$/ )
      @cli.send_packets( @source, @dest, :n_pkts => 10 )
    end


    it "should raise if both --duration and --n_pkts are specified" do
      lambda do
        @cli.send_packets( @source, @dest, :duration => 10, :n_pkts => 10 )
      end.should raise_error( "--duration and --n_pkts are exclusive." )
    end
  end


  context "when showing stats" do
    it "should show_stats of tx" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 show_stats --tx$/ )
      @cli.show_tx_stats @source
    end


    it "should show_stats of rx" do
      @cli.should_receive( :sh ).with( /cli -i trema-1 show_stats --rx$/ )
      @cli.show_rx_stats @dest
    end
  end


  context "when resetting stats" do
    it "should reset_stats" do
      @cli.should_receive( :sh ).with( /cli -i trema-0 reset_stats$/ )
      @cli.reset_stats @source
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
