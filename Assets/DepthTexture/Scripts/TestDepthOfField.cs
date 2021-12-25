using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestDepthOfField : MonoBehaviour
{
    //public Shader _shader;
    public Material _mat;
    public Material _bluemat;


    void Start()
    {
        //if (_mat != null)
        //    _mat = new Material(_shader);

        //Camera.main.depthTextureMode |= DepthTextureMode.Depth;
        Camera.main.depthTextureMode = DepthTextureMode.Depth;

    }

    void OnDisable()
    {
        Camera.main.depthTextureMode &= ~DepthTextureMode.Depth;
        DestroyImmediate(_mat);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_mat != null && _bluemat != null)
        {
            RenderTexture blurTex = RenderTexture.GetTemporary(source.width, source.height, 16);
            Graphics.Blit(source, blurTex, _bluemat);
            _mat.SetTexture("_BlurTexture", blurTex);
            Graphics.Blit(source, destination, _mat);
            RenderTexture.ReleaseTemporary(blurTex);
        }
        else
            Graphics.Blit(source, destination);
    }

}
