Shader "BibPit/Tenky"
{
        
    Properties {

  
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
                float3 col :TEXCOORD0;
                float yVal : TEXCOORD1;
                float whichMesh : TEXCOORD2;
                float3 world : TEXCOORD3;
                float3 eye : TEXCOORD4;
                float match :TEXCOORD5;
                float2 uv :TEXCOORD6;
            };
            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<Vert> _BaseVertBuffer;
            StructuredBuffer<int> _TriBuffer;

            #include "Assets/Shaders/Chunks/BibPit.cginc"


            int _NumVertsPerMesh;
            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;
                Vert v = _VertBuffer[_TriBuffer[vid]];
                int whichMesh = _TriBuffer[vid]/_NumVertsPerMesh;
                Vert b = _BaseVertBuffer[_TriBuffer[vid]%_NumVertsPerMesh];
                 o.nor = v.nor;
                o.col = b.vel;
                o.yVal = b.pos.z;
                o.world = v.pos;
                o.eye = normalize(_WorldSpaceCameraPos-v.pos);
                o.match = saturate(dot(v.nor, -o.eye));

                float3 fPos = v.pos + .01*v.nor * sampleAudio(o.yVal , N_ID(whichMesh));
                o.pos = mul (UNITY_MATRIX_VP, float4(fPos,1.0f));
               o.uv = v.uv;
                o.whichMesh = float( whichMesh ) + .01;
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture
                float3 col = v.col;//*1000;//float4( i.nor * .5 + .5 , 1);//tex2D(_MainTex, i.uv);

                float4 aCol = tex2D(_AudioMap , float2(v.col.x  *1 +v.uv.y * 1 + v.match* 1 ,0));
                col = (1-v.match)  * aCol.xyz * v.col;
                col = v.col * (1-v.match) * aCol.xyz * 5;

                col = v.col;

             //   col = v.col;
                return float4(col,1);
            }

            ENDCG
        }

    }

    
        Fallback "Diffuse"
}