using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;
using UnityEditor;

[CustomEditor(typeof(MeshFromSDF), true), CanEditMultipleObjects]
public class MeshFromSDFEditor : Editor
{

    public override void OnInspectorGUI()
    {
        MeshFromSDF meshFromSDF = (MeshFromSDF)target;

        if (GUILayout.Button("StepMeshTile"))
        {
            meshFromSDF.StepMeshTile();
        }


        if (GUILayout.Button("ResetMeshTile"))
        {
            meshFromSDF.ResetMeshTile();
        }

        if (GUILayout.Button("Do All Tiles"))
        {
            meshFromSDF.DoAllTiles();
        }

        DrawDefaultInspector();
    }



}
