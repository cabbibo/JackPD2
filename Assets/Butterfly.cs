using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Unity.Mathematics.math;
using Unity.Mathematics;

[ExecuteAlways]
public class Butterfly : MonoBehaviour
{

    public GameObject leftWing;
    public GameObject rightWing;

    public float3 leftVel;
    public float3 rightVel;

    public LineRenderer line;
    public float attractForce;

    public ButterflySpawner bs;
    void OnTriggerEnter(Collider c)
    {

        bs.GotAte(this);
    }
    /*

    void OnEnable()
    {
        leftVel = 0;
        rightVel = 0;
        leftWing.transform.position = transform.position + .1f * Vector3.left;
        rightWing.transform.position = transform.position - .1f * Vector3.left;
    }

    void Update()
    {


        line.SetPosition(0, leftWing.transform.position);
        line.SetPosition(1, transform.position);
        line.SetPosition(2, rightWing.transform.position);

        float3 force = 0;
        force -= float3(leftWing.transform.position - transform.position + tranform.left) * attractForce;
        leftVel += force;
        leftWing.transform.position += (Vector3)leftVel;
        leftVel *= .7f;


        force = 0;
        force -= float3(rightWing.transform.position - transform.position - tranform.left) * attractForce;
        rightVel += force;
        rightWing.transform.position += (Vector3)rightVel;
        force *= .7f;










    }*/



}
