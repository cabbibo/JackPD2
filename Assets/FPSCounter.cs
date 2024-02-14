using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro; // Import the TextMeshPro namespace

public class FPSCounter : MonoBehaviour
{
    public TMP_Text fpsText; // Reference to the TextMeshPro Text component
    private float deltaTime = 0.0f;

    void Update()
    {
        // Calculate deltaTime
        deltaTime += (Time.unscaledDeltaTime - deltaTime) * 0.1f;

        // Calculate FPS
        float fps = 1.0f / deltaTime;

        // Update the TextMeshPro text
        fpsText.text = string.Format("{0:0.} fps", fps);
    }
}