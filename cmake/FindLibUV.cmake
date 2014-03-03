# - Try to find libuv
# Once done, this will define
#
#  LIBUV_FOUND - system has libuv
#  LIBUV_INCLUDE_DIRS - the libuv include directories
#  LIBUV_LIBRARIES - link these to use libuv
#
# Set the LIBUV_USE_STATIC variable to specify if static libraries should
# be preferred to shared ones.

if(NOT LIBUV_USE_BUNDLED)
  find_package(PkgConfig)
  if (PKG_CONFIG_FOUND)
    pkg_check_modules(PC_LIBUV QUIET libuv)
  endif()
else()
  set(PC_LIBUV_INCLUDEDIR)
  set(PC_LIBUV_INCLUDE_DIRS)
  set(PC_LIBUV_LIBDIR)
  set(PC_LIBUV_LIBRARY_DIRS)
  set(LIMIT_SEARCH NO_DEFAULT_PATH)
endif()

set(CMAKE_PREFIX_PATH "${DEPS_INSTALL_DIR}")
find_path(LIBUV_INCLUDE_DIR uv.h
  HINTS ${PC_LIBUV_INCLUDEDIR} ${PC_LIBUV_INCLUDE_DIRS}
  PATHS "${DEPS_INSTALL_DIR}"
  ${LIMIT_SEARCH})

# If we're asked to use static linkage, add libuv.a as a preferred library name.
if(LIBUV_USE_STATIC)
  list(APPEND LIBUV_NAMES
    "${CMAKE_STATIC_LIBRARY_PREFIX}uv${CMAKE_STATIC_LIBRARY_SUFFIX}")
endif(LIBUV_USE_STATIC)

list(APPEND LIBUV_NAMES uv)

set(CMAKE_PREFIX_PATH "${DEPS_INSTALL_DIR}")
find_library(LIBUV_LIBRARY NAMES ${LIBUV_NAMES}
  HINTS ${PC_LIBUV_LIBDIR} ${PC_LIBUV_LIBRARY_DIRS}
  PATHS "${DEPS_INSTALL_DIR}"
  ${LIMIT_SEARCH})

mark_as_advanced(LIBUV_INCLUDE_DIR LIBUV_LIBRARY)

set(LIBUV_LIBRARIES ${LIBUV_LIBRARY})
set(LIBUV_INCLUDE_DIRS ${LIBUV_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set LIBUV_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(LibUV DEFAULT_MSG
                                  LIBUV_LIBRARY LIBUV_INCLUDE_DIR)

mark_as_advanced(LIBUV_INCLUDE_DIR LIBUV_LIBRARY)