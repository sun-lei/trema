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


#include "trema.h"
#include "controller.h"
#include "features_reply.h"
#include "packet_in.h"


extern VALUE mTrema;
VALUE cController;


static VALUE
controller_inherited( VALUE self, VALUE klass ) {
  VALUE controller = rb_funcall( klass, rb_intern( "new" ), 0 );
  rb_funcall( rb_gv_get( "$controllers" ), rb_intern( "<<" ), 1, controller );
  return self;
}


static VALUE
controller_init( VALUE self ) {
  int i;
  int argc = NUM2INT( rb_funcall( rb_gv_get( "$*" ), rb_intern( "size" ), 0 ) );
  char **argv = malloc( sizeof( char * ) * ( argc + 1 ) );
  for ( i = 0; i < argc; i++ ) {
    argv[ i ] = STR2CSTR( rb_funcall( rb_gv_get( "$*" ), rb_intern( "[]" ), 1, INT2FIX( i ) ) );
  }
  argv[ argc ] = NULL;

  setenv( "TREMA_HOME", STR2CSTR( rb_funcall( mTrema, rb_intern( "home" ), 0 ) ), 1 );

  init_trema( &argc, &argv );

  set_switch_ready_handler( handle_switch_ready, ( void * ) self );
  set_features_reply_handler( handle_features_reply, ( void * ) self );
  set_packet_in_handler( handle_packet_in, ( void * ) self );

  return self;
}


static VALUE
controller_name( VALUE self ) {
  return rb_str_new2( get_trema_name() );
}


static VALUE
controller_send_message( VALUE self, VALUE message, VALUE dpid ) {
  buffer *buf;
  Data_Get_Struct( message, buffer, buf );
  send_openflow_message( NUM2ULONG( dpid ), buf );
  return self;
}


static VALUE
controller_run( VALUE self ) {
  rb_funcall( self, rb_intern( "start" ), 0 );
  start_trema();
  return self;
}


static VALUE
controller_stop( VALUE self ) {
  stop_trema();
  return self;
}


/********************************************************************************
 * Handlers.
 ********************************************************************************/

// Override me if necessary.
static VALUE
controller_start( VALUE self ) {
  return self;
}


// Override me if necessary.
static VALUE
controller_switch_ready( VALUE self, VALUE datapath_id ) {
  return self;
}


// Override me if necessary.
static VALUE
controller_features_reply( VALUE self, VALUE message ) {
  return self;
}


// Override me if necessary.
static VALUE
controller_packet_in( VALUE self, VALUE packet_in ) {
  return self;
}


/********************************************************************************
 * Logging methods.
 ********************************************************************************/

static VALUE
controller_critical( int argc, VALUE *argv, VALUE self ) {
  critical( STR2CSTR( rb_f_sprintf( argc, argv ) ) );
  return self;
}


static VALUE
controller_error( int argc, VALUE *argv, VALUE self ) {
  error( STR2CSTR( rb_f_sprintf( argc, argv ) ) );
  return self;
}


static VALUE
controller_warn( int argc, VALUE *argv, VALUE self ) {
  warn( STR2CSTR( rb_f_sprintf( argc, argv ) ) );
  return self;
}


static VALUE
controller_notice( int argc, VALUE *argv, VALUE self ) {
  notice( STR2CSTR( rb_f_sprintf( argc, argv ) ) );
  return self;
}


static VALUE
controller_info( int argc, VALUE *argv, VALUE self ) {
  info( STR2CSTR( rb_f_sprintf( argc, argv ) ) );
  return self;
}


static VALUE
controller_debug( int argc, VALUE *argv, VALUE self ) {
  debug( STR2CSTR( rb_f_sprintf( argc, argv ) ) );
  return self;
}


/********************************************************************************
 * Init Controller module.
 ********************************************************************************/

void
Init_controller() {
  VALUE controllers = rb_ary_new();
  rb_gv_set( "$controllers", controllers );

  cController = rb_define_class_under( mTrema, "Controller", rb_cObject );

  rb_define_singleton_method( cController, "inherited", controller_inherited, 1 );
  rb_define_method( cController, "initialize", controller_init, 0 );
  rb_define_method( cController, "name", controller_name, 0 );
  rb_define_method( cController, "send_message", controller_send_message, 2 );
  rb_define_method( cController, "run", controller_run, 0 );
  rb_define_method( cController, "stop", controller_stop, 0 );

  // Handlers
  rb_define_method( cController, "start", controller_start, 0 );
  rb_define_method( cController, "switch_ready", controller_switch_ready, 1 );
  rb_define_method( cController, "features_reply", controller_features_reply, 1 );
  rb_define_method( cController, "packet_in", controller_packet_in, 1 );

  // Logging
  rb_define_method( cController, "critical", controller_critical, -1 );
  rb_define_method( cController, "error", controller_error, -1 );
  rb_define_method( cController, "warn", controller_warn, -1 );
  rb_define_method( cController, "notice", controller_notice, -1 );
  rb_define_method( cController, "info", controller_info, -1 );
  rb_define_method( cController, "debug", controller_debug, -1 );
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */
