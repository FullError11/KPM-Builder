#include <ktypes.h>  // 必须在 kpmodule.h 前引入
#include <kpmodule.h>
#include <linux/fs.h>
#include <linux/printk.h>

KPM_NAME("demo");  // KPM 模块的名称
KPM_VERSION("0.1.0");  // KPM 模块的版本
KPM_LICENSE("");  // KPM 模块的协议
KPM_AUTHOR("FullError11");  // KPM 模块的作者
KPM_DESCRIPTION("这是一个KPM模块的编写演示例子");  // KPM模块的简介


/// @brief 模块的初始化函数
/// @param args 
/// @param event 
/// @param reserved 
/// @return 
static long demo_init(const char* args, const char* event, void* __user reserved)
{
    pr_info("KPM demo: 内核版本: %d(%x) \n", kver, kver);
    return 0;
}

/// @brief 模块的控制函数
/// @param args 
/// @param out_msg 
/// @param outlen 
/// @return 
static long demo_control0(const char* args, char* __user out_msg, int outlen)
{
    return 0;
}

/// @brief 模块的退出函数
/// @param reserved 
/// @return 
static long demo_exit(void* __user reserved)
{
    return 0;
}

// 通过宏传递模块的基本函数
KPM_INIT(demo_init);  // 入口
KPM_CTL0(demo_control0);  // 控制
KPM_EXIT(demo_exit);  // 出口