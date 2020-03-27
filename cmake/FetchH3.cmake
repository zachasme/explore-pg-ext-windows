include(FetchContent)

FetchContent_Declare(h3api
  GIT_REPOSITORY https://github.com/uber/h3.git
  GIT_TAG v3.6.3
  CMAKE_ARGS
    -DCMAKE_C_FLAGS=-fPIC
    -DBUILD_TESTING=OFF
    -DENABLE_DOCS=OFF
    -DENABLE_FORMAT=OFF
    -DENABLE_LINTING=OFF
)
FetchContent_MakeAvailable(h3api)

set(H3_INCLUDE_DIR ${h3api_BINARY_DIR}/src/h3lib/include)