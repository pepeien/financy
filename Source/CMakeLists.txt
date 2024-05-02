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

############## Setup Executable  #######################
set(CMAKE_PREFIX_PATH "C:/src/qt/6.7.0/mingw_64/lib/cmake")

set(SKIP_AUTOMOC TRUE)
set(SKIP_AUTOUIC TRUE) 

find_package(Qt6 COMPONENTS Charts Core Gui Qml Quick)
qt_standard_project_setup()
qt_add_executable(
    ${NAME}

    ${SOURCES}
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