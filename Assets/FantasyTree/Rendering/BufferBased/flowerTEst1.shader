Shader "Debug/leaf16Test2"
{




        Properties {
    _Size ("Size", Float) = 0.1
    _Offset("Offset",Float) = .5
    _SpriteTex ("tex" , 2D )  = "white" {}
    _FallingAmount("falling amount" , Range(0,1)) = .5

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

      float hash( float n ){
        return frac(sin(n)*43758.5453);
      }

    float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}

        float _AmountShown;
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



            struct v2f { 
                float4 pos : SV_POSITION; 
                float3 nor : NORMAL;
                float3 world : TEXCOORD1;
                float  timeCreated : TEXCOORD3;
                float2  uv : TEXCOORD4;
                float2  uv2 : TEXCOORD5;
                
             
                LIGHTING_COORDS(5,6)
            };
            float4 _Color;
            float _Size;

          sampler2D _SpriteTex;
            StructuredBuffer<Vert> _VertBuffer;
            
           

          float _Offset;  
          float _FallingAmount;
          float4x4 _World;
            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;





                int bID = vid / 6;
                int alternate = vid % 6;



                Vert v = _VertBuffer[bID];

                float lerpVal = 0;


                float3 fwd = UNITY_MATRIX_VP[2].xyz;
                float3 up = v.nor;
                float3 left = normalize(cross(fwd,up));


                float3 centerPos = v.pos;

                


                float3 p1 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .1 * _Size - left * .25 * _Size;
                float3 p2 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .1 * _Size + left * .25 * _Size;
                float3 p3 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .6 * _Size - left * .25 * _Size;
                float3 p4 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .6 * _Size + left * .25 * _Size;

                float3 fPos;
                float2 fUV;
                if( alternate == 0 ){
                    fPos = p1;
                    fUV = float2(0,0);
                }else if( alternate == 1){
                    fPos = p2;
                    fUV = float2(1,0);
                }else if( alternate == 2){
                    fPos = p4;
                    fUV = float2(1,1);
                }else if( alternate == 3){
                    fPos = p1;
                    fUV = float2(0,0);
                }else if( alternate == 4){
                    fPos = p4;
                    fUV = float2(1,1);
                }else{
                    fPos = p3;
                    fUV = float2(0,1);
                }


                lerpVal =  (1-_AmountShown)-v.branchID * .9;
                lerpVal = lerpVal;
                lerpVal *= 10;
                lerpVal = saturate(lerpVal);
               
                fPos = lerp( v.pos, fPos , 1-lerpVal);
                
                fPos = mul(_World,float4(fPos,1.0f)).xyz;

                float falling = _FallingAmount - v.branchID * .9;//hash(bID) * .9;
                falling = saturate(falling*10);

                fPos = lerp( fPos , float3(fPos.x + sin( falling * 12 +hash(bID * 402) * 1012) * .1 , hash(bID) * .1 , fPos.z + cos(falling * 10 + hash(bID * 20) * 2012) * .3 ), falling);

                o.uv = fUV;

                float col = hash( float(bID * 10));
                float row = hash( float(bID * 20));
                o.uv2 = (fUV + floor(6 * float2( col , row )))/6;
                //float3 fPos = lerp( v.center, v.pos , lerpVal);
                o.pos = mul (UNITY_MATRIX_VP, float4(fPos,1.0f));
                o.world = fPos;
                o.timeCreated = v.branchID;

                
                
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                o.nor = v.nor;
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            { 

              float uvL = length(v.uv - .5);
              if(uvL > .5){
                discard;
              }
                // sample the texture
                fixed4 col = 1;//float4( i.nor * .5 + .5 , 1);//tex2D(_MainTex, i.uv);
                float atten = LIGHT_ATTENUATION(v);

                float4 spritCol = tex2D(_SpriteTex,v.uv2);
                if( spritCol.a < .1){discard;}
                //col.xyz = spritCol.xyz * .5 + .5;// dot( _WorldSpaceLightPos0.xyz, v.nor) *1 + 1;// *spritCol.xyz *  hsv( v.timeCreated + uvL * .2  + .1 , .8,.9) ;//tex2D(_MainTex, i.uv);
                
                col.xyz *= hsv(v.timeCreated * .2 + .75,.5,1);
                col *= atten;

                col *= v.timeCreated;

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

      float _AmountShown;
      float _Size;
      sampler2D _SpriteTex;


float4x4 _World;
      struct v2f {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
        float2 uv2 : TEXCOORD2;
        float3 nor : NORMAL;
      };
      float hash( float n ){
        return frac(sin(n)*43758.5453);
      }




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

  float _Offset;
  float _FallingAmount;
      v2f vert(appdata_base input, uint vid : SV_VertexID)
      {
        v2f o;


       




                int bID = vid / 6;
                int alternate = vid % 6;



                Vert v = _VertBuffer[bID];

                float lerpVal = 0;


                float3 fwd = UNITY_MATRIX_VP[2].xyz;
                float3 up = v.nor;
                float3 left = normalize(cross(fwd,up));


                float3 centerPos = v.pos;

                


                float3 p1 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .1 * _Size - left * .25 * _Size;
                float3 p2 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .1 * _Size + left * .25 * _Size;
                float3 p3 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .6 * _Size - left * .25 * _Size;
                float3 p4 = v.pos + v.nor *  v.debug.x * _Size * _Offset + up * .6 * _Size + left * .25 * _Size;

                float3 fPos;
                float2 fUV;
                if( alternate == 0 ){
                    fPos = p1;
                    fUV = float2(0,0);
                }else if( alternate == 1){
                    fPos = p2;
                    fUV = float2(1,0);
                }else if( alternate == 2){
                    fPos = p4;
                    fUV = float2(1,1);
                }else if( alternate == 3){
                    fPos = p1;
                    fUV = float2(0,0);
                }else if( alternate == 4){
                    fPos = p4;
                    fUV = float2(1,1);
                }else{
                    fPos = p3;
                    fUV = float2(0,1);
                }


                lerpVal =  (1-_AmountShown)-v.branchID * .9;
                lerpVal = lerpVal;
                lerpVal *= 10;
                lerpVal = saturate(lerpVal);
               
                fPos = lerp( v.pos, fPos , 1-lerpVal);
                
                fPos = mul(_World,float4(fPos,1.0f)).xyz;

                float falling = _FallingAmount - v.branchID * .9;//hash(bID) * .9;
                falling = saturate(falling*10);

                fPos = lerp( fPos , float3(fPos.x + sin( falling * 12 +hash(bID * 402) * 1012) * .1 , hash(bID) * .1 , fPos.z + cos(falling * 10 + hash(bID * 20) * 2012) * .3 ), falling);

                o.uv = fUV;

                float col = hash( float(bID * 10));
                float row = hash( float(bID * 20));
                o.uv2 = (fUV + floor(6 * float2( col , row )))/6;
                //float3 fPos = lerp( v.center, v.pos , lerpVal);
              

        float4 position = ShadowCasterPos(fPos,normalize(v.nor));
        o.pos = UnityApplyLinearShadowBias(position);
        return o;
      }

      float4 frag(v2f v) : COLOR
      {            float4 spritCol = tex2D(_SpriteTex,v.uv2);
                if( spritCol.a < .1){discard;}
                
        SHADOW_CASTER_FRAGMENT(v)
      }
      ENDCG
    }




























    }
}
