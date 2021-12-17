using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;



/// <summary>
/// 仿照官方commandbuff的例子，在BeforeForwardAlpha的渲染顺序前获取到当前屏幕的rt,
/// 经过模糊效果后得到一张模糊rt,将其放到 Cube物体半透明shader中的_GrabBlurTexture中，
/// 在半透明渲染时使用，使得在前面Cube中物体中渲染模糊玻璃的效果
/// </summary>
public class TestCbBlurRefraction : MonoBehaviour
{
    private Camera m_Cam;
    public Shader m_Shader;
    private Material m_Material;

    private CameraEvent selectCameraEvent = CameraEvent.BeforeForwardAlpha;//CameraEvent.AfterSkybox ;

    private CommandBuffer _buf; 

   
   

    public void OnWillRenderObject()
    {
        bool isActive = gameObject.activeInHierarchy && enabled;
        if (!isActive)
        {
            Clear();
            return;
        }

        if (m_Shader == null)
            return;

        if (m_Material == null)
            m_Material = new Material(m_Shader);

        //if (m_Cam != null)
        //{
        //    return;
        //}

        m_Cam = Camera.current;

        if (m_Cam != null && _buf != null)
            m_Cam.RemoveCommandBuffers(selectCameraEvent);

        _buf = new CommandBuffer();
        _buf.name = "Grab cb test";

        //从当前屏幕复制一张tx
        int screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
        _buf.GetTemporaryRT(screenCopyID, -1, -1, 0, FilterMode.Bilinear);
        _buf.Blit(BuiltinRenderTextureType.CameraTarget, screenCopyID);

        // 获取2张更小的贴图来做模糊
        int blurredID = Shader.PropertyToID("_Temp1");
        _buf.GetTemporaryRT(blurredID, -2, -2, 0, FilterMode.Bilinear);
        int blurredID2 = Shader.PropertyToID("_Temp2");
        _buf.GetTemporaryRT(blurredID2, -2, -2, 0, FilterMode.Bilinear);

        // 先采样之前采样的屏幕rt放到blurredID的rt里
        //然后释放掉屏幕rt
        _buf.Blit(screenCopyID, blurredID);
        _buf.ReleaseTemporaryRT(screenCopyID);

        //修改SeparableBlur.shader的全局参数offsets,使其产生各个方向的模糊效果来叠加增强效果
        // horizontal blur
        _buf.SetGlobalVector("offsets", new Vector4(2.0f / Screen.width, 0, 0, 0));
        _buf.Blit(blurredID, blurredID2, m_Material);
        // vertical blur
        _buf.SetGlobalVector("offsets", new Vector4(0, 2.0f / Screen.height, 0, 0));
        _buf.Blit(blurredID2, blurredID, m_Material);
        // horizontal blur
        _buf.SetGlobalVector("offsets", new Vector4(4.0f / Screen.width, 0, 0, 0));
        _buf.Blit(blurredID, blurredID2, m_Material);
        // vertical blur
        _buf.SetGlobalVector("offsets", new Vector4(0, 4.0f / Screen.height, 0, 0));
        _buf.Blit(blurredID2, blurredID, m_Material);

        //得到透明效果纹理后，将其赋值给GlassWithoutGrab.shader的_GrabBlurTexture混合得到模糊透明
        _buf.SetGlobalTexture("_GrabBlurTexture", blurredID);

        _buf.ReleaseTemporaryRT(blurredID2);
        _buf.ReleaseTemporaryRT(blurredID);


        m_Cam.AddCommandBuffer(selectCameraEvent, _buf);

    }

    public void OnDisable()
    {
        Clear();
    }
    public void OnEnable()
    {
        Clear();
    }


    private void Clear()
    {
        if (m_Cam != null && _buf != null)
            m_Cam.RemoveCommandBuffer(selectCameraEvent, _buf);

        if (m_Material != null)
            Object.DestroyImmediate(m_Material);
    }
}
