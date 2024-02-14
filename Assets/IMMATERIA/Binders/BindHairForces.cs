using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

public class BindHairForces : Binder
{

    public float _NoiseSize;
    public float _NoiseForce;
    public float _NoiseSpeed;
    public float _Dampening;
    public float _NormalForce;

    public Vector3 _Gravity;
    public override void Bind()
    {

        toBind.BindFloat("_NoiseSize", () => _NoiseSize);
        toBind.BindFloat("_NoiseSpeed", () => _NoiseSpeed);
        toBind.BindFloat("_NoiseForce", () => _NoiseForce);
        toBind.BindFloat("_Dampening", () => _Dampening);
        toBind.BindFloat("_NormalForce", () => _NormalForce);
        toBind.BindFloat("_NormalForce", () => _NormalForce);
        toBind.BindVector3("_Gravity", () => _Gravity);

    }
}
