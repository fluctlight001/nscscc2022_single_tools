## 修改方法
1. 替换待测试项目的 tb.sv，也就是你自己的 tb.sv 路径：nscscc2022_single\thinpad_top.srcs\sim_1\new\tb.sv
2. 在 thinpad_top 中增加对应的 debug 接口
3. debug 接口的实例化在 sample_thinpad_top.v 中给了例子，在文件中搜索 debug_wb_ 就可大致理解其连接方法

## debug 信号组说明

| 信号名 | 介绍 |  
|-|-|
| debug_wb_pc | 写回阶段（wb）的pc |       
| debug_wb_rf_wen | 写回阶段（wb）对寄存器堆（regfile）的写使能，需要拓展成4bit（字节使能）|
| debug_wb_rf_wnum | 写回阶段（wb）对寄存器堆（regfile）的写地址（目标寄存器号）|
| debug_wb_rf_wdata | 写回阶段（wb）对寄存器堆（regfile）的写数据 |

