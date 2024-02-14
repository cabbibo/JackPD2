Shader "BibPit/Post"
{
    Properties
    {
        _Multiplier("_Multiplier", Range(0, 1)) = 1
        _Contrast("_Contrast", Range(0, 1)) = 1
        _Saturation("_Saturation", Range(0, 1)) = 1
    }


    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
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
            };



            float _Multiplier;
            float _Contrast;
            float _Saturation;

            sampler2D _MainTex;
            float2 _Size;
            float2 _Offset;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


float3 AdjustContrast(float3 color, float contrast)
{
    return (color - 0.5) * contrast + 0.5;
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