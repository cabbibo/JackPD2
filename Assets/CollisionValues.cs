using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using IMMATERIA;

public class CollisionValues : MonoBehaviour
{


    public TMP_Text text;
    public ClosestLife life;


    // Update is called once per frame
    void Update()
    {
        text.text = ""  + life.closestID + "<br>" + life.closestPos;
    }
}
