/*
 * Author: Yasuhito Takamiya <yasuhito@gmail.com>
 *
 * Copyright (C) 2008-2011 NEC Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License, version 2, as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


#include <string.h>
#include "trema.h"
#include "ruby.h"
#include "port.h"


extern VALUE mTrema;
VALUE cFeaturesReply;


static VALUE
features_reply_init( VALUE self, VALUE attribute ) {
  rb_iv_set( self, "@attribute", attribute );
  return self;
}


static VALUE
features_reply_datapath_id( VALUE self ) {
  return rb_hash_aref( rb_iv_get( self, "@attribute" ), ID2SYM( rb_intern( "datapath_id" ) ) );
}


static VALUE
features_reply_transaction_id( VALUE self ) {
  return rb_hash_aref( rb_iv_get( self, "@attribute" ), ID2SYM( rb_intern( "transaction_id" ) ) );
}


static VALUE
features_reply_n_buffers( VALUE self ) {
  return rb_hash_aref( rb_iv_get( self, "@attribute" ), ID2SYM( rb_intern( "n_buffers" ) ) );
}


static VALUE
features_reply_n_tables( VALUE self ) {
  return rb_hash_aref( rb_iv_get( self, "@attribute" ), ID2SYM( rb_intern( "n_tables" ) ) );
}


static VALUE
features_reply_capabilities( VALUE self ) {
  return rb_hash_aref( rb_iv_get( self, "@attribute" ), ID2SYM( rb_intern( "capabilities" ) ) );
}


static VALUE
features_reply_actions( VALUE self ) {
  return rb_hash_aref( rb_iv_get( self, "@attribute" ), ID2SYM( rb_intern( "actions" ) ) );
}


static VALUE
features_reply_ports( VALUE self ) {
  return rb_hash_aref( rb_iv_get( self, "@attribute" ), ID2SYM( rb_intern( "ports" ) ) );
}


void
Init_features_reply() {
  cFeaturesReply = rb_define_class_under( mTrema, "FeaturesReply", rb_cObject );
  rb_define_method( cFeaturesReply, "initialize", features_reply_init, 1 );
  rb_define_method( cFeaturesReply, "datapath_id", features_reply_datapath_id, 0 );
  rb_define_method( cFeaturesReply, "transaction_id", features_reply_transaction_id, 0 );
  rb_define_method( cFeaturesReply, "n_buffers", features_reply_n_buffers, 0 );
  rb_define_method( cFeaturesReply, "n_tables", features_reply_n_tables, 0 );
  rb_define_method( cFeaturesReply, "capabilities", features_reply_capabilities, 0 );
  rb_define_method( cFeaturesReply, "actions", features_reply_actions, 0 );
  rb_define_method( cFeaturesReply, "ports", features_reply_ports, 0 );
}


static VALUE
ports_from( const list_element *phy_ports ) {
  VALUE ports = rb_ary_new();
  list_element *port_head = xmalloc( sizeof( list_element ) );
  memcpy( port_head, phy_ports, sizeof( list_element ) );
  list_element *port = NULL;
  for ( port = port_head; port != NULL; port = port->next ) {
    rb_ary_push( ports, port_from( ( struct ofp_phy_port * ) port->data ) );
  }
  xfree( port_head );
  return ports;
}


void
handle_switch_ready( uint64_t datapath_id, void *controller ) {
  rb_funcall( ( VALUE ) controller, rb_intern( "switch_ready" ), 1, ULL2NUM( datapath_id ) );
}


void
handle_features_reply(
  uint64_t datapath_id,
  uint32_t transaction_id,
  uint32_t n_buffers,
  uint8_t n_tables,
  uint32_t capabilities,
  uint32_t actions,
  const list_element *phy_ports,
  void *controller
) {
  VALUE attributes = rb_hash_new();
  rb_hash_aset( attributes, ID2SYM( rb_intern( "datapath_id" ) ), UINT2NUM( datapath_id ) );
  rb_hash_aset( attributes, ID2SYM( rb_intern( "transaction_id" ) ), UINT2NUM( transaction_id ) );
  rb_hash_aset( attributes, ID2SYM( rb_intern( "n_buffers" ) ), UINT2NUM( n_buffers ) );
  rb_hash_aset( attributes, ID2SYM( rb_intern( "n_tables" ) ), UINT2NUM( n_tables ) );
  rb_hash_aset( attributes, ID2SYM( rb_intern( "capabilities" ) ), UINT2NUM( capabilities ) );
  rb_hash_aset( attributes, ID2SYM( rb_intern( "actions" ) ), UINT2NUM( actions ) );
  rb_hash_aset( attributes, ID2SYM( rb_intern( "ports" ) ), ports_from( phy_ports ) );

  VALUE features_reply = rb_funcall( cFeaturesReply, rb_intern( "new" ), 1, attributes );
  rb_funcall( ( VALUE ) controller, rb_intern( "features_reply" ), 1, features_reply );
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */

