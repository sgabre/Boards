#/TestHarness/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(TestHareness VERSION 0.0.0)

if(NOT CMAKE_BUILD_TYPE)
    # Set a default build type if not defined
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the build type (Release, Debug)" FORCE)
    message(STATUS "CMAKE_BUILD_TYPE not defined, defaulting to Debug.")
endif()

# TODO: Add Test or Option to define/enable the Packs libraries if the toolchaine for embedded target is used  

# Define default only if not already defined
if(NOT DEFINED APPLICATION_TYPE)
    set(APPLICATION_TYPE "NONE")
endif()

message(STATUS "Application Type: ${APPLICATION_TYPE}")


# Ensure the ....
option(TEST_LEVEL "Select the test type (UnitTesting, IntegrationTesting, etc.)" "None")
message(STATUS "Test Type: ${TEST_LEVEL}")


# Ensure the Libraries directory exists before installation
set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR}/Libraries)

# Define valid build types
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")

# Display the current build type
message(STATUS "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
#message(STATUS "CMAKE_PROJECT_NAME: ${CMAKE_PROJECT_NAME}")
#message(STATUS "MAJOR_VERSION: ${PROJECT_VERSION_MAJOR}")
#message(STATUS "MINOR_VERSION: ${PROJECT_VERSION_MINOR}")
#message(STATUS "PATCH_VERSION: ${PROJECT_VERSION_PATCH}")

# Display the toolchain details in the output
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "C++ Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "ASM Compiler: ${CMAKE_ASM_COMPILER}")
message(STATUS "Linker: ${CMAKE_LINKER}")
message(STATUS "C Flags: ${CMAKE_C_FLAGS}")
message(STATUS "CXX Flags: ${CMAKE_CXX_FLAGS}")

# Define UNIT_TEST_WRAPPER for unit testing
#if(TEST_LEVEL STREQUAL "ALL" OR TEST_LEVEL STREQUAL "UNIT")
if(NOT TEST_LEVEL STREQUAL "NONE")
    add_definitions(-DUNIT_TEST_WRAPPER)
endif()

# Add Firmware subdirectory for all build types
add_subdirectory(Firmware)

# TODO: Add Condition ?
#include(${CMAKE_SOURCE_DIR}/.cmake/docs/doxygen.cmake)

# Enable testing globally if any tests are to be included
if(NOT TEST_LEVEL STREQUAL "NONE")
    enable_testing()
endif()


# Conditionally add Unity and UnitTesting when the build type is UnitTesting
if(TEST_LEVEL STREQUAL "ALL" OR TEST_LEVEL STREQUAL "UNIT")
    message(STATUS "Unit Testing build type detected!")
        
    # Include Unity CMake file
    include(${CMAKE_SOURCE_DIR}/.cmake/Unity/Unity.cmake)
    
     # Add the Unit Testing directory as a subdirectory
    add_subdirectory(Tests/UnitTesting)
endif()

if(TEST_LEVEL STREQUAL "ALL" OR TEST_LEVEL STREQUAL "COMPONENT")
    message(STATUS "Component Testing build type detected!")
endif()

if(TEST_LEVEL STREQUAL "ALL" OR TEST_LEVEL STREQUAL "CIT")
    message(STATUS "Component Integration Testing build type detected!")
endif()

if(TEST_LEVEL STREQUAL "ALL" OR TEST_LEVEL STREQUAL "SIT")
    message(STATUS "System Integration Testing build type detected!")
endif()

if(TEST_LEVEL STREQUAL "ALL" OR TEST_LEVEL STREQUAL "SYSTEM")
    message(STATUS "System Integration Testing build type detected!")
endif()

if(TEST_LEVEL STREQUAL "ALL" OR TEST_LEVEL STREQUAL "VALIDATION")
    message(STATUS "Acceptance Integration Testing build type detected!")
    add_test(
    NAME AcceptanceTesting
    COMMAND ${CMAKE_COMMAND} -E env ROBOT_SYSLOG=NONE robot --exitonfailure --outputdir ${CMAKE_SOURCE_DIR}/tests/Reports/AcceptanceTesting ${CMAKE_SOURCE_DIR}/tests/AcceptanceTesting
)
    # Define execution order
    #set_tests_properties(AcceptanceTesting PROPERTIES DEPENDS "UnitTest1;UnitTest2")
endif()


#install(TARGETS Module)





