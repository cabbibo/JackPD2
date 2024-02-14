// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Debug/BarkParks" {
    Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _Size ("Size", float) = .01
    _AmountShown ("AmountShown", Range (0, 1)) = .5
    }


  SubShader{
    Cull Off
    Pass{

      CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"
     
     struct Vert{
         float3 pos;
         float3 nor;
         float2 uv;
         float baseVal;
         float totalPoints;
         float branchID;
         float debug;
     };



      uniform int _Count;
      uniform float _Size;
      uniform float3 _Color;
      uniform float _AmountShown;

      
      StructuredBuffer<Vert> _VertBuffer;


      //uniform float4x4 worldMat;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 nor      : TEXCOORD0;
          float3 worldPos : TEXCOORD1;
          float3 eye      : TEXCOORD2;
          float3 debug    : TEXCOORD3;
          float2 uv       : TEXCOORD4;
          float2 uv2       : TEXCOORD6;
          float id        : TEXCOORD5;
          float timeCreated        : TEXCOORD7;

          
      };


uniform float4x4 _Transform;
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

    int bID = base;

    Vert v = _VertBuffer[bID];

      if( alternate == 0 ){ extra = v.pos +(-u - l) * _Size; }
      if( alternate == 1 ){ extra = v.pos +(+u - l) * _Size ;}
      if( alternate == 2 ){ extra = v.pos +(+u + l) * _Size ;  }
      if( alternate == 3 ){ extra = v.pos +(-u - l) * _Size ;  }
      if( alternate == 4 ){ extra = v.pos +(+u +l) * _Size ;  }
      if( alternate == 5 ){ extra = v.pos +(-u+ l) * _Size ;  }

        o.worldPos = extra;// mul(_Transform, float4((v.pos) ,1));
        ///o.worldPos +=  extra * _Size;
        o.eye = _WorldSpaceCameraPos - o.worldPos;

      
        o.timeCreated = v.branchID;
        o.pos = mul (UNITY_MATRIX_VP, float4(o.worldPos,1.0f));


   


  }

  return o;

}


    float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}  

//Pixel function returns a solid color for each point.
float4 frag (varyings v) : COLOR {
  if( v.timeCreated > _AmountShown ){
    discard;
  }

  float3 col =hsv( v.timeCreated,1,1);// _Color;

    return float4(col,1 );
}

      ENDCG

    }
  }

  Fallback Off


}
