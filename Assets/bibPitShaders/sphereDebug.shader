Shader "Unlit/sphereDebug"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off
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
                float3 nor: TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.nor = normalize(v.vertex.xyz);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col =1;
                col.xyz = i.nor * .5 + .5;

                col.xyz *= .3;

                col.xyz += pow(sin( i.nor.y * 100),5) * float3(0,1,0);
                col.xyz += pow(sin( i.nor.x * 100),5) * float3(1,0,0);
                col.xyz += pow(sin( i.nor.z * 100),5) * float3(0,0,1);
                return col;
            }
            ENDCG
        }
    }
}
