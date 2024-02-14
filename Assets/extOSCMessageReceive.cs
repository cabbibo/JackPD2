using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using UnityEngine.Events;
using TMPro;



[ExecuteAlways]
public class extOSCMessageReceive : MonoBehaviour
{

    public OSCReceiver receiver;
    public string messageAddress;


    public float[] values;

    public UnityEvent onMessagReceived;

    public TMP_Text debugText;


    // Start is called before the first frame update
    void OnEnable()
    {
        receiver.Bind(messageAddress, MessageReceived);
    }


    void MessageReceived(OSCMessage message)
    {
        Debug.LogFormat("Received: {0}", message);

        values = new float[message.Values.Count];

        debugText.text = "Input : ";

        for (int i = 0; i < message.Values.Count; i++)
        {
            values[i] = message.Values[i].FloatValue;
            debugText.text += " | " + string.Format("{0:0.00}", values[i]); ;
        }

        onMessagReceived.Invoke();
    }


}
