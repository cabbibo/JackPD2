using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;
using UnityEngine.Rendering;
public class SensorRenderer : Cycle
{

    public Form butterfly;
    public Form shark;
    public Form megaShark;

    public AquariumController aquarium;

    public bool showButterflySensors;
    public bool showButterflyRun1;
    public bool showButterflyRun2;

    public bool showSharkSensors;
    public bool showSharkChase;
    public bool showSharkRun;

    public bool showMegaSharkSensors;
    public bool showMegaSharkChase1;
    public bool showMegaSharkChase2;

    public Material butterflySelfMaterial;
    public Material butterflyRunMaterial1;
    public Material butterflyRunMaterial2;


    public Material sharkSelfMaterial;
    public Material sharkRunMaterial;
    public Material sharkChaseMaterial;

    public Material megaSharkSelfMaterial;
    public Material megaSharkChaseMaterial1;
    public Material megaSharkChaseMaterial2;


    MaterialPropertyBlock mpb;

    public override void WhileDebug()
    {

        if (mpb == null) { mpb = new MaterialPropertyBlock(); }

        if (showButterflySensors)
        {

            mpb.SetBuffer("_VertBuffer1", butterfly._buffer);
            mpb.SetBuffer("_VertBuffer2", butterfly._buffer);
            mpb.SetInt("_Count1", butterfly.count);
            mpb.SetInt("_Count2", butterfly.count);
            mpb.SetFloat("_CohesionDistance", aquarium.butterflyCohesionDistance);
            mpb.SetFloat("_AlignmentDistance", aquarium.butterflyAlignmentDistance);
            mpb.SetFloat("_SeperationDistance", aquarium.butterflySeperationDistance);

            int totalCount = butterfly.count * butterfly.count * 9;

            Graphics.DrawProcedural(butterflySelfMaterial, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }


        if (showButterflyRun1)
        {

            mpb.SetBuffer("_VertBuffer1", butterfly._buffer);
            mpb.SetBuffer("_VertBuffer2", shark._buffer);
            mpb.SetInt("_Count1", butterfly.count);
            mpb.SetInt("_Count2", shark.count);
            mpb.SetFloat("_RepelRadius", aquarium.butterflySharkRepel1Radius);

            int totalCount = butterfly.count * shark.count * 3;


            Graphics.DrawProcedural(butterflyRunMaterial1, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }


        if (showButterflyRun2)
        {

            mpb.SetBuffer("_VertBuffer1", butterfly._buffer);
            mpb.SetBuffer("_VertBuffer2", megaShark._buffer);
            mpb.SetInt("_Count1", butterfly.count);
            mpb.SetInt("_Count2", megaShark.count);
            mpb.SetFloat("_RepelRadius", aquarium.butterflySharkRepel2Radius);

            int totalCount = butterfly.count * megaShark.count * 3;


            Graphics.DrawProcedural(butterflyRunMaterial2, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }




        if (showSharkSensors)
        {

            mpb.SetBuffer("_VertBuffer1", shark._buffer);
            mpb.SetBuffer("_VertBuffer2", shark._buffer);
            mpb.SetInt("_Count1", shark.count);
            mpb.SetInt("_Count2", shark.count);
            mpb.SetFloat("_CohesionDistance", aquarium.sharkCohesionDistance);
            mpb.SetFloat("_AlignmentDistance", aquarium.sharkAlignmentDistance);
            mpb.SetFloat("_SeperationDistance", aquarium.sharkSeperationDistance);

            int totalCount = shark.count * shark.count * 9;

            Graphics.DrawProcedural(sharkSelfMaterial, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }

        if (showSharkRun)
        {

            mpb.SetBuffer("_VertBuffer1", shark._buffer);
            mpb.SetBuffer("_VertBuffer2", megaShark._buffer);
            mpb.SetInt("_Count1", shark.count);
            mpb.SetInt("_Count2", megaShark.count);
            mpb.SetFloat("_RepelRadius", aquarium.sharkSharkRepel1Radius);

            int totalCount = shark.count * megaShark.count * 3;


            Graphics.DrawProcedural(sharkRunMaterial, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }


        if (showSharkChase)
        {

            mpb.SetBuffer("_VertBuffer1", shark._buffer);
            mpb.SetBuffer("_VertBuffer2", butterfly._buffer);
            mpb.SetInt("_Count1", shark.count);
            mpb.SetInt("_Count2", butterfly.count);
            mpb.SetFloat("_RepelRadius", aquarium.sharkPreyAttract1Radius);

            int totalCount = shark.count * butterfly.count * 3;


            Graphics.DrawProcedural(sharkChaseMaterial, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }






        if (showMegaSharkSensors)
        {

            mpb.SetBuffer("_VertBuffer1", megaShark._buffer);
            mpb.SetBuffer("_VertBuffer2", megaShark._buffer);
            mpb.SetInt("_Count1", megaShark.count);
            mpb.SetInt("_Count2", megaShark.count);
            mpb.SetFloat("_CohesionDistance", aquarium.megaSharkCohesionDistance);
            mpb.SetFloat("_AlignmentDistance", aquarium.megaSharkAlignmentDistance);
            mpb.SetFloat("_SeperationDistance", aquarium.megaSharkSeperationDistance);

            int totalCount = megaShark.count * megaShark.count * 9;

            Graphics.DrawProcedural(megaSharkSelfMaterial, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }




        if (showMegaSharkChase1)
        {

            mpb.SetBuffer("_VertBuffer1", megaShark._buffer);
            mpb.SetBuffer("_VertBuffer2", butterfly._buffer);
            mpb.SetInt("_Count1", megaShark.count);
            mpb.SetInt("_Count2", butterfly.count);
            mpb.SetFloat("_RepelRadius", aquarium.megaSharkPreyAttract1Radius);

            int totalCount = megaShark.count * butterfly.count * 3;


            Graphics.DrawProcedural(megaSharkChaseMaterial1, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }



        if (showMegaSharkChase2)
        {

            mpb.SetBuffer("_VertBuffer1", megaShark._buffer);
            mpb.SetBuffer("_VertBuffer2", shark._buffer);
            mpb.SetInt("_Count1", megaShark.count);
            mpb.SetInt("_Count2", shark.count);
            mpb.SetFloat("_RepelRadius", aquarium.megaSharkPreyAttract2Radius);

            int totalCount = megaShark.count * shark.count * 3;


            Graphics.DrawProcedural(megaSharkChaseMaterial2, new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles, totalCount, 1, null, mpb, ShadowCastingMode.Off, true, LayerMask.NameToLayer("Sensors"));

        }



    }


}
