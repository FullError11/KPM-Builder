cmake_minimum_required(VERSION 3.12)

project(kpm_builder_demo C)

# 设置 编译链 和 KernelPatch 路径
set(KPM_COMPILE_CHAIN_PATH "/home/fe11/arm-gnu-toolchain-14.3.rel1-aarch64-aarch64-none-elf")
set(KPM_KP_ROOT_DIR "third_party/KernelPatch")
# 引入 kpm 编译脚本
include(KPM_Builder.cmake)

# 编译 demo 模块
build_kpm_module(demo demo/main.c)
