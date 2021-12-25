using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnableCameraDepthTex : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        //if (_mat != null)
        //    _mat = new Material(_shader);

        //Camera.main.depthTextureMode |= DepthTextureMode.Depth;
        Camera.main.depthTextureMode = DepthTextureMode.Depth;

    }
}
