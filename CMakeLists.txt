############## Include #######################
include(./.env.cmake OPTIONAL RESULT_VARIABLE LOCAL_ENV)

############## Setup Project #######################
cmake_minimum_required(VERSION 3.11.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(NAME "Financy")

project(${NAME} VERSION 1.9.0)

##############  Set values  #######################
if (NOT DEFINED CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

set(ASSETS_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/Assets")
set(BUILD_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/Bin/${CMAKE_BUILD_TYPE}")
set(SOURCES_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/Source")
set(UI_DIR       "${CMAKE_CURRENT_SOURCE_DIR}/UI")
set(VENDOR_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/Vendors")

set(ASSETS_TARGET_NAME "${NAME}_Assets")

##############  Set source files  #######################
file (
    GLOB_RECURSE
    HEADERS

    // Headers
    ${SOURCES_DIR}/*.hpp
)

file(
    GLOB_RECURSE
    SOURCES

    // Sources
    ${SOURCES_DIR}/*.cpp

    ${VENDOR_DIR}/libharu/src/*.c
)

file(
    GLOB_RECURSE
    UI_SOURCES

    ${UI_DIR}/*.qrc
)

############## Setup Libs #######################
set(CMAKE_AUTORCC ON)

set(SKIP_AUTOMOC TRUE)
set(SKIP_AUTOUIC TRUE)

find_package(Qt6 REQUIRED COMPONENTS Charts Core Gui Qml Quick)

qt_standard_project_setup()

if (WIN32)
    if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "Release")  
        qt_add_executable(
            ${NAME}

            ${SOURCES}
            ${UI_SOURCES}
        )
    else()
        qt_add_executable(
            ${NAME}
                WIN32
            ${SOURCES}
            ${UI_SOURCES}
        )
    endif()
else()
    qt_add_executable(
        ${NAME}

        ${SOURCES}
        ${UI_SOURCES}
    )
endif()

target_include_directories(
    ${NAME}

    PRIVATE
        ${SOURCES_DIR}

        ${VENDOR_DIR}/libharu/include
)

target_link_libraries(
    ${NAME}

    PRIVATE
        Qt6::Charts
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        base64
        nlohmann_json
)

set_target_properties(
    ${NAME}
    PROPERTIES

    VS_DEBUGGER_WORKING_DIRECTORY
    "${BUILD_DIR}"

    ARCHIVE_OUTPUT_DIRECTORY_RELEASE
    "${BUILD_DIR}"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE
    "${BUILD_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE
    "${BUILD_DIR}"

    ARCHIVE_OUTPUT_DIRECTORY_DEBUG
    "${BUILD_DIR}"
    LIBRARY_OUTPUT_DIRECTORY_DEBUG
    "${BUILD_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG
    "${BUILD_DIR}"
)

add_subdirectory(${ASSETS_DIR})

add_subdirectory(${VENDOR_DIR})

add_dependencies(${NAME} ${ASSETS_TARGET_NAME})