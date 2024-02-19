using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

using static Unity.Mathematics.math;
using Unity.Mathematics;

[ExecuteAlways]
public class ButterflySpawner : MonoBehaviour
{

    public int numButterflys;
    public GameObject butterflyPrefab;


    public Vector3 bbMax;
    public Vector3 bbMin;
    public Vector3 bbCenter;
    public Vector3 bbSize;

    public int totalSeperating;
    public int totalAligning;
    public int totalCohesioning;
    public int totalSharksRepelling;
    public int totalPreyAttracting;


    public float percentageSeperating;
    public float percentageAligning;
    public float percentageCohesioning;
    public float percentageSharksRepelling;

    public float percentagePreyAttracting;
    public float biggestPackPercentage;
    public float biggestPackSizePercentage;
    public Vector3 biggestPackLocationPercentage; // normalized using bounding box





    [Space(20)]
    public ButterflySpawner[] sharkSpawners;

    public float[] sharkRepelRadiuses;
    public float[] sharkRepelForces;


    public ButterflySpawner[] preySpawners;
    public float[] preyAttractRadiuses;
    public float[] preyAttractForces;


    [Space(20)]

    public float centerForce;

    public float maxSpeed = 1;
    public float minSpeed = .01f;
    public float maxTurnSpeed = .01f;



    public float cohesionDistance = 1;
    public float cohesionStrength = 1;

    public float alignmentDistance;
    public float alignmentStrength;

    public float seperationStrength = 1;
    public float seperationDistance = 1;

    public Vector3 spawnRange;


    [Space(20)]
    public TransformBuffer tb;
    public Cycle tbParent;

    [Space(50)]


    public GameObject[] butterflys;
    // Get interested in a butterfly
    // follow it for a certain amount of time
    // then when its over that time, it can follow another one if its closer ?
    // or just follow the closest one?

    public int[] tmpPreyAttractID;
    public float[] tmpPreyAttractStartTime;

    public float3 sharkPos;
    public float3 sharkSpeed;


    public float3[] positions;
    public float3[] oPositions;
    public float3[] velocities;
    public bool[] active;






    // Start is called before the first frame update
    void OnEnable()
    {

        for (int i = this.transform.childCount; i > 0; --i)
            DestroyImmediate(this.transform.GetChild(0).gameObject);

        butterflys = new GameObject[numButterflys];

        positions = new float3[numButterflys];
        oPositions = new float3[numButterflys];
        velocities = new float3[numButterflys];
        active = new bool[numButterflys];

        tb.Deactivate();
        tb.transforms = new Transform[numButterflys];
        for (int i = 0; i < numButterflys; i++)
        {
            Vector3 fPos = new Vector3(UnityEngine.Random.Range(-spawnRange.x, spawnRange.x),
                                        UnityEngine.Random.Range(-spawnRange.y, spawnRange.y),
                                        UnityEngine.Random.Range(-spawnRange.z, spawnRange.z));

            fPos += transform.position;// transform.position;
            GameObject bug = Instantiate(butterflyPrefab, fPos, Quaternion.identity);
            bug.SetActive(true);
            bug.GetComponent<Butterfly>().bs = this;
            bug.transform.parent = this.transform;

            //            print(bug);
            butterflys[i] = bug;
            positions[i] = fPos;
            active[i] = true;
            velocities[i] = float3(0, 0, 0);//new float3(UnityEngine.Random.Range(-1, 1), UnityEngine.Random.Range(-1, 1), UnityEngine.Random.Range(-1, 1));

            tb.transforms[i] = bug.transform;
        }




        if (tbParent != null)
        {
            tbParent.SafeInsert(tb);

            if (tbParent.living)
            {
                //  print("alive");
                tbParent.JumpStart(tb);
            }
            else
            {
                tb.Activate();
            }
        }





    }

    void OnDisable()
    {

        if (tbParent != null)
        {
            if (tbParent.living)
            {
                //   print("alive");
                tbParent.JumpDeath(tb);
            }
            else
            {
                tb.Deactivate();
            }
        }



        for (int i = this.transform.childCount; i > 0; --i)
        {
            DestroyImmediate(this.transform.GetChild(0).gameObject);
            butterflys = new GameObject[0];

            positions = new float3[0];
            velocities = new float3[0];
            active = new bool[0];


        }
    }

