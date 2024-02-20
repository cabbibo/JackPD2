Shader "BibPit/straightBlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale", Vector) = (1, 1,1,1)
    }


    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #include "Assets/Shaders/Chunks/snoise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _FrameTexture;

            float2 _Size;
            float2 _Offset;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 centeredUV = i.uv * _Size + _Offset + (1.0 - _Size) * 0.5;
                
                return tex2D(_MainTex, centeredUV);
            }
            ENDCG
        }
    }
}