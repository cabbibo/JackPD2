using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

public class BindOSCFloat : Binder
{
   
   public OscSynapse osc;

    public string oscString;
    public string nameInShader;
    public string idNameInShader;

    public Body[] bodies;
    public Form[] forms;
    public Life[] lives;

    public float val;

    public Vector3 colorInfo;
    public string colorInfoName;

    public int id;

    public float multiplier = 1;
   public override void Bind(){

        oscString = gameObject.name;
        print( oscString );

    for( int i = 0; i< osc.floatStrings.Length; i++){
        if( osc.floatStrings[i] == oscString){
            id = i;
        }
    }


    if( toBind != null ){
        toBind.BindFloat(nameInShader,()=> osc.floatValues[id] * multiplier );
        toBind.BindFloat(idNameInShader,()=> id );
    }

    for( int i = 0; i < lives.Length; i++ ){
        lives[i].BindFloat(nameInShader,()=> osc.floatValues[id] * multiplier );
        lives[i].BindFloat(idNameInShader,()=> id );
    }

   }

    public override void WhileLiving(float v){

        for( int i = 0;  i<bodies.Length; i++ ){
            bodies[i].mpb.SetFloat(nameInShader,osc.floatValues[id] * multiplier);
            bodies[i].mpb.SetFloat(idNameInShader,id );
            bodies[i].mpb.SetVector(colorInfoName, colorInfo);
        }

             for( int i = 0;  i<forms.Length; i++ ){
            forms[i].mpb.SetFloat(nameInShader,osc.floatValues[id] * multiplier);
            forms[i].mpb.SetFloat(idNameInShader,id );
            forms[i].mpb.SetVector(colorInfoName, colorInfo);
        }


    }

}
