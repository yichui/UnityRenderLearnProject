using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class TestGrabDisort : MonoBehaviour
{

    private Camera m_Cam;
    public Shader m_Shader;
    private Material m_Material;

    private CameraEvent selectCameraEvent = CameraEvent.AfterSkybox;// CameraEvent.BeforeForwardAlpha;//CameraEvent.AfterSkybox ;

    private CommandBuffer _buf;

    public void OnWillRenderObject()
    {

        bool isActive = gameObject.activeInHierarchy && enabled;
        if (!isActive)
        {
            Clear();
            return;
        }

        //if (m_Shader == null)
        //    return;

        //if (m_Material == null)
        //    m_Material = new Material(m_Shader);

        //if (m_Cam != null)
        //{
        //    return;
        //}

        m_Cam = Camera.current;

        if (m_Cam != null && _buf != null)
            m_Cam.RemoveCommandBuffers(selectCameraEvent);

        _buf = new CommandBuffer();
        _buf.name = "Grab disort test";
        //从当前屏幕复制一张tx
        int screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
        _buf.GetTemporaryRT(screenCopyID, -1, -1, 0, FilterMode.Bilinear);
        _buf.Blit(BuiltinRenderTextureType.CameraTarget, screenCopyID);

        _buf.SetGlobalTexture("_GrabDisortTexture", screenCopyID);

        _buf.ReleaseTemporaryRT(screenCopyID);
        m_Cam.AddCommandBuffer(selectCameraEvent, _buf);
        
       // 
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
