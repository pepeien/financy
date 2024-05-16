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
set(VENDOR_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/Vendors")

##############  Set source files  #######################
file(
    GLOB_RECURSE
    SOURCES

    // Sources
    ${SOURCES_DIR}/*.cpp

    // Vendors
    ${VENDOR_DIR}/QtOpenCV/cvmatandqimage.cpp
)

file(
    GLOB_RECURSE
    UI_SOURCES

    ${UI_DIR}/*.qrc
)

############## Setup Libs #######################
list(APPEND CMAKE_PREFIX_PATH "${QT_PATH}/lib/cmake")
list(APPEND CMAKE_PREFIX_PATH "${VENDOR_DIR}/opencv/build")

set(CMAKE_AUTORCC ON)

set(SKIP_AUTOMOC TRUE)
set(SKIP_AUTOUIC TRUE) 

set(OpenCV_DIR "${VENDOR_DIR}/opencv/build/lib")

find_package(Qt6    REQUIRED COMPONENTS Charts Core Gui Qml Quick)
find_package(OpenCV REQUIRED COMPONENTS core imgproc highgui)

qt_standard_project_setup()
qt_add_executable(
    ${NAME}

    ${SOURCES}
    ${UI_SOURCES}
)

target_include_directories(
    ${NAME}

    PRIVATE
        ${SOURCES_DIR}

        ${VENDOR_DIR}/base64/include
        ${VENDOR_DIR}/QtOpenCV
        ${OpenCV_INCLUDE_DIRS}
        ${VENDOR_DIR}/json/include
)

target_link_libraries(
    ${NAME}

    PRIVATE
        # Qt6
        Qt6::Charts
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick

        # OpenCV
        ${OpenCV_LIBRARIES}
)

############## Setup Executable #######################
set_target_properties(
    ${NAME}
    PROPERTIES

    VS_DEBUGGER_WORKING_DIRECTORY
    "${BUILD_DIR}/Debug"

    ARCHIVE_OUTPUT_DIRECTORY_RELEASE
    "${BUILD_DIR}/Release"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE
    "${BUILD_DIR}/Release"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE
    "${BUILD_DIR}/Release"

    ARCHIVE_OUTPUT_DIRECTORY_DEBUG
    "${BUILD_DIR}/Debug"
    LIBRARY_OUTPUT_DIRECTORY_DEBUG
    "${BUILD_DIR}/Debug"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG
    "${BUILD_DIR}/Debug"
)

##############  Set compiler  #######################
if (CMAKE_GENERATOR STREQUAL "MinGW Makefiles")
    if (NOT MINGW_PATH) 
      	message(FATAL_ERROR "MINGW_PATH not set in .env.cmake")
    endif()

    message(${MINGW_PATH})
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