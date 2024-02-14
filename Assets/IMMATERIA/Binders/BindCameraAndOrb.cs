using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using IMMATERIA;

public class BindCameraAndOrb : Binder
{

    public Transform _Camera;
    public Transform _Orb;

    public float _OrbRepelForce;

    public float _CameraRepelForce;
    public float _CameraViewRepelForce;
    public float _CameraCurlForce;

    public float _CameraForceFalloff;

    public float _OrbCurlForce;

    public Life[] otherLives;

    public override void Bind()
    {
        toBind.BindFloat("_OrbRepelForce", () => _OrbRepelForce);
        toBind.BindFloat("_CameraRepelForce", () => _CameraRepelForce);
        toBind.BindFloat("_CameraViewRepelForce", () => _CameraViewRepelForce);
        toBind.BindFloat("_CameraCurlForce", () => _CameraCurlForce);
        toBind.BindFloat("_CameraForceFalloff", () => _CameraForceFalloff);
        toBind.BindFloat("_OrbCurlForce", () => _OrbCurlForce);

        toBind.BindFloat("_OrbRadius", () => _Orb.localScale.x / 2);

        toBind.BindMatrix("_CameraTransform", () => this._Camera.localToWorldMatrix);
        toBind.BindMatrix("_OrbTransform", () => this._Orb.localToWorldMatrix);

        for (int i = 0; i < otherLives.Length; i++)
        {
            otherLives[i].BindFloat("_OrbRepelForce", () => _OrbRepelForce);
            otherLives[i].BindFloat("_CameraRepelForce", () => _CameraRepelForce);
            otherLives[i].BindFloat("_CameraViewRepelForce", () => _CameraViewRepelForce);
            otherLives[i].BindFloat("_CameraForceFalloff", () => _CameraForceFalloff);
            otherLives[i].BindFloat("_CameraCurlForce", () => _CameraCurlForce);
            otherLives[i].BindFloat("_OrbCurlForce", () => _OrbCurlForce);

            otherLives[i].BindFloat("_OrbRadius", () => _Orb.localScale.x / 2);

            otherLives[i].BindMatrix("_CameraTransform", () => this._Camera.localToWorldMatrix);
            otherLives[i].BindMatrix("_OrbTransform", () => this._Orb.localToWorldMatrix);
        }
    }
}
