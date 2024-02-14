using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace IMMATERIA
{
  public class BindForm3DData : Binder
  {
    public Form3D form;
    public string dimensions = "_Dimensions";
    public string extents = "_Extents";
    public string center = "_Center";

    public override void Bind()
    {
      toBind.BindVector3(dimensions, () => form.dimensions);
      toBind.BindVector3(extents, () => form.extents);
      toBind.BindVector3(center, () => form.center);
    }
  }
}
