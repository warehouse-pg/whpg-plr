cmake_minimum_required(VERSION 3.14)
project(plr-whpg)

# To build R and plr for WHPG.
# R_HOME and LD_LIBRARY_PATH are the two things we care here. Since we try to
# avoid putting vars in the greenplum_path.sh to pollute ENVs.
#
# R is built and installed to a temp location. However, we use
# '/usr/local/greenplum-db' as its prefix, which is also the final location
# where user install it. That will make the relevant R_HOME dir macros points
# to the correct place. No R_HOME needs to be set for R to find its home, since
# the default one is correct.
#
# For plr, R_HOME is:
# - needed by the its Makefile, we give it the R's temp installation dir.
# - needed by the init function through a MACRO, we set it to the final one
#   through the CPPFLAGS.

include(ExternalProject)

if(POLICY CMP0135) # From CMake 3.24
    # We don't care about DOWNLOAD_EXTRACT_TIMESTAMP; prefer the new behavior
    cmake_policy(SET CMP0135 NEW)
endif()

# Check the fortran version. We need to set different FFLAGS
enable_language(Fortran)
message(STATUS "Fortran compiler version: ${CMAKE_Fortran_COMPILER_VERSION}")
if(${CMAKE_Fortran_COMPILER_VERSION} VERSION_GREATER_EQUAL 10)
    # Fix gcc10 fortran failure with cmplx.f
    # See https://stackoverflow.com/questions/63892055/fortran-error-type-mismatch-between-two-unrelated-subroutine-calls
    # FFLAGS="-fallow-argument-mismatch"
    SET(FFLAGS "FFLAGS=-fallow-argument-mismatch")
else()
    SET(FFLAGS "")
endif()

if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE "Release" CACHE
        STRING "Choose the type of build." FORCE)
endif()
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
set(CONFIGURE_ENABLE_DEBUG --enable-debug)
endif()

if(DEFINED ENV{GPHOME})
    set(GPHOME_DIR "$ENV{GPHOME}")
    message(STATUS "Use '${GPHOME_DIR}' as GPHOME")
else()
    message(FATAL_ERROR
        "Error: The GPHOME environment variable is not set."
        "Please set it to your Greenplum Database installation path before"
        "running cmake.")
endif()


# For the local dev build, set this to the $GPHOME.
# proj and gdal should use `/usr/local/greenplum-db` as the prefix, to make
# sure it can find the `share/proj` and `share/gdal` at runtime.
if(NOT R_PREFIX)
    set(R_PREFIX /usr/local/greenplum-db)
    message(STATUS
        "R will use '${R_PREFIX}' as the prefix.")
endif()
# For the cmake install target
set(CMAKE_INSTALL_PREFIX ${GPHOME_DIR})

set(INSTALL_DIR ${CMAKE_BINARY_DIR}/usr)
set(DOWNLOAD_DIR ${CMAKE_SOURCE_DIR}/3rdparty/download)
set(PLR_TEMP_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/plr_temp_install)
set(PATCH_DIR ${CMAKE_SOURCE_DIR}/3rdparty)
set(PLR_SOURCE_DIR ${CMAKE_SOURCE_DIR}/..)

if(NOT JOBS)
    set(JOBS 4)
endif()

ExternalProject_Add(
    r

    URL
    https://cran.r-project.org/src/base/R-3/R-3.6.3.tar.gz
    https://mirrors.tuna.tsinghua.edu.cn/CRAN/src/base/R-3/R-3.6.3.tar.gz
    URL_HASH
    SHA256=89302990d8e8add536e12125ec591d6951022cf8475861b3690bc8bf1cefaa8f
    DOWNLOAD_DIR ${DOWNLOAD_DIR}

    # There are many "multiple definition" error with gcc10 and R 3.3.3.
    # Just turn the error off for el9.
    # CFLAGS="-fcommon"
    CONFIGURE_COMMAND
    ${CMAKE_COMMAND} -E env
    ${FFLAGS}
    "CFLAGS=-fcommon -Wno-error=implicit-function-declaration"
    <SOURCE_DIR>/configure
    --prefix=${R_PREFIX}
    --with-x=no
    --with-readline=no
    # Static link doesn't work in this version since it mistakenly put main.o in
    # the libR.a
    --enable-R-shlib
    --disable-rpath

    BUILD_COMMAND
    ${CMAKE_COMMAND} -E env
    make -j${JOBS}

    INSTALL_COMMAND
    make install DESTDIR=${INSTALL_DIR}
    # Create symoblics links to $GPHONE/lib, so user doesn't have to change
    # LD_LIBRARY_PATH anymore.
    COMMAND
    ${CMAKE_COMMAND} -E make_directory ${INSTALL_DIR}${R_PREFIX}/lib
    COMMAND
    ${CMAKE_COMMAND} -E chdir ${INSTALL_DIR}${R_PREFIX}/lib
    ln -s ../lib64/R/lib/libR.so ../lib64/R/lib/libRblas.so ../lib64/R/lib/libRlapack.so .
)

ExternalProject_Add(
    plr

    SOURCE_DIR ${PLR_SOURCE_DIR}
    BUILD_IN_SOURCE YES

    CONFIGURE_COMMAND
    echo "No configure steps for plr"

    BUILD_COMMAND
    # Always clean first, the makefile doesn't work well.
    ${CMAKE_COMMAND} -E env
    "R_HOME=${INSTALL_DIR}${R_PREFIX}/lib64/R"
    make USE_PGXS=1 clean
    COMMAND
    ${CMAKE_COMMAND} -E env
    "R_HOME=${INSTALL_DIR}${R_PREFIX}/lib64/R"
    make -j${JOBS} USE_PGXS=1 with_llvm=no CPPFLAGS="-DR_HOME_DEFAULT=\\\"${R_PREFIX}/lib64/R\\\""

    INSTALL_COMMAND
    ${CMAKE_COMMAND} -E env
    "R_HOME=${INSTALL_DIR}${R_PREFIX}/lib64/R"
    make install
    USE_PGXS=1 with_llvm=no DESTDIR=${PLR_TEMP_INSTALL_PREFIX}

    DEPENDS r
)

add_custom_target(
    installcheck
    ${CMAKE_COMMAND} -E env
    "R_HOME=${GPHOME_DIR}/lib64/R"
    make installcheck USE_PGXS=1
    WORKING_DIRECTORY ${PLR_SOURCE_DIR}
)

install(DIRECTORY ${INSTALL_DIR}${R_PREFIX}/ DESTINATION ${GPHOME_DIR}
    USE_SOURCE_PERMISSIONS)
install(DIRECTORY
    ${PLR_TEMP_INSTALL_PREFIX}${GPHOME_DIR}/share/ TYPE DATA
    USE_SOURCE_PERMISSIONS)
install(DIRECTORY
    ${PLR_TEMP_INSTALL_PREFIX}${GPHOME_DIR}/lib/ TYPE LIB
    USE_SOURCE_PERMISSIONS)
