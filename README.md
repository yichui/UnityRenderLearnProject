学习unity渲染知识的记录

一. CommandBuffs的学习（已完成）:
1.类Grab模糊
2.类后处理直接转换颜色
3.伪景深
4.rt替换目标mat的maintexture
5.实现类grabpass的扰动效果
![Image text](https://s4.ax1x.com/2021/12/18/TArc3n.png)


二. 深度图的学习与应用（已完成）:
1.已实现：能量场效果、相交高亮、全局雾效、扫描线、景深，
  未实现：水淹、垂直雾效、边缘检测
  
 
三. PBR（计划中）

四. NPR（计划中） 

五. 偏导数实现边缘锐化和抗锯齿（计划中）

六. GPU Instance（实现中）

 工作流程和原理：将骨骼动画每帧的矩阵运算数据写到一张纹理，
	然后将VBO和这张纹理同时提交给GPU，之后的蒙皮操作就会在GPU进行了，
	VBO相当于提供了一份vector buffer，这样每帧的数据都在这个vector buffer
	中找到索引，对于GPU来说在绘制每帧的时候就能在这个vector buffer找到对应
	索引，因此只保存一份通过索引的方式GPU就可避免重复的操作。虽然在内存的角
	度上会有所增加，但这种方式会大大提升CPU的效率

 第一步：根据unity官网提供的例子实现
	![Image text](https://s4.ax1x.com/2022/01/21/7gg93Q.png)
