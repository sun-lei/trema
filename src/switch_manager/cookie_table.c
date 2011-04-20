/*
 * Author: Kazusi Sugyo
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


#include <openflow.h>
#include <string.h>
#include "cookie_table.h"
#include "trema.h"


static cookie_table_t cookie_table;
static uint64_t cookie_dough = 0ULL;
static uint64_t INVALID_COOKIE = UINT64_MAX;
static const time_t COOKIE_ENTRY_LIFETIME = 86400 * 30;


static uint64_t
generate_cookie( void ) {
  uint64_t initial_value = ( cookie_dough != ( INVALID_COOKIE - 1 ) ) ? ++cookie_dough : 1;

  while ( lookup_cookie_entry_by_cookie( &cookie_dough ) != NULL ) {
    if ( cookie_dough != ( INVALID_COOKIE - 1 ) ) {
      cookie_dough++;
    }
    else {
      cookie_dough = 1;
    }
    if ( initial_value == cookie_dough ) {
      error( "Failed to generate cookie value." );
      cookie_dough = RESERVED_COOKIE;
      break;
    }
  }

  return cookie_dough;
}


static bool
compare_cookie( const void *x, const void *y ) {
  return ( ( memcmp( x, y, sizeof( uint64_t ) ) == 0 ) ? true : false );
}


static unsigned int
hash_cookie_entry( const void *key ) {
  const uint64_t *cookie = key;

  return ( unsigned int )( ( *cookie >> 32 ) ^ *cookie );
}


static bool
compare_application( const void *x, const void *y ) {
  return ( ( memcmp( x, y, sizeof( application_entry_t ) ) == 0 ) ? true : false );
}


static cookie_entry_t *
allocate_cookie_entry( uint64_t *original_cookie, char *service_name, uint16_t flags ) {
  cookie_entry_t *new_entry;

  new_entry = xmalloc( sizeof ( cookie_entry_t ) );
  memset( new_entry, 0, sizeof( cookie_entry_t ) );

  new_entry->cookie = generate_cookie();
  new_entry->application.cookie = *original_cookie;

  if ( strlen( service_name ) + 1 > MESSENGER_SERVICE_NAME_LENGTH ) {
    warn( "Too long service name ( service_name = %s ).", service_name );
  }
  strncpy( new_entry->application.service_name, service_name, MESSENGER_SERVICE_NAME_LENGTH );
  new_entry->application.service_name[ MESSENGER_SERVICE_NAME_LENGTH - 1 ] = '\0';

  new_entry->application.flags = flags;
  new_entry->reference_count = 1;
  new_entry->expire_at = time( NULL ) + COOKIE_ENTRY_LIFETIME;

  return new_entry;
}


static void
free_cookie_entry( cookie_entry_t *free_entry ) {
  xfree( free_entry );
}


static void
free_cookie_table_walker( void *key, void *value, void *user_data ) {
  cookie_entry_t *entry = value;

  UNUSED( key );
  UNUSED( user_data );

  free_cookie_entry( entry );
}


void
init_cookie_table( void ) {
  cookie_table.global = create_hash( compare_cookie, hash_cookie_entry );
  cookie_table.application = create_hash( compare_application, hash_cookie_entry );
}


void
finalize_cookie_table( void ) {
  foreach_hash( cookie_table.global, free_cookie_table_walker, NULL );
  delete_hash( cookie_table.global );
  delete_hash( cookie_table.application );
  cookie_table.global = NULL;
  cookie_table.application = NULL;
}


uint64_t *
insert_cookie_entry( uint64_t *original_cookie, char *service_name, uint16_t flags ) {
  cookie_entry_t *new_entry, *conflict_entry;

  debug( "Inserting cookie entry ( original_cookie = %#llx, service_name = %s, flags = %#x ).",
         original_cookie, service_name, flags );

  new_entry = lookup_cookie_entry_by_application( original_cookie, service_name );
  if ( new_entry != NULL ) {
    new_entry->reference_count++;
    new_entry->expire_at = time( NULL ) + COOKIE_ENTRY_LIFETIME;
    new_entry->application.flags |= flags; // FIXME: save flags for each flow individually

    return &new_entry->cookie;
  }

  new_entry = allocate_cookie_entry( original_cookie, service_name, flags );
  conflict_entry = insert_hash_entry( cookie_table.global, &new_entry->cookie, new_entry );
  if ( conflict_entry != NULL ) {
    warn( "Conflicted cookie ( cookie = %#llx ).", new_entry->cookie );
    // TODO: delete conflicted cookie entry
  }

  conflict_entry = insert_hash_entry( cookie_table.application, &new_entry->application, new_entry );
  if ( conflict_entry != NULL ) {
    warn( "Conflicted cookie ( cookie = %#llx, service_name = %s ).",
          new_entry->application.cookie, new_entry->application.service_name );
    // TODO: delete conflicted cookie entry
  }

  return &new_entry->cookie;
}


void
delete_cookie_entry( cookie_entry_t *entry ) {
  debug( "Deleting cookie entry ( cookie = %#llx, application = [ cookie = %#llx, service_name = %s, "
         "flags = %#x ], reference_count = %d, expire_at = %u ).",
         entry->cookie, entry->application.cookie, entry->application.service_name,
         entry->application.flags, entry->reference_count, entry->expire_at );

  if ( entry->reference_count > 1 ) {
    debug( "Decrementing reference counter ( reference_count = %d ).", entry->reference_count );
    entry->reference_count--;
    return;
  }

  cookie_entry_t *delete_entry_global = delete_hash_entry( cookie_table.global, &entry->cookie );
  if ( delete_entry_global == NULL ) {
    error( "No cookie entry found ( cookie = %#llx ).", entry->cookie );
  }
  cookie_entry_t *delete_entry_application = delete_hash_entry( cookie_table.application, &entry->application );
  if ( delete_entry_application == NULL ) {
    error( "No cookie entry found ( cookie = %#llx, service_name = %s ).",
           entry->application.cookie, entry->application.service_name );
  }

  if ( delete_entry_global == delete_entry_application ) {
    if ( delete_entry_application != NULL ) {
      free_cookie_entry( delete_entry_application );
    }
  }
  else {
    if ( delete_entry_global != NULL ) {
      free_cookie_entry( delete_entry_global );
    }
    if ( delete_entry_application != NULL ) {
      free_cookie_entry( delete_entry_application );
    }
  }
}


cookie_entry_t *
lookup_cookie_entry_by_cookie( uint64_t *cookie ) {
  return lookup_hash_entry( cookie_table.global, cookie );
}


cookie_entry_t *
lookup_cookie_entry_by_application( uint64_t *cookie, char *service_name ) {
  cookie_entry_t key;
  cookie_entry_t *entry;

  memset( &key, 0, sizeof( cookie_entry_t ) );
  key.application.cookie = *cookie;
  strncpy( key.application.service_name, service_name, MESSENGER_SERVICE_NAME_LENGTH );
  key.application.service_name[ MESSENGER_SERVICE_NAME_LENGTH - 1 ] = '\0';

  entry = lookup_hash_entry( cookie_table.application, &key );

  return entry;
}


static void
age_cookie_entry( cookie_entry_t *entry ) {
  if ( entry->expire_at < time( NULL ) ) {
    // TODO: check if the target flow is still alive or not
    warn( "Aging out cookie entry ( cookie = %#llx, application = [ cookie = %#llx, service_name = %s, "
          "flags = %#x ], reference_count = %d, expire_at = %u ).",
          entry->cookie, entry->application.cookie, entry->application.service_name,
          entry->application.flags, entry->reference_count, entry->expire_at );

    delete_hash_entry( cookie_table.global, &entry->cookie );
    delete_hash_entry( cookie_table.application, &entry->application );
    free_cookie_entry( entry );
  }
}


void
age_cookie_table( void *user_data ) {
  UNUSED( user_data );

  hash_iterator iter;
  hash_entry *e;

  init_hash_iterator( cookie_table.global, &iter );
  while ( ( e = iterate_hash_next( &iter ) ) != NULL ) {
    age_cookie_entry( e->value );
  }
}


static void
dump_cookie_entry( cookie_entry_t *entry ) {
  info( "cookie = %#llx, application = [ cookie = %#llx, service_name = %s, "
        "flags = %#x ], reference_count = %d, expire_at = %u",
        entry->cookie, entry->application.cookie, entry->application.service_name,
        entry->application.flags, entry->reference_count, entry->expire_at );
}


void
dump_cookie_table( void ) {
  hash_iterator iter;
  hash_entry *e;

  info( "#### COOKIE TABLE ####" );
  info( "[global]" );
  init_hash_iterator( cookie_table.global, &iter );
  while ( ( e = iterate_hash_next( &iter ) ) != NULL ) {
    dump_cookie_entry( e->value );
  }

  info( "[application]" );
  init_hash_iterator( cookie_table.application, &iter );
  while ( ( e = iterate_hash_next( &iter ) ) != NULL ) {
    dump_cookie_entry( e->value );
  }
  info( "#### END ####" );
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */
