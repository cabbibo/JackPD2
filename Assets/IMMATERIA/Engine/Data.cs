using System.Collections;
using System.Collections.Generic;
using UnityEngine;


/*
  
  This Script is going to be a relatively massive singleton
  that is going to hold all the data and helpers for binding
  that data throughout the project! 

  I'm hoping this will help me get away from the horrific
  spagetti code I'm used to!


*/

namespace IMMATERIA {
public class Data : Cycle
{

  public God god;
  public Transform camera;

  public InputEvents events;
  public AudioPlayer audio;


  public float time;

  public override void Create(){
    if( events != null ){ SafeInsert(events); }
    if( audio != null ){ SafeInsert(audio); }
    if( camera == null ){ camera = Camera.main.transform; }
    if( god == null ){ GetComponent<God>(); }
  }


  
  public void BindCameraData(Life toBind){
    toBind.BindVector3("_CameraForward",  () => this.camera.forward  );
    toBind.BindVector3("_CameraUp",       () => this.camera.up       );
    toBind.BindVector3("_CameraRight",    () => this.camera.right    );
  }

  public void BindRayData(Life toBind){
    toBind.BindVector3( "_RO" , () => this.camera.position );
    toBind.BindVector3( "_RD" , () => this.camera.forward );
  }

  public void BindAllData(Life life){
    BindCameraData( life );
  }

  public override void WhileLiving( float v ){
    time = Time.time;
  }

}
}