using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
namespace FantasyTree {
[CustomEditor(typeof(Tree))]
public class TreeEditor : Editor 
{

    public int lookupIndex;
    public int treeCount;
    public string[] trees;
    
    public override void OnInspectorGUI()
    {

        Tree tree = (Tree)target; 
        
        if(GUILayout.Button("Save")){
            tree.SaveAll();
        }

        if( GUILayout.Button("Save New Mesh") ){
            Debug.Log(tree.mesh);
            string name = "Assets/Plugins/FantasyTree/Trees/"  + tree.saveName + "/bakedTree" + Random.Range(0,12141414) + ".asset";
            Debug.Log(name);

            Mesh m;
            if(tree.mesh== null){
                m = tree.gameObject.GetComponent<MeshFilter>().sharedMesh;
            }else{
                m = tree.mesh;
            }


            AssetDatabase.CreateAsset(m,name);
        }

        if(GUILayout.Button("Re Load")){
            tree.LoadAll();
        }

        if(GUILayout.Button("Regenerate")){
            tree.BuildBranches();
        }

        

        
        string[] t =   Directory.GetDirectories(tree.basePath());



        if( t.Length != treeCount ){

            trees = new string[t.Length];
            treeCount = t.Length;
            for( int i = 0; i < trees.Length; i++ ){
                trees[i] = (t[i].Replace( tree.basePath(),"" ));
            }

        }


        int o = lookupIndex;
        lookupIndex = EditorGUILayout.Popup(lookupIndex, trees);


        if( o != lookupIndex ){
            tree.saveName = trees[lookupIndex];
            tree.LoadAll();
        }


        
        EditorGUI.BeginChangeCheck();

        DrawDefaultInspector();

        if (EditorGUI.EndChangeCheck()) {
          //  tree.BuildBranches();
        }
    }
}}