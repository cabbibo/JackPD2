using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

[ExecuteAlways]
public class BindTransformBufferToMaterial : MonoBehaviour
{


    public TransformBuffer buffer;


    public MaterialPropertyBlock mpb;
    public Renderer renderer;

    // Update is called once per frame
    void Update()
    {

        if (buffer == null) { return; }

        if (renderer == null) { renderer = GetComponent<MeshRenderer>(); }
        if (mpb == null) { mpb = new MaterialPropertyBlock(); }

        renderer.GetPropertyBlock(mpb);
        mpb.SetBuffer("_TransformBuffer", buffer._buffer);
        mpb.SetInt("_TransformCount", buffer.count);
        renderer.SetPropertyBlock(mpb);



    }
}
