
# not important which version is used
cmake_minimum_required (VERSION 2.6)

# !!! project includes C, C++, and assembler (.S)
project (testNRFLib C CXX ASM)

# cmake includes modules from here
# !!! only for simple names without the .cmake suffix
# set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/CMakeScripts/")
set(CMAKE_MODULE_PATH "/home/bootch/git/nRF5Cmake/")
message(" Module path is ${CMAKE_MODULE_PATH}")


# environment (location of NRF_SDK and other tools)
# i.e. file CMakeEnv.cmake on the MODULE_PATH
include("CMakeEnv")

# var configures CMake_nRF5x to chip family nrf52
set(NRF_TARGET "nrf52")
set(NRF_SOFTDEVICE "s132")

# scripts specific to nRF5x building
# Defines cmake macros prefixed with "nRF5x"
# Sets many cmake vars for tool flags
include("nRF5")

nRF5CheckSetupPreconditions()
nRF5SetBuildOptions()
nRF5SetIncludePaths()
nRF5SetSDKSourcesBasic()


# sanity: sets a var
message(" Linker script is ${NRF5_LINKER_SCRIPT}")


# import libs from outside project
set(NRFDRIVERS_DIR  "/home/bootch/git/libNRFDrivers")
add_library(NRFDrivers STATIC IMPORTED)
set_target_properties( NRFDrivers 
    PROPERTIES 
        IMPORTED_LOCATION "${NRFDRIVERS_DIR}/Debug/libNRFDrivers.a"
        INTERFACE_INCLUDE_DIRECTORIES "${NRFDRIVERS_DIR}"
    )

get_property(FOO TARGET NRFDrivers PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
message("library includes ${FOO}")

# cmake won't allow this:  target_sources(NRFDrivers

IF(EXISTS ${NRFDRIVERS_DIR}/lowFreqClockCoordinated.h)
    message("header exists")
else()
    message("FATAL_ERROR header not exist")
ENDIF()

#  INTERFACE_

# target is executable
# source specified later
add_executable(testNRFLib "")


# test harness is main plus SDK startup files
target_sources(testNRFLib
    PUBLIC
       "${CMAKE_CURRENT_LIST_DIR}/main.cpp"
       "${SDK_SOURCE_FILES}"
    )

# main includes headers of lib under test
# but that is declared as property of lib
    
# main links to lib nrfDrivers
target_link_libraries(
    testNRFLib
    PUBLIC
        NRFDrivers
    )
    
nRF5GenerateOtherArtifacts(testNRFLib)
nRF5AddCustomTargets(testNRFLib)

    
list(SORT SDK_SOURCE_FILES)
message("SDK sources are ${SDK_SOURCE_FILES}")
list(LENGTH SDK_SOURCE_FILES LENGTH_VAR)
message("SDK sources count: ${LENGTH_VAR}")





macro(print_all_variables)
    message(STATUS "print_all_variables------------------------------------------{")
    get_cmake_property(_variableNames VARIABLES)
    foreach (_variableName ${_variableNames})
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
    message(STATUS "print_all_variables------------------------------------------}")
endmacro()

#print_all_variables()
