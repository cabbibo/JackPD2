using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using System.IO;
using System.Text;


namespace IMMATERIA
{
  public class MeshFromSDF : Simulation
  {

    public MarchingCubeVerts verts;
    public Life marchingLife;
    public Material meshMaterial;
    public Life resetLife;
    public Life marchingResetLife;


    public GameObject completedMesh;


    public bool SaveToOBJ;
    public string objName;

    public float _SDFOffset;

    public float _SmoothingValue;

    public override void Create()
    {

      SafeInsert(verts);
      SafeInsert(marchingLife);
      SafeInsert(resetLife);
      SafeInsert(marchingResetLife);

      if (completedMesh != null)
      {
        print("Got a funky mesh");
        DestroyImmediate(completedMesh);
      }

    }

    public override void Bind()
    {


      print("BINDING");
      //life.BindInt( "_CurrentStep" , () => currentStep );
      //life.BindFloat( "_PercentageDone" , () => percentageDone );

      life.BindMatrix("_Transform", () => transform.localToWorldMatrix);
      life.BindMatrix("_InverseTransform", () => transform.worldToLocalMatrix);
      life.BindPrimaryForm("_VolumeBuffer", form);


      life.BindMatrix("_Transform", () => transform.localToWorldMatrix);

      //life.BindForm("_VertBuffer" , mesh.verts);
      //life.BindForm("_TriBuffer" , mesh.triangles);

      life.BindVector3("_Center", () => ((Form3D)form).center);
      life.BindVector3("_Dimensions", () => ((Form3D)form).dimensions);
      life.BindVector3("_Extents", () => ((Form3D)form).extents);
      life.BindFloat("_SmoothingValue", () => this._SmoothingValue);

      marchingLife.BindPrimaryForm("_VolumeBuffer", form);
      marchingLife.BindForm("_VertBuffer", verts);

      marchingLife.BindVector3("_Center", () => ((Form3D)form).center);
      marchingLife.BindVector3("_Dimensions", () => ((Form3D)form).dimensions);
      marchingLife.BindVector3("_Extents", () => ((Form3D)form).extents);

      marchingLife.BindMatrix("_Transform", () => transform.localToWorldMatrix);

      marchingLife.BindTexture("Texture", () => ((Form3D)form)._texture);
      marchingLife.BindFloat("_SDFOffset", () => this._SDFOffset);


      resetLife.BindPrimaryForm("_VolumeBuffer", form);
      marchingResetLife.BindPrimaryForm("_VertBuffer", verts);
      marchingResetLife.BindForm("_VolumeBuffer", form);


    }




    public int size;
    public float tileSize;
    public int currentTile;
    public int frame;
    public bool tiling;



    private List<Vector3> positions;
    private List<Vector3> normals;
    private List<int> indices;

    private int baseIndex;
    public override void OnBirthed()
    {
      tiling = true;
      currentTile = 0;
      frame = 0;
      baseIndex = 0;
      positions = new List<Vector3>();
      normals = new List<Vector3>();
      indices = new List<int>();
    }

    public override void WhileLiving(float v)
    {

      frame++;

      if ((frame % 1) == 0 && tiling == true)
      {
        StepMeshTile();
      }
    }

    public void StepMeshTile()
    {

      if (tiling == true && currentTile < size * size * size)
      {
        DoMeshTile(currentTile);
        currentTile++;
        if (currentTile >= size * size * size)
        {
          tiling = false;
          MakeGameObject(positions, normals, indices);
        }
      }
    }


    public void DoAllTiles()
    {
      ResetMeshTile();
      for (int i = 0; i < size * size * size; i++)
      {
        DoMeshTile(i);
      }


      OptimizeMesh2();
      //MakeGameObject(positions, normals, indices);

    }

    public void ResetMeshTile()
    {
      tiling = true;
      currentTile = 0;
      frame = 0;
      baseIndex = 0;
      positions = new List<Vector3>();
      normals = new List<Vector3>();
      indices = new List<int>();
    }

