cmake_minimum_required(VERSION 3.11)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

project(simple VERSION 0.0.1
    LANGUAGES C)

if (NOT CMAKE_BUILD_TYPE)
    # Default to Release builds
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel" FORCE)
endif ()

message(STATUS "Build type is ${CMAKE_BUILD_TYPE}")

find_package(PostgreSQL REQUIRED)

message(STATUS "Compiling against PostgreSQL version ${PostgreSQL_VERSION_STRING}")

add_subdirectory(sql)
add_subdirectory(src/h3)

set(EXT_CONTROL_FILE ${PROJECT_NAME}.control)
configure_file(${EXT_CONTROL_FILE} ${EXT_CONTROL_FILE})

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/${EXT_CONTROL_FILE}
  DESTINATION "${PostgreSQL_SHARE_DIR}/extension"
)
