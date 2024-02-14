﻿Shader "Scenes/KelpScene/kelpTip"
{
    Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _MainTex ("Texture", 2D) = "white" {}
    _ColorMap ("Color Map", 2D) = "white" {}
    _HueStart ("HueStart", Float) = 0

    _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}

  }
    SubShader
    {
        
        Pass
        {
Tags { "RenderType"="Opaque" }
        LOD 100

        Cull Off

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
    


            #include "../../Chunks/Struct16.cginc"

            sampler2D _MainTex;
            sampler2D _ColorMap;
            sampler2D _AudioMap;

      samplerCUBE _CubeMap;


            struct v2f { 
              float4 pos : SV_POSITION; 
              float3 nor : NORMAL;
              float2 uv :TEXCOORD0; 
              float3 worldPos :TEXCOORD1;
              float3 vel :TEXCOORD5;
              float2 debug :TEXCOORD3;
              float id :TEXCOORD4;
              UNITY_SHADOW_COORDS(2)
            };
            float4 _Color;
            float _HueStart;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;

            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;

        UNITY_INITIALIZE_OUTPUT(v2f, o);
                Vert v = _VertBuffer[_TriBuffer[vid]];
                o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));


                o.nor = v.nor;
                o.uv = v.uv;
                o.vel = v.vel;
                o.worldPos = v.pos;
                o.debug = v.debug;
                o.id = vid / 12;


        UNITY_TRANSFER_SHADOW(o,o.worldPos);

                return o;
            }

      float DoShadowDiscard( float3 pos , float2 uv , float3 nor ){
        float v = dot(normalize(_WorldSpaceLightPos0.xyz), normalize(nor));
        return v;//sin( uv.y * 100 + _Time.y);
      }

            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture
                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.worldPos) * .5 + .5;
                float val = -dot(normalize(_WorldSpaceLightPos0.xyz),normalize(v.nor));// -DoShadowDiscard( i.worldPos , i.uv , i.nor );

                 float4 tCol = tex2D(_MainTex, v.uv );
                 float vL = length(v.uv-.5) ;
                 if( length( tCol ) < .1){ discard; }

                 float4 cCol = tex2D(_ColorMap,sin( v.id) * .1 + _Time.y);

                fixed4 col = 1;
                col.xyz =  cCol;//cCol;//match;//1;//aCol * aCol * 2 * (normalize(v.vel) *  .5 + .5) * clamp(length(v.vel) * 30, 0 ,1);//match;//saturate(match+.5)*1.1*tCol*tex2D(_ColorMap , float2( length( tCol) * .1 + sin(vL*10 + length(tCol)*10 - _Time.y*10  * sin(v.id/300)) * .04 + sin(v.id/1000) * .2+  _HueStart   + match *.2, 0) );//saturate(((_Time-v.debug.y) * 1 )) *  tex2D(_ColorMap , float2( length( tCol) * length( tCol ) * .1  + _HueStart , 0) )  * tCol* tCol;//* 20-10;//*tCol* lookupVal*4;//* 10 - 1;
                if( vL > .3){ col = 0;}
                  //if( v.debug.x > .5 ){ col =float4(1,0,0,1);}
                
                return col;
            }

            ENDCG
        

        }

                  // SHADOW PASS

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

      float DoShadowDiscard( float3 pos , float2 uv ){
        // return 1;//float lookupVal =  max(min( uv.y * 2,( 1- uv.y ) ) * 1.5,0);//2 * tex2D(_MainTex,uv * float2(4 * saturate(min( uv.y * 4,( 1- uv.y ) )) ,.8) + float2(0,.2));
         // float4 tCol = tex2D(_MainTex, uv *   float2( 6,(lookupVal)* 1 ));
                          float4 tCol = tex2D(_MainTex, uv );
                          return length( tCol) * .3;
         // if( ( lookupVal + 1.3) - 1.2*length( tCol ) < .5 ){ return 0;}else{return 1;}
      }

      #include "../../Chunks/ShadowDiscardFunction.cginc"
      ENDCG
    }
  
    




    }



    Fallback "Diffuse"
}