project (translator)
cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (HICOLOR_DIR ${DATADIR}/icons/hicolor)

set (PKGDATADIR "${DATADIR}/translator")
set (GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
set (EXEC_NAME "translator")
set (RELEASE_NAME "translator")
set (VERSION "0.7")
set (VERSION_INFO "0.7")
set (PREFIX ${CMAKE_INSTALL_PREFIX})

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

file(GLOB_RECURSE sources src/*.vala)

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.28" MINIMUM)
include (ValaPrecompile)

add_definitions (-DGETTEXT_PACKAGE="translator")

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gtk+-3.0 libsoup-2.4 gee-0.8 gio-2.0 granite gthread-2.0 json-glib-1.0)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

vala_precompile(VALA_C ${EXEC_NAME}
    src/Main.vala
    src/TranslatorApplication.vala
    src/TranslatorWindow.vala
    src/GlobalSettings.vala
    src/Assets.vala
    src/AsyncTaskExecuter.vala
    src/TranslatorService.vala
    src/DictionaryService.vala
    src/WebJsonClient.vala
PACKAGES
    gtk+-3.0
    granite
    libsoup-2.4
    json-glib-1.0
OPTIONS
    --thread
)

add_executable(${EXEC_NAME} ${VALA_C})
add_subdirectory (po)

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/images DESTINATION "${PKGDATADIR}")
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/${CMAKE_PROJECT_NAME}.desktop DESTINATION "${DATADIR}/applications")

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/translator.svg DESTINATION ${HICOLOR_DIR}/16x16/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/translator.svg DESTINATION ${HICOLOR_DIR}/24x24/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/translator.svg DESTINATION ${HICOLOR_DIR}/32x32/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/translator.svg DESTINATION ${HICOLOR_DIR}/48x48/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/translator.svg DESTINATION ${HICOLOR_DIR}/64x64/apps/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/translator.svg DESTINATION ${HICOLOR_DIR}/128x128/apps/)

include(GSettings)
add_schema (data/skyprojects.eos.translate.gschema.xml)
install (CODE
    "execute_process (COMMAND gtk-update-icon-cache ${HICOLOR_DIR})"
)
