Shader "Debug/normal12"
{    
  
  
    Properties {
       _PLightMap("Painterly Light Map", 2D) = "white" {}
    }


    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off





















        Pass
        {
                   Tags{ "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            // make fog work
            #pragma multi_compile_fogV
 #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

      #include "UnityCG.cginc"
      #include "AutoLight.cginc"
    float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}

        float _AmountShown;

        uniform sampler2D _PLightMap;
     struct Vert{
         float3 pos;
         float3 nor;
         float3 center;
         float2 uv;
         float baseVal;
         float totalPoints;
         float branchID;
         float2 debug;
     };

      float4x4 _World;

            struct v2f { 
                float4 pos : SV_POSITION; 
                float3 nor : NORMAL;
                float3 world : TEXCOORD1;
                float  timeCreated : TEXCOORD3;
                float2  uv: TEXCOORD2;
                LIGHTING_COORDS(5,6)
            };
            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;

            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;
                Vert v = _VertBuffer[_TriBuffer[vid]];

                float lerpVal = 0;

                lerpVal =  _AmountShown-v.branchID;
                lerpVal *= 10;
                lerpVal = saturate(lerpVal);
                
                float3 fPos = lerp( v.center, v.pos , lerpVal);
                fPos = mul(_World,float4(fPos,1.0f)).xyz;
                o.pos = mul (UNITY_MATRIX_VP, float4(fPos,1.0f));
                o.world = fPos;
                o.timeCreated = v.branchID;
                o.uv  = v.uv;

                
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                o.nor = v.nor;
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture
                fixed4 col = 1;//float4( i.nor * .5 + .5 , 1);//tex2D(_MainTex, i.uv);
            
              //fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.world) * .5 + .5;




              float m = 1-dot(_WorldSpaceLightPos0.xyz , v.nor);

                

                ///in frag shader;
                float atten = LIGHT_ATTENUATION(v);
                //m = 1-pow(-fern,.5);//*fern*fern;//pow( fern * fern, 1);
                //m = saturate( 1-m );

                //                m = (-m* atten);

                float4 p = tex2D( _PLightMap , v.uv * float2(1,3) );
                m = 1-((1-m)*atten);
                m *= 3;

                float4 fLCol = float4(1,0,0,0);


                float4 weights = 0;
                if( m < 1 ){
                    weights = float4(1-m , m , 0, 0);//lerp( p.x , p.y , m );
                    }else if( m >= 1 && m < 2){
                    weights = float4(0,1-(m-1) , (m-1) ,  0);
                    }else if( m >= 2 && m < 3){
                    weights = float4(0,0,1-(m-2) , (m-2) );
                    }else{
                    weights = float4(0,0,0 , 1);
                }



                fLCol = p.x * weights.x;
                fLCol += p.y * weights.y;
                fLCol += p.z * weights.z;
                fLCol += p.w * weights.w;
                fLCol = 1-fLCol;


 
                 col.xyz = fLCol;//  hsv( v.timeCreated  *2+ .3, .2,1) ;//tex2D(_MainTex, i.uv);
              // col.xyz = v.nor * .5 + .5;
                 //col *= atten;
                return col;
            }

            ENDCG
        }






































         Pass
    {
      Tags{ "LightMode" = "ShadowCaster" }


      Fog{ Mode Off }
      ZWrite On
      ZTest LEqual
      Cull Off
      Offset 1, 1
      CGPROGRAM

      #pragma target 4.5
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster
      #pragma fragmentoption ARB_precision_hint_fastest

      #include "UnityCG.cginc"
      sampler2D _MainTex;


     struct Vert{
         float3 pos;
         float3 nor;
         float3 center;
         float2 uv;
         float baseVal;
         float totalPoints;
         float branchID;
         float2 debug;
     };
      StructuredBuffer<Vert> _VertBuffer;
      StructuredBuffer<int> _TriBuffer;

      float _AmountShown;

      struct v2f {
        V2F_SHADOW_CASTER;
        float3 nor : NORMAL;
      };




float4 ShadowCasterPos (float3 vertex, float3 normal) {
  float4 clipPos;
    
    // Important to match MVP transform precision exactly while rendering
    // into the depth texture, so branch on normal bias being zero.
    if (unity_LightShadowBias.z != 0.0) {
    float3 wPos = vertex.xyz;
    float3 wNormal = normal;
    float3 wLight = normalize(UnityWorldSpaceLightDir(wPos));

  // apply normal offset bias (inset position along the normal)
  // bias needs to be scaled by sine between normal and light direction
  // (http://the-witness.net/news/2013/09/shadow-mapping-summary-part-1/)
  //
  // unity_LightShadowBias.z contains user-specified normal offset amount
  // scaled by world space texel size.

    float shadowCos = dot(wNormal, wLight);
    float shadowSine = sqrt(1 - shadowCos * shadowCos);
    float normalBias = unity_LightShadowBias.z * shadowSine;

    wPos -= wNormal * normalBias;

    clipPos = mul(UNITY_MATRIX_VP, float4(wPos, 1));
    }
    else {
        clipPos = UnityObjectToClipPos(vertex);
    }
  return clipPos;
}

float4x4 _World;
      v2f vert(appdata_base input, uint id : SV_VertexID)
      {
        v2f o;


          Vert v = _VertBuffer[_TriBuffer[id]];

    float lerpVal = _AmountShown;

    
    lerpVal =  _AmountShown-v.branchID;
    lerpVal *= 10;
    lerpVal = saturate(lerpVal);
    
    float3 fPos =  lerp( v.center, v.pos , lerpVal );

                fPos = mul(_World,float4(fPos,1.0f)).xyz;

        float4 position = ShadowCasterPos(fPos, v.nor * 0);
        o.pos = UnityApplyLinearShadowBias(position);
        return o;
      }

      float4 frag(v2f i) : COLOR
      {
        SHADOW_CASTER_FRAGMENT(i)
      }
      ENDCG
    }




























    }
}
