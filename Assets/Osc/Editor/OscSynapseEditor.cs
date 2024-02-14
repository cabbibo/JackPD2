using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(OscSynapse))]
public class OscSynapseEditor : Editor
{
    public override void OnInspectorGUI()
    {


        OscSynapse osc = (OscSynapse)target;


        if (GUILayout.Button("RECONNECT"))
        {
            osc.Reconnect();
        }


        if (GUILayout.Button("Record"))
        {
            osc.ToggleRecord();
        }

        if (GUILayout.Button("Load Data"))
        {
            osc.LoadRecordedData();
        }

        if (GUILayout.Button("Start Recorded Playback"))
        {
            osc.StartRecordedPlayback();
        }

        DrawDefaultInspector();


    }





}