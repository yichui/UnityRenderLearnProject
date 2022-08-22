using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenCameraDepth : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;//打開當前相機深度圖
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
