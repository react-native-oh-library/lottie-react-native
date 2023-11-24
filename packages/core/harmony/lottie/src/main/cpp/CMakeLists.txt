cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

file(GLOB rnoh_lottie_SRC CONFIGURE_DEPENDS *.cpp)
add_library(rnoh_lottie SHARED ${rnoh_lottie_SRC})
target_include_directories(rnoh_lottie PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(rnoh_lottie PUBLIC rnoh)


