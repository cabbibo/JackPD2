

Shader "FantasyCrystals/CompassShader"
{

    Properties {

    
    _NumSteps("Num Trace Steps",int) = 10
    _DeltaStepSize("DeltaStepSize",float) = .01
    _StepRefractionMultiplier("StepRefractionMultiplier", float) = 0
  
    _Opaqueness("_Opaqueness",float) = 1
    _IndexOfRefraction("_IndexOfRefraction",float) = .8
    _ColorSplit("_ColorSplit",float) = .8
    _Contrast("_Constrast",float) = .8
    

    _ReflectionColor ("ReflectionColor", Color) = (1,1,1,1)
    _ReflectionSharpness("ReflectionSharpness",float)=1
    _ReflectionMultiplier("_ReflectionMultiplier",float)=1
    
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

    _HueStart( "_HueStart", float ) = 0
    _HueSize( "_HueSize", float ) = 1
    _Saturation( "_Saturation", float ) = 1
    _Lightness( "_Lightness", float ) = 1
    _ColorMultiplier( "_ColorMultiplier", float ) = 1


    _MainTex ("Albedo (RGB)", 2D) = "white" {}
    _DiscardTex ("Discard (RGB)", 2D) = "white" {}
    }


  SubShader{

            // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Transparent" }
Blend One One // Additive
        // Grab the screen behind the object into _BackgroundTexture

      Cull Off
    Pass{
CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"
      
    int _NumSteps;
    float _DeltaStepSize;
    float _NoiseSize;
    float _CenterOrbFalloff;
    float _NoiseImportance;
    float _CenterOrbImportance;
    float _CenterOrbFalloffSharpness;
    float _StepRefractionMultiplier;
    float _NoiseSharpness;
    float _NoiseSpeed;
    float _Opaqueness;
    float _NoiseSubtractor;
    float _ColorMultiplier;
    float _IndexOfRefraction;
    float3 _CenterOrbOffset;
    float3 _NoiseOffset;

    float _ReflectionSharpness;
    float _ReflectionMultiplier;
    float4 _ReflectionColor;

    float _OffsetMultiplier;

    float _HueStart;
    float _HueSize;
    float _Saturation;
    float _Lightness;

    float _ColorSplit;
    float _Contrast;


    float _WrenID;

    sampler2D _MainTex;
    sampler2D _DiscardTex;


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

          float3 rdR : TEXCOORD9;
          float3 rdG : TEXCOORD10;
          float3 rdB : TEXCOORD11;

          float2 uv : TEXCOORD12;
          float2 uv2 : TEXCOORD13;
          
          
      };


            sampler2D _BackgroundTexture;
            sampler2D _FullColorMap;
            float _Hue1;


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
        o.ro = p;//worldPos.xyz;
        o.localPos = p.xyz;
        
        
        float3 localP = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
        float3 eye = normalize(localP - p.xyz);

        float m1 = floor( (sin( _WrenID  * 100 ) +1 ) * 2 ) /2;
        float m2 = floor( (sin( _WrenID  * 100 ) +1 ) * 4 ) /4;

o.uv2 = vertex.uv;
    o.uv = vertex.uv.yx * float2( .25 , .5 ) + float2( m1 , m2);


        o.unrefracted = eye;
        o.rd = refract( eye , -n , _IndexOfRefraction);
        o.rdR = refract( eye , -n , _IndexOfRefraction - _ColorSplit * 0);
        o.rdG = refract( eye , -n , _IndexOfRefraction - _ColorSplit * 1);
        o.rdB = refract( eye , -n , _IndexOfRefraction - _ColorSplit * 2);
        o.eye = refract( -normalize(_WorldSpaceCameraPos - worldPos) , normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f))) , _IndexOfRefraction);
    
        o.worldNor = normalize(mul (unity_ObjectToWorld, float4(-n,0.0f)).xyz);
        o.lightDir = normalize(mul( unity_ObjectToWorld , float4(1,-1,0,0)).xyz);

        float4 refractedPos = UnityObjectToClipPos( float4(o.ro + o.rd * 1.5,1));
    o.grabPos = ComputeGrabScreenPos(refractedPos);
    

  return o;

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

float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}



float4 trace( float3 ro , float3 rd , float iOR ){


   float dt = _DeltaStepSize;
  float t = 0;
  float c = 0.;
float3 p = 0;

float totalSmoke = 0;

float3 col = 0;

  for(int i =0 ; i < _NumSteps; i++ ){
      t+=dt*exp(-2.*c);
    p = ro - rd * t * 2;
    
  float3 smoke = nT3D( p * _NoiseSize  );
  float3 nor = normalize(smoke);

    float noiseDensity = saturate(length(smoke) - _NoiseSubtractor);


    noiseDensity =   pow( noiseDensity , _NoiseSharpness)  * _NoiseImportance;


    //float centerOrbDensity = ((_CenterOrbImportance)/(pow(length(p-_CenterOrbOffset),_CenterOrbFalloffSharpness) * _CenterOrbFalloff)) ;
  
    //c= saturate(centerOrbDensity +noiseDensity);   
   // centerOrbDensity -= noiseDensity;
    totalSmoke += noiseDensity;

    rd = normalize(rd * (1-c*_StepRefractionMultiplier) + nor *  c*_StepRefractionMultiplier);
    col = .99*col;


    float fHue= _HueStart + _HueSize * noiseDensity;//lerp( _HueStart , _HueSize , noiseDensity);

  col += hsv( fHue , _Saturation , _Lightness );
 
  }
  return float4(col * pow( totalSmoke , 3),totalSmoke);

}
//Pixel function returns a solid color for each point.
float4 frag (varyings v) : COLOR {
  float3 col =0;//hsv( float(v.face) * .3 , 1,1);


  float4 traceValR =  trace(v.ro, v.rdR, 1);
  float4 traceValG =  trace(v.ro, v.rdG, 1);
  float4 traceValB =  trace(v.ro, v.rdB, 1);
  //float4 traceVal =  trace(v.ro, v.rd, 1);
 // float4 traceVal =  trace(v.ro, v.rd, 1);

  col.r = traceValR.r;
  col.g = traceValG.g;
  col.b = traceValB.b;
       
 float m = dot( normalize(v.unrefracted), normalize(v.nor) );
 col += pow((1-m),_ReflectionSharpness) * _ReflectionMultiplier * _ReflectionColor;

 col = pow( length(col), _Contrast) * _ColorMultiplier * col;



    col = saturate(col * .8) / .8;
    col *= tex2D(_FullColorMap , float2(  length(col.xyz) * _HueSize  + v.uv.y , _HueStart + _Hue1 )).xyz * 10;

    col = lerp( length(col) / 2 , col , _Saturation * v.uv.x);
    col *= 2;


float4 tCol = tex2D(_DiscardTex, v.uv);


float dVal = abs(v.uv2.y -.5);// - v.uv.x*.5;


dVal = dVal - (.5 - max( v.uv2.x * .5 , (.5-v.uv2.x*3)));
//dVal += length(col.rgb) * .3;
if(dVal > -.05){
  //col *= 10;
}
if( dVal > 0 ){
 //discard;
}


col *= 10*v.uv2.x;

//col *= tex2D(_FullColorMap , float2(  traceValR.a * .3 + v.uv.y + tCol.x * .3 , _Hue1 )).xyz * 10;
    //col *= pow( v.uv.y,10);// * v.uv.x;
    return float4( col.xyz , 1);//saturate(float4(col,3*length(col) ));




}

      ENDCG

    }
  }

  Fallback Off


}
