# 龙芯杯个人赛 golden_trace 机制

## 项目说明

1. 该 golden_trace 机制移植自龙芯杯团队赛功能测试中的 golden_trace 机制。

2. golden_trace 的主要功能：通过比对处理器对寄存器堆（regfile）的修改，来找出测试处理器与正确运行行为之间的差异。

3. 该项目中的对照处理器为本人 2020 年的参赛项目，为大家比对方便关闭了双发射机制，原始项目就在隔壁，如有需要自行获取。

4. trace 机制本人已在自己 2022 年的参赛项目上进行验证，请大家放心使用。

## 使用说明

1. 请根据dut_tb文件夹中的 __README__ 对项目进行修改。

2. 可自行替换本项目中的比对内容，修改对照处理器项目 tb 中载入的 bin 文件即可。如不知道到底是哪个 tb ，打开本项目的 .xpr 文件，修改当前正在使用的 tb 即可

3. 运行本对照处理器项目后 golden_trace.txt 会产生在 .xpr 文件所在目录，需要把该文件复制到目标项目的 .xpr 文件所在目录中。

4. 当前已生成一个 kernel 的 golden_trace 波形。该波形一直持续到串口输出第三个字母。

5. __注意__ ：如果在串口中出现比对错误是正常的，可能是由于设计差异导致串口提前完成，致使串口轮询提前结束。

## 注

1. 如有问题请直接在龙芯杯群（583344130）中联系 RT_NI
2. 多来点建议呀！！！~~（不然我怎么更新~~

---

## PS: 如果觉得好用，请star以示鼓励

## Stargazers over time
[![Stargazers over time](https://starchart.cc/fluctlight001/nscscc2022_single_tools.svg?variant=light)](https://starchart.cc/fluctlight001/nscscc2022_single_tools)
