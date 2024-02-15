using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace IMMATERIA {
public class BindTransform : Binder
{


  public Transform transform;

  public bool bindInverse;
  public string name = "_Transform";
  public string inverseName;
    public Matrix4x4 transformMatrix;
    public Matrix4x4 inverseTransformMatrix;
    public override void Bind(){

      
      toBind.BindMatrix(name, () => this.transformMatrix );
      if( bindInverse ){
        toBind.BindMatrix(inverseName,()=>this.inverseTransformMatrix);
      }
    }


    public override void WhileLiving( float v){
//      print(transform.localToWorldMatrix[0]);
      transformMatrix = transform.localToWorldMatrix;
      inverseTransformMatrix = transform.worldToLocalMatrix;
    }
  }
}