Shader "IMMAT/Debug/sdfTextureDebugger"
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 world : TEXCOORD1;
            };


            #include "Assets/Shaders/Chunks/sdfTextureSample.cginc"

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.world = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = 0;// tex2D(_MainTex, i.uv);


                float4 v = SampleSDF(i.world);

                col.xyz = v.x;//v.yzw * .5 + .5;//i.world;
                return col;
            }
            ENDCG
        }
    }
}
