// OSC Jack - Open Sound Control plugin for Unity
// https://github.com/keijiro/OscJack

using UnityEngine;
using UnityEngine.Events;
using System.Collections.Generic;
using OscJack;
using System.IO;
using System.Linq;
using System;



[ExecuteAlways]
public class OscSynapse : MonoBehaviour
{



    // Used to store values on initialization
    public int port = 1337;




    public float timeline;
    public float timelineRaw;
    public float timelineLerpSpeed;







    public string[] midiStrings;
    public List<Vector2>[] midiArray;
    public Queue<float>[] midiQueues;
    public int midiNumOf;


    // need to make sure the order of the float strings
    // also goes to the order of the floats
    // how do we make sure that when we 'dequeue'
    // we get the floats in the right order

    public string[] floatStrings;
    public List<float>[] floatArray;
    public List<float> floatValues;
    public Queue<float>[] floatQueues;
    public int floatNumOf;



    public bool debug;


    // we need to make sure we aren't 
    // attached to a port when we do this!
    // Figure out what 'Kills' a server reference
    void RegisterCallback()
    {

        var server = OscMaster.GetSharedServer(port);
        server.MessageDispatcher.AddCallback(string.Empty, OnDataReceive);

    }

    void UnregisterCallback()
    {


    }


    public void Reconnect()
    {

        print("OK! trying to reconnect");

        UnregisterCallback();
        RegisterCallback();

    }

    void OnEnable()
    {

        midiNumOf = midiStrings.Length;

        midiQueues = new Queue<float>[midiNumOf];
        for (int i = 0; i < midiNumOf; i++)
        {
            midiQueues[i] = new Queue<float>(16);
        }
        midiArray = new List<Vector2>[midiNumOf];
        for (int i = 0; i < midiNumOf; i++)
        {
            midiArray[i] = new List<Vector2>();
        }

        floatNumOf = floatStrings.Length;

        floatQueues = new Queue<float>[floatNumOf];
        for (int i = 0; i < floatNumOf; i++)
        {
            floatQueues[i] = new Queue<float>(16);
        }

        floatArray = new List<float>[floatNumOf];
        for (int i = 0; i < floatNumOf; i++)
        {
            floatArray[i] = new List<float>();
        }


        floatValues = new List<float>();
        for (int i = 0; i < floatNumOf; i++)
        {
            floatValues.Add(0);
        }



    }

    void OnDisable()
    {
        //   UnregisterCallback();
    }

    void OnValidate()
    {
        if (Application.isPlaying && enabled)
            OnEnable(); // Update the settings.
    }



    // we want to have this run before 
    // the rest of the stuff that is taking in this information
    // for the sake of having it not be a frame late
    void Update()
    {

        if (useRecordedData)
        {
            SetRecordedData();
        }
        else
        {
            SetOSCData();
        }


        timeline = Mathf.Lerp(timeline, timelineRaw, timelineLerpSpeed);



        if (isRecording)
        {
            SaveOSCFrameData();
        }


    }

    public int currentDataIndex;
    public void SetRecordedData()
    {
        bool full = false;
        float currentTime = Time.time - playbackDataStartTime;
        while (!full)
        {
            if (currentDataIndex >= recordedData.Count)
            {
                full = true;
                OnRecordedPlaybackFinish();
                break;
            }


            OSCEvent e = recordedData[currentDataIndex];

            float t = e.time - loadedDataStartTime;

            if (t > currentTime)
            {
                full = true;
            }
            else
            {

                if (e.type == "midi")
                {
                    midiArray[e.id].Add(new Vector2(e.value, e.onOff));
                }

                if (e.type == "float")
                {
                    floatValues[e.id] = e.value;
                }

                print(e.id);

                currentDataIndex++;
            }

        }
    }


    public void OnRecordedPlaybackFinish()
    {
        useRecordedData = false;
        print("Reached the end of the data ");
    }

    public void SetOSCData()
    {
        for (int i = 0; i < floatNumOf; i++)
        {

            floatArray[i].Clear();
            float v = -999;

            while (floatQueues[i].Count > 0)
            {
                lock (floatQueues[i])
                {
                    v = floatQueues[i].Dequeue();
                    floatArray[i].Add(v);

                }
            }

            if (v != -999)
            {
                floatValues[i] = v;
            }


        }




        // Getting out all the midi info from the queue!
        for (int i = 0; i < midiNumOf; i++)
        {

            midiArray[i].Clear();
            float v = -999;

            while (midiQueues[i].Count > 0)
            {
                lock (midiQueues[i])
                {
                    midiArray[i].Add(new Vector2(
                        midiQueues[i].Dequeue(),
                        midiQueues[i].Dequeue()
                    ));
                }
            }

        }

    }



    public bool minSecSubSec;



