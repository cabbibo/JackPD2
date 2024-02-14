using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

public class SetSDFTexture : Cycle
{
  public Form3D form;

  MaterialPropertyBlock mpb;

  Renderer renderer;

  public override void Create()
  {
    renderer = GetComponent<MeshRenderer>();
    if (mpb == null) { mpb = new MaterialPropertyBlock(); }
  }

  public override void WhileLiving(float f)
  {


    if (form._texture != null)
    {

      mpb.SetTexture("_SDFTexture", form._texture);
      mpb.SetVector("_SDFExtents", form.extents);
      mpb.SetVector("_SDFCenter", form.center);
      mpb.SetVector("_SDFDimensions", form.dimensions);
      mpb.SetMatrix("_SDFTransform", form.transform.localToWorldMatrix);
      mpb.SetMatrix("_SDFInverseTransform", form.transform.worldToLocalMatrix);
      renderer.SetPropertyBlock(mpb);

    }
  }
}
