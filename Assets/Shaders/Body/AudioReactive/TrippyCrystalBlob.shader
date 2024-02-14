

Shader "FantasyCrystals/TrippyCrystalBlob"
{

    Properties {

    _BaseColor ("BaseColor", Color) = (1,1,1,1)
    
    _NumSteps("Num Trace Steps",int) = 10
    _ColorMultiplier("ColorMultiplier",float)=1
  
    _Opaqueness("_Opaqueness",float) = 1
    _IndexOfRefraction("_IndexOfRefraction",float) = .8
    _RefractionBackgroundSampleExtraStep("_RefractionBackgroundSampleExtraStep",float) = 0

    _ReflectionColor ("ReflectionColor", Color) = (1,1,1,1)
    _ReflectionSharpness("ReflectionSharpness",float)=1
    _ReflectionMultiplier("_ReflectionMultiplier",float)=1
  

    _SampleColor ("SampleColor", Color) = (1,1,1,1)
    _SampleTexture("SampleTexture", 2D) = "white" {}
    _SampleSize("SampleSize", float) = 1


    _LightFallOffBase("LightFallOffBase", float) = .1
    _LightFallOffPower("LightFallOffPower", float) = 2
    _LightFallOffMultiplier("LightFallOffMultiplier", float) = 1
    _LightColorMultiplier("LightColorMultiplier", float) = 1

    _DeltaStepSize("Del_DeltaStepSize", float) = 1

    _CenterOrbOffset ("CenterOrbOffset", Vector) = (0,0,0)
    _CenterOrbColor ("CenterOrbColor", Color) = (1,1,1,1)
    _CenterOrbFalloff("CenterOrbFalloff", float) = 6
    _CenterOrbFalloffSharpness("CenterOrbFalloffSharpness", float) = 1

    _CenterOrbImportance("CenterOrbImportance", float) = .3

    _NoiseColor ("NoiseColor", Color) = (1,1,1,1)
    _NoiseOffset ("NoiseOffset", Vector) = (0,0,0)
    _NoiseSize("NoiseSize", float) = 1
    _NoiseSpeed("NoiseSpeed", float) = 1
    _NoiseImportance("NoiseImportance", float) = 1
    _NoiseSharpness("NoiseSharpness",float) = 1
    _NoiseSubtractor("NoiseSubtractor",float)=0
    _OffsetMultiplier("OffsetMu_OffsetMultiplier",float)=0

    }


  SubShader{

            // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Geometry+100" }

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }

      Cull Off
    Pass{
CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"
      
      #include "../../Chunks/hash.cginc"
      #include "../../Chunks/snoise.cginc"


    float4 _BaseColor;
    float4 _SampleColor;
    int _NumSteps;
    float _Opaqueness;
    float _ColorMultiplier;
    float _RefractionBackgroundSampleExtraStep;
    float _IndexOfRefraction;

    float _ReflectionSharpness;
    float _ReflectionMultiplier;
    float4 _ReflectionColor;

        float _LightFallOffBase;
    float _LightFallOffPower;
    float _LightFallOffMultiplier;
    float _LightColorMultiplier;


    float4 _CenterOrbColor;
    float4 _NoiseColor;
    float _DeltaStepSize;
    float _NoiseSize;
    float _CenterOrbFalloff;
    float _NoiseImportance;
    float _CenterOrbImportance;
    float _CenterOrbFalloffSharpness;
    float _StepRefractionMultiplier;
    float _NoiseSharpness;
    float _NoiseSpeed;
    float _NoiseSubtractor;
    float3 _CenterOrbOffset;
    float3 _NoiseOffset;


    sampler2D _SampleTexture;
    float _SampleSize;
    sampler2D _AudioMap;


      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 nor : NORMAL;
          float3 ro : TEXCOORD1;
          float3 rd : TEXCOORD2;
          float3 eye : TEXCOORD3;
          float3 localPos : TEXCOORD4;
          float3 worldNor : TEXCOORD5;
          float3 lightDir : TEXCOORD6;
          float4 grabPos : TEXCOORD7;
          float3 unrefracted : TEXCOORD8;
          float3 world : TEXCOORD9;
          float noise :TEXCOORD10;
          float disform : TEXCOORD11;
          
          
      };


            sampler2D _BackgroundTexture;
            sampler2D _FullColorMap;

            struct Transform{
              float4x4 ltw;
              float4x4 wtl;
            };

            StructuredBuffer<Transform> _TransformBuffer;
            int _TransformCount;

            StructuredBuffer<float4> _ColorBuffer;
            int _ColorCount;


             struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
            };

