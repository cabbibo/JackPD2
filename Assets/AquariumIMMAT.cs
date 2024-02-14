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





    public TrailSim butterflyTrail;
    public TrailSim sharkTrail;
    public TrailSim megaSharkTrail;

    public TubeTransfer butterflyTube;
    public MeshTrailLifeform butterflyMesh;


    public MeshHairTransfer sharkMesh;
    public MeshTrailLifeform megaSharkMesh;







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
