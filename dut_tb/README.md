## 修改方法
1. 替换待测试项目的 tb.sv，也就是你自己的 tb.sv 路径：nscscc2022_single\thinpad_top.srcs\sim_1\new\tb.sv
2. 在 thinpad_top 中增加对应的 debug 接口 _（debug接口在综合时需要全部注释，参见第四条）_
3. debug 接口的实例化在 sample_thinpad_top.v 中给了例子，在文件中搜索 debug_wb_ 就可大致理解其连接方法
4. 重要注意事项：由本项目在引入的端口仅限于在仿真中使用，在综合时需要把debug信号组注释掉。tb文件不参与综合，所以可以不用管。具体的注释方案请对比参考 sample_thinpad_top.v 和 https://github.com/fluctlight001/cpu_for_nscscc2022_single/blob/main/thinpad_top.srcs/sources_1/new/thinpad_top.v 。

## debug 信号组说明

| 信号名 | 介绍 |  
|-|-|
| debug_wb_pc | 写回阶段（wb）的pc |       
| debug_wb_rf_wen | 写回阶段（wb）对寄存器堆（regfile）的写使能，需要拓展成4bit（字节使能）|
| debug_wb_rf_wnum | 写回阶段（wb）对寄存器堆（regfile）的写地址（目标寄存器号）|
| debug_wb_rf_wdata | 写回阶段（wb）对寄存器堆（regfile）的写数据 |

