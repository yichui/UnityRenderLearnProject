基于GPU Instance的原理：

把需要渲染的一个物体的顶点数据VBO传递到了GPU侧，然后通过instance id
和不同的变换矩阵，在vs和ps中绘制出多个对象，虽然只有一次Drawcall调用，
但是渲染后端内部处理的时候会将这一个物体的顶点数据使用vs处理多次（我们想要绘制出的实例数量），
那么对于在视角中完全不可见的实例，对它进行的vs处理就是不必要的，但
是自己使用GPU Instance控制绘制的实例没有办法享受应用阶段的裁剪红利
（一般由引擎提供粗粒度的，以对象为单位的裁剪），也就需要项目对GPU Instance进行手动裁剪。

虽然最后在齐次裁剪空间的裁剪会帮我们把不必要的片元给裁剪掉，但是我们自己提前手动做视锥体
裁剪的话可以减少很多顶点操作，对于超多数量的实例，性能提升的幅度一想便知。

针对裁剪，可以做两次：
第一次，纯CPU端的裁剪，通过对每棵草进行分块，然后对分出的块使用摄像机的视锥体进行AABB测试，
	在视锥体内的才会加入待渲染的草地块列表。

第二次，可以基于Compute Shader的纯GPU的裁剪，将传递进来的一块或多块草地区域中的每棵草通过
	VP矩阵变换到齐次裁剪空间进行手动裁剪，通过测试的才会加入最终的待渲染列表。
	
	
	
学习参考：
1.GPU Skinning 结合 Instanced 高效实现大量单位动画：https://www.cnblogs.com/smallrainf/p/11746909.html
2.URP渲染管线 - GPUInstance绘制草地：https://zhuanlan.zhihu.com/p/354633512 
3.GPUSkinning：https://github.com/chengkehan/GPUSkinning
4.GPGPU Computing Animation & Skinning:https://zhuanlan.zhihu.com/p/50640269