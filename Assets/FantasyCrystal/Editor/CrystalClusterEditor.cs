using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(CrystalCluster)), CanEditMultipleObjects]
public class CrystalClusterEditor : Editor 
{
    public override void OnInspectorGUI()
    {
        CrystalCluster crystal = (CrystalCluster)target;

        DrawDefaultInspector();

        if(GUILayout.Button("Regenerate Cluster"))
        {
            crystal.RegenerateCluster();
        }


        if(GUILayout.Button("Save Mesh"))
        {

            string name = "Assets/Plugins/FantasyCrystal/SavedCrystals/CRYSTAL_" + Random.Range(0,12141414) + ".asset";
            Debug.Log(name);

            Mesh m;
            m = crystal.gameObject.GetComponent<MeshFilter>().sharedMesh;
            AssetDatabase.CreateAsset(m,name);
        }
      
    }
}