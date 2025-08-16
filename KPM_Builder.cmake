#[[
KPM_Builder.cmake
一个用于直接使用 cmake 编译 KPM模块 (KernelPatchModule)的 cmake拓展

使用要求:
在引入此文件前，需要设置以下变量并确保变量对此文件可见
KPM_COMPILE_CHAIN_PATH 编译KPM模块使用的链路径
对于此编译链，可以在 https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads 下载
 - 注意: 此拓展仅针对linux环境编写，且仅使用64位(aarch64)版本，即必须下载 xxxxx-aarch64-none 版本
 - 推荐下载编译链为
    X86_64 Linux:  xxxxx-x86_64-aarch64-none-elf
    aarch64 Linux:  xxxxx-aarch64-aarch64-none-elf
    macOS:  xxxxx-darwin-arm64-aarch64-none-elf
KPM_KPM_KP_ROOT_DIR 项目 KernelPatch 的路径 (https://github.com/bmax121/KernelPatch.git)
编译时需引入 KernelPatch 中的头文件

使用函数: 
这里只有一个函数，内容如下
function(build_kpm_module TARGET_NAME SOURCE_FILES)
    cmake_parse_arguments(ARG "" "" "INCLUDE_DIRS;DEFINITIONS;OPTIONS" ${ARGN})
    ...
endfunction()
参数介绍如下
TARGET_NAME 单值参数 即这个kpm模块的名称，编译后的产物为 ${TARGET_NAME}.kpm
SOURCE_FILES 多值参数 编译这个kpm的源文件列表，可以有多个
INCLUDE_DIRS 多值参数 使用前需先标明 INCLUDE_DIRS，此后的参数都会被作为引入头文件路径
DEFINITIONS 多值参数 使用前需先标明 DEFINITIONS，此后的参数都会被作为编译kpm模块时的全局宏使用
OPTIONS 多值参数 使用前需先标明 OPTIONS，此后的参数都会被作为编译kpm模块时的选项
使用例子
build_kpm_module(我的KPM模块
    源文件1
    源文件2
    INCLUDE_DIRS
    头文件路径1
    头文件路径2
    DEFINITIONS
    全局宏定义1
    全局宏定义2
    OPTIONS
    -O2
)

Fe11 编写于 2025-08-16
]]

# 设置工具链路径
set(C_COMPILER_FOR_KPM "${KPM_COMPILE_CHAIN_PATH}/bin/aarch64-none-elf-gcc")
set(LINKER_FOR_KPM "${KPM_COMPILE_CHAIN_PATH}/bin/aarch64-none-elf-ld")

# 检查编译器是否存在
if(NOT EXISTS "${C_COMPILER_FOR_KPM}")
    find_program(C_COMPILER_FOR_KPM_IN_PATH "aarch64-none-elf-gcc")
    if(C_COMPILER_FOR_KPM_IN_PATH)
        set(C_COMPILER_FOR_KPM "${C_COMPILER_FOR_KPM_IN_PATH}")
    else()
        message(FATAL_ERROR "C编译器不存在: ${C_COMPILER_FOR_KPM}，设置变量 COMPILE_CHAIN_PATH 以指定编译链路径")
    endif()
endif()

# 检查链接器是否存在
if(NOT EXISTS "${LINKER_FOR_KPM}")
    find_program(LINKER_FOR_KPM_IN_PATH "aarch64-none-elf-ld")
    if(LINKER_FOR_KPM_IN_PATH)
        set(LINKER_FOR_KPM "${LINKER_FOR_KPM_IN_PATH}")
    else()
        message(FATAL_ERROR "链接器不存在: ${LINKER_FOR_KPM}，设置变量 COMPILE_CHAIN_PATH 以指定编译链路径")
    endif()
endif()

message(STATUS "[KPM Builder] 使用的编译器: ${C_COMPILER_FOR_KPM}")
message(STATUS "[KPM Builder] 使用的链接器: ${LINKER_FOR_KPM}")


# 当有多个源文件时，cmake只编译了第一个源文件(在add_library部分)，帮我修复这个BUG

function(build_kpm_module TARGET_NAME)
    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs 
        INCLUDE_DIRS    # 包含目录 
        DEFINITIONS     # 定义宏 
        OPTIONS        # 编译选项 
    )
    
    cmake_parse_arguments(PARSE_ARGV 1 "ARG" 
        "${options}" 
        "${oneValueArgs}" 
        "${multiValueArgs}"
    )

    set(SOURCE_FILES ${ARG_UNPARSED_ARGUMENTS})
 
    set(TMP_OBJS_NAME "${TARGET_NAME}_tmp_objs")
    add_library(${TMP_OBJS_NAME} OBJECT ${SOURCE_FILES})
    set_target_properties(${TMP_OBJS_NAME} PROPERTIES
        C_COMPILER "${C_COMPILER_FOR_KPM}"
        LINKER "${LINKER_FOR_KPM}"
        POSITION_INDEPENDENT_CODE OFF
    )
    target_include_directories(${TMP_OBJS_NAME} PRIVATE
        ${ARG_INCLUDE_DIRS}
        # KernelPatch的头文件路径
        ${KPM_KP_ROOT_DIR}/kernel
        ${KPM_KP_ROOT_DIR}/kernel/include
        ${KPM_KP_ROOT_DIR}/kernel/patch/include
        ${KPM_KP_ROOT_DIR}/kernel/linux/include
        ${KPM_KP_ROOT_DIR}/kernel/linux/arch/arm64/include
        ${KPM_KP_ROOT_DIR}/kernel/linux/tools/arch/arm64/include
    )
    target_compile_definitions(${TMP_OBJS_NAME} PRIVATE ${ARG_DEFINITIONS})
    target_compile_options(${TMP_OBJS_NAME} PRIVATE
        -r
        -O2  
        -fno-PIC
        -fno-unwind-tables
        -fno-asynchronous-unwind-tables
        -nostdlib
        -ffreestanding
        -Wa,--noexecstack
        -Xassembler --noexecstack
        ${ARG_OPTIONS}
    )

    add_custom_command(
        OUTPUT ${TARGET_NAME}.kpm
        COMMAND ${LINKER_FOR_KPM} -r -o ${TARGET_NAME}.kpm 
            $<TARGET_OBJECTS:${TMP_OBJS_NAME}>
        DEPENDS ${TMP_OBJS_NAME}
        COMMAND_EXPAND_LISTS
        VERBATIM
    )
   
    add_custom_target(${TARGET_NAME} ALL
        DEPENDS ${TARGET_NAME}.kpm
    )
endfunction()
