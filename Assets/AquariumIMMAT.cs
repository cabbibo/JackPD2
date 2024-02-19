using System.Collections;
using System.Collections.Generic;
using IMMATERIA;
using UnityEngine;


[ExecuteAlways]
public class AquariumIMMAT : MonoBehaviour
{



    public float butterflyTrailFollowSpeed;
    public float butterflyTrailFollowSpeed_L;
    public float butterflyTrailFollowSpeed_H;

    public float sharkTrailFollowSpeed;
    public float sharkTrailFollowSpeed_L;
    public float sharkTrailFollowSpeed_H;

    public float megaSharkTrailFollowSpeed;
    public float megaSharkTrailFollowSpeed_L;
    public float megaSharkTrailFollowSpeed_H;


    public float butterflyTubeRadius;
    public float butterflyTubeRadius_L;
    public float butterflyTubeRadius_H;

    public float butterflyMeshRadius;
    public float butterflyMeshRadius_L;
    public float butterflyMeshRadius_H;

    public float sharkMeshRadius;
    public float sharkMeshRadius_L;
    public float sharkMeshRadius_H;



    public float megaSharkMeshRadius;
    public float megaSharkMeshRadius_L;
    public float megaSharkMeshRadius_H;



    public bool showButterflyTransformDebug;
    public bool showButterflyTrailDebug;
    public bool showButterflyTrailMeshDebug;
    public bool showButterflyTrailTubeDebug;

    public bool showButterflySensors;

    public bool showButterflyTrailTube;
    public bool showButterflyTrailMesh;


    public bool showSharkTransformDebug;
    public bool showSharkTrailDebug;
    public bool showSharkTrailMeshDebug;

    public bool showSharkSensors;
    public bool showSharkMesh;


    public bool showMegaSharkTransformDebug;
    public bool showMegaSharkTrailDebug;
    public bool showMegaSharkTrailMeshDebug;

    public bool showMegaSharkSensors;
    public bool showMegaSharkMesh;



    public TrailSim butterflyTrail;
    public TrailSim sharkTrail;
    public TrailSim megaSharkTrail;

    public TubeTransfer butterflyTube;
    public Hair butterflyTrailHair;
    public MeshTrailLifeform butterflyMesh;
    public IndexForm butterflyMeshTris;
    public IndexForm butterflyTubeTris;
    public TransformBuffer butterflyTransform;



    public Hair sharkTrailHair;
    public MeshHairTransfer sharkMesh;
    public IndexForm sharkMeshTris;
    public TransformBuffer sharkTransform;


    public Hair megaSharkTrailHair;
    public MeshTrailLifeform megaSharkMesh;
    public IndexForm megaSharkMeshTris;
    public TransformBuffer megaSharkTransform;



    public SensorRenderer sensorRenderer;



    public extOSCMessageReceive receiver;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {



        sharkMesh.radius = sharkMeshRadius;
        megaSharkMesh.radius = megaSharkMeshRadius;
        butterflyMesh.radius = butterflyMeshRadius;
        butterflyTube.radius = butterflyTubeRadius;

        sharkTrail._TrailFollowForce = sharkTrailFollowSpeed;
        megaSharkTrail._TrailFollowForce = megaSharkTrailFollowSpeed;
        butterflyTrail._TrailFollowForce = butterflyTrailFollowSpeed;



        butterflyTransform.debug = showButterflyTransformDebug;
        butterflyTrailHair.debug = showButterflyTrailDebug;
        butterflyMeshTris.debug = showButterflyTrailMeshDebug;
        butterflyTubeTris.debug = showButterflyTrailTubeDebug;

        butterflyMesh.showBody = showButterflyTrailTube;
        butterflyTube.showBody = showButterflyTrailMesh;




        sharkTransform.debug = showSharkTransformDebug;
        sharkTrailHair.debug = showSharkTrailDebug;
        sharkMeshTris.debug = showSharkTrailMeshDebug;

        sharkMesh.showBody = showSharkMesh;

        megaSharkTransform.debug = showMegaSharkTransformDebug;
        megaSharkTrailHair.debug = showMegaSharkTrailDebug;
        megaSharkMeshTris.debug = showMegaSharkTrailMeshDebug;

        megaSharkMesh.showBody = showMegaSharkMesh;







    }


    public void MessageReceived()
    {

        butterflyTrailFollowSpeed = Mathf.Lerp(butterflyTrailFollowSpeed_L, butterflyTrailFollowSpeed_H, receiver.values[0]);
        sharkTrailFollowSpeed = Mathf.Lerp(sharkTrailFollowSpeed_L, sharkTrailFollowSpeed_H, receiver.values[1]);
        megaSharkTrailFollowSpeed = Mathf.Lerp(megaSharkTrailFollowSpeed_L, megaSharkTrailFollowSpeed_H, receiver.values[2]);

        butterflyTubeRadius = Mathf.Lerp(butterflyTubeRadius_L, butterflyTubeRadius_H, receiver.values[3]);
        butterflyMeshRadius = Mathf.Lerp(butterflyMeshRadius_L, butterflyMeshRadius_H, receiver.values[4]);

        sharkMeshRadius = Mathf.Lerp(sharkMeshRadius_L, sharkMeshRadius_H, receiver.values[5]);
        megaSharkMeshRadius = Mathf.Lerp(megaSharkMeshRadius_L, megaSharkMeshRadius_H, receiver.values[6]);

    }
}
