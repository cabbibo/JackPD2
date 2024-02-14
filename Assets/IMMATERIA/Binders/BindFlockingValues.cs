using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

public class BindFlockingValues : Binder
{

    public Transform center;
    public Vector3 _Size;

    public float _CohesionDistance;
    public float _CohesionStrength;

    public float _AlignmentDistance;
    public float _AlignmentStrength;


    public float _SeperationDistance;
    public float _SeperationStrength;


    public float _MaxSpeed;
    public float _CenterForce;

    public Transform _SpawnPoint;

    public float _AttackForce;
    public float _AttackRadius;

    public float _FleeForce;
    public float _FleeRadius;

    public float _CurlSize = 1;
    public float _CurlSpeed = 1;
    public float _CurlForce = 1;





    public override void Bind()
    {

        toBind.BindVector3("_Center", () => center.position);
        toBind.BindFloat("_CenterForce", () => _CenterForce);
        toBind.BindVector3("_Size", () => _Size);

        toBind.BindFloat("_CohesionDistance", () => _CohesionDistance);
        toBind.BindFloat("_CohesionStrength", () => _CohesionStrength);
        toBind.BindFloat("_AlignmentDistance", () => _AlignmentDistance);
        toBind.BindFloat("_AlignmentStrength", () => _AlignmentStrength);
        toBind.BindFloat("_SeperationDistance", () => _SeperationDistance);
        toBind.BindFloat("_SeperationStrength", () => _SeperationStrength);



        toBind.BindFloat("_AttackForce", () => _AttackForce);
        toBind.BindFloat("_AttackRadius", () => _AttackRadius);


        toBind.BindFloat("_FleeForce", () => _FleeForce);
        toBind.BindFloat("_FleeRadius", () => _FleeRadius);

        toBind.BindFloat("_CurlSpeed", () => _CurlSpeed);
        toBind.BindFloat("_CurlForce", () => _CurlForce);
        toBind.BindFloat("_CurlSize", () => _CurlSize);


        toBind.BindMatrix("_SpawnPoint", () => _SpawnPoint.localToWorldMatrix);

        toBind.BindFloat("_MaxSpeed", () => _MaxSpeed);




    }




}
