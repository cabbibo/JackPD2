Shader "BibPit/displayShader"
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
                
                float4 frameColor = tex2D(_FrameTexture, i.uv);
                
                float n = snoise(float3(i.uv * float2(10,1),_Time.y * .2));
                float frameVal = abs(cos(frameColor.r * frameColor.r  * 2 + n));
                frameVal *= frameVal * frameVal;
                
                
                float4 mainTextureR = tex2D(_MainTex, centeredUV + frameVal * .001);
                float4 mainTextureG = tex2D(_MainTex, centeredUV+ frameVal * .0015);
                float4 mainTextureB = tex2D(_MainTex, centeredUV+ frameVal * .002);

                
                float4 color = float4(mainTextureR.r, mainTextureG.g, mainTextureB.b, 1);

           

                return lerp( color , 1-color, frameVal * frameVal * frameVal*frameVal * .2) * saturate(frameColor * frameColor * 10);// saturate(frameVal);
               // return tex2D(_MainTex, centeredUV);
            }
            ENDCG
        }
    }
}