//Our vertex function simply fetches a point from the buffer corresponding to the vertex index
//which we transform with the view-projection matrix before passing to the pixel program.
varyings vert ( appdata vertex ){



  varyings o;
     float4 p = vertex.position;
     float3 n =  vertex.normal;//_NormBuffer[id/3];


  float nVal = snoise( p  * 2.3+ float3(0,_Time.y * .001,0) + mul (unity_ObjectToWorld, float4(0,0,0,1.0f)).xyz  * .3);

        o.noise = nVal;

    float4 aVal = tex2Dlod(_AudioMap, float4((nVal+1)/2,0,0,0));
     p.xyz += n * length(aVal) * .003;
        o.disform = length(aVal);

        float3 worldPos = mul (unity_ObjectToWorld, float4(p.xyz,1.0f)).xyz;
        float3 worldNor = normalize( mul (unity_ObjectToWorld, float4(n.xyz,0.0f)).xyz );


        

        float3 eye = normalize(_WorldSpaceCameraPos - worldPos);
        float m = dot( worldNor, eye );




        o.pos = UnityObjectToClipPos (float4(p.xyz,1.0f));
        o.nor = n;//normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f)));; 
        o.ro = p;//worldPos.xyz;
        o.world = worldPos;
        o.localPos = p.xyz;
        
        
        float3 localP = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
        float3 eyeL = normalize(localP - p.xyz);


        o.unrefracted = eyeL;
        o.rd = refract( eyeL , -n , _IndexOfRefraction);
        o.eye = refract( -normalize(_WorldSpaceCameraPos - worldPos) , normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f))) , _IndexOfRefraction);
        //o.worldNor = mul (unity_ObjectToWorld, float4(n.xyz,0.0f)).xyz;
        o.worldNor = normalize(mul (unity_ObjectToWorld, float4(-n,0.0f)).xyz);
        o.lightDir = normalize(mul( unity_ObjectToWorld , float4(1,-1,0,0)).xyz);

        float4 refractedPos = UnityObjectToClipPos( float4(o.ro + o.rd * 1.5,1));
    o.grabPos = ComputeGrabScreenPos(refractedPos);
    
  return o;

}




float4 projectOnPlane( float3 pos, float3 nor , float3 ro , float3 rd ){

    float hit = 0.0;
    float dotP = dot(rd,nor);

    
    float distToHit = dot(pos - ro, nor) / dotP;

    hit = distToHit;
    if( distToHit < 0 ){
        hit = 0;
    }

    return float4(hit * rd + ro,hit);

}


float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}

float3 ClosestPointOnLine(float3 a, float3 b, float3 p){
    float3 ap = p-a;
    float3 ab = b-a;
    return a + dot(ap,ab)/dot(ab,ab) * ab;
}

float DistToPoint(float3 a, float3 b, float3 p){
    float3 ap = p-a;
    float3 ab = b-a;
    return dot(ap,ab)/dot(ab,ab);
}




float tri(in float x){return abs(frac(x)-.5);}
float3 tri3(in float3 p){return float3( tri(p.y+tri(p.z)), tri(p.z+tri(p.x)), tri(p.y+tri(p.x)));}
           
float triAdd( in float3 p ){ return (tri(p.x+tri(p.y+tri(p.z)))); }

float triangularNoise( float3 p ){

    float totalFog = 0;

    float noiseScale = 1;

    float3 tmpPos = p;

    float noiseContribution = 1;

    float3 offset = 0;

    p *= _NoiseSize;
    p *= 2;

   float speed = 1.1;
 
   p +=  tri3(p.xyz * .3 + _NoiseSpeed * _Time.x* .1 ) *1.6;
   totalFog += triAdd(p.yxz * .3) * .35;
    
   p +=  tri3(p.xyz * .4 + 121  + _NoiseSpeed * _Time.x* .2) * 1;
   totalFog += triAdd(p.yxz * 1) * .25;
    
   p +=  tri3(p.xyz * .8 + 31  + _NoiseSpeed * _Time.x * .3) * 1;
   totalFog += triAdd(p.yxz* 1.3) * .15;

  return totalFog;

}


float t3D( float3 pos ){
  float3 fPos = pos * .05 + _NoiseOffset;

  // Adds Randomness to noise for each crystal
 // fPos += 100 * mul(unity_ObjectToWorld,float4(0,0,0,1)).xyz;
  return triangularNoise( fPos);
}

float dT3D( float3 pos , float3 lightDir ){

  float eps = .0001;

  
  return ((t3D(pos) - t3D(pos+ lightDir * eps))/eps+.5);
}

float3 nT3D( float3 pos ){

  float3 eps = float3(.0001,0,0);

  return t3D(pos) * normalize(
         float3(  t3D(pos + eps.xyy) - t3D(pos - eps.xyy), 
                  t3D(pos + eps.yxy) - t3D(pos - eps.yxy),
                  t3D(pos + eps.yyx) - t3D(pos - eps.yyx) ));


}

