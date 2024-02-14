using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class MidiSpawner : MonoBehaviour
{


public bool debug;
public OscSynapse osc;
public string messageID;

public int midiID;

    public GameObject prefab;


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
    public float [] sizes;



    MaterialPropertyBlock mpb;
    Renderer renderer;

    public float playTime;
    public Texture2D midiTexture;

    public float aspectRatio;
    public float _FadeSpeed = 1;

    public float _Size;
    public Vector2 _Offset;
    public Color _Color;

    public List<float> allMessages;


    public float dampening;
    public float decaySpeed;
    public float spawnSizeMultiplier;

    void OnEnable(){

        if( reset ){

            if( objectBuffer != null ){
                for( int i = 0; i < objectBuffer.Length; i++ ){
                    DestroyImmediate(objectBuffer[i]);
                }
            }

            objectBuffer = new GameObject[totalObjects];
           



        }else{

            totalObjects = objectBuffer.Length;
 
        }


        allMessages = new List<float>();

        ids = new int[totalObjects];
        spawnTimes = new float[totalObjects];
        spawnSize = new float[totalObjects];
        velocities = new Vector3[totalObjects];
        currentlySpawned = new bool[ totalObjects];
        renderers = new Renderer[totalObjects];
        mpbs =  new MaterialPropertyBlock[totalObjects];

        for( int i = 0; i < totalObjects; i++ ){



            if( reset ){
                objectBuffer[i] =  Instantiate(prefab, new Vector3(0, 0, 0), Quaternion.identity);
                objectBuffer[i].SetActive(false);
                objectBuffer[i].transform.parent = transform;

            }

            mpbs[i] = new MaterialPropertyBlock();
            renderers[i] = objectBuffer[i].GetComponent<Renderer>();

        }


        int found = 0;
        for( int i = 0; i < osc.midiStrings.Length; i++ ){

            print( osc.midiStrings[i]);
            if( osc.midiStrings[i] == messageID ){
                midiID = i;
                found ++;
            }
        }

        if( found == 0 ){
            Debug.Log("NO STRING");
        }

        if( found > 1 ){
            Debug.Log("MULTIPLE STRINGS FOUND");
        }
        

    }


    void Update()
    {



        if( osc.midiArray[midiID].Count != 0){
            

            foreach( Vector2 v in osc.midiArray[midiID] ){
                if( v.y > 0 ){
                    NoteOn(v);
                }else{
                    NoteOff(v);
                }

                    if( !allMessages.Contains(v.x) ){
                        allMessages.Add( v.x);
                    }

                   if( debug ){ Debug.Log(v.y); }
            }

            
        }





          for( int i = 0; i < totalObjects; i++ ){
            if( currentlySpawned[i] ){
                objectBuffer[i].transform.position += velocities[i] * .01f;
            
                velocities[i] *= dampening;
                float amount = (Time.time - spawnTimes[i]) / decaySpeed;
                objectBuffer[i].transform.localScale = Vector3.one * (1-amount) * spawnSize[i] * spawnSizeMultiplier;

                if( amount > 1 ){
                    Despawn(i);
                }

            }
        }


    }

    public float lastSpawnTime;


    public void NoteOn( Vector2 v ){


        // normalize
        float val = v.y/128;
        
        ids[currentObject] = (int)v.x;

        lastSpawnTime = Time.time;
        spawnTimes[currentObject] = Time.time;
        spawnSize[currentObject] = val;
        currentlySpawned[currentObject] = true;
        GameObject go = objectBuffer[currentObject];
        go.SetActive( true );


        go.transform.position = transform.position + new Vector3( Random.Range( -spawnWidth.x , spawnWidth.x ),Random.Range( -spawnWidth.y , spawnWidth.y ),Random.Range( -spawnWidth.z , spawnWidth.z ));
        velocities[currentObject] = Vector3.zero;///fDirection *  v * spawnValueVelocityMultiplier;

        go.transform.eulerAngles = new Vector3( Random.Range( -spawnRotation.x , spawnRotation.x ),Random.Range( -spawnRotation.y , spawnRotation.y ),Random.Range( -spawnRotation.z , spawnRotation.z ));

        renderers[currentObject].GetPropertyBlock(mpbs[currentObject]);
        mpbs[currentObject].SetFloat("_SpawnValue",val);
        mpbs[currentObject].SetFloat("_spawnID", (float)currentObject);
        mpbs[currentObject].SetFloat("_noteID", (float)currentObject);
        mpbs[currentObject].SetColor("_Color", defaultColor);
        renderers[currentObject].SetPropertyBlock(mpbs[currentObject]);

        currentObject += 1;
        currentObject %= totalObjects;


    }

    public void NoteOff( Vector2 v ){

    }


    public void Despawn( int id ){

        objectBuffer[id].SetActive(false);
        currentlySpawned[id] = false;

    }

}
