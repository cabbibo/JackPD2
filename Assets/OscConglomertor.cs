using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class OscConglomertor : MonoBehaviour
{

    public float centroid;
    public float spread;
    public float skewness;
    public float kurtosis;
    public float rolloff;
    public float flatness;
    public float crest;

    public void ReceiveCentroid(float v){
        centroid = v;
    }

    public void ReceiveSpread(float v){
        spread = v;
    }

    public void ReceiveSkewness(float v ){
        skewness = v;
    }

    public void ReceiveKurtosis( float v ){
        kurtosis = v;
    }

    public void ReceiveRolloff(float v){
        rolloff = v;
    }

    public void ReceiveFlatness( float v ){
        flatness = v;
    }

    public void ReceiveCrest( float v ){
        crest = v;
    }


    public TMP_Text text;

    public void Update(){

        string full = "Values <br>";
        full += "centroid : " + centroid + "<br>";
        full += "spread : " + spread + "<br>";
        full += "skewness : " + skewness + "<br>";
        full += "kurtosis : " + kurtosis + "<br>";
        full += "rolloff : " + rolloff + "<br>";
        full += "flatness : " + flatness + "<br>";
        full += "crest : " + crest + "<br>";
        text.SetText(full);
    }

}
