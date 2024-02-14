using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using TMPro;


public class extOSCMessageSend : MonoBehaviour
{

    public string address;
    public OSCTransmitter transmitter;

    public TMP_Text debugText;
    public float[] values;

    // Start is called before the first frame update
    void Start()
    {

    }

    void Update()
    {



    }

    public void SendAquariumData(float[] data)
    {

        debugText.text = "Output : ";
        var message = new OSCMessage(address);
        for (int i = 0; i < data.Length; i++)
        {
            message.AddValue(OSCValue.Float(data[i]));
            debugText.text += " | " + string.Format("{0:0.00}", data[i]);
        }

        transmitter.Send(message);
    }
}
