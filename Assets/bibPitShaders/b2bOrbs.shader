Shader "BibPit/b2bOrbs"
{

    Properties {
         _AudioMultiplier("_AudioMultiplier",float) = 1
        _AudioPow("_AudioPower",float) = 1
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
                float3 world : TEXCOORD0; 
                float3 vel : TEXCOORD1;
                float2 debug: TEXCOORD2;
            };

            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;


            #include "Assets/Shaders/Chunks/BibPit.cginc"
            #include "Assets/Shaders/Chunks/hsv.cginc"


            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;
                Vert v = _VertBuffer[_TriBuffer[vid]];
                o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));
                o.nor = v.nor;
                o.vel = v.vel;
                o.debug = v.debug;
                o.world = v.pos;
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {

                float3 nor = -cross(normalize(ddx(v.world)),normalize(ddy(v.world)));
                // sample the texture

                float4 aCol = sampleAudio( v.debug.y * .1 + dot( nor, normalize(v.vel)) * .2 + .4,N_ID(v.debug.x ));
                fixed3 col = aCol *v.debug.y * 4* tex2D(_ColorMap , v.debug.y * .1 + N_ID(v.debug.x ) );//aCol.xyz;// hsv(v.debug.y * .3 ,1, 1);//aCol.xyz * length(v.vel);// ( normalize(v.vel) * .5 + .5 );;//hsv( v.debug.x , 1,1 );// float3( v.debug.x , v.debug.y , 0.4 );//float4( nor * .5 + .5 , 1);//tex2D(_MainTex, i.uv);
               

                
               
                return float4(col,1);
            }

            ENDCG
        }
    }
}