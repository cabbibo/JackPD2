
Shader "IMMAT/Debug/Eden16" {
    Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _Size ("Size", float) = .01


    }


  SubShader{
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


float _Delay;

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
      //Vert v = _VertBuffer[base % _Count];
      o.worldPos = (v.pos) + extra * _Size  * clamp(v.debug.y *v.debug.x,0,1) ;
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

// Generic algorithm to desaturate images used in most game engines
float3 generic_desaturate(float3 color, float factor)
{
	float3 lum = float3(0.299, 0.587, 0.114);
	float3 gray = dot(lum, color);
	return lerp(color, gray, factor);
}



      sampler2D _FullColorMap;
      float _OSCID;
      float _OSCValue;

      float3 _ColorInfo;

      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

          if( length( v.uv2 -.5) > .5 ){ discard;}


          float3 col = tex2D(_FullColorMap , float2(_ColorInfo.x + v.debug.x * v.debug.y  * _ColorInfo.z,  _ColorInfo.y )).xyz;// *saturate(v.debug.y);//(v.debug.x  * v.debug.x * 5 * v.debug.y + .4)* _Color;
          
          col *= v.debug.x;
          col *= v.debug.y;
         col *=   (_Delay * 2 + saturate(_OSCValue * 1) * (1-_Delay));
        // col *= _OSCValue;
        //  col = generic_desaturate(col, saturate(_Delay * 1) );

          col *= _OSCValue;


          return float4(col,1 );
      }

      ENDCG

    }
  }


}