    public void DoMeshTile(int i)
    {


      int x = i % size;
      int y = (i / size) % size;
      int z = (i / (size * size));

      float xV = ((float)x / (float)size - .5f) * tileSize * size * 2 + (tileSize);
      float yV = ((float)y / (float)size - .5f) * tileSize * size * 2 + (tileSize);
      float zV = ((float)z / (float)size - .5f) * tileSize * size * 2 + (tileSize);

      float extra = 3 / ((float)((Form3D)form).dimensions.x);
      ((Form3D)form).center = new Vector3(xV, yV, zV) + Vector3.one * extra / 2;
      ((Form3D)form).extents = new Vector3(tileSize, tileSize, tileSize) + Vector3.one * extra;


      MakeMesh();
    }

    public void MakeMesh()
    {

      resetLife.YOLO();
      life.YOLO();
      marchingResetLife.YOLO();
      marchingLife.YOLO();
      AddVertsMesh();
    }


    public void OnDrawGizmos()
    {
      Gizmos.matrix = transform.localToWorldMatrix;

      Gizmos.color = new Vector4(1f, .4f, .2f, 1);
      Gizmos.DrawWireCube(Vector3.zero, Vector3.one * tileSize * (float)size * 2);

      Gizmos.color = new Vector4(.2f, .8f, .9f, 1);
      for (int x = 0; x < size; x++)
      {
        for (int y = 0; y < size; y++)
        {
          for (int z = 0; z < size; z++)
          {



            float xV = ((float)x / (float)size - .5f) * tileSize * size * 2 + (tileSize);
            float yV = ((float)y / (float)size - .5f) * tileSize * size * 2 + (tileSize);
            float zV = ((float)z / (float)size - .5f) * tileSize * size * 2 + (tileSize);

            Vector3 center = new Vector3(xV, yV, zV);

            float extra = 0;
            Vector3 extents = new Vector3(tileSize, tileSize, tileSize) + Vector3.one * extra;

            Gizmos.DrawWireCube(center, extents * 2); ;



          }
        }
      }
    }





    public void AddVertsMesh()
    {


      float[] values = new float[verts.count * verts.structSize];
      verts.GetData(values);

      //Extract the positions, normals and indexes.
      for (int i = 0; i < verts.count; i++)
      {

        if (values[i * 8 + 0] != -1)
        {
          Vector3 p = new Vector3(values[i * 8 + 0], values[i * 8 + 1], values[i * 8 + 2]);
          Vector3 n = -1 * new Vector3(values[i * 8 + 3], values[i * 8 + 4], values[i * 8 + 5]);

          positions.Add(p);
          normals.Add(n);
          indices.Add(baseIndex);
          baseIndex++;
        }

      }

      print(positions.Count);
      print(normals.Count);
      print(indices.Count);

    }




    void MakeGameObject(List<Vector3> positions, List<Vector3> normals, List<int> indices)
    {


      print(indices.Count);
      GameObject go = new GameObject("Voxel Mesh");
      Mesh mesh = new Mesh();


      List<Vector3> fPositions = new List<Vector3>(positions);
      List<int> fIndicies = new List<int>(indices);

      Vector3 p1 = new Vector3();
      Vector3 p2 = new Vector3();
      List<int> idsToRemove = new List<int>();
      /*  for (int i = 0; i < positions.Count; i++)
        {
          int baseIndex = indices[i];
          p1 = positions[i];


          for (int j = i + 1; j < positions.Count; j++)
          {
            p2 = positions[j];

            if ((p1 - p2).magnitude < .01)
            {
              idsToRemove.Add(j);
              fIndicies[j] = baseIndex;
            }

          }



        }


        print(idsToRemove.Count);
        print(fPositions.Count);
        idsToRemove.ForEach(id => fPositions[id] = Vector3.zero);
        fPositions.RemoveAll(item => item == Vector3.zero);
        print(fPositions.Count);
  */

      mesh.indexFormat = IndexFormat.UInt32;

      mesh.vertices = positions.ToArray();
      mesh.normals = normals.ToArray();
      mesh.bounds = new Bounds(new Vector3(0, 0, 0), new Vector3(100, 100, 100));
      mesh.SetTriangles(indices.ToArray(), 0);

      mesh.RecalculateNormals();

      go.AddComponent<MeshFilter>();
      go.AddComponent<MeshRenderer>();
      go.GetComponent<Renderer>().material = meshMaterial;//new Material(Shader.Find("Custom/CelShadingForward"));
      go.GetComponent<MeshFilter>().mesh = mesh;
      go.transform.parent = transform;

      completedMesh = go;

      if (SaveToOBJ)
      {
        MeshToFile(objName, MeshToString(objName, positions.ToArray(), mesh.normals, indices.ToArray()));
      }
    }

