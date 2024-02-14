Shader "audio/bopShader"
{
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off

          Tags{ "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            // make fog work
            #pragma multi_compile_fogV
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "UnityLightingCommon.cginc"

            #include "../../Chunks/Struct16.cginc"
            #include "../../Chunks/hsv.cginc"

            sampler2D _MainTex;
            sampler2D _ColorMap;

            struct v2f { 
              float4 pos : SV_POSITION; 
              float3 nor : NORMAL;
              float2 uv :TEXCOORD0; 
              float3 worldPos :TEXCOORD1;
              float2 debug : TEXCOORD3;
              float3 eye : TEXCOORD4;
             LIGHTING_COORDS(5,6) 
              float3 vel : TEXCOORD7;
              float3 tan : TEXCOORD8;
            };
            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;

            sampler2D _AudioMap;
            float _AudioTime;
            float _AudioID;

            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;

                UNITY_INITIALIZE_OUTPUT(v2f, o);
                Vert v = _VertBuffer[_TriBuffer[vid]];

                int base = vid/3;
                base *=3;
                Vert v1 = _VertBuffer[_TriBuffer[base+0]];
                Vert v2 = _VertBuffer[_TriBuffer[base+1]];
                Vert v3 = _VertBuffer[_TriBuffer[base+2]];
                o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));




                o.nor = normalize(cross(v1.pos - v2.pos, v1.pos - v3.pos)*1000);// v.nor;
                o.uv = v.uv;
                o.worldPos = v.pos;
                o.debug = v.debug;
                o.vel = v.vel;
                o.eye = v.pos - _WorldSpaceCameraPos;
                o.tan = v.tan;


                UNITY_TRANSFER_LIGHTING(o,o.worldPos);

                return o;
            }



            fixed4 frag (v2f v) : SV_Target
            {


                
                float3 nor =v.nor;// -cross(normalize(ddx(v.world)),normalize(ddy(v.world)));
                // sample the texture
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos);
                float3 amb = ShadeSH9(half4(nor, 1));
                //fixed shadow = LIGHT_ATTENUATION(v) ;
                float3 col = v.nor * .5 + .5;// _LightColor0.xyz;

                col = length(v.vel) * 30 * v.debug.x*v.debug.x;
                col *= shadow * .9 + .1;
                col *= v.tan * 10 + .3;

                float3  a = tex2D(_AudioMap, float2((1-v.debug.y) * .1, _AudioTime)).xyz;
                col *= 400*a*a+.1;

                col *= hsv(_AudioID * .04 + .5, .5,1);


         half3 worldViewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));
         half3 worldRefl = reflect(-worldViewDir, nor);
         half4 skyData =UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
         half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR);
         col = 1*skyColor;


                return float4(col,1);
            }

            ENDCG
        }


Pass {
			Tags {
				"LightMode" = "ForwardAdd"
			}
Blend One One


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
            #include "UnityLightingCommon.cginc"

            sampler2D _MainTex;
            sampler2D _ColorMap;

            struct v2f { 
              float4 pos : SV_POSITION; 
              float3 nor : NORMAL;
              float2 uv :TEXCOORD0; 
              float3 worldPos :TEXCOORD1;
              float2 debug : TEXCOORD3;
              float3 eye : TEXCOORD4;
             LIGHTING_COORDS(5,6) 
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


                UNITY_TRANSFER_LIGHTING(o,o.worldPos);

                return o;
            }



            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture
                //fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos) * .5 + .5;
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos);
                float3 col = _LightColor0.xyz;//_Color.xyz;
                col = _LightColor0;
                col *= shadow;
                return float4(col,1);
            }

            ENDCG
		}
    // SHADOW PASS

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

      #include "UnityCG.cginc"

      float DoShadowDiscard( float3 pos , float2 uv ){
         return   1-length( uv - .5 );
      }

      #include "../../Chunks/Shadow16.cginc"
      ENDCG
    }
  
    }
}
