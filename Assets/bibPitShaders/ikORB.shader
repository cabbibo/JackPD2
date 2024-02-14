Shader "BibPit/ikOrbs"
{

    Properties {
         _AudioMultiplier("_AudioMultiplier",float) = 1
        _AudioPow("_AudioPower",float) = 1
        _AudioLookupSizeMultiplier("_AudioLookupSizeMultiplier",float) = 1
        
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
                float3 eye : TEXCOORD3;
            
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
                o.eye = normalize(_WorldSpaceCameraPos-v.pos);
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {

                float3 nor = -cross(normalize(ddx(v.world)),normalize(ddy(v.world)));
                // sample the texture

                float nID = N_ID(v.debug.x );

            float m = dot( v.eye, nor );
                float4 aCol = sampleAudio( (v.debug.y * .01 + length(v.vel) * .01 + m * .01   + .4) * _AudioLookupSizeMultiplier,nID);
                fixed3 col = aCol *saturate(pow(v.debug.y,.5) * .3) * 4* tex2D(_ColorMap , v.debug.y * .1 + v.debug.x / 100 ) * hsv( nID,.2,1);//aCol.xyz;// hsv(v.debug.y * .3 ,1, 1);//aCol.xyz * length(v.vel);// ( normalize(v.vel) * .5 + .5 );;//hsv( v.debug.x , 1,1 );// float3( v.debug.x , v.debug.y , 0.4 );//float4( nor * .5 + .5 , 1);//tex2D(_MainTex, i.uv);
               //col = m;
               if( length(col) < .4 ){
                discard;
               }

                
               
                return float4(col,1);
            }

            ENDCG
        }
    }
}