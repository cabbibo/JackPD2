Shader "audio/emberDebug"
{
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

        
        _Size("_Size",float) = .1

        _FocalDistance("_FocalDistance" , float )= 2
        _FocalBase("_FocalBase" , float )= 3
        _FocalPower("_FocalPower" , float )= 3
        _FocalSizeMultiplier("_FocalSizeMultiplier" , float )= 2
        _FocalBrightnessMultiplier("_FocalBrightnessMultiplier" , float )= 2
        _CurlNoisePower("_CurlNoisePower",float) = .3
        _CurlNoiseOffset("_CurlNoiseOffset",float) = .8
        _CurlNoiseSize("_CurlNoiseSize",float) = 1
        _CurlNoiseSpeed("_CurlNoiseSpeed",Vector) = (0,0,0)
        _NoisePower("_NoisePower",float) = .3
        _NoiseOffset("_NoiseOffset",float) = .8
        _NoiseSize("_NoiseSize",float) = 1
        _NoiseSpeed("_NoiseSpeed",Vector) = (0,0,0)
        _AudioPower("_AudioPower",float) = .3
        _AudioOffset("_AudioOffset",float) = .8
        _Multiplier("_Multiplier",float)=1

        _FocalDistanceOsscilationSize("_FocalDistanceOsscilationSize",float)=1
        _FocalDistanceOsscilationSpeed("_FocalDistanceOsscilationSpeed",float)=1

        _VignetteSize("_VignetteSize",float) = 1
        _VignetteFade("_VignetteFade",float) = 1




        
    }


    SubShader
    {
        
        Pass
        {
        //Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off
     ZWrite Off
        
    Blend One One // Additive  
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
     Cull Off Lighting Off ZWrite Off
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            // make fog work

            
            #pragma multi_compile_fogV

            #include "UnityCG.cginc"

            #include "../../Chunks/Struct16.cginc"
            #include "../../Chunks/hsv.cginc"
            #include "../../Chunks/snoise.cginc"
            #include "../../Chunks/hash.cginc"
            #include "../../Chunks/curlNoise.cginc"

            sampler2D _MainTex;
            sampler2D _ColorMap;
            sampler2D _AudioMap;


            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;


float _FocalDistance;
float _FocalSizeMultiplier;
float _FocalBrightnessMultiplier;
float _CurlNoisePower;
float _CurlNoiseOffset;
float _CurlNoiseSize;
float3 _CurlNoiseSpeed;
float _NoisePower;
float _NoiseOffset;
float _NoiseSize;
float3 _NoiseSpeed;
float _AudioPower;
float _AudioOffset;
float _Multiplier;
float _FocalBase;
float _FocalPower;
float _FocalDistanceOsscilationSize;
float _FocalDistanceOsscilationSpeed;

      uniform int _Count;
      uniform float _Size;

      


      //uniform float4x4 worldMat;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 nor      : TEXCOORD0;
          float3 worldPos : TEXCOORD1;
          float3 eye      : TEXCOORD2;
          float2 debug    : TEXCOORD3;
          float2 uv       : TEXCOORD4;
          float2 uv2       : TEXCOORD6;
          float id        : TEXCOORD5;
          float focalValue : TEXCOORD7;
          float3 curl : TEXCOORD8;
          float snoise : TEXCOORD9;
          float frontBack : TEXCOORD10;
      };



//float _Multiplier;
//Our vertex function simply fetches a point from the buffer corresponding to the vertex index
//which we transform with the view-projection matrix before passing to the pixel program.
varyings vert (uint id : SV_VertexID){

  varyings o;

  int base = id / 6;
  int alternate = id %6;

  if( base < _Count ){

      float3 extra = float3(0,0,0);

    float3 l = UNITY_MATRIX_V[0].xyz;
    float3 u = UNITY_MATRIX_V[1].xyz;
    
    float2 uv = float2(0,0);

    if( alternate == 0 ){ extra = -l - u; uv = float2(0,0); }
    if( alternate == 1 ){ extra =  l - u; uv = float2(1,0); }
    if( alternate == 2 ){ extra =  l + u; uv = float2(1,1); }
    if( alternate == 3 ){ extra = -l - u; uv = float2(0,0); }
    if( alternate == 4 ){ extra =  l + u; uv = float2(1,1); }
    if( alternate == 5 ){ extra = -l + u; uv = float2(0,1); }

      Vert v = _VertBuffer[base];
    float focalValue =length( v.pos - _WorldSpaceCameraPos ) - _FocalDistance + _FocalDistanceOsscilationSize * sin( _Time.x*_FocalDistanceOsscilationSpeed); 

    float frontBack = sign(focalValue );
    focalValue = abs(focalValue);
    //focalValue *= focalValue;

    focalValue = pow( focalValue , _FocalPower );
    focalValue  *= _FocalSizeMultiplier;
    o.focalValue = focalValue;
    o.frontBack = frontBack;



      //Vert v = _VertBuffer[base % _Count];
      o.worldPos = (v.pos) + extra * _Size * .001 * (focalValue+_FocalBase) * (.5-abs(v.debug.y-.5));
      o.eye = _WorldSpaceCameraPos - o.worldPos;
      o.nor =v.nor;
      o.uv = v.uv;
      o.uv2 = uv;
      o.id = base;

      o.curl =  curlNoise(v.pos * _CurlNoiseSize + _CurlNoiseSpeed * _Time );
      o.snoise = snoise(v.pos * _NoiseSize + _NoiseSpeed * _Time);

      o.debug = v.debug;
      o.pos = mul (UNITY_MATRIX_VP, float4(o.worldPos,1.0f));

  }

  return o;

}



float _VignetteSize;
float _VignetteFade;

            fixed4 frag (varyings v) : SV_Target
            {

                float3 col = _Color.xyz;

                float lookupVal =  length( v.uv2 - .6 ) * 2;
                lookupVal = saturate( lookupVal );
             
               float v1 = min( smoothstep(0.8,0.9,lookupVal) + .8 , 1-smoothstep(.9,1,lookupVal) );
               float v2 = 1-lookupVal;

                float3 fV =  lerp( v1 , v2 , 1-(v.frontBack +1 )/2 );


                lookupVal =  length( v.uv2 - .5 ) * 2;
                lookupVal = saturate( lookupVal );
             
                v1 = min( smoothstep(0.8,0.9,lookupVal) + .8 , 1-smoothstep(.9,1,lookupVal) );
                v2 = 1-lookupVal;

                fV.g =  lerp( v1 , v2 , 1-(v.frontBack +1 )/2 );


               lookupVal =  length( v.uv2 - .4 ) * 2;
                lookupVal = saturate( lookupVal );
             
                v1 = min( smoothstep(0.8,0.9,lookupVal) + .8 , 1-smoothstep(.9,1,lookupVal) );
                v2 = 1-lookupVal;

                fV.b =  lerp( v1 , v2 , 1-(v.frontBack +1 )/2 );


                fV = saturate((1-lookupVal * 2) * .5  + snoise( float3( v.uv2 , v.debug.x)* 1 ) * .2);//fV.g;

                col *= fV;

               // col *= tex2D( _MainTex , v.uv2 ).a;// * 1;

              col /= pow(v.focalValue * _FocalBrightnessMultiplier,2);
                col *= _AudioPower * tex2D(_AudioMap, abs(v.snoise))  + _AudioOffset;
                col *= _Multiplier;
                //col *= 10;
               // col *= v.worldPos.z* v.worldPos.z * v.worldPos.z;
                col *= v.snoise * _NoisePower + _NoiseOffset;
                col *= v.curl * _CurlNoisePower + _CurlNoiseOffset;



                float vignette = _VignetteSize - _VignetteFade*length(v.worldPos.xy) * (1+ snoise( v.pos * .01 ) * .3);
                col *= saturate(vignette);


              //  col = v.debug.y;
                //col *= 100000;
                return float4(col,1);
            }

            ENDCG
        }
}

}
