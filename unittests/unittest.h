/*
 * Common utility macros for unit tests.
 *
 * Author: Yasuhito Takamiya <yasuhito@gmail.com>
 #
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


#ifndef UNITTEST_H
#define UNITTEST_H


#include <setjmp.h>
#include <stdarg.h>
#include <stddef.h>
#include <sys/select.h>
#include "cmockery.h"


/********************************************************************************
 * Relax cmockery's restrictions to avoid warnings.
 * See also: http://bit.ly/iw9ZbB
 ********************************************************************************/

#ifdef expect_string_count
#undef expect_string_count
#endif
#define expect_string_count( function, parameter, string, count )	     \
  _expect_string( #function, #parameter, __FILE__, __LINE__, string, count )

#ifdef expect_assert_failure
#undef expect_assert_failure
#endif
#define expect_assert_failure( function_call )                                    \
  {                                                                               \
    const char *expression = ( const char * ) setjmp( global_expect_assert_env ); \
    global_expecting_assert = 1;                                                  \
    if ( expression ) {                                                           \
      print_message( "Expected assertion %s occurred\n", expression );            \
      global_expecting_assert = 0;                                                \
    } else {                                                                      \
      function_call ;                                                             \
      global_expecting_assert = 0;                                                \
      print_error( "Expected assert in %s\n", #function_call )    ;               \
      _fail( __FILE__, __LINE__ );                                                \
    }                                                                             \
  }


/********************************************************************************
 * Misc common macros.
 ********************************************************************************/

#define ARRAY_SIZE( name ) ( sizeof( name ) / sizeof( name[ 0 ] ) )

#define will_return_void( f ) will_return( f, 0 )

#define FD_ISZERO( s )                                   \
  ( {                                                    \
      fd_set zero_set;                                   \
      FD_ZERO( &zero_set );                              \
      memcmp( ( s ), &zero_set, sizeof( fd_set ) ) == 0; \
    }                                                    \
  )


#endif /* UNITTEST_H */
