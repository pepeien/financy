############## Include #######################
include(./.env.cmake OPTIONAL RESULT_VARIABLE LOCAL_ENV)

############## Setup Project #######################
cmake_minimum_required(VERSION 3.11.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(NAME "Financy")

project(${NAME} VERSION 0.0.1)

##############  Set values  #######################
set(BUILD_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/Bin/${CMAKE_SYSTEM_NAME}")
set(SOURCES_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/Source")
set(UI_DIR       "${CMAKE_CURRENT_SOURCE_DIR}/UI")

##############  Set compiler  #######################
if (CMAKE_GENERATOR STREQUAL "MinGW Makefiles")
    if (NOT MINGW_PATH) 
      	message(FATAL_ERROR "MINGW_PATH not set in .env.cmake")
    endif()

    set(CMAKE_C_COMPILER   ${MINGW_PATH}/bin/gcc.exe)
    set(CMAKE_CXX_COMPILER ${MINGW_PATH}/bin/g++.exe)

    if (WIN32)
        target_include_directories(
            ${NAME}

            PRIVATE
                ${MINGW_PATH}/include
        )

        target_link_directories(
            ${NAME}

            PRIVATE
                ${MINGW_PATH}/lib
        )
    endif()
endif()

##############  Set source files  #######################
file(
    GLOB_RECURSE
    SOURCES

    ${SOURCES_DIR}/*.cpp
)

file(
    GLOB_RECURSE
    UI_SOURCES

    ${UI_DIR}/*.qrc
)

############## Setup Executable  #######################
set(CMAKE_PREFIX_PATH ${QT_PATH})

set(CMAKE_AUTORCC ON)

set(SKIP_AUTOMOC TRUE)
set(SKIP_AUTOUIC TRUE) 

find_package(Qt6 COMPONENTS Charts Core Gui Qml Quick)

qt_standard_project_setup()
qt_add_executable(
    ${NAME}

    ${SOURCES}
    ${UI_SOURCES}
)

set_target_properties(
    ${NAME}
    PROPERTIES

    VS_DEBUGGER_WORKING_DIRECTORY
    "${BUILD_DIR}"

    RUNTIME_OUTPUT_DIRECTORY
    "${BUILD_DIR}"

    RUNTIME_OUTPUT_DIRECTORY_DEBUG
    "${BUILD_DIR}"

    RUNTIME_OUTPUT_DIRECTORY_RELEASE
    "${BUILD_DIR}"
)

target_link_libraries(
    ${NAME}

    PRIVATE
        Qt6::Charts
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
)