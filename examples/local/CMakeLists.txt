cmake_minimum_required(VERSION 2.8.12)

project(LocalArcBuild)

add_executable(hi main.cpp)

if(ANDROID)
  target_link_libraries(hi gnustl_static)
endif()
