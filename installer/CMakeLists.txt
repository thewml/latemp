# see - http://www.cmake.org/Wiki/CMake_FAQ#Is_there_an_option_to_produce_more_.27verbose.27_compiling.3F
# SET(CMAKE_VERBOSE_MAKEFILE ON)

SET (private_mod_path "${CMAKE_SOURCE_DIR}/cmake")
LIST (APPEND CMAKE_MODULE_PATH "${private_mod_path}")
INCLUDE(Shlomif_Common)

SHLOMIF_COMMON_SETUP("${private_mod_path}")

READ_VERSION_FROM_VER_TXT()

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

IF (NOT CMAKE_INSTALL_PREFIX)
    MESSAGE (FATAL_ERROR "CMAKE_INSTALL_PREFIX must be defined. Specify it with -DCMAKE_INSTALL_PREFIX=...")
ENDIF (NOT CMAKE_INSTALL_PREFIX)

SET (MYPREFIX "${CMAKE_INSTALL_PREFIX}")
# MESSAGE (FATAL_ERROR "MYPREFIX = <<${MYPREFIX}>>")
STRING (LENGTH "${MYPREFIX}" MYPREFIX_LEN)

SET (WML_LIB_DIR_BASE "lib")

SET (WML_LIB_DIR "${WML_LIB_DIR_BASE}/wml")
SET (WML_DATA_DIR "${WML_LIB_DIR}/data")
SET (WML_LIBEXE_DIR "${WML_LIB_DIR}/exec/")

# This is the equivalent to perform a "make dist"/"make distdir" etc.
SET(CPACK_PACKAGE_NAME "latemp")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "The Latemp Offline Content Management System")
SET(CPACK_PACKAGE_VENDOR "Shlomi Fish")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/COPYING")

# Process and extract the version number.
# FILE( READ "ver.txt" VERSION)

CHOMP (VERSION)

STRING (REGEX MATCHALL "([0-9]+)" VERSION_DIGITS "${VERSION}")

LIST(GET VERSION_DIGITS 0 CPACK_PACKAGE_VERSION_MAJOR)
LIST(GET VERSION_DIGITS 1 CPACK_PACKAGE_VERSION_MINOR)
LIST(GET VERSION_DIGITS 2 CPACK_PACKAGE_VERSION_PATCH)

SET(CPACK_PACKAGE_INSTALL_DIRECTORY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY} ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

