using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
[Serializable]
[PostProcess (typeof (ScreenSpaceToWorldPosRender), PostProcessEvent.AfterStack, "Dk/ScreenToWorldPos")]
public sealed class ScreenSpaceToWorldPos : PostProcessEffectSettings {

}
public sealed class ScreenSpaceToWorldPosRender : PostProcessEffectRenderer<ScreenSpaceToWorldPos> {
    Camera camera {
        get {
            if (_Camera == null) _Camera = Camera.main;
            return _Camera;
        }
    }
    Camera _Camera;
    public override void Render (PostProcessRenderContext context) {
        var sheet = context.propertySheets.Get (Shader.Find ("Hidden/Dk/ScreenSpaceToWorldPos"));

        var aspect = camera.aspect;
        var far = camera.farClipPlane;
        var right = camera.transform.right;
        var up = camera.transform.up;
        var forward = camera.transform.forward;
        var halfFovTan = Mathf.Tan (camera.fieldOfView * 0.5f * Mathf.Deg2Rad);

        var rightVec = right * far * halfFovTan * aspect;
        var upVec = up * far * halfFovTan;
        var forwardVec = forward * far;

        var topLeft = forwardVec - rightVec + upVec;
        var topRight = forwardVec + rightVec + upVec;
        var bottomleft = forwardVec - rightVec - upVec;
        var bottomRight = forwardVec + rightVec - upVec;

        var mar = Matrix4x4.identity;
        mar.SetRow (0, topLeft);
        mar.SetRow (1, topRight);
        mar.SetRow (2, bottomleft);
        mar.SetRow (3, bottomRight);

        sheet.properties.SetMatrix ("_CamRay", mar);

        context.command.BlitFullscreenTriangle (context.source, context.destination, sheet, 0);
    }
}