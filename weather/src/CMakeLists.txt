#Tested with cmake version 3.13.4
cmake_minimum_required(VERSION 3.13)

project(weather)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

include_directories(include)
file(GLOB SOURCES *.cpp)

find_package(CURL REQUIRED)
find_package(Boost COMPONENTS system)

add_executable(weather ${SOURCES})
target_link_libraries(weather pthread boost_system InfluxDB curl jsoncpp)
target_compile_options(weather PRIVATE -Werror -Wall -Wextra)

set(CMAKE_INSTALL_PREFIX /usr)
install(TARGETS weather DESTINATION bin)
