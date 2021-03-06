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


$LOAD_PATH << File.join( File.dirname( __FILE__ ), "/../ruby" )


require "rubygems"

require "rspec"
require "trema/dsl/context"


def trema_conf conf
  context = Trema::DSL::Context.new
  Trema::DSL::Syntax.new( context ).instance_eval conf

  Trema::Controller.each do | each |
    context.add_app each
  end
  
  context.switch_manager.run
  context.links.each do | each |
    each.up!
  end
  context.hosts.each do | each |
    each.run
  end
  context.switches.each do | each |
    each.run
  end
  context.hosts.each do | each |
    each.add_arp_entry context.hosts - [ each ]
  end

  Process.fork do
    context.apps.last.run
  end
end


def trema_kill
  system "./trema kill"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
