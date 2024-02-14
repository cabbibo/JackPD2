using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;
using UnityEngine.Rendering;
using System.IO;
using System.Text;


public class FormsToMesh : Cycle
{

    public Body[] bodies;


    int numVerts;
    int numTris;
    int numNormals;
    int numUVS;


    List<Vector3> positions;
    List<Vector3> normals;
    List<Vector4> tangents;
    List<Vector2> uvs;
    List<Vector2> uvs2;

    List<int> tris;

    public int totalVerts;

    public void Build(){
        BuildMesh();
    }

   /* struct Vert{
    float3 pos;
    float3 vel;
    float3 nor;
    float3 tangent;
    float2 uv;
    float2 debug;
};*/
    public void BuildMesh(){


        positions = new List<Vector3>();
        normals = new List<Vector3>();
        tangents = new List<Vector4>();
        uvs = new List<Vector2>();
        uvs2 = new List<Vector2>();
        tris = new List<int>();

        totalVerts = 0;

        for(int i = 0; i < bodies.Length; i++ ){

            float[] data = bodies[i].verts.GetData();


            int ss = bodies[i].verts.structSize;
            int count = data.Length / ss;

            for( int j = 0; j < count; j++ ){
                positions.Add( new Vector3( data[j*ss+0],data[j*ss+1],data[j*ss+2] ));
                normals.Add(new Vector3( data[j*ss+6],data[j*ss+7],data[j*ss+8] ));
                tangents.Add(new Vector4( data[j*ss+9],data[j*ss+10],data[j*ss+11] ,1));
                uvs.Add( new Vector2(data[j*ss+12],data[j*ss+13] ));
                uvs2.Add( new Vector2(data[j*ss+14],data[j*ss+15] ));
            }



            int[] triData = bodies[i].triangles.GetIntData();
            int startID = tris.Count;

            for( int j = 0; j < triData.Length; j++ ){
                tris.Add( triData[j] + totalVerts );
            }
            
            totalVerts += count;

        }



        MakeGameObject(positions, normals, tris);




    }

public Material meshMaterial;

void MakeGameObject(List<Vector3> positions, List<Vector3> normals, List<int> indices){

    print( indices.Count );
    GameObject go = new GameObject("Voxel Mesh");
    Mesh mesh = new Mesh();
    mesh.indexFormat =  IndexFormat.UInt32;

    //indices.Clear();
    
    Vector3 t1; bool hasSame; int sameID;
    int baseIndex = 0;
    
   List<Vector3> pFinals = new List<Vector3>();
    for( int i = 0; i < positions.Count; i++ ){
   
        positions[i] = transform.InverseTransformPoint(positions[i]);
        normals[i] = transform.InverseTransformDirection(normals[i]);
    }

  
    
    mesh.vertices = positions.ToArray();
    mesh.normals = normals.ToArray();
    mesh.bounds = new Bounds(new Vector3(0, 0, 0), new Vector3(100, 100, 100));
    mesh.SetTriangles(indices.ToArray(), 0);

   // mesh.RecalculateNormals();
    
    go.AddComponent<MeshFilter>();
    go.AddComponent<MeshRenderer>();
    go.GetComponent<Renderer>().material = meshMaterial;//new Material(Shader.Find("Custom/CelShadingForward"));
    go.GetComponent<MeshFilter>().mesh = mesh;
    go.transform.parent = transform;
    go.transform.localPosition = Vector3.zero;
    go.transform.localRotation = Quaternion.identity;
    go.transform.localScale = Vector3.one;

    //completedMesh = go;

     MeshToFile( "writhingMass", MeshToString("writhingMass" ,positions.ToArray(), mesh.normals,indices.ToArray() ));

    /*if( SaveToOBJ ){
      MeshToFile( objName , MeshToString(objName ,positions.ToArray(), mesh.normals,indices.ToArray() ));
    }*/
  
  }


    
   public static string MeshToString( string name , Vector3[] positions , Vector3[] normals , int[] triangles ) {
      
        StringBuilder sb = new StringBuilder();
 
        sb.Append("o ").Append( name ).Append("\n");
        foreach(Vector3 v in positions) {
            sb.Append(string.Format("v {0} {1} {2}\n",v.x,v.y,v.z));
        }

        sb.Append("\n");
        foreach(Vector3 v in normals) {
            sb.Append(string.Format("vn {0} {1} {2}\n",v.x,v.y,v.z));
        }

        

        sb.Append("\n");  
        for (int i=0;i<triangles.Length;i+=3) {
            sb.Append(string.Format("f {0}/{0}/{0} {1}/{1}/{1} {2}/{2}/{2}\n", 
                triangles[i]+1, triangles[i+1]+1, triangles[i+2]+1));
        }
        
        return sb.ToString();
    }
 
    public static void MeshToFile( string name , string info ) {

      string filename = "Assets/BakedMeshes/" + name + ".OBJ";

        using (StreamWriter sw = new StreamWriter(filename)) 
        {
            sw.Write(info);
        }
    }



}
