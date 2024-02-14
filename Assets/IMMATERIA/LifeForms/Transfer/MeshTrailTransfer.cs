using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace IMMATERIA
{
    public class MeshTrailTransfer : TransferLifeForm
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
            transfer.BindInt("_NumVertsPerHair", () => s.numVertsPerHair);
            transfer.BindInt("_Direction", () => direction);

            transfer.BindForm("_BaseBuffer", baseVerts);


        }


    }
}