    void Destroy()
    {
        for (int i = this.transform.childCount; i > 0; --i)
        {
            DestroyImmediate(this.transform.GetChild(0).gameObject);

            butterflys = new GameObject[0];

            positions = new float3[0];
            velocities = new float3[0];
            active = new bool[0];
        }
    }

    public float randomFromInt(int i)
    {
        return (float)Mathf.Sin(((float)i * 10131.9494f + (float)i * 441.414f)) * 0.5f + 0.5f;
    }


    public int biggestPackCount;
    public Vector3 biggestPackCenter;

    // Update is called once per frame
    void Update()
    {


        bbMin = Vector3.zero;
        bbMax = Vector3.one;

        float3 force;


        biggestPackCount = 0;
        totalAligning = 0;
        totalCohesioning = 0;
        totalSeperating = 0;
        totalSharksRepelling = 0;
        totalPreyAttracting = 0;

        biggestPackBoundingBoxMaxFinal = float3(0.1f, 0.1f, 0.1f);
        biggestPackBoundingBoxMaxFinal = float3(-0.1f, -0.1f, -0.1f);

        for (int i = 0; i < positions.Length; i++)
        {
            oPositions[i].x = positions[i].x;
            oPositions[i].y = positions[i].y;
            oPositions[i].z = positions[i].z;
        }


        // print(length(oPositions[0] - positions[1]) * 100);

        for (int i = 0; i < butterflys.Length; i++)
        {

            force = 0;

            force += CohesionForce(i);
            force += AlignmentForce(i);
            force += SeperationForce(i);

            if (sharkSpawners.Length > 0)
            {
                for (int j = 0; j < sharkSpawners.Length; j++)
                {
                    force += SharkRepelForce(i, j);
                }
            }

            if (preySpawners.Length > 0)
            {
                for (int j = 0; j < preySpawners.Length; j++)
                {
                    force += PreyAttractForce(i, j);
                }
            }

            //force += SharkAttractForce(i);



            Vector3 adjustedVel = AdjustVelocity((Vector3)velocities[i], (Vector3)force, maxTurnSpeed);


            //velocities[i] += force;
            velocities[i] = (float3)adjustedVel;

            if (length(velocities[i]) < .01f)
            {
                velocities[i] = float3(0, 0, minSpeed);
            }
            if (length(velocities[i]) < minSpeed)
            {

                velocities[i] = normalize(velocities[i]) * minSpeed;
            }


            if (length(velocities[i]) > maxSpeed)
            {
                velocities[i] = normalize(velocities[i]) * maxSpeed;
            }


        }

        for (int i = 0; i < butterflys.Length; i++)
        {


            force = 0;
            force += float3(centerForce * (transform.position - butterflys[i].transform.position)) * (randomFromInt(i) * .5f + .8f);

            velocities[i] += force;

            positions[i] += velocities[i];

            butterflys[i].transform.position = positions[i];
            butterflys[i].transform.rotation = Quaternion.Slerp(butterflys[i].transform.rotation, Quaternion.LookRotation(velocities[i], Vector3.up), .1f);


            bbMin = Vector3.Min(bbMin, positions[i]);
            bbMax = Vector3.Max(bbMax, positions[i]);


        }

        bbCenter = (bbMax + bbMin) * .5f;


        bbSize = bbMax - bbMin;
        percentageAligning = (float)totalAligning / ((float)butterflys.Length * (float)butterflys.Length);
        percentageCohesioning = (float)totalCohesioning / ((float)butterflys.Length * (float)butterflys.Length);
        percentageSeperating = (float)totalSeperating / ((float)butterflys.Length * (float)butterflys.Length);




        biggestPackPercentage = (float)biggestPackCount / (float)butterflys.Length;
        biggestPackSizePercentage = length(biggestPackBoundingBoxMaxFinal - biggestPackBoundingBoxMinFinal) / length(bbMax - bbMin);



        biggestPackLocationPercentage = (Vector3)((float3)biggestPackCenter - (float3)bbMin) / ((float3)bbMax - (float3)bbMin);




        int maxSharks = 0;
        for (int i = 0; i < sharkSpawners.Length; i++)
        {
            maxSharks += sharkSpawners[i].positions.Length;
        }


        if (maxSharks == 0)
        {
            percentageSharksRepelling = 0;
        }
        else
        {
            percentageSharksRepelling = (float)totalSharksRepelling / (numButterflys * (float)maxSharks);
        }


        int maxPrey = 0;
        for (int i = 0; i < preySpawners.Length; i++)
        {
            maxPrey += preySpawners[i].positions.Length;
        }

        if (maxPrey == 0)
        {
            percentagePreyAttracting = 0;
        }
        else
        {

            percentagePreyAttracting = (float)totalPreyAttracting / (numButterflys * (float)maxPrey);
        }



    }



