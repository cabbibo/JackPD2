using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OSCToSimulation : MonoBehaviour
{

    public extOSCMessageReceive receiver;
    public extOSCMessageSend sender;


    public AquariumController controller;


    // Set All the info!
    void Update()
    {


    }



    // Only send values once everyone has done their work!
    void LateUpdate()
    {

    }
}
