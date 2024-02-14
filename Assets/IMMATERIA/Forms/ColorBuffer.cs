using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using IMMATERIA;

public class ColorBuffer : Form
{

    public Color[] colors;
    public bool dynamic;
    public override void SetCount()
    {
        count = colors.Length;
    }
    public override void SetStructSize()
    {
        structSize = 4;
    }

    public override void Embody()
    {
        base.Embody();
        SetColors();
    }

    public override void WhileLiving(float v)
    {
        base.WhileLiving(v);
        if (dynamic)
        {
            SetColors();
        }
    }

    public void SetColors()
    {

        float[] values = new float[colors.Length * 4];

        int index = 0;
        for (int i = 0; i < colors.Length; i++)
        {

            values[index++] = colors[i].r;
            values[index++] = colors[i].g;
            values[index++] = colors[i].b;
            values[index++] = colors[i].a;


        }


        SetData(values);

    }

}
