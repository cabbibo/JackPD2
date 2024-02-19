using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class AquariumController : MonoBehaviour
{


    public ButterflySpawner butterflies;
    public ButterflySpawner sharks;
    public ButterflySpawner megaSharks;


    [Space(20)]


    public const float butterflyCenterForce_L = .00001f;
    public const float butterflyCenterForce_H = .01f;

    [Range(butterflyCenterForce_L, butterflyCenterForce_H)]
    public float butterflyCenterForce;


    public const float butterflyMaxSpeed_L = .02f;
    public const float butterflyMaxSpeed_H = .2f;

    [Range(butterflyMaxSpeed_L, butterflyMaxSpeed_H)]
    public float butterflyMaxSpeed;




    public const float butterflyMinSpeed_L = .01f;
    public const float butterflyMinSpeed_H = .02f;

    [Range(butterflyMinSpeed_L, butterflyMinSpeed_H)]
    public float butterflyMinSpeed;


    public const float butterflyMaxTurnSpeed_L = .5f;
    public const float butterflyMaxTurnSpeed_H = 2f;

    [Range(butterflyMaxTurnSpeed_L, butterflyMaxTurnSpeed_H)]
    public float butterflyMaxTurnSpeed;



    public const float butterflyCohesionDistance_L = 0f;
    public const float butterflyCohesionDistance_H = 10f;

    [Range(butterflyCohesionDistance_L, butterflyCohesionDistance_H)]
    public float butterflyCohesionDistance;


    public const float butterflyCohesionStrength_L = 0f;
    public const float butterflyCohesionStrength_H = 1f;

    [Range(butterflyCohesionStrength_L, butterflyCohesionStrength_H)]
    public float butterflyCohesionStrength;


    public const float butterflyAlignmentDistance_L = 0f;
    public const float butterflyAlignmentDistance_H = 10f;

    [Range(butterflyAlignmentDistance_L, butterflyAlignmentDistance_H)]
    public float butterflyAlignmentDistance;

    public const float butterflyAlignmentStrength_L = 0f;
    public const float butterflyAlignmentStrength_H = 1f;

    [Range(butterflyAlignmentStrength_L, butterflyAlignmentStrength_H)]
    public float butterflyAlignmentStrength;

    public const float butterflySeperationDistance_L = 0f;
    public const float butterflySeperationDistance_H = 10f;

    [Range(butterflySeperationDistance_L, butterflySeperationDistance_H)]
    public float butterflySeperationDistance;

    public const float butterflySeperationStrength_L = 0;
    public const float butterflySeperationStrength_H = 1;

    [Range(butterflySeperationStrength_L, butterflySeperationStrength_H)]
    public float butterflySeperationStrength;





    public const float butterflySharkRepel1Radius_L = 0;
    public const float butterflySharkRepel1Radius_H = 10;

    [Range(butterflySharkRepel1Radius_L, butterflySharkRepel1Radius_H)]
    public float butterflySharkRepel1Radius;


    public const float butterflySharkRepel1Force_L = 0;
    public const float butterflySharkRepel1Force_H = 1;

    [Range(butterflySharkRepel1Force_L, butterflySharkRepel1Force_H)]
    public float butterflySharkRepel1Force;


    public const float butterflySharkRepel2Radius_L = 0;
    public const float butterflySharkRepel2Radius_H = 10;

    [Range(butterflySharkRepel2Radius_L, butterflySharkRepel2Radius_H)]
    public float butterflySharkRepel2Radius;


    public const float butterflySharkRepel2Force_L = 0;
    public const float butterflySharkRepel2Force_H = 100;

    [Range(butterflySharkRepel2Force_L, butterflySharkRepel2Force_H)]
    public float butterflySharkRepel2Force;

    [Space(20)]



    /*

    SHART XING


    */

    [Space(100)]
    public const float sharkCenterForce_L = .00001f;
    public const float sharkCenterForce_H = .01f;

    [Range(sharkCenterForce_L, sharkCenterForce_H)]
    public float sharkCenterForce;


    public const float sharkMaxSpeed_L = .02f;
    public const float sharkMaxSpeed_H = .2f;

    [Range(sharkMaxSpeed_L, sharkMaxSpeed_H)]
    public float sharkMaxSpeed;




    public const float sharkMinSpeed_L = .01f;
    public const float sharkMinSpeed_H = .02f;

    [Range(sharkMinSpeed_L, sharkMinSpeed_H)]
    public float sharkMinSpeed;


    public const float sharkMaxTurnSpeed_L = .5f;
    public const float sharkMaxTurnSpeed_H = 2f;

    [Range(sharkMaxTurnSpeed_L, sharkMaxTurnSpeed_H)]
    public float sharkMaxTurnSpeed;



    public const float sharkCohesionDistance_L = 0f;
    public const float sharkCohesionDistance_H = 10f;

    [Range(sharkCohesionDistance_L, sharkCohesionDistance_H)]
    public float sharkCohesionDistance;


    public const float sharkCohesionStrength_L = 0f;
    public const float sharkCohesionStrength_H = 1f;

    [Range(sharkCohesionStrength_L, sharkCohesionStrength_H)]
    public float sharkCohesionStrength;


    public const float sharkAlignmentDistance_L = 0f;
    public const float sharkAlignmentDistance_H = 10f;

    [Range(sharkAlignmentDistance_L, sharkAlignmentDistance_H)]
    public float sharkAlignmentDistance;

    public const float sharkAlignmentStrength_L = 0f;
    public const float sharkAlignmentStrength_H = 1f;

    [Range(sharkAlignmentStrength_L, sharkAlignmentStrength_H)]
    public float sharkAlignmentStrength;

    public const float sharkSeperationDistance_L = 0f;
    public const float sharkSeperationDistance_H = 10f;

    [Range(sharkSeperationDistance_L, sharkSeperationDistance_H)]
    public float sharkSeperationDistance;

    public const float sharkSeperationStrength_L = 0;
    public const float sharkSeperationStrength_H = 1;

    [Range(sharkSeperationStrength_L, sharkSeperationStrength_H)]
    public float sharkSeperationStrength;





    public const float sharkSharkRepel1Radius_L = 0;
    public const float sharkSharkRepel1Radius_H = 10;

    [Range(sharkSharkRepel1Radius_L, sharkSharkRepel1Radius_H)]
    public float sharkSharkRepel1Radius;


    public const float sharkSharkRepel1Force_L = 0;
    public const float sharkSharkRepel1Force_H = 200;

    [Range(sharkSharkRepel1Force_L, sharkSharkRepel1Force_H)]
    public float sharkSharkRepel1Force;


    public const float sharkPreyAttract1Radius_L = 0;
    public const float sharkPreyAttract1Radius_H = 10;

    [Range(sharkPreyAttract1Radius_L, sharkPreyAttract1Radius_H)]
    public float sharkPreyAttract1Radius;


    public const float sharkPreyAttract1Force_L = 0;
    public const float sharkPreyAttract1Force_H = 10;

    [Range(sharkPreyAttract1Force_L, sharkPreyAttract1Force_H)]
    public float sharkPreyAttract1Force;



    [Space(100)]

    /*

    Mega Shart XING


    */


    public const float megaSharkCenterForce_L = .00001f;
    public const float megaSharkCenterForce_H = .01f;

    [Range(megaSharkCenterForce_L, megaSharkCenterForce_H)]
    public float megaSharkCenterForce;


    public const float megaSharkMaxSpeed_L = .02f;
    public const float megaSharkMaxSpeed_H = .2f;

    [Range(megaSharkMaxSpeed_L, megaSharkMaxSpeed_H)]
    public float megaSharkMaxSpeed;




    public const float megaSharkMinSpeed_L = .01f;
    public const float megaSharkMinSpeed_H = .02f;

    [Range(megaSharkMinSpeed_L, megaSharkMinSpeed_H)]
    public float megaSharkMinSpeed;


    public const float megaSharkMaxTurnSpeed_L = .5f;
    public const float megaSharkMaxTurnSpeed_H = 2f;

    [Range(megaSharkMaxTurnSpeed_L, megaSharkMaxTurnSpeed_H)]
    public float megaSharkMaxTurnSpeed;



    public const float megaSharkCohesionDistance_L = 0f;
    public const float megaSharkCohesionDistance_H = 10f;

    [Range(megaSharkCohesionDistance_L, megaSharkCohesionDistance_H)]
    public float megaSharkCohesionDistance;


    public const float megaSharkCohesionStrength_L = 0f;
    public const float megaSharkCohesionStrength_H = 1f;

    [Range(megaSharkCohesionStrength_L, megaSharkCohesionStrength_H)]
    public float megaSharkCohesionStrength;


    public const float megaSharkAlignmentDistance_L = 0f;
    public const float megaSharkAlignmentDistance_H = 10f;

    [Range(megaSharkAlignmentDistance_L, megaSharkAlignmentDistance_H)]
    public float megaSharkAlignmentDistance;

    public const float megaSharkAlignmentStrength_L = 0f;
    public const float megaSharkAlignmentStrength_H = 1f;

    [Range(megaSharkAlignmentStrength_L, megaSharkAlignmentStrength_H)]
    public float megaSharkAlignmentStrength;

    public const float megaSharkSeperationDistance_L = 0f;
    public const float megaSharkSeperationDistance_H = 20f;

    [Range(megaSharkSeperationDistance_L, megaSharkSeperationDistance_H)]
    public float megaSharkSeperationDistance;

    public const float megaSharkSeperationStrength_L = 0;
    public const float megaSharkSeperationStrength_H = 3;

    [Range(megaSharkSeperationStrength_L, megaSharkSeperationStrength_H)]
    public float megaSharkSeperationStrength;






    public const float megaSharkPreyAttract1Radius_L = 0;
    public const float megaSharkPreyAttract1Radius_H = 10;

    [Range(megaSharkPreyAttract1Radius_L, megaSharkPreyAttract1Radius_H)]
    public float megaSharkPreyAttract1Radius;


    public const float megaSharkPreyAttract1Force_L = 0;
    public const float megaSharkPreyAttract1Force_H = 10;

    [Range(megaSharkPreyAttract1Force_L, megaSharkPreyAttract1Force_H)]
    public float megaSharkPreyAttract1Force;




    public const float megaSharkPreyAttract2Radius_L = 0;
    public const float megaSharkPreyAttract2Radius_H = 10;

    [Range(megaSharkPreyAttract2Radius_L, megaSharkPreyAttract2Radius_H)]
    public float megaSharkPreyAttract2Radius;


    public const float megaSharkPreyAttract2Force_L = 0;
    public const float megaSharkPreyAttract2Force_H = 10;

    [Range(megaSharkPreyAttract2Force_L, megaSharkPreyAttract2Force_H)]
    public float megaSharkPreyAttract2Force;







    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {


        butterflies.centerForce = butterflyCenterForce;
        butterflies.maxSpeed = butterflyMaxSpeed;
        butterflies.minSpeed = butterflyMinSpeed;
        butterflies.maxTurnSpeed = butterflyMaxSpeed;
        butterflies.cohesionDistance = butterflyCohesionDistance;
        butterflies.seperationDistance = butterflySeperationDistance;
        butterflies.alignmentDistance = butterflyAlignmentDistance;
        butterflies.cohesionStrength = butterflyCohesionStrength;
        butterflies.seperationStrength = butterflySeperationStrength;
        butterflies.alignmentStrength = butterflyAlignmentStrength;

        butterflies.sharkRepelRadiuses[0] = butterflySharkRepel1Radius;
        butterflies.sharkRepelForces[0] = butterflySharkRepel1Force;

        butterflies.sharkRepelRadiuses[1] = butterflySharkRepel1Radius;
        butterflies.sharkRepelForces[1] = butterflySharkRepel1Force;




        sharks.centerForce = sharkCenterForce;
        sharks.maxSpeed = sharkMaxSpeed;
        sharks.minSpeed = sharkMinSpeed;
        sharks.maxTurnSpeed = sharkMaxSpeed;
        sharks.cohesionDistance = sharkCohesionDistance;
        sharks.seperationDistance = sharkSeperationDistance;
        sharks.alignmentDistance = sharkAlignmentDistance;
        sharks.cohesionStrength = sharkCohesionStrength;
        sharks.seperationStrength = sharkSeperationStrength;
        sharks.alignmentStrength = sharkAlignmentStrength;

        sharks.sharkRepelRadiuses[0] = sharkSharkRepel1Radius;
        sharks.sharkRepelForces[0] = sharkSharkRepel1Force;

        sharks.preyAttractRadiuses[0] = sharkPreyAttract1Radius;
        sharks.preyAttractForces[0] = sharkPreyAttract1Force;



        megaSharks.centerForce = megaSharkCenterForce;
        megaSharks.maxSpeed = megaSharkMaxSpeed;
        megaSharks.minSpeed = megaSharkMinSpeed;
        megaSharks.maxTurnSpeed = megaSharkMaxSpeed;
        megaSharks.cohesionDistance = megaSharkCohesionDistance;
        megaSharks.seperationDistance = megaSharkSeperationDistance;
        megaSharks.alignmentDistance = megaSharkAlignmentDistance;
        megaSharks.cohesionStrength = megaSharkCohesionStrength;
        megaSharks.seperationStrength = megaSharkSeperationStrength;
        megaSharks.alignmentStrength = megaSharkAlignmentStrength;


        megaSharks.preyAttractRadiuses[0] = megaSharkPreyAttract1Radius;
        megaSharks.preyAttractForces[0] = megaSharkPreyAttract1Force;


        megaSharks.preyAttractRadiuses[1] = megaSharkPreyAttract2Radius;
        megaSharks.preyAttractForces[1] = megaSharkPreyAttract2Force;



        //SetNormalizedValues();



    }

    public void LateUpdate()
    {
        SendOSC();
    }


    public float[] outputValues;

    void NormalizeValues()
    {

    }




    public float[] normalizedValues;
    public void SetNormalizedValues()
    {

        normalizedValues = new float[42];

        normalizedValues[0] = Mathf.InverseLerp(butterflyCenterForce_L, butterflyCenterForce_H, butterflyCenterForce);
        normalizedValues[1] = Mathf.InverseLerp(butterflyMaxSpeed_L, butterflyMaxSpeed_H, butterflyMaxSpeed);
        normalizedValues[2] = Mathf.InverseLerp(butterflyMinSpeed_L, butterflyMinSpeed_H, butterflyMinSpeed);
        normalizedValues[3] = Mathf.InverseLerp(butterflyMaxTurnSpeed_L, butterflyMaxTurnSpeed_H, butterflyMaxTurnSpeed);
        normalizedValues[4] = Mathf.InverseLerp(butterflyCohesionDistance_L, butterflyCohesionDistance_H, butterflyCohesionDistance);
        normalizedValues[5] = Mathf.InverseLerp(butterflyCohesionStrength_L, butterflyCohesionStrength_H, butterflyCohesionStrength);
        normalizedValues[6] = Mathf.InverseLerp(butterflyAlignmentDistance_L, butterflyAlignmentDistance_H, butterflyAlignmentDistance);
        normalizedValues[7] = Mathf.InverseLerp(butterflyAlignmentStrength_L, butterflyAlignmentStrength_H, butterflyAlignmentStrength);
        normalizedValues[8] = Mathf.InverseLerp(butterflySeperationDistance_L, butterflySeperationDistance_H, butterflySeperationDistance);



    }

    public void DenormalizeValues()
    {




        butterflyCenterForce = Mathf.Lerp(butterflyCenterForce_L, butterflyCenterForce_H, receiver.values[0]);
        butterflyMaxSpeed = Mathf.Lerp(butterflyMaxSpeed_L, butterflyMaxSpeed_H, receiver.values[1]);
        butterflyMinSpeed = Mathf.Lerp(butterflyMinSpeed_L, butterflyMinSpeed_H, receiver.values[2]);
        butterflyMaxTurnSpeed = Mathf.Lerp(butterflyMaxTurnSpeed_L, butterflyMaxTurnSpeed_H, receiver.values[3]);
        butterflyCohesionDistance = Mathf.Lerp(butterflyCohesionDistance_L, butterflyCohesionDistance_H, receiver.values[4]);
        butterflyCohesionStrength = Mathf.Lerp(butterflyCohesionStrength_L, butterflyCohesionStrength_H, receiver.values[5]);
        butterflyAlignmentDistance = Mathf.Lerp(butterflyAlignmentDistance_L, butterflyAlignmentDistance_H, receiver.values[6]);
        butterflyAlignmentStrength = Mathf.Lerp(butterflyAlignmentStrength_L, butterflyAlignmentStrength_H, receiver.values[7]);
        butterflySeperationDistance = Mathf.Lerp(butterflySeperationDistance_L, butterflySeperationDistance_H, receiver.values[8]);
        butterflySeperationStrength = Mathf.Lerp(butterflySeperationStrength_L, butterflySeperationStrength_H, receiver.values[9]);
        butterflySharkRepel1Radius = Mathf.Lerp(butterflySharkRepel1Radius_L, butterflySharkRepel1Radius_H, receiver.values[10]);
        butterflySharkRepel1Force = Mathf.Lerp(butterflySharkRepel1Force_L, butterflySharkRepel1Force_H, receiver.values[11]);
        butterflySharkRepel2Radius = Mathf.Lerp(butterflySharkRepel2Radius_L, butterflySharkRepel2Radius_H, receiver.values[12]);
        butterflySharkRepel2Force = Mathf.Lerp(butterflySharkRepel2Force_L, butterflySharkRepel2Force_H, receiver.values[13]);

        sharkCenterForce = Mathf.Lerp(sharkCenterForce_L, sharkCenterForce_H, receiver.values[14]);
        sharkMaxSpeed = Mathf.Lerp(sharkMaxSpeed_L, sharkMaxSpeed_H, receiver.values[15]);
        sharkMinSpeed = Mathf.Lerp(sharkMinSpeed_L, sharkMinSpeed_H, receiver.values[16]);
        sharkMaxTurnSpeed = Mathf.Lerp(sharkMaxTurnSpeed_L, sharkMaxTurnSpeed_H, receiver.values[17]);
        sharkCohesionDistance = Mathf.Lerp(sharkCohesionDistance_L, sharkCohesionDistance_H, receiver.values[18]);
        sharkCohesionStrength = Mathf.Lerp(sharkCohesionStrength_L, sharkCohesionStrength_H, receiver.values[19]);
        sharkAlignmentDistance = Mathf.Lerp(sharkAlignmentDistance_L, sharkAlignmentDistance_H, receiver.values[20]);
        sharkAlignmentStrength = Mathf.Lerp(sharkAlignmentStrength_L, sharkAlignmentStrength_H, receiver.values[21]);
        sharkSeperationDistance = Mathf.Lerp(sharkSeperationDistance_L, sharkSeperationDistance_H, receiver.values[22]);
        sharkSeperationStrength = Mathf.Lerp(sharkSeperationStrength_L, sharkSeperationStrength_H, receiver.values[23]);
        sharkSharkRepel1Radius = Mathf.Lerp(sharkSharkRepel1Radius_L, sharkSharkRepel1Radius_H, receiver.values[24]);
        sharkSharkRepel1Force = Mathf.Lerp(sharkSharkRepel1Force_L, sharkSharkRepel1Force_H, receiver.values[25]);
        sharkPreyAttract1Radius = Mathf.Lerp(sharkPreyAttract1Radius_L, sharkPreyAttract1Radius_H, receiver.values[26]);
        sharkPreyAttract1Force = Mathf.Lerp(sharkPreyAttract1Force_L, sharkPreyAttract1Force_H, receiver.values[27]);

        megaSharkCenterForce = Mathf.Lerp(megaSharkCenterForce_L, megaSharkCenterForce_H, receiver.values[28]);
        megaSharkMaxSpeed = Mathf.Lerp(megaSharkMaxSpeed_L, megaSharkMaxSpeed_H, receiver.values[29]);
        megaSharkMinSpeed = Mathf.Lerp(megaSharkMinSpeed_L, megaSharkMinSpeed_H, receiver.values[30]);
        megaSharkMaxTurnSpeed = Mathf.Lerp(megaSharkMaxTurnSpeed_L, megaSharkMaxTurnSpeed_H, receiver.values[31]);
        megaSharkCohesionDistance = Mathf.Lerp(megaSharkCohesionDistance_L, megaSharkCohesionDistance_H, receiver.values[32]);
        megaSharkCohesionStrength = Mathf.Lerp(megaSharkCohesionStrength_L, megaSharkCohesionStrength_H, receiver.values[33]);
        megaSharkAlignmentDistance = Mathf.Lerp(megaSharkAlignmentDistance_L, megaSharkAlignmentDistance_H, receiver.values[34]);
        megaSharkAlignmentStrength = Mathf.Lerp(megaSharkAlignmentStrength_L, megaSharkAlignmentStrength_H, receiver.values[35]);
        megaSharkSeperationDistance = Mathf.Lerp(megaSharkSeperationDistance_L, megaSharkSeperationDistance_H, receiver.values[36]);
        megaSharkSeperationStrength = Mathf.Lerp(megaSharkSeperationStrength_L, megaSharkSeperationStrength_H, receiver.values[37]);
        megaSharkPreyAttract1Radius = Mathf.Lerp(megaSharkPreyAttract1Radius_L, megaSharkPreyAttract1Radius_H, receiver.values[38]);
        megaSharkPreyAttract1Force = Mathf.Lerp(megaSharkPreyAttract1Force_L, megaSharkPreyAttract1Force_H, receiver.values[39]);
        megaSharkPreyAttract2Radius = Mathf.Lerp(megaSharkPreyAttract2Radius_L, megaSharkPreyAttract2Radius_H, receiver.values[40]);
        megaSharkPreyAttract2Force = Mathf.Lerp(megaSharkPreyAttract2Force_L, megaSharkPreyAttract2Force_H, receiver.values[41]);



    }

    public extOSCMessageReceive receiver;
    public extOSCMessageSend sender;

    public void ReceiveOSC()
    {

        DenormalizeValues();

    }


    float[] sendData;
    public void SendOSC()
    {


        sendData = new float[30];

        sendData[0] = butterflies.percentageSeperating;
        sendData[1] = butterflies.percentageAligning;
        sendData[2] = butterflies.percentageCohesioning;
        sendData[3] = butterflies.percentageSharksRepelling;
        sendData[4] = butterflies.percentagePreyAttracting;
        sendData[5] = butterflies.biggestPackPercentage;
        sendData[6] = butterflies.biggestPackSizePercentage;
        sendData[7] = butterflies.biggestPackLocationPercentage.x;
        sendData[8] = butterflies.biggestPackLocationPercentage.y;
        sendData[9] = butterflies.biggestPackLocationPercentage.z;

        sendData[10] = sharks.percentageSeperating;
        sendData[11] = sharks.percentageAligning;
        sendData[12] = sharks.percentageCohesioning;
        sendData[13] = sharks.percentageSharksRepelling;
        sendData[14] = sharks.percentagePreyAttracting;
        sendData[15] = sharks.biggestPackPercentage;
        sendData[16] = sharks.biggestPackSizePercentage;
        sendData[17] = sharks.biggestPackLocationPercentage.x;
        sendData[18] = sharks.biggestPackLocationPercentage.y;
        sendData[19] = sharks.biggestPackLocationPercentage.z;


        sendData[20] = megaSharks.percentageSeperating;
        sendData[21] = megaSharks.percentageAligning;
        sendData[22] = megaSharks.percentageCohesioning;
        sendData[23] = megaSharks.percentageSharksRepelling;
        sendData[24] = megaSharks.percentagePreyAttracting;
        sendData[25] = megaSharks.biggestPackPercentage;
        sendData[26] = megaSharks.biggestPackSizePercentage;
        sendData[27] = megaSharks.biggestPackLocationPercentage.x;
        sendData[28] = megaSharks.biggestPackLocationPercentage.y;
        sendData[29] = megaSharks.biggestPackLocationPercentage.z;




        sender.SendAquariumData(sendData);

    }



}