float _ID;


//Pixel function returns a solid color for each point.
float4 frag (varyings v) : COLOR {
  float3 col =0;//hsv( float(v.face) * .3 , 1,1);


 float dt = _DeltaStepSize;
  float t = 0;
  float c = 0.;
float3 p = 0;

float totalSmoke = 0;
  float3 rd = v.rd;
  for(int i =0 ; i < _NumSteps; i++ ){
      t+=dt*exp(-2.*c);
    p = v.ro - rd * t * 2;
    
  float3 smoke = nT3D( p * _NoiseSize  );
  float3 nor = normalize(smoke);

  float noiseDensity = saturate(length(smoke) - _NoiseSubtractor);


    noiseDensity =   pow( noiseDensity , _NoiseSharpness)  * _NoiseImportance;


    float centerOrbDensity = ((_CenterOrbImportance)/(pow(length(p-_CenterOrbOffset),_CenterOrbFalloffSharpness) * _CenterOrbFalloff)) ;
  
    c= saturate(centerOrbDensity +noiseDensity);   
    centerOrbDensity -= noiseDensity;
    totalSmoke += c;

    rd = normalize(rd * (1-c*_StepRefractionMultiplier) + nor *  c*_StepRefractionMultiplier);
    col = .99*col +lerp( lerp(_BaseColor,_CenterOrbColor , saturate(centerOrbDensity)), _NoiseColor , saturate(noiseDensity));// saturate(dot(v.lightDir , nor)) * .1 *c;//hsv(c,.4, dT3D(p*3,float3(0,-1,0))) * c;//hsv(c * .8 + .3,1,1)*c;;// hsv(smoke,1,1) * saturate(smoke);

 
  }

        float3 eye = normalize(_WorldSpaceCameraPos - v.world);
        eye = refract( eye , -v.worldNor , .8);
               // float4 refractedPos = UnityObjectToClipPos( float4(o.ro + o.rd * 1.5,1));
  float4 refractedPos = ComputeGrabScreenPos(mul(UNITY_MATRIX_VP,(float4(v.world+eye * _RefractionBackgroundSampleExtraStep,1))));
float4 backgroundCol = tex2Dproj(_BackgroundTexture, refractedPos);


float closest = 100000;

float4 pointLights = 0;
for( int i =0; i < _TransformCount; i++ ){
  float3 tPoint= mul( _TransformBuffer[i].ltw , float4(0,0,0,1)).xyz;

  float d = length(v.world - tPoint);

  
  pointLights += _ColorBuffer[i] * _LightColorMultiplier/(_LightFallOffBase+pow(d,_LightFallOffPower)*_LightFallOffMultiplier);



}

col *= _ColorBuffer[_ID] * .6 + .2;// float3(1,1,0);
col *= length(_ColorBuffer[_ID]  ) * 3;
// col += pointLights;
 col *= _ColorMultiplier;
 //col *= pow( v.disform ,6) * .1;

 col *= 3;

 //col =col + .5*backgroundCol;
 col +=  2*backgroundCol* _ColorBuffer[_ID] *10;

 col *= 1;

// col *=  pow(tex2D(_AudioMap,float2(totalSmoke *.1 + .5,0)),4) * 10;
//float m = dot( normalize(v.unrefracted), normalize(v.nor) );
//col += pow((1-m),_ReflectionSharpness) * _ReflectionMultiplier * _ReflectionColor;//

//  float3 baseCol =_BaseColor.xyz;//

//    col = lerp(baseCol*backgroundCol,col,saturate(totalSmoke * _Opaqueness));//

//       
 float m = saturate(dot( normalize(v.unrefracted), normalize(v.nor) ));

 float reflA = tex2D(_AudioMap,1-m);
 col += reflA *reflA *reflA *pow((1-m),_ReflectionSharpness) * _ReflectionMultiplier * _ReflectionColor*(_ColorBuffer[_ID] * .8 + .2);//
col *= .7;
 col=saturate(col);
// col = tex2D(_AudioMap,float2(totalSmoke *1 + .5,0))  * tex2D(_FullColorMap,float2(totalSmoke *1 + .5,0)) * col;//
//

//col = pow( tex2D(_AudioMap,float2(v.noise * 1,0)),10) *3;// * tex2D(_FullColorMap,float2(totalSmoke *1 + .5,0)) * _CenterOrbColor * _CenterOrbColorMultiplier;//

//col +=  pointLights * 1;

//col = tex2D(_AudioMap,float2(totalSmoke *.1 + .5,0));//  * tex2D(_FullColorMap,float2(totalSmoke *1 + .5,0));// * col;
    return float4( col.xyz , 1);//saturate(float4(col,3*length(col) ));




}

      ENDCG

    }
  }

  Fallback Off


}
