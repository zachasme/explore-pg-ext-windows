include_directories(${PostgreSQL_INCLUDE_DIRS})

add_library(${PROJECT_NAME} MODULE
  simple.h
  simple.c
)

set_target_properties(${PROJECT_NAME} PROPERTIES
  OUTPUT_NAME ${PROJECT_NAME}
  PREFIX ""
)

install(
  TARGETS ${PROJECT_NAME}
  DESTINATION ${PostgreSQL_LIBRARY_DIR}
)
