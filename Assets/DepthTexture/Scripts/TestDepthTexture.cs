using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestDepthTexture : MonoBehaviour
{
    public Shader _shader;
    private Material _mat;

    void Start()
    {
        if (_shader != null)
            _mat = new Material(_shader);

        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        Camera.main.depthTextureMode &= ~DepthTextureMode.Depth;
        DestroyImmediate(_mat);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_mat != null)
            Graphics.Blit(source, destination, _mat);
        else
            Graphics.Blit(source, destination);
    }

}
