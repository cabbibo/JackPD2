﻿Shader "IMMAT/Basic/Shadows/BasicColorWithShadow"
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
            };
            float4 _Color;
            float _HueStart;

            sampler2D _AudioMap;
            sampler2D _FullColorMap;
            float _ColorMapSection;

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

    float _OSCID;
    float _OSCValue;

            fixed4 frag (v2f v) : SV_Target
            {
                float3 col = _Color.xyz;

                float3 aColor = tex2D(_AudioMap , v.uv.x).xyz;

                if( abs(v.uv.y - .5) *(1-_OSCValue) >length(aColor)){
                  //  discard;
                }

                
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos) * .5 + .5;

                //col = tex2D(_FullColorMap , float2( v.uv.x * .1 + _OSCID, _ColorMapSection)) *aColor * _OSCValue;
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
         return  1;// 1-length( uv - .5 );
      }

      #include "../../Chunks/ShadowDiscardFunction.cginc"
      ENDCG
    }
  


    }

    
}
