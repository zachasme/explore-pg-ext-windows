include(FetchH3)

if (WIN32)
  string(APPEND CMAKE_MODULE_LINKER_FLAGS " ${PostgreSQL_LIBRARY_DIR}/postgres.lib")
endif (WIN32)

include_directories(${CMAKE_BINARY_DIR}/src/h3 ${PostgreSQL_INCLUDE_DIRS} ${H3_INCLUDE_DIR})

#SHLIB_LINK += -lh3 -L$(LIBH3_BUILD)/lib
target_link_libraries(${PROJECT_NAME} h3api)

message(STATUS "h3 at ${H3_INCLUDE_DIR}")

configure_file(extension.in.h extension.h)

add_library(${PROJECT_NAME} MODULE
  extension.h
  extension.c
  hierarchy.c
  indexing.c
  inspection.c
  miscellaneous.c
  opclass_btree.c
  opclass_hash.c
  regions.c
  traversal.c
  type.c
  uniedges.c
)

set_target_properties(${PROJECT_NAME} PROPERTIES
  OUTPUT_NAME ${PROJECT_NAME}
  PREFIX ""
)

install(
  TARGETS ${PROJECT_NAME}
  DESTINATION ${PostgreSQL_LIBRARY_DIR}
)
