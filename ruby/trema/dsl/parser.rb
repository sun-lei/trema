#
# DSL parser.
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


require "fileutils"
require "trema/dsl/syntax"
require "trema/path"


module Trema
  module DSL
    class Parser
      CURRENT_CONTEXT = File.join( Trema.tmp, ".context" )


      def self.dump context
        File.open( CURRENT_CONTEXT, "w" ) do | f |
          f.print Marshal.dump( context )
        end
      end


      def self.load file
        context = Context.new
        Syntax.new( context ).instance_eval IO.read( file ), file
        dump context
        context
      end


      def self.load_current
        context = Context.new
        if FileTest.exists?( CURRENT_CONTEXT )
          context = Marshal.load( IO.read CURRENT_CONTEXT )
        end
        context
      end


      def self.dump_after method
        Syntax.module_eval do
          original = instance_method( method )
          define_method( method ) do | *args, &block |
            if block
              original.bind( self ).call( *args, &block )
            else
              original.bind( self ).call( *args )
            end
            Parser.dump instance_variable_get( :@context )
          end
        end
      end


      dump_after :use_tremashark
      dump_after :port
      dump_after :link
      dump_after :switch
      dump_after :vswitch
      dump_after :vhost
      dump_after :filter
      dump_after :event
      dump_after :app
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
