include(FetchContent)

set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "")  # Forces the value
set(BUILD_TESTING OFF CACHE INTERNAL "")  # Forces the value
set(BUILD_FILTERS OFF CACHE INTERNAL "")  # Forces the value
set(BUILD_BENCHMARKS OFF CACHE INTERNAL "")  # Forces the value
set(BUILD_GENERATORS OFF CACHE INTERNAL "")  # Forces the value

FetchContent_Declare(h3
  GIT_REPOSITORY https://github.com/uber/h3.git
  GIT_TAG v3.6.3
)
FetchContent_MakeAvailable(h3)

set(H3_INCLUDE_DIR ${h3_BINARY_DIR}/src/h3lib/include)