
Shader "audio/particles2" {
    Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _Size ("Size", float) = .01
    _MainTex ("Tex",  2D) = "white" {}
    }


  SubShader{
    Pass{

   Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    Blend SrcAlpha One
    Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
      CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"
      #include "../../Chunks/Struct16.cginc"
      #include "../../Chunks/hsv.cginc"
      #include "../../Chunks/hash.cginc"
      #include "../../Chunks/snoise.cginc"


      



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


uniform sampler2D _AudioMap;
uniform float  _AudioTime;
uniform float _AudioID;


sampler2D _MainTex;


float3 rotateVector( float3 input, float3 axis , float angle ){
float4x4 rotationMatrix = float4x4(
  cos(angle) + axis.x * axis.x * (1 - cos(angle)),
  axis.y * axis.x * (1 - cos(angle)) + axis.z * sin(angle),
  axis.z * axis.x * (1 - cos(angle)) - axis.y * sin(angle),
  0,
  axis.x * axis.y * (1 - cos(angle)) - axis.z * sin(angle),
  cos(angle) + axis.y * axis.y * (1 - cos(angle)),
  axis.z * axis.y * (1 - cos(angle)) + axis.x * sin(angle),
  0,
  axis.x * axis.z * (1 - cos(angle)) + axis.y * sin(angle),
  axis.y * axis.z * (1 - cos(angle)) - axis.x * sin(angle),
  cos(angle) + axis.z * axis.z * (1 - cos(angle)),
  0,
  0, 0, 0, 1
);



return mul(rotationMatrix ,float4(input,0)).xyz;


}

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
    float3 f = UNITY_MATRIX_V[2].xyz;


    float angle = snoise(v.pos*0);// hash( (float)base * 112 ) * 6.28;

    l = rotateVector( l , normalize(f),angle);
    u = rotateVector( u , normalize(f),angle);


    
    float2 uv = float2(0,0);

    if( alternate == 0 ){ extra = -l - u; uv = float2(0,0); }
    if( alternate == 1 ){ extra =  l - u; uv = float2(1,0); }
    if( alternate == 2 ){ extra =  l + u; uv = float2(1,1); }
    if( alternate == 3 ){ extra = -l - u; uv = float2(0,0); }
    if( alternate == 4 ){ extra =  l + u; uv = float2(1,1); }
    if( alternate == 5 ){ extra = -l + u; uv = float2(0,1); }



      //Vert v = _VertBuffer[base % _Count];
      float4 aVal = tex2Dlod(_AudioMap, float4(v.uv.x  ,_AudioTime,0,0));
      float a = v.debug.x;//length(a *a* .001)
      o.worldPos = (v.pos) + extra * _Size * clamp(v.debug.x,.3,1) * v.debug.y;//* clamp(length(pow(a,1) * 1),0.1,.2);// * v.debug.y;
      o.eye = _WorldSpaceCameraPos - o.worldPos;
      o.nor =v.nor;
      o.uv = v.uv;
      o.uv2 = uv  /8 + float2(floor(hash( float(base * 10) )  * 8)/8, floor(hash( float(base * 30) )  * 8)/8);
      o.id = base;
      o.debug = v.debug;
      o.pos = mul (UNITY_MATRIX_VP, float4(o.worldPos,1.0f));

  }

  return o;

}




      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

         // if( length( v.uv2 -.5) > .5 ){ discard;}
         // if( length( v.uv2 -.5) < .45 ){ discard;}

          float3 col = hsv( v.debug.x *1+ 0 - v.debug.y * .1  + _AudioID / 10, .5,1);


          float4 t = tex2D(_MainTex , v.uv2);
          //float4 a  = tex2D(_AudioMap, float2((1-v.debug.y) * .04 + t.a* .003 ,_AudioTime));
          float4 a  = tex2D(_AudioMap, float2( v.uv.x  + t.a* .01 ,v.uv.y));
          //float4 a  = tex2D(_AudioMap, float2(v.uv.x + t.a* .003 + (1-v.debug.y) * .1 ,_AudioTime));

          col = saturate(col*clamp(100.6*a*a,.00001,1)* t.a );
          
          return float4(col,1 );
      }

      ENDCG

    }
  }


}
