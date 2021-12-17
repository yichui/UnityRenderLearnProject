using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;


/// <summary>
/// 最简单例子
/// 将一个renderer和material提交到主camera的commandbuffer列表进行绘制渲染，
/// 代码比较好理解，render的网格几何数据加上material的shader渲染命令，就相当于提交drawcall了。
/// 有点类似OnImageRender做屏幕后期特效一样，原本standard材质的灰色渲染出来后又经过commandbuff指定的material变成了绿色。
/// </summary>
public class FirstCBTest : MonoBehaviour
{
    public Shader shader;
    private void OnEnable()
    {
        CommandBuffer cmd = new CommandBuffer();

        cmd.DrawRenderer(GetComponent<Renderer>(), new Material(shader));

        Camera.main.AddCommandBuffer(CameraEvent.AfterForwardOpaque ,cmd);
    }
}
