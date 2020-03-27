include(FetchContent)

FetchContent_Declare(h3
  GIT_REPOSITORY https://github.com/uber/h3.git
  GIT_TAG v3.6.3
  CMAKE_ARGS
    -DCMAKE_C_FLAGS=-fPIC
    -DBUILD_TESTING=OFF
    -DBUILD_BENCHMARKS=OFF
    -DBUILD_FILTERS=OFF
    -DBUILD_GENERATORS=OFF
    -DENABLE_DOCS=OFF
    -DENABLE_FORMAT=OFF
    -DENABLE_LINTING=OFF
)
FetchContent_MakeAvailable(h3)

set(H3_INCLUDE_DIR ${h3_BINARY_DIR}/src/h3lib/include)