    void OnDataReceive(string address, OscDataHandle data)
    {

        if (debug)
        {
            print(address);
        }

        if (address == "time")
        {

            print("hiii");

            if (minSecSubSec)
            {
                var subSecond = data.GetElementAsFloat(3);
                var second = data.GetElementAsFloat(2);
                var minute = data.GetElementAsFloat(1);
                timelineRaw = subSecond / 30 + second + minute * 60;
            }
            else
            {

                timelineRaw = data.GetElementAsFloat(0);
            }


        }
        // Get our String
        var s = address.Split('/');


        for (int i = 0; i < midiStrings.Length; i++)
        {

            // check to see if the address 
            // is one of the midi addresses
            var d = address.Split(midiStrings[i]);
            if (d.Length > 1)
            {

                Queue<float> q = midiQueues[i];

                float v = data.GetElementAsFloat(0);


                lock (q)
                {
                    q.Enqueue(data.GetElementAsFloat(0));
                    q.Enqueue(data.GetElementAsFloat(2));
                }
            }
        }




        for (int i = 0; i < floatStrings.Length; i++)
        {

            // check to see if the address 
            // is one of the float addresses
            var d = address.Split(floatStrings[i]);
            if (d.Length > 1)
            {

                Queue<float> q = floatQueues[i];

                float v = data.GetElementAsFloat(0);

                lock (q)
                {
                    q.Enqueue(data.GetElementAsFloat(0));
                }

            }

        }




        // if we have /ableton/info its our type of data
        /*  if( s.Length == 3 ){


              var s2 = s[2];


              var splitValue = s2.Split("return");
              var isReturn = splitValue.Length;
              if( isReturn == 2 ){

                  Queue<float> q = returnQueues[int.Parse(splitValue[1])-1];
                  lock (q) { q.Enqueue(data.GetElementAsFloat(0)); }

              }



          }*/


    }






    public List<OSCEvent> recordedData;

    [Serializable]
    public class OSCEvent
    {
        [SerializeField]
        public string address;

        [SerializeField]
        public float value;

        [SerializeField]
        public float onOff; // for midi

        [SerializeField]
        public float time;

        [SerializeField]
        public string type;

        [SerializeField]
        public int id;


    }
    public bool isRecording;
    public void Record()
    {
        isRecording = true;
        recordedData = new List<OSCEvent>();
        // frame = 0;

    }

    public void StopRecord()
    {
        isRecording = false;
        SaveRecordedData();
    }

    public void ToggleRecord()
    {
        if (isRecording == false)
        {
            Record();
        }
        else
        {
            StopRecord();
        }
    }

    public void SaveOSCFrameData()
    {
        float t = Time.time; // TODO GET THIS FROM OSC




        for (int i = 0; i < floatNumOf; i++)
        {



            foreach (float v in floatArray[i])
            {

                OSCEvent e = new OSCEvent();
                e.address = floatStrings[i];
                e.id = i;
                e.value = v;
                e.time = t;
                e.type = "float";

                recordedData.Add(e);

            }


        }

        for (int i = 0; i < midiNumOf; i++)
        {

            List<Vector2> v = midiArray[i];

            if (v.Count > 0)
            {

                for (int j = 0; j < v.Count; j++)
                {

                    OSCEvent e = new OSCEvent();
                    e.address = midiStrings[i];
                    e.id = i;
                    e.value = v[j].x;
                    e.onOff = v[j].y;
                    e.time = t;
                    e.type = "midi";

                    recordedData.Add(e);

                }

            }

        }




    }

    public bool useRecordedData;

    public void GetRecordedData()
    {

    }
    [Serializable]
    private class Wrapper<OSCEvent>
    {
        public OSCEvent[] Items;
    }
    public string dataName;
    public void SaveRecordedData()
    {

        string path = Application.dataPath + "/OSC/Data/" + dataName + ".json";

        OSCEvent[] data = recordedData.ToArray();


        Wrapper<OSCEvent> wrapper = new Wrapper<OSCEvent>();
        wrapper.Items = data;

        string json = JsonUtility.ToJson(wrapper);

        File.WriteAllText(path, json);

    }


    public static T[] FromJson<T>(string json)
    {
        Wrapper<T> wrapper = JsonUtility.FromJson<Wrapper<T>>(json);
        return wrapper.Items;
    }


    public float loadedDataStartTime;
    public float playbackDataStartTime;
    public void LoadRecordedData()
    {
        string path = Application.dataPath + "/OSC/Data/" + dataName + ".json";
        string json = File.ReadAllText(path);
        print(json.Length);
        for (int i = 0; i < 100; i++)
        {
            //  print(json[i]);
        }
        OSCEvent[] data = FromJson<OSCEvent>(json);//JsonUtility.FromJson<OSCEvent[]>(json);
        print(data.Length);
        for (int i = 0; i < data.Length; i++)
        {
            // print(data[i]);
        }
        recordedData = new List<OSCEvent>(data);

        loadedDataStartTime = data[0].time;
    }


    public void StartRecordedPlayback()
    {
        LoadRecordedData();
        useRecordedData = true;
        playbackDataStartTime = Time.time;
        currentDataIndex = 0;

    }

}


