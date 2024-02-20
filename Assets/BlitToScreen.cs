using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteAlways]
public class BlitToScreen : MonoBehaviour
{
    public RenderTexture sourceTexture;

    public Material displayShader;
    public Vector2 offset;
    public Vector2 size;

    public Texture frameTexture;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {

        displayShader.SetVector("_Offset", offset);
        displayShader.SetVector("_Size", size);
        displayShader.SetTexture("_FrameTexture", frameTexture);
        Graphics.Blit(sourceTexture, dest, displayShader);
    }
}