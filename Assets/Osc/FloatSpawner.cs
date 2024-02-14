using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class FloatSpawner : MonoBehaviour
{

    public bool nameFromGameObject;
    public bool debug;
    public OscSynapse osc;
    public string messageID;

    public int floatID;

    public GameObject prefab;

    public Transform holder;


    public bool reset;
    public int totalObjects;

    public int currentObject;
    public GameObject[] objectBuffer;
    public MaterialPropertyBlock[] mpbs;
    public Renderer[] renderers;
    public float[] spawnTimes;
    public float[] spawnSize;
    public Vector3[] velocities;
    public bool[] currentlySpawned;
    public int[] ids;


    public Vector3 spawnWidth;
    public Vector3 spawnRotation;



    public Texture2D defaultTexture;
    public float defaultSize = 1;
    public Vector2 defaultOffset = Vector2.zero;
    public Color defaultColor = Color.white;

    public int[] drumMessages;

    public Texture2D[] textures;
    public Vector2[] offsets;
    public float[] sizes;



    MaterialPropertyBlock mpb;
    Renderer renderer;

    public float playTime;
    public Texture2D midiTexture;

    public float aspectRatio;
    public float _FadeSpeed = 1;

    public float _Size;
    public Vector2 _Offset;
    public Color _Color;

    //public List<float> allMessages;


    public float dampening;
    public float decaySpeed;
    public float spawnSizeMultiplier;

    public float spawnValueVelocityMultiplier;
    public Vector3 frameForce;


    void OnEnable()
    {
        if (nameFromGameObject)
        {
            messageID = gameObject.name;
        }
        if (reset)
        {

            if (objectBuffer != null)
            {
                for (int i = 0; i < objectBuffer.Length; i++)
                {
                    DestroyImmediate(objectBuffer[i]);
                }
            }

            objectBuffer = new GameObject[totalObjects];




        }
        else
        {

            totalObjects = objectBuffer.Length;

        }


        //allMessages = new List<float>();

        ids = new int[totalObjects];
        spawnTimes = new float[totalObjects];
        spawnSize = new float[totalObjects];
        velocities = new Vector3[totalObjects];
        currentlySpawned = new bool[totalObjects];
        renderers = new Renderer[totalObjects];
        mpbs = new MaterialPropertyBlock[totalObjects];

        for (int i = 0; i < totalObjects; i++)
        {



            if (reset)
            {
                objectBuffer[i] = Instantiate(prefab, new Vector3(0, 0, 0), Quaternion.identity);
                objectBuffer[i].SetActive(false);
                objectBuffer[i].transform.parent = holder;

            }

            mpbs[i] = new MaterialPropertyBlock();
            renderers[i] = objectBuffer[i].GetComponent<Renderer>();

        }


        int found = 0;
        for (int i = 0; i < osc.floatStrings.Length; i++)
        {

            if (osc.floatStrings[i] == messageID)
            {
                floatID = i;
                found++;
            }
        }

        if (found == 0)
        {
            Debug.Log("NO STRING");
        }

        if (found > 1)
        {
            Debug.Log("MULTIPLE STRINGS FOUND");
        }


    }

    public Transform centerSphere;
    public Renderer sphereRenderer;
    public MaterialPropertyBlock sphereMPB;

    public float centerSphereScaleMultiplier;
    public float centerSphereScaleBase;

    public float oscVal;
    public float smoothedVal;

    public Light light;
    public float lightRangeMultiplier;
    public float lightIntensityMultiplier;
    public float maxLightRange;

    public float maxLightIntensity;
    void Update()
    {

        if (centerSphere == null)
        {
            centerSphere = transform.Find("Sphere");
        }
        if (sphereRenderer == null)
        {
            sphereRenderer = centerSphere.GetComponent<Renderer>();

        }


        if (sphereMPB == null)
        {
            sphereMPB = new MaterialPropertyBlock();
            sphereRenderer.GetPropertyBlock(sphereMPB);
        }
        oscVal = 0;

        if (osc.floatArray[floatID].Count != 0)
        {


            foreach (float v in osc.floatArray[floatID])
            {

                oscVal = Mathf.Max(v, oscVal);

                if (v > 0)
                {
                    NoteOn(v);
                }
                else
                {
                    NoteOff(v);
                }




                /*if (!allMessages.Contains(v.x))
                {
                    allMessages.Add(v.x);
                }*/

                if (debug) { Debug.Log(v); }
            }





        }

        smoothedVal = Mathf.Lerp(smoothedVal, oscVal, .1f);

        _Color = defaultColor * smoothedVal;
        if (sphereMPB != null)
        {

            sphereRenderer.GetPropertyBlock(sphereMPB);
            sphereMPB.SetColor("_Color", _Color * .5f);
            sphereRenderer.SetPropertyBlock(sphereMPB);

            centerSphere.localScale = Vector3.one * (smoothedVal * centerSphereScaleMultiplier + centerSphereScaleBase);


        }

        if (light == null) { light = GetComponent<Light>(); }
        light.color = _Color;
        light.range = Mathf.Clamp(lightRangeMultiplier * smoothedVal, 0, maxLightRange);
        light.intensity = Mathf.Clamp(lightIntensityMultiplier * smoothedVal, 0, maxLightIntensity);





        for (int i = 0; i < totalObjects; i++)
        {
            if (currentlySpawned[i])
            {


                velocities[i] += frameForce;
                objectBuffer[i].transform.position += velocities[i] * .01f;

                velocities[i] *= dampening;
                float amount = (Time.time - spawnTimes[i]) / decaySpeed;
                objectBuffer[i].transform.localScale = Vector3.one * (1 - amount) * spawnSize[i] * spawnSizeMultiplier;
                objectBuffer[i].transform.eulerAngles += new Vector3(spawnRotation.x, spawnRotation.y, spawnRotation.z) * .01f * Time.deltaTime;


                if (amount > 1)
                {
                    Despawn(i);
                }

            }
        }


    }

    public float lastSpawnTime;




    public void NoteOn(float v)
    {


        // normalize
        float val = v;

        ids[currentObject] = (int)v;

        lastSpawnTime = Time.time;
        spawnTimes[currentObject] = Time.time;
        spawnSize[currentObject] = val;
        currentlySpawned[currentObject] = true;
        GameObject go = objectBuffer[currentObject];
        go.SetActive(true);


        go.transform.position = transform.position + new Vector3(Random.Range(-spawnWidth.x, spawnWidth.x), Random.Range(-spawnWidth.y, spawnWidth.y), Random.Range(-spawnWidth.z, spawnWidth.z));
        velocities[currentObject] = Random.insideUnitSphere * v * spawnValueVelocityMultiplier;

        go.transform.eulerAngles = new Vector3(Random.Range(-spawnRotation.x, spawnRotation.x), Random.Range(-spawnRotation.y, spawnRotation.y), Random.Range(-spawnRotation.z, spawnRotation.z));

        renderers[currentObject].GetPropertyBlock(mpbs[currentObject]);
        mpbs[currentObject].SetFloat("_SpawnValue", val);
        mpbs[currentObject].SetFloat("_spawnID", (float)currentObject);
        mpbs[currentObject].SetFloat("_noteID", (float)currentObject);
        mpbs[currentObject].SetColor("_Color", defaultColor * val);
        mpbs[currentObject].SetFloat("_FloatID", floatID);
        renderers[currentObject].SetPropertyBlock(mpbs[currentObject]);

        currentObject += 1;
        currentObject %= totalObjects;


    }

    public void NoteOff(float v)
    {

    }


    public void Despawn(int id)
    {

        objectBuffer[id].SetActive(false);
        currentlySpawned[id] = false;

    }

}
