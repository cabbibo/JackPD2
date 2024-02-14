Shader "BibPit/Dragon"
{
        
    Properties {

    _AmountShown( "_AmountShown" , float)=1
      _AudioPow ("_AudioPow", float) = 2
      _AudioMultiplier ("_AudioMultiplier",float) =1000
      _ColorLookupXMult ("_ColorLookupXMult",float) =.1
      _ColorLookupY ("_ColorLookupY",float) =.1
       _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}

      
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _Color("Color", Color) = (1,1,1,1)
        
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


   sampler2D _MainTex;
   float _ColorLookupXMult;
   float _ColorLookupY;



            struct v2f { 
                float4 pos : SV_POSITION; 
                float3 nor : NORMAL;
                float3 vel :TEXCOORD0;
                float yVal : TEXCOORD1;
                float whichMesh : TEXCOORD2;
                float3 world : TEXCOORD3;
                float3 eye : TEXCOORD4;
                float match :TEXCOORD5;
                float2 uv :TEXCOORD6;
                float2 debug :TEXCOORD7;
                float3 tangent :TEXCOORD8;
                float3 col : TEXCOORD10;
            };
            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<Vert> _BaseVertBuffer;
            StructuredBuffer<int> _TriBuffer;

            samplerCUBE _CubeMap;

            #include "Assets/Shaders/Chunks/BibPit.cginc"

  float _AmountShown;

            int _NumVertsPerMesh;
            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;
                Vert v = _VertBuffer[_TriBuffer[vid]];
                int whichMesh = _TriBuffer[vid]/_NumVertsPerMesh;
                Vert b = _BaseVertBuffer[_TriBuffer[vid]%_NumVertsPerMesh];

                float2 debug = v.debug;
                o.debug = v.debug;
                 o.nor = v.nor;
                 o.col = b.vel;
                o.vel = v.vel;
                o.yVal = b.pos.z;
                o.world = v.pos;
                o.eye = normalize(_WorldSpaceCameraPos-v.pos);
                o.match = dot(v.nor, o.eye);
                o.tangent = v.tan;



                float3 fPos = v.pos + .01*v.nor * sampleAudio(o.yVal , N_ID(whichMesh));

             

                o.pos = mul (UNITY_MATRIX_VP, float4(fPos,1.0f));
               o.uv = v.uv;
                o.whichMesh = float( whichMesh ) + .01;
                return o;
            }
// Generic algorithm to desaturate images used in most game engines
float4 desaturate(float3 color, float factor)
{
	float3 lum = float3(0.299, 0.587, 0.114);
	float3 gray = dot(lum, color);
	return float4(lerp(color, gray, factor), 1.0);
}

            fixed4 frag (v2f v) : SV_Target
            {

              
                float3 nor = -cross(normalize(ddx(v.world)),normalize(ddy(v.world)));

                float m = dot( nor, v.eye);
                // sample the texture
                float3 col = 0;//v.col;//*1000;//float4( i.nor * .5 + .5 , 1);//tex2D(_MainTex, i.uv);

                float4 aCol = tex2D(_AudioMap, float2( v.col.x  + v.debug.x * .5 + length(v.world - v.tangent) * .03,0));
               // float4 cCol = tex2D( _ColorMap,v.debug.x * .5 + length(v.world - v.tangent) * .3 );
               
                float4 cCol = tex2D(_ColorMap, float2( v.debug.x * _ColorLookupXMult  + v.debug.y * .1,  _ColorLookupY));

                col = aCol * (cCol * .5 +.5);

                //col *= nor * .5+.5;
                col *= m* m + pow( saturate(1-m) , 3) * 5;

                col = v.col;//tex2D(_MainTex, float2( v.debug.x * _ColorLookupXMult  + v.debug.y * .1,  _ColorLookupY));
                col *= 1-m;
                col *= aCol * aCol * 10;
                col = v.col * (cCol.xyz * .8+ .2) * 2;//* (((normalize(v.vel) * .5 + .5) *4 * length(v.vel) * 10) * .3 + .8);
                col = v.nor * .5 + .5;

                col *= texCUBE( _CubeMap, reflect( v.eye, v.nor));
                col *=  2 *(cCol * .7+ .3);
                //col *= normalize(v.vel) * .5 + .5;
                col *= 3;

              //  col *= .5;
                col += .2;

                col = desaturate(col,.5);
                col *= _Color.xyz;

                if( length(v.col) == 0 ){

                }else{

                col *=  .3;
                col += (col * 1 + .8) * v.col;   
                }


                //col = length(v.vel) * 10;
                //col = v.debug.y;
                return float4(col,1);
            }

            ENDCG
        }

    }

    
        Fallback "Diffuse"
}