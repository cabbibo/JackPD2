Shader "audio/Fft2"
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
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 local : TEXCOORD2;
                float3 world : TEXCOORD4;
                float3 worldNor : TEXCOORD3;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _AudioMap;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.local = v.vertex.xyz;
                o.world = mul(unity_ObjectToWorld, float4(o.local,0.0f)).xyz;
     float3 n =  v.normal;//_NormBuffer[id/3];
        o.worldNor = normalize(mul (unity_ObjectToWorld, float4(n,0.0f)).xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

                float m = atan2( i.local.x , i.local.y );
                fixed4 col = tex2D(_AudioMap, float2( (i.local.x+.5) * 1, 0 ));


                if( i.uv.y  > length(col)*.5 ){
                    col = 0;
                }else{
                    col = col * col * col;
                   // col = 0;
                }


                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
