using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IMMATERIA
{
    public class Particles : Form
    {

        public override void SetStructSize() { structSize = 16; }

        public override void Embody()
        {
            float[] values = new float[count * structSize];
            SetData(values);
        }
    }
}