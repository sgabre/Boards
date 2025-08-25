#/Sample/sources/CMakeLists.txt

message(STATUS "Application Type: ${APPLICATION_TYPE}")
if(APPLICATION_TYPE STREQUAL "EMBEDDED_APPLICATION")
    # Path to the external library files
    set(EXTERNAL_LIB_PATH "${CMAKE_SOURCE_DIR}/Packs/Boards/STM32F403RE")

    # Specify the include directory for the external library
    include_directories("${EXTERNAL_LIB_PATH}/inc")

    message(STATUS "PACK_LIB_PATH: ${EXTERNAL_LIB_PATH}")
    message(STATUS "PACK_LIB_PATH: ${EXTERNAL_LIB_PATH}/inc")
    message(STATUS "PACK_LIB_PATH: ${EXTERNAL_LIB_PATH}/Lib")

    # Enable CMake support for ASM and C languages
    enable_language(C ASM)



endif()


# Set source files for the application
set(SOURCES
	main.c
)

if(APPLICATION_TYPE STREQUAL "EMBEDDED_APPLICATION")
    # Set source files for the application
    #list(APPEND SOURCES ../Startup/Standalone-stm32f401xe-Startup.s)
endif()

# Create the executable for the application
ADD_EXECUTABLE(Sample ${SOURCES})

# Link with the Module library if required
set(ITEMS)

if(APPLICATION_TYPE STREQUAL "EMBEDDED_APPLICATION")
    list(APPEND ITEMS "${EXTERNAL_LIB_PATH}/Lib/STM32F403RELib.a")
endif()

target_link_libraries(Sample PRIVATE ${ITEMS})

# Include directories
TARGET_INCLUDE_DIRECTORIES(Sample PRIVATE ${CMAKE_CURRENT_LIST_DIR})

install(TARGETS Sample
    RUNTIME DESTINATION bin
)
