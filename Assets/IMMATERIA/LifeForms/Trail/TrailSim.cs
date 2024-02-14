using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IMMATERIA
{
    public class TrailSim : Simulation
    {

        public Form head;
        public Life transport;

        public float _TrailFollowForce;
        public float _TrailFollowDampening;
        public float _AmountShown;


        public override void Create()
        {
            if (transport) SafeInsert(transport);
        }

        public override void Bind()
        {

            life.BindForm("_HeadBuffer", head);

            Hair tp = (Hair)form;
            life.BindInt("_ParticlesPerTrail", () => tp.numVertsPerHair);

            life.BindFloat("_TrailFollowForce", () => _TrailFollowForce);
            life.BindFloat("_TrailFollowDampening", () => _TrailFollowDampening);
            life.BindFloat("_AmountShown", () => _AmountShown);

            if (transport)
            {
                transport.BindPrimaryForm("_ParticleBuffer", head);
                transport.BindForm("_VertBuffer", form);
                transport.BindInt("_NumVertsPerHair", () => tp.numVertsPerHair);
                data.BindCameraData(transport);
            }

        }


    }
}