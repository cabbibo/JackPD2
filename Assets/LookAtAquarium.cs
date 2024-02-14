using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class LookAtAquarium : MonoBehaviour
{

    public Transform aquarium;
    public float distance = 10;


    public float lerpSpeed = .01f;
    public float centerLerpSpeed = .1f;


    public Camera fullCamera;
    public ButterflySpawner[] spawners;

    public Vector3 targetPosition;

    public Vector3 center;
    public Vector3 size;

    public Vector3 lookTarget;



    public float left;
    public float leftMin;
    public float leftMax;


    public float up;
    public float upMin;
    public float upMax;


    public float lookLeft;
    public float lookLeftMin;
    public float lookLeftMax;


    public float lookUp;
    public float lookUpMin;
    public float lookUpMax;



    public float distanceMultiplier;
    public float distanceMultiplierMin;
    public float distanceMultiplierMax;

    public float distanceOsscilateSize;
    public float distanceOsscilateSizeMin;
    public float distanceOsscilateSizeMax;

    public float distanceOsscilateSpeed;
    public float distanceOsscilateSpeedMin;
    public float distanceOsscilateSpeedMax;


    public extOSCMessageReceive receiver;
    public void OnReceiveData()
    {


        print("hi");
        print(receiver.values[0]);
        left = Mathf.Lerp(leftMin, leftMax, receiver.values[0]);
        up = Mathf.Lerp(upMin, upMax, receiver.values[1]);
        distanceMultiplier = Mathf.Lerp(distanceMultiplierMin, distanceMultiplierMax, receiver.values[2] * receiver.values[2]);
        distanceOsscilateSize = Mathf.Lerp(distanceOsscilateSizeMin, distanceOsscilateSizeMax, receiver.values[3]);
        distanceOsscilateSpeed = Mathf.Lerp(distanceOsscilateSpeedMin, distanceOsscilateSpeedMax, receiver.values[4]);

        lookLeft = Mathf.Lerp(lookLeftMin, lookLeftMax, receiver.values[5]);
        lookUp = Mathf.Lerp(lookUpMin, lookUpMax, receiver.values[6]);




    }
    public void Update()
    {

        Vector3 bbMin = Vector3.one * -1;
        Vector3 bbMax = Vector3.one * 1;

        Vector3 center = Vector3.zero;
        Vector3 size = Vector3.one;

        for (int i = 0; i < spawners.Length; i++)
        {
            bbMin = Vector3.Min(bbMin, spawners[i].bbMin);
            bbMax = Vector3.Max(bbMax, spawners[i].bbMax);
        }

        center = (bbMin + bbMax) / 2;
        size = bbMax - bbMin;

        Bounds bounds = new Bounds(center, size);


        float cameraDistance = 2.0f; // Constant factor
        Vector3 objectSizes = bounds.max - bounds.min;
        float objectSize = Mathf.Max(objectSizes.x, objectSizes.y, objectSizes.z);
        float cameraView = 2.0f * Mathf.Tan(0.5f * Mathf.Deg2Rad * fullCamera.fieldOfView); // Visible height 1 meter in front
        float distance = cameraDistance * objectSize / cameraView; // Combined wanted distance from the object
        distance += 0.5f * objectSize; // Estimated offset from the center to the outside of the object

        Vector3 positionVector = new Vector3(left, up, 1);

        float fDist = distance * distanceMultiplier * (1 + Mathf.Sin(Time.time * distanceOsscilateSpeed) * distanceOsscilateSize);

        targetPosition = fDist * positionVector.normalized;


        fullCamera.transform.position = Vector3.Lerp(fullCamera.transform.position, targetPosition, lerpSpeed);


        Vector3 newLookTarget = bounds.center + Vector3.right * lookLeft + Vector3.up * lookUp;

        lookTarget = Vector3.Lerp(lookTarget, newLookTarget, centerLerpSpeed);
        fullCamera.transform.LookAt(lookTarget);

    }
}
