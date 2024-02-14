using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace IMMATERIA
{


  public class Body : Cycle
  {


    public Form verts;
    public IndexForm triangles;

    public Material material;
    public Material debugMaterial;

    public MaterialPropertyBlock mpb;

    public bool blockRender;

    public override void _Create()
    {

      if (mpb == null) { mpb = new MaterialPropertyBlock(); }


      if (verts == null) { verts = GetComponent<Form>(); }
      if (triangles == null) { triangles = GetComponent<IndexForm>(); }

      SafeInsert(verts);
      SafeInsert(triangles);


      mpb.SetInt("_VertCount", verts.count);
      mpb.SetBuffer("_VertBuffer", verts._buffer);
      mpb.SetBuffer("_TriBuffer", triangles._buffer);

      DoCreate();


    }

    public override void _WhileLiving(float v)
    {


      DoLiving(v);


      if (active && !blockRender)
      {
        mpb.SetInt("_VertCount", verts.count);
        mpb.SetBuffer("_VertBuffer", verts._buffer);
        mpb.SetBuffer("_TriBuffer", triangles._buffer);

        // Infinit bounds so its always drawn!
        Graphics.DrawProcedural(material, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, triangles.count, 1, null, mpb, ShadowCastingMode.On, true, gameObject.layer);
      }
    }










    public virtual void Bake(Mesh mesh)
    {
      mesh.Clear();

      float[] data = verts.GetData();
      int[] dataTri = triangles.GetIntData();
      mesh.vertices = ExtractVerts(data);
      mesh.normals = ExtractNormals(data);
      mesh.triangles = ExtractTriangles(dataTri);
      mesh.tangents = ExtractTangents(data);
      mesh.SetUVs(0, ExtractUVs(data));
      mesh.SetUVs(1, ExtractDebug(data));
      mesh.SetUVs(2, ExtractVelocity(data));


    }

    public virtual Vector3[] ExtractVerts(float[] data)
    {

      Vector3[] v = new Vector3[verts.count];

      int offset = 0;

      Vector3 info;
      for (int i = 0; i < verts.count; i++)
      {

        info = new Vector3(data[i * verts.structSize + offset + 0]
                          , data[i * verts.structSize + offset + 1]
                          , data[i * verts.structSize + offset + 2]);

        v[i] = info;

      }

      return v;
    }


    public virtual Vector4[] ExtractTangents(float[] data)
    {

      Vector4[] v = new Vector4[verts.count];

      int offset = 9;


      if (verts.structSize == 9) { return v; }
      if (verts.structSize == 12) { return v; }
      if (verts.structSize == 16) { offset = 9; }
      if (verts.structSize == 24) { offset = 9; }
      if (verts.structSize == 36) { offset = 9; }

      Vector3 info;
      for (int i = 0; i < verts.count; i++)
      {

        info = new Vector4(data[i * verts.structSize + offset + 0]
                          , data[i * verts.structSize + offset + 1]
                          , data[i * verts.structSize + offset + 2],
                          0);

        v[i] = info;

      }

      return v;
    }



    public virtual Vector3[] ExtractNormals(float[] data)
    {

      Vector3[] n = new Vector3[verts.count];

      int offset = 3;

      if (verts.structSize == 9) { offset = 3; }
      if (verts.structSize == 12) { offset = 3; }
      if (verts.structSize == 16) { offset = 6; }
      if (verts.structSize == 24) { offset = 6; }
      if (verts.structSize == 36) { offset = 6; }

      Vector3 info;

      for (int i = 0; i < verts.count; i++)
      {

        info = new Vector3(data[i * verts.structSize + offset + 0]
                          , data[i * verts.structSize + offset + 1]
                          , data[i * verts.structSize + offset + 2]);

        n[i] = info;

      }

      return n;

    }

    public virtual Vector2[] ExtractUVs(float[] data)
    {

      Vector2[] uv = new Vector2[verts.count];

      int offset = 9;
      if (verts.structSize == 9) { offset = 6; }
      if (verts.structSize == 12) { offset = 9; }
      if (verts.structSize == 16) { offset = 12; }
      if (verts.structSize == 24) { offset = 12; }
      if (verts.structSize == 36) { offset = 12; }

      Vector2 info;
      for (int i = 0; i < verts.count; i++)
      {

        info = new Vector2(data[i * verts.structSize + offset + 0]
                          , data[i * verts.structSize + offset + 1]);

        uv[i] = info;

      }

      return uv;

    }


    public virtual Vector2[] ExtractDebug(float[] data)
    {

      Vector2[] debug = new Vector2[verts.count];

      int offset = 9;
      if (verts.structSize == 9) { return debug; }
      if (verts.structSize == 12) { return debug; }
      if (verts.structSize == 16) { offset = 14; }
      if (verts.structSize == 24) { offset = 14; }
      if (verts.structSize == 36) { offset = 14; }

      Vector2 info;
      for (int i = 0; i < verts.count; i++)
      {

        info = new Vector2(data[i * verts.structSize + offset + 0]
                          , data[i * verts.structSize + offset + 1]);

        debug[i] = info;

      }

      return debug;

    }


    public virtual Vector3[] ExtractVelocity(float[] data)
    {

      Vector3[] vel = new Vector3[verts.count];

      int offset = 9;
      if (verts.structSize == 9) { return vel; }
      if (verts.structSize == 12) { return vel; }
      if (verts.structSize == 16) { offset = 3; }
      if (verts.structSize == 24) { offset = 3; }
      if (verts.structSize == 36) { offset = 3; }

      Vector2 info;
      for (int i = 0; i < verts.count; i++)
      {

        info = new Vector3(data[i * verts.structSize + offset + 0]
                          , data[i * verts.structSize + offset + 1]
                          , data[i * verts.structSize + offset + 2]);

        vel[i] = info;

      }

      return vel;

    }




    public virtual int[] ExtractTriangles(int[] data)
    {
      return data;
    }


    public override void WhileDebug()
    {
      debugMaterial.SetPass(0);
      debugMaterial.SetBuffer("_VertBuffer", verts._buffer);
      debugMaterial.SetBuffer("_TriBuffer", triangles._buffer);
      debugMaterial.SetInt("_Count", triangles.count);
      Graphics.DrawProceduralNow(MeshTopology.Triangles, triangles.count * 3 * 2);
    }



  }
}