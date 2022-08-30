

参考链接：
https://zhuanlan.zhihu.com/p/330599077
https://zhuanlan.zhihu.com/p/440805975
https://zhuanlan.zhihu.com/p/365339160
https://zhuanlan.zhihu.com/p/360229590
https://zhuanlan.zhihu.com/p/110025903
https://zhuanlan.zhihu.com/p/163791090
https://zhuanlan.zhihu.com/p/95986273

https://www.zhihu.com/column/c_1412379488113700864
https://zhuanlan.zhihu.com/p/435005339

https://github.com/sanagi/UnityGraphicTest/blob/dfc63cfb9c8f858472f9558452adcc9d382261fa/UnityChanSSU_URP-release-1.0.2/Assets/Shaders/URPGenToon.shader
https://github.com/ashyukiha/GenshinCharacterShaderZhihuVer/blob/main/GenshinCharacterShaderZhihuVer.shader
https://github.com/LeeJJason/LearnUnityShader
https://github.com/unity3d-jp/UnityChanToonShaderVer2_Project

tools：
https://zhuanlan.zhihu.com/p/107664564

【翻译】西川善司「实验做出的游戏图形」「GUILTY GEAR Xrd -SIGN-」中实现的「纯卡通动画的实时3D图形」的秘密，前篇（1）
https://www.cnblogs.com/TracePlus/p/4205798.html

【游戏开发实战】下载原神模型，PMX转FBX，导入到Unity中，卡通渲染，绑定人形动画（附Demo工程）
https://blog.csdn.net/linxinfa/article/details/121370565

原神LightMap光照贴图通道信息含义：
	r :高光类型Layer,根据值域选择不同的高光类型(eg:BlinPhong 裁边视角光) 
		丝袜裁边⾼光 ：0~50
		布料裁边⾼光 ：50~150
		头发：150~250
		金属高光 ：250以上
	g :阴影AO ShadowAOMask 
	b :BlinPhong高光强度Mask遮罩 SpecularIntensityMask 
	a :Ramp过渡类型Layer，根据值域选择不同的Ramp 
		0.0 ： 硬的物体 hard/emission/specular/silk
		0.3 ： 软的物体 soft/common
		0.5 ： 金属/金属投影 metal
		0.7： 丝绸/丝袜 tights
		1.0 ： 皮肤/头发 skin