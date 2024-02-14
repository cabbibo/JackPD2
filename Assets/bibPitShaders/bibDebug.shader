
Shader "BibPit/debug_1" {
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
      #include "Assets/Shaders/Chunks/Struct16.cginc"
      #include "Assets/Shaders/Chunks/debugVSChunk.cginc"
      #include "Assets/Shaders/Chunks/hsv.cginc"
      #include "Assets/Shaders/Chunks/BibPit.cginc"



      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {

          if( length( v.uv2 -.5) > .5 ){ discard;}



          float3 col = hsv(v.debug.x / float(_NumStems) ,.5,1) * _Color.xyz;//_Color.xyz;// float3(v.uv.x , 0 , 0);
          return float4(col,1 );
      }

      ENDCG

    }
  }


}
