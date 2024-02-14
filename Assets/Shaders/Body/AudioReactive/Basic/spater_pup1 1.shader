
Shader "IMMAT/SPATER1_pup"
{
    Properties {

  
       _TextureMap ("Texture", 2D) = "white" {}
       _PainterlyLightMap ("Painterly", 2D) = "white" {}
       _NormalMap ("Normal", 2D) = "white" {}
       _CubeMap( "Cube Map" , Cube )  = "defaulttexture" {}

      _ColorSize("_ColorSize", float ) = 0.5
      _ColorBase("_ColorBase", float ) = 0
      _OutlineColor("_OutlineColor", float ) = 0
      _OutlineAmount("_OutlineAmount", float ) = .16
      _PaintSize("_PaintSize", Vector ) = (1,1,1,1)
      _NormalSize("_NormalSize", Vector ) = (1,1,1,1)
      _NormalDepth("_NormalDepth", float ) = .4
       _GlobalColorSchemeID("_GlobalColorSchemeID", float ) = .4
       
       _ColorScheme ("_ColorScheme", 2D) = "white" {}
      
      
  }
    SubShader
    {
        
      



        Pass
        {

          Tags { "RenderType"="Opaque" }
          LOD 100

          Cull Off
          // Lighting/ Texture Pass
          Stencil
          {
            Ref 4
            Comp always
            Pass replace
            ZFail keep
          }

          Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM


            #include "../../../Chunks/struct16.cginc"

            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight


            #include "../../../Chunks/ShadowVertPassthrough.cginc"


            #include "../../../Chunks/PainterlyLight.cginc"
            #include "../../../Chunks/TriplanarTexture.cginc"
            #include "../../../Chunks/MapNormal.cginc"
            #include "../../../Chunks/Reflection.cginc"


            #include "../../../Chunks/SampleAudio.cginc"
      
            #include "../../../Chunks/ColorScheme.cginc"


            float _WhichColor;

            sampler2D _FullColorMap;
            float _ColorMapSection;

            float sdCapsule( float3 p, float3 a, float3 b, float r )
{
    float3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}



float _DiscardMultiplier;
float _BrightnessMultiplier;
            fixed4 frag (v2f v) : SV_Target
            {

                fixed shadow = UNITY_SHADOW_ATTENUATION(v,v.world) * .5 + .5;
                
                float3 nor = -cross(normalize(ddx(v.world)),normalize(ddy(v.world)));

                float3 n = normalize(nor);//MapNormal( v , v.uv * _NormalSize , _NormalDepth );
                float3 reflectionColor = Reflection( v.pos , n );

                float m = dot( n, _WorldSpaceLightPos0.xyz);
                float baseM = m;
                m =m;// saturate(( m +1 )/2);

                m *= shadow;

                m = saturate(m);

                m = 1-m;

              
               // o.vel = v.vel;



                float3 col  =0;// GetGlobalColor( m * _ColorSize  + _ColorBase );
            float globalCol  = GetGlobalColorWithID( .5 , 12 );
            col = globalCol;
                float3 p = Painterly( m, v.uv.xy * _PaintSize );


                float4 tex = tex2D(_TextureMap , v.uv.yx * float2( 1, 2.2) );


               //col.xyz *= p * .3+ p * r;
               ////col *= baseM;
               ////col *= 10.;
               //col.xyz *=   r.xyz * 2;
               /// col *= col;


               //col.yxz = p.xyz*tex * .6 + .4;


               //col = p;
               //col = r*audio * 15;
                col = col*p;

                
                float3 refl = normalize(reflect( v.eye,n ));
                float rM = saturate(dot(refl,_WorldSpaceLightPos0.xyz));
              //  col += col *pow(rM,5)*20;
                
               // float3 audio = SampleAudio(v.uv.x * .1 + p.x * .03 );

                float3 velocityColor = (normalize(v.vel) * .5 + .5) * length(v.vel) * .1 + (( n* .5 + .5) * .4);

               // col.xyz *= (audio *audio*10 + 1);
                col.xyz *= reflectionColor * 4;


              float3 colorMapCol =  tex2D(_FullColorMap , float2(m + length(v.vel) * .1 , _ColorMapSection)).xyz;
                
             //   float4  colorMapCol = tex2D(_TextureMap , float2(m + length(v.vel) * .1 , .4) );

                col.xyz =  colorMapCol * velocityColor*reflectionColor * 10;

                //col.xyz *= velocityColor;
               // float3 forward = mul((float3x3)unity_CameraToWorld, float3(0,0,1));
                //UNITY_MATRIX_IT_MV[2].xyz

                // TODO add noise
                float discardVal = abs(dot(  normalize(v.eye) , normalize(UNITY_MATRIX_IT_MV[2].xyz) )) + _DiscardMultiplier;//  sdCapsule( v.world, _WorldSpaceCameraPos, _WorldSpaceCameraPos  + v.eye , _DiscardMultiplier);//


               float normalizeDiscard = discardVal / _DiscardMultiplier;

              
                if( 1-discardVal < 0 ){
                  discard;
                }

                 //   float4 audio = SampleAudio(length(reflectionColor.xyz) * .05 + v.uv.x * .2) * 2;


                    float4 audio = SampleAudio( length(v.vel) * .01);
               // col  +=  (1-saturate(length(col.xyz)*10))* audio.xyz;

                //col.xyz = p * p * col;//m;//normalize(_WorldSpaceLightPos0.xyz) * .5+ .5 ;//m;//p;
                //col = shadow;


col *= _BrightnessMultiplier;
col *= audio * 10;


 if( 1-discardVal  < .1 * _DiscardMultiplier){

  float nVal =  (1-discardVal)/.1 * _DiscardMultiplier ;

                col = colorMapCol;
               }
//col = normalizeDiscard * .001;

                return float4(col,1);
            }

            ENDCG
        }



    
  
  
  
  }








}