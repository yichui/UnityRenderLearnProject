using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

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
