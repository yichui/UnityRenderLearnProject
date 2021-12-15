using System.Collections;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;


public class TestCbRimLight : PostEffectBase
{
    private CommandBuffer commandBuffer = null;
    private RenderTexture renderTexture = null;
    private Renderer targetRenderer = null;
    public GameObject targetObject = null;
    public Material replaceMaterial = null;

    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;//亮度
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;  //对比度
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;//饱和度

    void OnEnable()
    {
        targetRenderer = targetObject.GetComponentInChildren<Renderer>();
        //申请RT
        renderTexture = RenderTexture.GetTemporary(512, 512, 16, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, 4);
        commandBuffer = new CommandBuffer();
        //设置Command Buffer渲染目标为申请的RT
        commandBuffer.SetRenderTarget(renderTexture);
        //初始颜色设置为灰色
        commandBuffer.ClearRenderTarget(true, true, Color.gray);
        //绘制目标对象，如果没有替换材质，就用自己的材质
        Material mat = replaceMaterial == null ? targetRenderer.sharedMaterial : replaceMaterial;
        commandBuffer.DrawRenderer(targetRenderer, mat);
        //然后接受物体的材质使用这张RT作为主纹理
        this.GetComponent<Renderer>().sharedMaterial.mainTexture = renderTexture;
        //targetRenderer.sharedMaterial.mainTexture = renderTexture;
        if (_Material)
        {
            //这是个比较危险的写法，一张RT即作为输入又作为输出，在某些显卡上可能不支持，如果不像我这么懒的话...还是额外申请一张RT
            commandBuffer.Blit(renderTexture, renderTexture, _Material);
        }
        //直接加入相机的CommandBuffer事件队列中
        Camera.main.AddCommandBuffer(CameraEvent.BeforeForwardOpaque, commandBuffer);
    }

    void OnDisable()
    {
        //移除事件，清理资源
        Camera.main.RemoveCommandBuffer(CameraEvent.BeforeForwardOpaque, commandBuffer);
        commandBuffer.Clear();
        //renderTexture.Release();
        RenderTexture.ReleaseTemporary(renderTexture);
    }

    //为方便调整，放在update里面了
    void Update()
    {
        _Material.SetFloat("_Brightness", brightness);
        _Material.SetFloat("_Saturation", saturation);
        _Material.SetFloat("_Contrast", contrast);

    }
    //也可以在OnPreRender中直接通过Graphics执行Command Buffer，不过OnPreRender和OnPostRender只在挂在相机的脚本上才有作用！！！
    //void OnPreRender()
    //{
    //    //在正式渲染前执行Command Buffer
    //    Graphics.ExecuteCommandBuffer(commandBuffer);

        //}
    }
