Shader "IMMAT/ClothObject"
{
    Properties {
        _BumpMap("_BumpMap", 2D) = "white" {}
        _ColorMap("_ColorMap", 2D) = "white" {}
        _ColorMapStart("_ColorMapStart",float) = 0
        _ColorMapSize("_ColorMapSize",float) = 0
        _Multiplier("_Multiplier",float) = 1
    }
    SubShader
    {
        
        
        Pass
        {

        Tags { "RenderType"="Transparent"  "Queue"="Transparent"}
        LOD 100    
       // Tags {Queue = Transparent}
    Blend One One
   ZWrite Off

        Cull Front

          Tags{ "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            #include "../../Chunks/Struct16.cginc"
            #include "../../Chunks/hsv.cginc"
            #include "UnityLightingCommon.cginc"
            sampler2D _MainTex;
            sampler2D _ColorMap;

            int _Steps;
            float _ColorMapStart;
            float _ColorMapSize;

            sampler2D _AudioMap;

            float _Multiplier;

            struct v2f { 
              float4 pos : SV_POSITION; 
              float3 nor : NORMAL;
              float2 uv :TEXCOORD0; 
              float3 worldPos :TEXCOORD1;
              float2 debug : TEXCOORD3;
              float3 eye : TEXCOORD4;
              float3 vel :TEXCOORD10;
              float3 tan :TEXCOORD11;
             LIGHTING_COORDS(5,6) 
                 half3 tspace0 : TEXCOORD7; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD8; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD9; // tangent.z, bitangent.z, normal.z
            };
            float4 _Color;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;

            sampler2D _BumpMap;
            
            float4 _BumpMap_ST;
            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;

                UNITY_INITIALIZE_OUTPUT(v2f, o);
                Vert v = _VertBuffer[_TriBuffer[vid]];
                o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));

                o.nor = v.nor;
                o.uv = TRANSFORM_TEX(v.uv, _BumpMap );
                o.worldPos = v.pos;
                o.debug = v.debug;
                o.vel = v.vel;
                o.tan = v.tan;
                o.eye = v.pos - _WorldSpaceCameraPos;


                half3 wNormal = v.nor;//UnityObjectToWorldNormal(normal);
                half3 wTangent = v.tan;//UnityObjectToWorldDir(tangent.xyz);
                half3 wBitangent = normalize(cross(wNormal, wTangent));// * tangentSign;
                // output the tangent space matrix
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);

                //UNITY_TRANSFER_LIGHTING(o,o.worldPos);


                return o;
            }

   // normal map texture from shader properties

            fixed4 frag (v2f v) : SV_Target
            {

                      // sample the normal map, and decode from the Unity encoding
                half3 tnormal = UnpackNormal(tex2D(_BumpMap, v.uv));
                // transform normal from tangent to world space
                half3 worldNormal;
                worldNormal.x = dot(v.tspace0, tnormal);
                worldNormal.y = dot(v.tspace1, tnormal);
                worldNormal.z = dot(v.tspace2, tnormal);

                float3 nor = -cross(normalize(ddx(v.worldPos)),normalize(ddy(v.worldPos)));

                worldNormal = nor;
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos);
                float val = dot( worldNormal , _WorldSpaceLightPos0.xyz);

                         // rest the same as in previous shader
         half3 worldViewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));
         half3 worldRefl = reflect(-worldViewDir, worldNormal);
         half4 skyData =UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);
         half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR);
//

    float lookup = dot( worldViewDir , worldNormal );
                float3 col = skyColor * tex2D(_ColorMap,v.uv.x *_ColorMapSize + _ColorMapStart);// + worldNormal* .2+ .3;//UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldNormal);///worldNormal * .5 + .5;//skyColor;//tex2D(_ColorMap, val * _ColorMapSize + _ColorMapStart ) * val;

               // col = v.debug.x *v.debug.x * v.debug.x* 3000 * col;




                float3 aCol = tex2D(_AudioMap, v.debug.x ).xyz;

                if( length(aCol) < abs(v.uv.y-.5)*2){
                 //   discard;
                }


            float vOff= abs( v.pos.z - v.vel.z) * 1;
                //col =  tex2D(_AudioMap, vOff * .1).xyz * pow( vOff ,10) * .00001;//col;//col*aCol*_Multiplier;


        float3 tCol = tex2D( _ColorMap , float2(v.nor.z ,0)).xyz;

        col = col *1000 *(normalize(v.tan)  * .5 + .5 ) * length( v.tan) * tCol;// normalize( v.pos - v.vel);
               // col = v.nor + 10000;

                return float4(col,length(col));
            }

            ENDCG
        }

// Shadow Pass
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
      #include "../../Chunks/Shadow16.cginc"
      ENDCG
    }
    


  
    }
}
