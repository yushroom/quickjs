cmake_minimum_required(VERSION 3.16)

project(quickjs)

option(USE_BIGNUM "use bignum" OFF)

set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

set(QUICKJS_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")
add_library(quickjs
    ${QUICKJS_ROOT_DIR}/cutils.c
    ${QUICKJS_ROOT_DIR}/cutils.h
    ${QUICKJS_ROOT_DIR}/libregexp.c
    ${QUICKJS_ROOT_DIR}/libregexp.h
    ${QUICKJS_ROOT_DIR}/libunicode.c
    ${QUICKJS_ROOT_DIR}/libunicode.h
    ${QUICKJS_ROOT_DIR}/list.h
    ${QUICKJS_ROOT_DIR}/quickjs-atom.h
    ${QUICKJS_ROOT_DIR}/quickjs-libc.c
    ${QUICKJS_ROOT_DIR}/quickjs-libc.h
    ${QUICKJS_ROOT_DIR}/quickjs-opcode.h
    ${QUICKJS_ROOT_DIR}/quickjs.c
    ${QUICKJS_ROOT_DIR}/quickjs.h
)

set_target_properties(quickjs PROPERTIES UNITY_BUILD OFF)
target_include_directories(quickjs PUBLIC ${QUICKJS_ROOT_DIR})
target_compile_definitions(quickjs PUBLIC CONFIG_VERSION="2021-03-27")
target_compile_definitions(quickjs PRIVATE _GNU_SOURCE)

if (WIN32)
    target_sources(quickjs PRIVATE
        ${QUICKJS_ROOT_DIR}/sys_time.h
        ${QUICKJS_ROOT_DIR}/gettimeofday.c)
    target_compile_definitions(quickjs PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_compile_definitions(quickjs PRIVATE EMSCRIPTEN)
endif()

if (USE_BIGNUM)
    target_sources(quickjs PRIVATE
        ${QUICKJS_ROOT_DIR}/libbf.c
        ${QUICKJS_ROOT_DIR}/libbf.h)
    target_compile_definitions(quickjs PRIVATE CONFIG_BIGNUM)
endif ()

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    add_executable(qjsc qjsc.c getopt.h getopt.c)
    target_link_libraries(qjsc PUBLIC quickjs)

    if (EXISTS ${QUICKJS_ROOT_DIR}/repl.c)
        add_executable(qjs qjs.c repl.js repl.c)
        target_link_libraries(qjs PUBLIC quickjs)

        if (EXISTS ${QUICKJS_ROOT_DIR}/qjscalc.c)
            target_sources(qjs PRIVATE qjscalc.js qjscalc.c)
        endif()
    endif()
endif()