
Shader "IMMAT/Debug/Particles16" {
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
      #include "../../Chunks/debugVSChunk.cginc"
      #include "../../Chunks/hsv.cginc"



      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

          if( length( v.uv2 -.5) > .5 ){ discard;}



          float3 col = _Color.xyz;// float3(v.uv.x , 0 , 0);
          return float4(col,1 );
      }

      ENDCG

    }
  }


}
