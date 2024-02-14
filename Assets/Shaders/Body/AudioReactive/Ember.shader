Shader "audio/ember"
{
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}

        _FocalDistance("_FocalDistance" , float )= 2
        _FocalFade("_FocalFade" , float )= 2
        
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
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            #include "../../Chunks/Struct16.cginc"
            #include "../../Chunks/hsv.cginc"
            #include "../../Chunks/snoise.cginc"
            #include "../../Chunks/hash.cginc"
            #include "../../Chunks/curlNoise.cginc"

            sampler2D _MainTex;
            sampler2D _ColorMap;
            sampler2D _AudioMap;


            struct v2f { 
              float4 pos : SV_POSITION; 
              float3 nor : NORMAL;
              float2 uv :TEXCOORD0; 
              float3 worldPos :TEXCOORD1;
              float2 debug : TEXCOORD3;
              float3 eye : TEXCOORD4;
              UNITY_SHADOW_COORDS(2)
            };
            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;

            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;

                UNITY_INITIALIZE_OUTPUT(v2f, o);
                Vert v = _VertBuffer[_TriBuffer[vid]];
                o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));


                o.nor = v.nor;
                o.uv = v.uv;
                o.worldPos = v.pos;
                o.debug = v.debug;
                o.eye = v.pos - _WorldSpaceCameraPos;

            


                UNITY_TRANSFER_SHADOW(o,o.worldPos);

                return o;
            }



            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos) * .5 + .5;
                float val = -dot(normalize(_WorldSpaceLightPos0.xyz),normalize(v.nor));


                float4 t = tex2D(_MainTex, float2(v.uv.yx));
                float lookupVal =  length( v.uv - .5 );
                if( t.a < .5){discard;}

                float3 col = _Color.xyz;


                float nVal = snoise(v.worldPos  * 1+ float3(0,0,_Time.y*.1));

               // col *= shadow;

                col *= t.xyz;
                col *= hsv(.0 + v.debug.y* .2, .8,1);
                //col *= 10*tex2D(_AudioMap, abs(nVal));
                //col *= .04;
                //col *= 10;
               // col *= v.worldPos.z* v.worldPos.z * v.worldPos.z;
              // col *= curlNoise(v.worldPos) * .1 + .8;
                col *= 10*nVal;

                //col *= 100000;
                return float4(col,1);
            }

            ENDCG
        }

// Shadow Pass
   Pass
    {
      Tags{ "LightMode" = "ShadowCaster" }


      Fog{ Mode Off }
      ZWrite On
      ZTest LEqual
      Cull Off
      Offset 1, 1
      CGPROGRAM

      #pragma target 4.5
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster
      #pragma fragmentoption ARB_precision_hint_fastest

            sampler2D _MainTex;
      #include "UnityCG.cginc"
      float DoShadowDiscard( float3 pos , float2 uv ){

                  float4 t = tex2D(_MainTex, float2(uv.yx));
                //float lookupVal =  length( v.uv - .5 );
                //if( t.a < .5){discard;}
         return   t.a;
      }

      #include "../../Chunks/ShadowDiscardFunction.cginc"
      ENDCG
    }
  
    }

    
}