SET(CPACK_SOURCE_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

SET (base_with_ver "${CPACK_PACKAGE_NAME}-[0-9]+\\\\.[0-9]+\\\\.[0-9]+")

SET(CPACK_SOURCE_IGNORE_FILES
    "/build/"
    "/_CPack_Packages/"
    "/CMakeFiles/"
    "/.deps/"
    "^${base_with_ver}(-Source|-Linux)?/"
    "${base_with_ver}.tar\\\\.(gz|bz2|Z|lzma|xz)$"
    "\\\\.o$"
    "~$"
    "\\\\.so(\\\\.[0-9]+)*$"
    "/\\\\.svn/"
    "\\\\.(pdf|fo)$"
    "/t/t/.*\\\\.exe$"
    "/t/Presets"
    "/CMakeCache\\\\.txt$"
    "/Makefile$"
    "/tags$"
    "/([0-9]+)\\\\.board$"
    "/config\\\\.h$"
    "ids-whitelist\\\\.txt"
)

IF(WIN32 AND NOT UNIX)
    # There is a bug in NSI that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    # SET(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\dondorf-king.bmp")
    SET(CPACK_NSIS_INSTALLED_ICON_NAME "bin\\\\wml.exe")
    SET(CPACK_NSIS_HELP_LINK "http:\\\\\\\\thewml.org")
    SET(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\thewml.org")
    SET(CPACK_NSIS_DISPLAY_NAME "Website Meta Language")
    SET(CPACK_NSIS_CONTACT "shlomif@cpan.org")
    SET(CPACK_NSIS_MODIFY_PATH ON)
    # Setting for NSIS :
    SET(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\wml.ico")
    SET(CPACK_NSIS_MUI_UNIICON ${CPACK_NSIS_MUI_ICON})
    SET(CPACK_PACKAGE_ICON ${CPACK_NSIS_MUI_ICON})
    SET(CPACK_NSIS_MODIFY_PATH "ON")
ELSE(WIN32 AND NOT UNIX)
    # SET(CPACK_STRIP_FILES "")
    # SET(CPACK_SOURCE_STRIP_FILES "")
ENDIF(WIN32 AND NOT UNIX)

SET(CPACK_PACKAGE_EXECUTABLES
    "latemp-config" "Latemp configuration flags"
    "latemp-setup" "Set up a latemp site"
)

FOREACH (name "latemp-config" "latemp-setup")
    SET (source_script "${name}.pl")
    SET (SRC_NAME "${CMAKE_CURRENT_SOURCE_DIR}/${source_script}")
    SET (DEST "${CMAKE_CURRENT_BINARY_DIR}/${name}")
    ADD_CUSTOM_COMMAND(
        OUTPUT "${DEST}"
        COMMAND "${PERL_EXECUTABLE}"
        ARGS "${CMAKE_SOURCE_DIR}/cmake/preprocess-prefix-and-version.pl"
            "--input" "${SRC_NAME}"
            "--output" "${DEST}"
            "--version" "${VERSION}"
            "--prefix" "${CMAKE_INSTALL_PREFIX}"
            COMMAND chmod ARGS "a+x" "${DEST}"
        DEPENDS "${SRC_NAME}"
    )
    SET (TARGET "${name}_preproc")
    # The custom command needs to be assigned to a target.
    ADD_CUSTOM_TARGET(
        "${TARGET}" ALL
        DEPENDS "${DEST}"
    )
    INSTALL(
        PROGRAMS "${DEST}"
        DESTINATION "bin"
    )
ENDFOREACH (name)

SET (WML_FILES
    "html-header.wml"
    "html-head-tag.wml"
    "h-w-nav-menu.wml"
    "latemp-driver.wml"
    "latemp-main.wml"
    "latemp-prelude.wml"
    "news-management.wml"
    "template-params.wml"
    "texts.wml"
    "utils.wml"
)

SET (latemp_dest  "lib/wml/include/latemp")

FOREACH (wml_file ${WML_FILES})
    INSTALL (
        FILES "${CMAKE_CURRENT_SOURCE_DIR}/wml/latemp/${wml_file}"
        DESTINATION "${latemp_dest}"
    )
ENDFOREACH (wml_file)

SET (THEMES
    "better-scm"
    "perl-begin-1"
    "sinorca-2.0"
    "css-zen-garden"
)

# Build the document:
IF (1)
    SET (basename "latemp-ref")
    SET (pod "${basename}.pod")
    SET (html "${basename}.html")
    SET (SRC "${CMAKE_CURRENT_SOURCE_DIR}/docs/${pod}")
    SET (DEST_DIR "${CMAKE_CURRENT_BINARY_DIR}/docs/")
    SET (DEST "${DEST_DIR}/${html}")

    FILE (MAKE_DIRECTORY "${DEST_DIR}")
    ADD_CUSTOM_COMMAND(
        OUTPUT "${DEST}"
        COMMAND "${PERL_EXECUTABLE}"
        ARGS "${CMAKE_SOURCE_DIR}/docs/render.pl"
            "${SRC}" "${DEST}"
        DEPENDS "${SRC}"
    )

    SET (TARGET "${basename}_preproc")
    # The custom command needs to be assigned to a target.
    ADD_CUSTOM_TARGET(
        "${TARGET}" ALL
        DEPENDS "${DEST}"
    )

    INSTALL (
        FILES
            "${DEST}"
            "${SRC}"
        DESTINATION
            "share/doc/${CPACK_PACKAGE_NAME}"
    )

ENDIF (1)

INSTALL(
    PROGRAMS "${DEST}"
    DESTINATION "bin"
)
FOREACH (theme ${THEMES})
    INSTALL (
        FILES "${CMAKE_CURRENT_SOURCE_DIR}/wml/latemp/themes/${theme}/template.wml"
        DESTINATION "${latemp_dest}/themes/${theme}"
    )
ENDFOREACH (theme)

INCLUDE (CPack)
