using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// 将物体渲染顺序推到后处理后渲染
/// </summary>
public class RenderPutAfterPostEffect : MonoBehaviour
{
    public Renderer _targetRenderer = null;

    CommandBuffer _commandBuffer = null;

    void OnEnable()
    {
        _targetRenderer = gameObject.GetComponentInChildren<Renderer>();
        if (_targetRenderer)
        {
            _commandBuffer = new CommandBuffer();
            //  Add a "draw renderer" command.
            _commandBuffer.DrawRenderer(_targetRenderer, _targetRenderer.sharedMaterial);
            //直接加入相机的CommandBuffer事件队列中,推到后处理后再显示
            Camera.main.AddCommandBuffer(CameraEvent.AfterImageEffects, _commandBuffer);

            //这样做的问题是无视深度，只能在需要放最前面的物体才能这样做
            _targetRenderer.enabled = false;
        }
    }

    private void OnDisable()
    {
        if (_targetRenderer)
        {
            //移除事件，清理资源
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterImageEffects, _commandBuffer);
            _commandBuffer.Clear();
            _targetRenderer.enabled = true;
        }   

    }
}
