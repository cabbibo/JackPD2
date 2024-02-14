using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

public class DataForm : Form
{
    

    public float[] values;
    public int ss;

    public override void SetStructSize()
    {
        structSize = ss;
    }
    public override void OnBirthed(){
        values = new float[ count * structSize ];
    }
    public override void WhileLiving(float v){
        _buffer.GetData(values);
    }
}
