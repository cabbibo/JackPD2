
Shader "IMMAT/Debug/ParticlesRayToCenter" {
    Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _Size ("Size", float) = .01
    }


  SubShader{ 
    
    Tags {Queue = Transparent}
    Blend One One
    ZWrite Off

    Cull Off
    Pass{

      CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"
      #include "../../Chunks/Struct16.cginc"
    

    

      uniform int _Count;
      uniform float _Size;
      uniform float3 _Color;

      
      StructuredBuffer<Vert> _VertBuffer;


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
      };



float3 _WrenPos;
float _OSCValue;
float _OSCID;



#include "../../Chunks/hash.cginc"

  const float PHI = 1.61803398874989484820459; // Φ = Golden Ratio 

  float gold_noise(in float2 xy, in float seed)
  {
    return frac(tan(distance(xy*PHI, xy)*seed)*xy.x);
  }


  float3 randomDir( float seed ){


    return normalize(float3( 
      gold_noise(float2(hash(seed), hash(seed*2)),seed * 11),
      gold_noise(float2(hash(seed*7), hash(seed*3)),seed *12 ),
      gold_noise(float2(hash(seed*5), hash(seed*4)),seed * 13)
    ) - .5);



  }


    
sampler2D _AudioMap;


//float _Multiplier;
//Our vertex function simply fetches a point from the buffer corresponding to the vertex index
//which we transform with the view-projection matrix before passing to the pixel program.
varyings vert (uint id : SV_VertexID){

  varyings o;

  int base = id / 6;
  int alternate = id %6;

  if( base < _Count ){

      Vert v = _VertBuffer[base];
      float3 extra = float3(0,0,0);

    float3 l = UNITY_MATRIX_V[0].xyz;
    float3 u = UNITY_MATRIX_V[1].xyz;
    
    float2 uv = float2(0,0);


    float3 p1 = _WrenPos;
    float3 p2 = _WrenPos;

    float3 outDir = randomDir( float(base));

    float3 otherDir = cross( UNITY_MATRIX_V[2].xyz , outDir );

    float3 p3 = v.pos + otherDir*(1 + 3*v.uv.x);
    float3 p4 = v.pos - otherDir*(1 + 3*v.uv.x);

    if( alternate == 0 ){ extra = p1; uv = float2(0.5,0); }
    if( alternate == 1 ){ extra =  p3; uv = float2(0,1); }
    if( alternate == 2 ){ extra =  p4; uv = float2(1,1); }


    if( alternate == 3 ){ extra = 0; uv = float2(.5,0); }
    if( alternate == 4 ){ extra =  0; uv = float2(1,1); }
    if( alternate == 5 ){ extra = 0; uv = float2(0,1); }


    float3 axis = float3( v.uv.x , v.uv.y , v.debug.x );



      //Vert v = _VertBuffer[base % _Count];
      o.worldPos =  extra;//(v.pos) + extra * _Size;
      o.eye = _WorldSpaceCameraPos - o.worldPos;
      o.nor =v.nor;
      o.uv = v.uv;
      o.uv2 = uv;
      o.id = base;
      o.debug = v.debug;
      o.pos = mul (UNITY_MATRIX_VP, float4(o.worldPos,1.0f));

  }

  return o;

}




sampler2D _FullColorMap;
float _ColorMapSection;

      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

         // if( length( v.uv2 -.5) > .5 ){ discard;}

         float3 aCol = tex2D(_AudioMap,float2(v.uv2.y * 1,0)).xyz;

         float3 cMap = tex2D(_FullColorMap,float2(v.uv.y ,_ColorMapSection));
          
          float3 col = sin(v.uv2.y * 100);
          col = aCol;

          col = 1;

          col = cMap * 1* aCol;

          col  *= pow( 2*(.5-abs(v.uv2.x-.5)) * (1-v.uv2.y),20);//abs(v.uv2.x -.5);// length( v.uv2 -.5);
          return float4(col,1 );
      }

      ENDCG

    }
  }


}
