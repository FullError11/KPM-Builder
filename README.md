# KPM_Builder - 用于 KernelPatch 模块 (KPM) 编译的 CMake 扩展

## 项目简介

`KPM_Builder.cmake` 是一个 CMake 扩展脚本，用于简化 **KernelPatch 模块 (KPM)** 的编译流程。

## 功能特性

- 自动化配置 ARM GNU 工具链 (aarch64-none-elf)
- 一键式 KPM 模块编译
- 自动包含 KernelPatch 项目头文件
- 支持自定义编译选项和宏定义
- 支持 x86_64/aarch64 Linux

## 使用要求

### 必备组件
1. **ARM GNU 工具链**  
   从 [ARM 官网](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads) 下载：
   - x86_64 Linux: `xxxxx-x86_64-aarch64-none-elf`
   - aarch64 Linux: `xxxxx-aarch64-aarch64-none-elf`
   - macOS: `xxxxx-darwin-arm64-aarch64-none-elf`

2. **KernelPatch 项目**  
   从 GitHub 克隆:  
   ```bash
   git clone https://github.com/bmax121/KernelPatch.git
   ```

## 安装配置

1. 将 `KPM_Builder.cmake` 放入您的项目目录
2. 在 CMakeLists.txt 中添加配置：

```cmake
# 设置工具链路径
set(KPM_COMPILE_CHAIN_PATH "/path/to/arm-gnu-toolchain")
set(KPM_KP_ROOT_DIR "/path/to/KernelPatch")

# 包含 KPM 构建器
include(KPM_Builder.cmake)
```

## 使用示例

```cmake
# 构建 KPM 模块
build_kpm_module(
    my_module             # 模块名称
    src/my_module.c       # 源文件
    INCLUDE_DIRS          # 附加包含目录
        include/
    DEFINITIONS           # 自定义宏
        MODULE_VERSION=1
    OPTIONS                 # 编译选项
        -O2
)
```

## 构建选项

| 参数 | 说明 |
|------|------|
| `TARGET_NAME` | 目标模块名称 (输出: TARGET_NAME.kpm) |
| `SOURCE_FILES` | 源文件列表 |
| `INCLUDE_DIRS` | 附加包含目录 (可选) |
| `DEFINITIONS` | 自定义宏定义 (可选) |
| `OPTIONS` | 编译选项 (可选) |

## 清理构建
```bash
make clean  # 自动清理生成的 .kpm 文件
```

## 常见问题

**Q: 出现 "C编译器不存在" 错误怎么办？**  
A: 请检查：
1. 是否正确设置了 `KPM_COMPILE_CHAIN_PATH`
2. 工具链是否解压完整
3. 系统是否安装了必要的依赖库

**Q: 如何验证工具链是否可用？**  
```bash
/path/to/toolchain/bin/aarch64-none-elf-gcc --version
```

## 项目起源
- VS Code对Mackfile的支持并不好 (无法自动管理Makefile内引入的头文件路径)  
- 本人不擅长 Makefile的语法 
所以基于 KernelPatch 内的示例Makefile, 就有了本项目


## 许可证

MIT License © 2025 FullError11

---

> 相关项目: [KernelPatch](https://github.com/bmax121/KernelPatch)