Shader "Aquarium/preyRunRender" {
	Properties {
  	_Color ("Color", Color) = (1,1,1,1)
	_Size ("Size", Float) = 1
	}


  SubShader{

    Pass{

		  CGPROGRAM

		  #pragma target 4.5

		  #pragma vertex vert
		  #pragma fragment frag

		  #include "UnityCG.cginc"


      

      uniform float3 _Color;


	  float _Size;


     struct Transform{
        float4x4 localToWorld;
        float4x4 worldToLocal;
      };

      StructuredBuffer<Transform> _VertBuffer1;
      StructuredBuffer<Transform> _VertBuffer2;
 uniform int _Count1;
 uniform int _Count2;


 float _RepelRadius;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos : SV_POSITION;
		  float whichForce : TEXCOORD0;
		  float3 dir : TEXCOORD1;
		  float lVal : TEXCOORD2;
      };

      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        // Getting ID information


		int baseID = id / 3;
		

		int inTriID = id % 3;

		o.whichForce = 0;//(float)whichForce;


		int id1 = baseID / _Count2;
		int id2 = baseID % _Count2;

		if( id1 < _Count1 && id2 < _Count2 ){


          Transform v1 = _VertBuffer1[id1];
          Transform v2 = _VertBuffer2[id2];

          float3 pos1 = mul( v1.localToWorld , float4(0,0,0,1)).xyz;
		  float3 pos2 = mul( v2.localToWorld , float4(0,0,0,1)).xyz;
		  float3 f2 = mul( v2.localToWorld , float4(0,0,1,0)).xyz;

		  float3 dir = pos2 - pos1;

		  o.dir = dir;

		  float3 perp = normalize(cross(normalize(dir), UNITY_MATRIX_V[2].xyz ));

		  float3 p1 =0;
		  float3 p2 =0;
		  float3 p3 =0;


		  float dist = length(dir);

			float lVal = dist / _RepelRadius;
			o.lVal = 1-lVal;
		  if( dist < _RepelRadius ){
		

			  p1 = pos1 - perp * _Size * 4;
			  p2 = pos1 + perp * _Size * 4;
			  p3 = pos1 + dir * saturate(pow((1-lVal),2) *8) * 1 ;
		  }

		  
	

		  float3 fPos; float2 fUV;

		  if( inTriID % 3 == 0 ){
			  fPos = p1; fUV = float2(0,0);
		  }else if( inTriID % 3 == 1 ){
			  fPos = p2; fUV = float2(1,0);
		  }else{	
			  fPos = p3; fUV = float2(0.5,1);
		  }


          o.pos = mul (UNITY_MATRIX_VP, float4(fPos,1.0f));
      
        }

        return o;

      }

      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

			float3 col = float3(1,1,1);

			col = (normalize(-v.dir) * .5)   + .5;//

          return float4( col * _Color  * pow(v.lVal,1) * 10, 1 );
      }




      ENDCG

    }
  }

  Fallback Off


}
