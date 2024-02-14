Shader "Unlit/playbackTest2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ID("_ID",float) = 0
        _AudioMultiplier("_AudioMultiplier",float) =1
        _AudioPow("_AudioPow",float) =1
    
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
    Cull Off
    ZWrite Off
    Blend One One // Additive

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
      


#include "Assets/Shaders/Chunks/BibPit.cginc"



            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {

               int id = int(v.uv.y);
                // sample the texture


                float4 aVal = sampleAudio(v.uv.x , v.uv.y );
                fixed4 col =0;//sampleAudio(i.uv.x,i.uv.y);

                col = aVal * float4(.3,.7,1,1);
                return col;
            }
            ENDCG
        }
    }
}
