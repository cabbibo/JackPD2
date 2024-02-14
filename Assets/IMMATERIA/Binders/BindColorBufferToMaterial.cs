using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

[ExecuteAlways]
public class BindColorBufferToMaterial : MonoBehaviour
{


    public ColorBuffer buffer;


    public MaterialPropertyBlock mpb;
    public Renderer renderer;

    // Update is called once per frame
    void Update()
    {

        if (buffer == null) { return; }

        if (renderer == null) { renderer = GetComponent<MeshRenderer>(); }
        if (mpb == null) { mpb = new MaterialPropertyBlock(); }

        renderer.GetPropertyBlock(mpb);
        mpb.SetBuffer("_ColorBuffer", buffer._buffer);
        mpb.SetInt("_ColorCount", buffer.count);
        renderer.SetPropertyBlock(mpb);



    }
}
