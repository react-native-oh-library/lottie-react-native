cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

set(rnoh_lottie_generated_dir "${CMAKE_CURRENT_SOURCE_DIR}/generated")
file(GLOB_RECURSE rnoh_lottie_generated_SRC "${rnoh_lottie_generated_dir}/**/*.cpp")
file(GLOB rnoh_lottie_SRC CONFIGURE_DEPENDS *.cpp)
add_library(rnoh_lottie SHARED ${rnoh_lottie_SRC} ${rnoh_lottie_generated_SRC})
target_include_directories(rnoh_lottie PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${rnoh_lottie_generated_dir})
target_link_libraries(rnoh_lottie PUBLIC rnoh)
