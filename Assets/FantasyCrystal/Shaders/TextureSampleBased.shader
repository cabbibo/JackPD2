

Shader "FantasyCrystals/TextureBased"
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


    _NormalMap("_NormalMap", 2D) = "white" {}

    }


  SubShader{

            // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Geometry+10" }

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

    sampler2D _SampleTexture;
    float _SampleSize;


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
          float2 uv : TEXCOORD10;
          
          
      };


            sampler2D _BackgroundTexture;

             struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

//Our vertex function simply fetches a point from the buffer corresponding to the vertex index
//which we transform with the view-projection matrix before passing to the pixel program.
varyings vert ( appdata vertex ){



  varyings o;
     float4 p = vertex.position;
     float3 n =  vertex.normal;//_NormBuffer[id/3];

        float3 worldPos = mul (unity_ObjectToWorld, float4(p.xyz,1.0f)).xyz;
        o.pos = UnityObjectToClipPos (float4(p.xyz,1.0f));
        o.nor = n;//normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f)));; 
        o.ro = worldPos.xyz;
        o.localPos = p.xyz;
        
        
        float3 localP = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
        float3 eye = normalize(localP - p.xyz);

      o.uv = vertex.uv;
        o.unrefracted = eye;
        o.rd = refract( eye , -n , _IndexOfRefraction);
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


float3 uvNormalMap( sampler2D normalMap , float3 pos , float2 uv , float3 norm , float texScale , float normalScale ){
             
  float3 q0 = ddx( pos.xyz );
  float3 q1 = ddy( pos.xyz );
  float2 st0 = ddx( uv.xy );
  float2 st1 = ddy( uv.xy );

  float3 S = normalize(  q0 * st1.y - q1 * st0.y );
  float3 T = normalize( -q0 * st1.x + q1 * st0.x );
  float3 N = normalize( norm );

  float3 mapN = tex2D( normalMap, uv*texScale ).xyz * 2.0 - 1.0;
  mapN.xy = normalScale * mapN.xy;
 
  float3x3 tsn = transpose( float3x3( S, T, N ) );
  float3 fNorm =  normalize( mul(tsn , mapN) ); 

  return fNorm;

} 

sampler2D _NormalMap;

//Pixel function returns a solid color for each point.
float4 frag (varyings v) : COLOR {
  float3 col =0;//hsv( float(v.face) * .3 , 1,1);


  float3 rd = normalize(v.ro  - _WorldSpaceCameraPos);
  float3 fNor = uvNormalMap( _NormalMap , v.ro, v.uv , v.worldNor , 2,.3);

  float3 rdR = refract(-rd , fNor , _IndexOfRefraction + .0);
  float3 rdG = refract(-rd , fNor , _IndexOfRefraction + .05);
  float3 rdB = refract(-rd , fNor , _IndexOfRefraction + .1);


  float4 refractedPosR = ComputeGrabScreenPos(UnityObjectToClipPos(float4(v.ro+rdR * _RefractionBackgroundSampleExtraStep,1)));
  float4 refractedPosG = ComputeGrabScreenPos(UnityObjectToClipPos(float4(v.ro+rdG * _RefractionBackgroundSampleExtraStep,1)));
  float4 refractedPosB = ComputeGrabScreenPos(UnityObjectToClipPos(float4(v.ro+rdB * _RefractionBackgroundSampleExtraStep,1)));
float4 backgroundColR = tex2Dproj(_BackgroundTexture, refractedPosR) + .00000000001*pow(rdR.z*100,5);
float4 backgroundColG = tex2Dproj(_BackgroundTexture, refractedPosG) + .00000000001*pow(rdG.z*100,5);
float4 backgroundColB = tex2Dproj(_BackgroundTexture, refractedPosB) + .00000000001*pow(rdB.z*100,5);


col = float3(backgroundColR.x,backgroundColG.y,backgroundColB.z);

//col.xy = normalize(v.uv ) * .5 + .5;

//col = -fNor * .5 + .5;

    return float4( col.xyz , 1);//saturate(float4(col,3*length(col) ));




}

      ENDCG

    }
  }

  Fallback Off


}
