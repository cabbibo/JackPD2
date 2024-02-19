using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;
using UnityEditor;

[CustomEditor(typeof(Form),true), CanEditMultipleObjects]
public class FormEditor : Editor 
{  

   public override void OnInspectorGUI()
    {
         Form form = (Form)target;

        if(GUILayout.Button("Reset"))
        {
            form._ResetData();
        }

        
        if( GUILayout.Button("Reload") ){
            form._ReloadData();
        }   


        if( GUILayout.Button("Save") ){
            form._SaveData();
        }   

        DrawDefaultInspector();
    }
}
