using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class ControlRender : MonoBehaviour
{


    public Camera[] cameras;
    public Vector4[] frustums;

    public bool focusRender;
    public int focusedRender;

    public Camera allCamera;

    public bool[] allCameraLayers;
    public string[] layerNames;

    public bool renderAllCamera;

    // Update is called once per frame
    void Update()
    {



        if (renderAllCamera)
        {
            allCamera.enabled = true;
            int mask = 0;
            for (int i = 0; i < layerNames.Length; i++)
            {
                if (allCameraLayers[i])
                {
                    mask |= 1 << LayerMask.NameToLayer(layerNames[i]);
                }
            }

            allCamera.cullingMask = mask;

            for (int i = 0; i < cameras.Length; i++)
            {
                cameras[i].enabled = false;
            }
        }
        else
        {
            allCamera.enabled = false;

            for (int i = 0; i < cameras.Length; i++)
            {
                cameras[i].enabled = true;
                cameras[i].rect = new Rect(frustums[i].x, frustums[i].y, frustums[i].z, frustums[i].w);
            }
        }

        /*if (focusRender)
                {
                    for (int i = 0; i < cameras.Length; i++)
                    {
                        if (i == focusedRender)
                        {
                            cameras[i].enabled = true;
                            cameras[i].rect = new Rect(0, 0, 1, 1);
                        }
                    }
                }
                else
                {

                    for (int i = 0; i < cameras.Length; i++)
                    {
                        cameras[i].enabled = true;
                        cameras[i].rect = new Rect(frustums[i].x, frustums[i].y, frustums[i].z, frustums[i].w);
                    }
                }*/

    }
}
