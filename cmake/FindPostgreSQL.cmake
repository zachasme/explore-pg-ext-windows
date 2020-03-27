#######################################################################
#
# FindPg.cmake - A CMake module for locating PostgreSQL
#
# Dave Page, EnterpriseDB UK Ltd.
# This code is released under the PostgreSQL Licence
#
#######################################################################

# To use this module, simply include it in your CMake project.
# If set, PostgreSQL will be assumed to be in the location specified
# by the PGDIR environment variable. Otherwise, it will be searched
# for in a number of standard locations.
#
#
# The following CMake variable will be set:
#
# PG_FOUND - Set to TRUE if PostgreSQL is located
# PG_CONFIG_PATH - The pg_config executable path
# PG_ROOT_DIR - The base install directory for PostgreSQL
# PG_INCLUDE_DIRS - The directory containing the PostgreSQL headers.
# PG_LIBRARIES - The PostgreSQL client libraries.
# PG_LIBRARY_DIRS - The directory containing the PostgreSQL client libraries.
# PG_PKG_LIBRARY_DIRS - The directory containing the PostgreSQL package libraries.
# PG_SHARE_DIR - The directory containing architecture-independent PostgreSQL support files.
# PG_VERSION_STRING - The PostgreSQL version number.
# PG_MAJOR_VERSION - The PostgreSQL major version (x in x.y.z).
# PG_MINOR_VERSION - The PostgreSQL minor version (y in x.y.z).
# PG_EXTENSION - Set to TRUE if PostgreSQL supports extensions.

#[=======================================================================[
FindPostgreSQL
--------------

Find the PostgreSQL installation.

IMPORTED Targets
^^^^^^^^^^^^^^^^

This module defines :prop_tgt:`IMPORTED` target ``PostgreSQL::PostgreSQL``
if PostgreSQL has been found.

Result Variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``PostgreSQL_FOUND``
  True if PostgreSQL is found.
``PostgreSQL_LIBRARIES``
  the PostgreSQL libraries needed for linking
``PostgreSQL_INCLUDE_DIRS``
  the directories of the PostgreSQL headers
``PostgreSQL_LIBRARY_DIRS``
  the link directories for PostgreSQL libraries
``PostgreSQL_VERSION_STRING``
  the version of PostgreSQL found
#]=======================================================================]

find_program(PostgreSQL_PG_CONFIG pg_config
  PATH
    /usr/local/pgsql/bin
    /opt/PostgreSQL/*/bin
    /Library/PostgreSQL/*/bin
    $ENV{ProgramFiles}/PostgreSQL/*/bin
    $ENV{SystemDrive}/PostgreSQL/*/bin
  DOC "Path to the pg_config executable"
)
message(STATUS "pg_config at ${PostgreSQL_PG_CONFIG}")

SET(PostgreSQL_FOUND TRUE)

# location of C header files of the client interfaces
exec_program(${PostgreSQL_PG_CONFIG} ARGS --includedir        OUTPUT_VARIABLE PostgreSQL_INCLUDE_DIR)
# location of C header files for server programming
exec_program(${PostgreSQL_PG_CONFIG} ARGS --includedir-server OUTPUT_VARIABLE PostgreSQL_INCLUDE_SERVER_DIR)
# location of object code libraries
exec_program(${PostgreSQL_PG_CONFIG} ARGS --libdir            OUTPUT_VARIABLE PostgreSQL_LIBRARY_DIR)
# location of dynamically loadable modules, or where the server would search for them
exec_program(${PostgreSQL_PG_CONFIG} ARGS --pkglibdir         OUTPUT_VARIABLE PostgreSQL_PKG_LIBRARY_DIR)
# location of architecture-independent support files
exec_program(${PostgreSQL_PG_CONFIG} ARGS --sharedir          OUTPUT_VARIABLE PostgreSQL_SHARE_DIR)
# value of the CPPFLAGS variable that was used for building PostgreSQL
exec_program(${PostgreSQL_PG_CONFIG} ARGS --cppflags          OUTPUT_VARIABLE PostgreSQL_CPP_FLAGS)
# value of the CFLAGS variable that was used for building PostgreSQL
exec_program(${PostgreSQL_PG_CONFIG} ARGS --cflags            OUTPUT_VARIABLE PostgreSQL_C_FLAGS)
# version of PostgreSQL
exec_program(${PostgreSQL_PG_CONFIG} ARGS --version           OUTPUT_VARIABLE PostgreSQL_VERSION_STRING)

set(PostgreSQL_INCLUDE_DIRS
  ${PostgreSQL_INCLUDE_DIR}
  ${PostgreSQL_INCLUDE_SERVER_DIR}
)
if(WIN32)
  list(APPEND PostgreSQL_INCLUDE_DIRS ${PostgreSQL_INCLUDE_SERVER_DIR}/port/win32)
  if(MSVC)
    list(APPEND PostgreSQL_INCLUDE_DIRS ${PostgreSQL_INCLUDE_SERVER_DIR}/port/win32_msvc)
  endif(MSVC)
endif(WIN32)

message(STATUS "includedir at ${PostgreSQL_INCLUDE_DIR}")
message(STATUS "includedir-server at ${PostgreSQL_INCLUDE_SERVER_DIR}")
message(STATUS "libdir at ${PostgreSQL_LIBRARY_DIR}")
message(STATUS "pkglibdir at ${PostgreSQL_PKG_LIBRARY_DIR}")
message(STATUS "sharedir at ${PostgreSQL_SHARE_DIR}")
message(STATUS "cppflags at ${PostgreSQL_CPP_FLAGS}")
message(STATUS "cflags at ${PostgreSQL_C_FLAGS}")
message(STATUS "version at ${PostgreSQL_VERSION_STRING}")

message(STATUS "PostgreSQL_INCLUDE_DIRS is ${PostgreSQL_INCLUDE_DIRS}")

