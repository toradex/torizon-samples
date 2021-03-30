cmake_minimum_required(VERSION 3.0.0)

# set the project name
project(alsa-example VERSION 1.0)

# add the executable
add_executable(${PROJECT_NAME} alsa-example.cpp)

find_package(ALSA REQUIRED)

target_link_libraries(${PROJECT_NAME} ALSA::ALSA)

# install (please be aware that changing the target folder may lead to issues during deployment and debugging)
install(TARGETS ${PROJECT_NAME} DESTINATION bin)
