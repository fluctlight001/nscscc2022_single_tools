## 修改方法
1. 替换待测试项目的tb.sv 路径：nscscc2022_single\thinpad_top.srcs\sim_1\new\tb.sv
2. 相对应的需要在thinpad_top中增加对应的debug接口 sample中给了例子，可以自行查看
3. debug信号组说明

| 信号名 | 介绍 |  
|-|-|
| debug_wb_pc | 写回阶段（wb）的pc |       
| debug_wb_rf_wen | 写回阶段（wb）对寄存器堆（regfile）的写使能，需要拓展成4bit（字节使能）|
| debug_wb_rf_wnum | 写回阶段（wb）对寄存器堆（regfile）的写地址（目标寄存器号）|
| debug_wb_rf_wdata | 写回阶段（wb）对寄存器堆（regfile）的写数据 |

