Shader "IMMAT/Debug/TriIndex16" {
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


      
		  #include "../../Chunks/Struct16.cginc"

 uniform int _Count;
      uniform float3 _Color;


	  float _Size;




      StructuredBuffer<Vert> _VertBuffer;
      StructuredBuffer<int> _TriBuffer;

      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos : SV_POSITION;
      };

      //Our vertex function simply fetches a point from the buffer corresponding to the vertex index
      //which we transform with the view-projection matrix before passing to the pixel program.
      varyings vert (uint id : SV_VertexID){

        varyings o;

        // Getting ID information


		int whichQuad = id / 6;
		int inQuadID = id % 6;

		int whichTri = whichQuad/3;
		int inTriID = whichQuad % 3;

	
        // Making sure we aren't looking up into a bad areas
        if( whichTri*3+inTriID < _Count ){

          int t1 = _TriBuffer[whichTri*3+ ((inTriID+0)%3)];
          int t2 = _TriBuffer[whichTri*3+ ((inTriID+1)%3)];


          Vert v1 = _VertBuffer[t1];
          Vert v2 = _VertBuffer[t2];

          float3 pos1 = v1.pos;
		  float3 pos2 = v2.pos;

		  float3 dir = pos2 - pos1;

		  float3 perp = normalize(cross(normalize(dir), UNITY_MATRIX_V[2].xyz ));

		  float3 p1 = pos1 - perp * _Size;
		  float3 p2 = pos1 + perp * _Size;
		  float3 p3 = pos2 - perp * _Size;
		  float3 p4 = pos2 + perp * _Size;

		  float3 fPos; float2 fUV;
		  
		  if( inQuadID == 0 ){
			  fPos = p1; fUV = float2(0,0);
		  }else if( inQuadID == 1 ){
			  fPos = p2; fUV = float2(1,0);
		  }else if( inQuadID == 2 ){
			  fPos = p4; fUV = float2(1,1);
		  }else if( inQuadID == 3 ){
			  fPos = p1; fUV = float2(0,0);
		  }else if( inQuadID == 4 ){
			  fPos = p4; fUV = float2(1,1);
		  }else if( inQuadID == 5 ){
			  fPos = p3; fUV = float2(0,1);
		  }

          o.pos = mul (UNITY_MATRIX_VP, float4(fPos,1.0f));
      
        }

        return o;

      }

      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {
          return float4( _Color , 1 );
      }




      ENDCG

    }
  }

  Fallback Off


}
