using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IMMATERIA
{
    public class MeshTrailLifeform : TransferLifeForm
    {

        public float meshLength;

        public MeshVerts baseVerts;

        public int direction;




        public override void Bind()
        {


            transfer.BindFloat("_ModelLength", () => meshLength);
            transfer.BindInt("_NumVertsPerMesh", () => baseVerts.count);

            Hair s = (Hair)skeleton;
            transfer.BindInt("_NumVertsPerTrail", () => s.numVertsPerHair);
            transfer.BindInt("_Direction", () => direction);

            transfer.BindForm("_BaseBuffer", baseVerts);
            transfer.BindFloat("_CountMultiplier", () => ((InstancedMeshVerts)body.verts).countMultiplier);


        }


    }
}