    // Adjusts the velocity with a limited turn angle
    public Vector3 AdjustVelocity(Vector3 currentVelocity, Vector3 force, float maxTurnRadians)
    {
        // Normalize the current velocity and force
        Vector3 normalizedVelocity = currentVelocity.normalized;
        Vector3 normalizedForce = force.normalized;


        // Rotate the force vector towards the velocity vector within the limit of maxTurnRadians
        Vector3 adjustedForce = Vector3.RotateTowards(normalizedForce, normalizedVelocity, maxTurnRadians, float.MaxValue);

        // Scale adjustedForce back to the original force magnitude and add it to the current velocity
        adjustedForce *= force.magnitude;
        Vector3 newVelocity = currentVelocity + adjustedForce;

        return newVelocity;
    }


    float3 projectPointOnLine(float3 linePoint, float3 lineVec, float3 point)
    {
        //get vector from point on line to point in space
        float3 linePointToPoint = point - linePoint;

        float t = dot(linePointToPoint, lineVec);

        return linePoint + lineVec * t;

    }

    float3 SharkRepelForce(int i, int spawnerID)
    {

        float3 totalSharkRepelForce = 0;

        ButterflySpawner sharkSpawner = sharkSpawners[spawnerID];

        for (int j = 0; j < sharkSpawner.positions.Length; j++)
        {

            sharkPos = sharkSpawner.positions[j];
            sharkSpeed = sharkSpawner.velocities[j];


            float3 diff = positions[i] - sharkPos;
            float dist = length(diff);

            if (dist < sharkRepelRadiuses[spawnerID])
            {

                totalSharksRepelling += 1;

                if (length(sharkSpeed) < .01f) return 0;
                float3 p = projectPointOnLine(sharkPos, normalize(sharkSpeed), positions[i]);
                diff = positions[i] - p;

                totalSharkRepelForce += (normalize(diff) / dist) * sharkRepelForces[spawnerID];// * length(sharkSpeed);
            }

        }

        return totalSharkRepelForce;

    }


    float3 PreyAttractForce(int i, int spawnerID)
    {

        float3 totalPreyAttractForce = 0;

        ButterflySpawner sharkSpawner = preySpawners[spawnerID];

        for (int j = 0; j < sharkSpawner.positions.Length; j++)
        {

            sharkPos = sharkSpawner.positions[j];
            sharkSpeed = sharkSpawner.velocities[j];


            float3 diff = positions[i] - sharkPos;
            float dist = length(diff);

            if (dist < preyAttractRadiuses[spawnerID])
            {


                totalPreyAttracting += 1;

                if (length(sharkSpeed) < .01f) return 0;
                float3 p = projectPointOnLine(sharkPos, normalize(sharkSpeed), positions[i]);
                diff = positions[i] - p;

                totalPreyAttractForce += -(normalize(diff) / dist) * preyAttractForces[spawnerID];// * length(sharkSpeed);
            }

        }

        return totalPreyAttractForce;


    }



    /* float3 SharkAttractForce(int i)
     {
         float3 diff = positions[i] - sharkPos;
         float dist = length(diff);
         if (dist < sharkAttractRadius)
         {
             return -diff * sharkAttractForce * length(sharkSpeed);
         }
         else
         {
             return 0;
         }
     }*/

