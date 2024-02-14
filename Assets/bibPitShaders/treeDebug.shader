Shader "bibPit/treeDebug"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Assets/Shaders/Chunks/hsv.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 texcoord1 : TEXCOORD1;
                float3 texcoord2 : TEXCOORD2;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 texcoord1 : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 delta : TEXCOORD2;
                float life : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                o.delta = v.texcoord1-v.vertex.xyz;
                o.texcoord1 = v.texcoord1;
                o.life = v.texcoord2.z;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = i.uv.y ;//tex2D(_MainTex, i.uv);
                col.xyz = (normalize(i.delta.xyz) * .5 + .5 ) * hsv(i.life ,1,1);
                return col;
            }
            ENDCG
        }
    }
}
