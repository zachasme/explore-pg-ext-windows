# Apache 2 Licensed
# Code modified from:
# TimescaleDB (https://www.timescale.com/)

set(EXT_SQL_FILE ${EXT_NAME}--${PROJECT_VERSION}.sql)
#set(EXT_SQL_UPDATE_FILE ${PROJECT_NAME}--${UPDATE_FROM_VERSION}--${PROEJCT_VERSION}.sql)
#set(EXT_SQL_UPDATE_PRE_FILE updates/pre-${UPDATE_FROM_VERSION}--${PROEJCT_VERSION}.sql)
#set(EXT_SQL_UPDATE_POST_FILE updates/post-${UPDATE_FROM_VERSION}--${PROEJCT_VERSION}.sql)

set(SQL_FILES
        simple.sql
#        00-type.sql
#        01-indexing.sql
#        02-inspection.sql
#        03-traversal.sql
#        04-hierarchy.sql
#        05-regions.sql
#        06-uniedge.sql
#        07-miscellaneous.sql
#        10-extension.sql
#        11-opclass_btree.sql
#        12-opclass_hash.sql
#        99-type.sql
)

if (WIN32)
    # Make list of files into string of files separated by "+"
    # to make Windows copy concatenate them
    string(REPLACE ";" ";+" SQL_FILES_JOINED "${SQL_FILES}")
    # Windows copy command requires backslashes for relative paths
    string(REPLACE "/" "\\" EXT_SQL_UPDATE_PRE_FILE "${EXT_SQL_UPDATE_PRE_FILE}")
    string(REPLACE "/" "\\" EXT_SQL_UPDATE_POST_FILE "${EXT_SQL_UPDATE_POST_FILE}")

    set(CAT_SQL_FILE_CMD copy /B /y ${SQL_FILES_JOINED} "\"${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_FILE}\"" >NUL)
    set(CAT_SQL_UPDATE_FILE_CMD copy /B /y ${EXT_SQL_UPDATE_PRE_FILE} + ${SQL_FILES_JOINED} + ${EXT_SQL_UPDATE_POST_FILE} "\"${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_UPDATE_FILE}\"" >NUL)
else ()
    set(CAT_SQL_FILE_CMD cat ${SQL_FILES} > ${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_FILE})
    set(CAT_SQL_UPDATE_FILE_CMD cat ${EXT_SQL_UPDATE_PRE_FILE} ${SQL_FILES} ${EXT_SQL_UPDATE_POST_FILE} > ${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_UPDATE_FILE})
endif ()

# Command and target for the SQL file
add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_FILE}
        DEPENDS ${SQL_FILES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ${CAT_SQL_FILE_CMD}
        COMMENT "Generating ${EXT_SQL_FILE}")

add_custom_target(sqlfile ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_FILE})

# Command and target for the update SQL file
#add_custom_command(
#        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_UPDATE_FILE}
#        DEPENDS ${SQL_FILES} ${EXT_SQL_UPDATE_PRE_FILE} ${EXT_SQL_UPDATE_POST_FILE}
#        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#        COMMAND ${CAT_SQL_UPDATE_FILE_CMD}
#        COMMENT "Generating ${EXT_SQL_UPDATE_FILE}")
#
#add_custom_target(sqlupdatefile ALL DEPENDS ${EXT_SQL_UPDATE_FILE})

install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${EXT_SQL_FILE}
        DESTINATION "${PostgreSQL_SHARE_DIR}/extension")
