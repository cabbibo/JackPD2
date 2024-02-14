using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SignalAsPosition : MonoBehaviour
{


    public OscConglomerate conglomerate;

    // Update is called once per frame
    void Update()
    {
        transform.position = new Vector3( conglomerate.signal1, conglomerate.signal2 , conglomerate.signal3 );
    }
    
}
