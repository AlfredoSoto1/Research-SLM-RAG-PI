cmake_minimum_required(VERSION 3.16)

project(slm_rag_pi_firmware VERSION 0.1.0 LANGUAGES CXX)

add_executable(slm-rag-pi-firmware
  src/main.cpp
)

target_compile_features(slm-rag-pi-firmware PRIVATE cxx_std_17)
target_compile_definitions(slm-rag-pi-firmware PRIVATE
  SLM_RAG_PI_FIRMWARE_VERSION="${PROJECT_VERSION}"
)

if(MSVC)
  target_compile_options(slm-rag-pi-firmware PRIVATE /W4)
else()
  target_compile_options(slm-rag-pi-firmware PRIVATE -Wall -Wextra -Wpedantic)
endif()

install(TARGETS slm-rag-pi-firmware RUNTIME DESTINATION bin)
