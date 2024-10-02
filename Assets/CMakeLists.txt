add_custom_target(${ASSETS_TARGET_NAME})

##############  Set source files  #######################
file(
    GLOB_RECURSE

    SOURCES
        "${ASSETS_DIR}/*"
)

list(
    FILTER
        SOURCES
    EXCLUDE
    REGEX
        ".:*CMakeLists.txt$"
)

##############  Copy files  #######################
foreach(ITEM ${SOURCES})
    get_filename_component(FILE_DIR  ${ITEM} DIRECTORY)
    get_filename_component(FILE_NAME ${ITEM} NAME)

    set(ITEM_DIR "${FILE_DIR}")
    string(REPLACE "${ASSETS_DIR}" "" ITEM_DIR ${ITEM_DIR})

    set(ITEM_DIR "${BUILD_DIR}/Assets/${ITEM_DIR}")
    string(REPLACE "//" "/" ITEM_DIR ${ITEM_DIR})

    file(MAKE_DIRECTORY "${ITEM_DIR}")

    set(ITEM_FILE "${ITEM_DIR}/${FILE_NAME}")
    string(REPLACE "//" "/" ITEM_FILE ${ITEM_FILE})

    add_custom_command(
        TARGET
            ${ASSETS_TARGET_NAME}
        POST_BUILD
        COMMAND
            ${CMAKE_COMMAND} -E copy
                ${ITEM}
                ${ITEM_FILE}
    )
endforeach(ITEM)