    public static string MeshToString(string name, Vector3[] positions, Vector3[] normals, int[] triangles)
    {

      StringBuilder sb = new StringBuilder();

      sb.Append("o ").Append(name).Append("\n");
      foreach (Vector3 v in positions)
      {
        sb.Append(string.Format("v {0} {1} {2}\n", v.x, v.y, v.z));
      }

      sb.Append("\n");
      foreach (Vector3 v in normals)
      {
        sb.Append(string.Format("vn {0} {1} {2}\n", v.x, v.y, v.z));
      }



      sb.Append("\n");
      for (int i = 0; i < triangles.Length; i += 3)
      {
        sb.Append(string.Format("f {0}/{0}/{0} {1}/{1}/{1} {2}/{2}/{2}\n",
            triangles[i] + 1, triangles[i + 1] + 1, triangles[i + 2] + 1));
      }

      return sb.ToString();
    }

    public static void MeshToFile(string name, string info)
    {

      string filename = "BakedMeshes/" + name + ".OBJ";

      using (StreamWriter sw = new StreamWriter(filename))
      {
        sw.Write(info);
      }
    }




    void OptimizeMesh2()
    {

      print(indices.Count);
      print(positions.Count);
      GameObject go = new GameObject("Voxel Mesh");
      Mesh mesh = new Mesh();


      float mergeDistance = 0.1f;
      Dictionary<int, int> vertexMap = new Dictionary<int, int>();

      List<Vector3> fPositions = new List<Vector3>();
      List<int> fIndicies = new List<int>(indices);



      bool allChecked = false;


      int index = 0;
      while (!allChecked)
      {




      }
      // Find vertices to merge
      for (int i = 0; i < fPositions.Count; i++)
      {


        for (int j = i + 1; j < fPositions.Count; j++)
        {
          if (Vector3.Distance(fPositions[i], fPositions[j]) < mergeDistance)
          {
            vertexMap[j] = i;
          }
        }
      }

      // Update triangles
      for (int i = 0; i < fIndicies.Count; i++)
      {
        if (vertexMap.TryGetValue(fIndicies[i], out int newVertexIndex))
        {
          fIndicies[i] = newVertexIndex;
        }
      }

      RemoveVerticesAndUpdateIndices(fPositions, fIndicies, vertexMap);


      for (int i = 0; i < fIndicies.Count; i++)
      {

        if (fIndicies[i] >= fPositions.Count)
        {
          print("BAD INDEX");
          print(fIndicies[i]);
        }

      }

      mesh.indexFormat = IndexFormat.UInt32;

      mesh.vertices = fPositions.ToArray();
      mesh.bounds = new Bounds(new Vector3(0, 0, 0), new Vector3(100, 100, 100));
      mesh.SetTriangles(fIndicies.ToArray(), 0);

      mesh.RecalculateNormals();

      go.AddComponent<MeshFilter>();
      go.AddComponent<MeshRenderer>();
      go.GetComponent<Renderer>().material = meshMaterial;//new Material(Shader.Find("Custom/CelShadingForward"));
      go.GetComponent<MeshFilter>().mesh = mesh;
      go.transform.parent = transform;

      completedMesh = go;



    }

    private static void RemoveVerticesAndUpdateIndices(List<Vector3> vertices, List<int> triangles, Dictionary<int, int> mergedVertices)
    {
      int offset = 0;
      for (int i = 0; i < vertices.Count; i++)
      {
        if (mergedVertices.ContainsKey(i))
        {
          vertices.RemoveAt(i - offset);
          offset++;
          UpdateTriangleIndices(triangles, i, offset);
        }
      }
    }
    private static void UpdateTriangleIndices(List<int> triangles, int removedIndex, int offset)
    {
      for (int i = 0; i < triangles.Count; i++)
      {
        if (triangles[i] > removedIndex)
        {
          triangles[i] -= offset;
        }
      }
    }

  }
}

