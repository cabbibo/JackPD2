Shader "BibPit/motes"
{
    
    Properties {

      _MainTex ("Texture", 2D) = "white" {}
  
      _AudioPow ("_AudioPow", float) = 2
      _AudioMultiplier ("_AudioMultiplier",float) =1000
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
            #pragma target 4.5
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #include "Assets/Shaders/Chunks/BibPit.cginc"
            #include "Assets/Shaders/Chunks/hsv.cginc"
            #include "Assets/Shaders/Chunks/hash.cginc"


              struct Vert{
      float3 pos;
      float3 vel;
      float3 nor;
      float3 tan;
      float2 uv;
      float2 debug;
    };


            struct v2f { 
                float4 pos : SV_POSITION; 
                float3 nor : NORMAL;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD2;
                float2 debug: TEXCOORD1;
            };
            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;

            sampler2D _MainTex;

            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;
                Vert v = _VertBuffer[_TriBuffer[vid]];
                o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));
                o.nor = v.nor;
                o.uv = v.uv;
                o.uv2.x = v.uv.x /6 + floor( hash(v.debug.x *101) * 6 )/6;
                o.uv2.y = v.uv.y /6 + floor( hash(v.debug.x *11) * 6 )/6;
                o.debug = v.debug + float2(0.1,.1);

                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture

                float3 col = tex2D(_MainTex, v.uv2);

                float l = length(v.uv-.5);
                if( col.x > .9){
                    discard;
                }
           
                col.xy = v.uv;

                float val = v.debug.x % _NumStems;
                val = N_ID(v.debug.x);
                col = sampleAudio(l * .04 + sin(v.debug.x) * .2+.2 +length(col) * .01  , val);//hsv(val, 1,1);

                col *= tex2D(_ColorMap,val);

                if( length(col) < .1 ){
                //    discard;
                }
                return float4(col,1);
            }

            ENDCG
        }

    }

    
        Fallback "Diffuse"
}