Shader "FantasyTree/Debug"
{
    Properties
    {
        
    _AmountShown ("AmountShown", Range (0, 1)) = .5
    
    _FallingAmount("falling amount" , Range(0,1)) = .5

    [Toggle] _FadeFromTop("fadeFromTop", Float) = 0
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
                float3 data1 : TEXCOORD1;
                float3 data2 : TEXCOORD2;
                float2 data3 : TEXCOORD3;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 data1 : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _AmountShown;
            float _FadeFromTop;


            float3 lerpUp( float timeInBranch, float lerp){

               float lerpVal = lerp;

                
                lerpVal =  (1-lerp)-timeInBranch * .9;
                lerpVal = lerpVal;
                lerpVal *= 9;
                lerpVal = saturate(lerpVal);

                return lerpVal;

            }

            float3 lerpDown( float timeInBranch, float lerp){

               float lerpVal = lerp;

                
                lerpVal =  (1-lerp)-timeInBranch * .9;
                lerpVal = lerpVal;
                lerpVal *= 9;
                lerpVal = saturate(lerpVal);

                return 1-lerpVal;

            }

            v2f vert (appdata v)
            {
                v2f o;

                o.data1 = v.data1;


                float3 fPos = lerp( v.data1.xyz, v.vertex.xyz , saturate(abs(-_FadeFromTop+lerpDown(1-_AmountShown, v.data2.z))));
                o.vertex = UnityObjectToClipPos(float4(fPos,1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                
                
                
                return o;
                
            }



            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = float4(i.data1,1);
                return col;
            }
            ENDCG
        }
    }
}