    float3 biggestPackBoundingBoxMin;
    float3 biggestPackBoundingBoxMax;


    float3 biggestPackBoundingBoxMinFinal;
    float3 biggestPackBoundingBoxMaxFinal;
    float3 CohesionForce(int i)
    {

        biggestPackBoundingBoxMax = float3(.1f, .1f, .1f);
        biggestPackBoundingBoxMin = float3(-.1f, -.1f, -.1f);

        float3 center = 0;
        int count = 0;
        for (int j = 0; j < butterflys.Length; j++)
        {
            if (i != j && active[j])
            {
                float3 diff = positions[i] - positions[j];
                float dist = length(diff);
                if (dist < cohesionDistance)
                {
                    biggestPackBoundingBoxMin = min(biggestPackBoundingBoxMin, positions[j]);
                    biggestPackBoundingBoxMax = max(biggestPackBoundingBoxMax, positions[j]);
                    center += positions[j];
                    count++;

                    //print("hi");
                    if (length(oPositions[i] - oPositions[j]) >= cohesionDistance)
                    {
                        print("hi2");
                        NewCohesion(i, j);
                    }
                }
            }
        }

        if (count > 0)
        {

            if (count > biggestPackCount)
            {
                biggestPackCount = count;
                biggestPackCenter = (Vector3)center / count;
                biggestPackBoundingBoxMaxFinal = biggestPackBoundingBoxMax;
                biggestPackBoundingBoxMinFinal = biggestPackBoundingBoxMin;


            }

            totalCohesioning += count;
            center /= count;
            return (center - positions[i]) * cohesionStrength;
        }
        else
        {
            return 0;
        }
    }


    float3 AlignmentForce(int i)
    {
        float3 alignment = 0;
        for (int j = 0; j < butterflys.Length; j++)
        {
            if (i != j && active[j])
            {
                float3 oVel = velocities[j];
                float3 diff = positions[i] - positions[j];
                float dist = length(diff);
                if (dist < alignmentDistance)
                {

                    totalAligning += 1;
                    alignment += oVel;

                    //print("hi");
                    if (length(oPositions[i] - oPositions[j]) >= alignmentDistance)
                    {
                        print("hi2");
                        NewAlignment(i, j);
                    }
                }

            }
        }
        return alignment * alignmentStrength;
    }



    float3 SeperationForce(int i)
    {
        float3 seperation = 0;
        for (int j = 0; j < butterflys.Length; j++)
        {
            if (i != j && active[j])
            {
                float3 diff = positions[i] - positions[j];
                float dist = length(diff);
                if (dist < seperationDistance)
                {
                    totalSeperating += 1;
                    seperation += diff * (1 / dist);


                    if (length(oPositions[i] - oPositions[j]) >= seperationDistance)
                    {
                        print("hi2");
                        NewSeperation(i, j);
                    }
                }


            }
        }

        return seperation * seperationStrength;

    }


    public void GotAte(Butterfly b)
    {

    }


    public Color debugColor;
    public bool drawDebug;
    public void OnDrawGizmos()
    {

        //        print("da");
        Gizmos.color = debugColor;
        Gizmos.DrawWireCube(bbCenter, bbSize);

        Gizmos.DrawWireCube(biggestPackCenter, biggestPackBoundingBoxMaxFinal - biggestPackBoundingBoxMinFinal);
    }


    public ParticleSystem ps;

    public void NewCohesion(int id1, int id2)
    {

        print(" new cohesion ");
        var emitParams = new ParticleSystem.EmitParams();
        emitParams.position = positions[id1];
        emitParams.velocity = new Vector3(0.0f, 0.0f, 0.0f);
        ps.Emit(emitParams, 1);




    }

    public void NewAlignment(int id1, int id2)
    {

    }

    public void NewSeperation(int id1, int id2)
    {
        print(" new cohesion ");
        var emitParams = new ParticleSystem.EmitParams();
        emitParams.position = positions[id1];
        emitParams.velocity = new Vector3(0.0f, 0.0f, 0.0f);
        ps.Emit(emitParams, 1);

    }

    public void NewSharkRepel(int id1, int id2, int whichShark)
    {

    }


}
