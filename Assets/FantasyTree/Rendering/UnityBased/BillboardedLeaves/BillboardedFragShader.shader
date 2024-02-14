Shader "FantasyTree/BillboardedFragShader"
{




        Properties {
    _SizeMultiplier ("SizeMultiplier", Float) = 1
    _SpriteSize ("SpriteSize", Int) = 6

    _SpriteTex ("tex" , 2D )  = "white" {}
    _BaseColor ("BaseColor" , Color )  =(1,1,1,1)
    _TipColor  ("TipColor" , Color )  = (1,1,1,1)
    _ShadowStrength("_ShadowStrength" , Range(0,1)) = .5
    _AmountShown("AmountShown" , Range(0,1)) = .5
    _FallingAmount("falling amount" , Range(0,1)) = .5
    [Toggle(WORLD_NORMAL)] _RandomNormal("RandomNormal", Float) = 0

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

            // making it so that we are going
            // to do our own lighting
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
#pragma shader_feature WORLD_NORMAL
      #include "UnityCG.cginc"
      #include "AutoLight.cginc"



    // little randomness funciton
      float hash( float n ){
        return frac(sin(n)*43758.5453);
      }


    // hue saturation value function
    float3 hsv(float h, float s, float v){
      return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
        h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
    }

     
    


            struct v2f { 
                float4 pos        : SV_POSITION; 
                float3 nor          : NORMAL;
                float3 world        : TEXCOORD1;
                float  timeCreated  : TEXCOORD3;
                float2 uv           : TEXCOORD4;
                float2 uv2          : TEXCOORD5;
                //LIGHTING_COORDS(5,6)
                SHADOW_COORDS(7)
            };

          float _AmountShown;
          float _FallingAmount;
          float4 _Color;
          float _SizeMultiplier;
          float _ShadowStrength;
          float4 _BaseColor;
          float4 _TipColor;


          sampler2D _SpriteTex;
          int _SpriteSize;
            


            
        // We use this value to blend every
        // vert from its center position
        // to its final position, based on 
        // how much of it should be 'show'
        // so it looks like its animating in!
        float3 lerpDown( float timeInBranch, float lerp){

            float lerpVal = lerp;

            lerpVal =  (1.1-lerp)-timeInBranch * .9;
            lerpVal = lerpVal;
            lerpVal *= 9;
            lerpVal = saturate(lerpVal);

            return 1-lerpVal;

        }
        

        
            v2f vert (  appdata_full v  )
            {
                v2f o;


                float3 worldNor = normalize(mul( unity_ObjectToWorld, float4(v.normal,0)).xyz);

                // Getting our left and up directions 
                // for our billboarded quad

                #ifdef WORLD_NORMAL
                  float3 left = worldNor;//UNITY_MATRIX_V[0].xyz;
                  float3 up = normalize(cross(UNITY_MATRIX_V[2].xyz,left));
                #else
                  float3 up = UNITY_MATRIX_V[0].xyz;
                  float3 left = UNITY_MATRIX_V[1].xyz;;
                #endif
                // we stored the center of our quad
                // as a texture coordinate in the mesh
                float3 centerPos =  mul(unity_ObjectToWorld,float4(v.texcoord1.xyz,1.0f)).xyz;


                // likewise we also stored our scale 
                // in one of the texture coordinates
                float scale = v.texcoord2.y;


                // Setting up the final position
                float3 fPos = centerPos;  
                

                float worldScale = length(mul(unity_ObjectToWorld,float4(1,0,0,0)).xyz);

                // making it so our single point turns into
                // a quad using the billboarded left and up
                fPos += _SizeMultiplier * worldScale * scale * up * (v.texcoord.x-.5);
                fPos += _SizeMultiplier * worldScale * scale * left * (v.texcoord.y-.5);

                float lerpVal = 0;

                // we stored the time that each leaf was
                // created in a a texturecoord as well
                // here we are calling that life
                float life =  v.texcoord2.z; 
               

                // making it so teh leaves can grow in using our "lerpDown"
                // function shown above
                float fLerpVal = saturate(abs(lerpDown(_AmountShown, life)));
                fPos = lerp( centerPos, fPos , fLerpVal);

                // This section creates a 'animation'
                // that will be played out as we change the
                // "FallingAmount" value
                // its always going to go to y = 0 so won't work for
                // pretty ground of any sort
                float falling = _FallingAmount - life * .9;
                falling = saturate(falling*10);
                fPos = lerp( fPos , float3(fPos.x + sin( falling * 12 +hash(life * 402) * 1012) * .1 , hash(life) * .1 , fPos.z + cos(falling * 10 + hash(life * 20) * 2012) * .3 ), falling);

                // pass through our base uv
                o.uv =  v.texcoord.xy;



                // here we are giving each individual particle
                // an individual UV so that they can sample
                // different parts of a texture. the texture
                // will need to be a X by X grid where X is your
                // Sprite Size
                float col = hash( float(life* 10));
                float row = hash( float(life* 20));
                o.uv2 = (o.uv + floor(_SpriteSize * float2( col , row )))/_SpriteSize;
                

                // our fPos is already in world space so we only need to multiply
                // by a view and projection matrix
                o.pos = mul (UNITY_MATRIX_VP, float4(fPos,1.0f));
                o.world = fPos;
                o.timeCreated = life;
TRANSFER_SHADOW(o)
                
                
                TRANSFER_VERTEX_TO_FRAGMENT(o);
               // o.nor = v.nor;
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            { 
                // sample the texture
                fixed4 col = 1;//float4( i.nor * .5 + .5 , 1);//tex2D(_MainTex, i.uv);
                
                // sample our sprite texture
                // and if the alpha is low enough discard it
                // since we don't really want to do true transparency here...
                float4 spriteCol = tex2D(_SpriteTex,v.uv2);
                if( spriteCol.a < .1){discard;}
                
                
                // Using the color from our texture as
                // the base texture
                col.xyz = 1;//spriteCol.xyz;
                col.xyz *= lerp(_BaseColor, _TipColor , v.timeCreated );//hsv(v.timeCreated * .2 + .75,.5,1);
                

                // here we get our light attenuation ( aka the shadows )
                // and make it so it isn't just a 1 -> 0 multiplier but
                // rather depended on how strong we want our shadows to be
                float atten = LIGHT_ATTENUATION(v) * _ShadowStrength + ( 1- _ShadowStrength);   
                col *= atten;

                return col;
            }

            ENDCG
        }
        








/*

  Here we are doing the Shadow pass which should be very similar to our above vert shader

  Its important to note here, that the sprite will be billboarded TOWARDS the light
  during their shadow pass. This means that the shadow map wont actually line up
  exactly, but unless your shadowmap resolution is SUPER high, you probably 
  wont be able to see this

*/ 



         Pass
    {
      Tags{ "LightMode" = "ShadowCaster" }


      Fog{ Mode Off }
      ZWrite On
      ZTest LEqual
      //Cull Off
      Offset 1, 1
      CGPROGRAM

      #pragma target 4.5
      #pragma vertex vert
      #pragma fragment frag
      #pragma multi_compile_shadowcaster
      #pragma fragmentoption ARB_precision_hint_fastest
#pragma shader_feature WORLD_NORMAL
      #include "UnityCG.cginc"


          float _AmountShown;
          float4 _Color;
          float _SizeMultiplier;
          float _ShadowStrength;
          float4 _BaseColor;
          float4 _TipColor;
  float _FallingAmount;



          sampler2D _SpriteTex;
          int _SpriteSize;
            
      struct v2f {
        V2F_SHADOW_CASTER;
        float2 uv : TEXCOORD1;
        float2 uv2 : TEXCOORD2;
        float3 nor : NORMAL;
      };
      float hash( float n ){
        return frac(sin(n)*43758.5453);
      }



  #include "ShadowCasterPos.cginc "


   // We use this value to blend every
        // vert from its center position
        // to its final position, based on 
        // how much of it should be 'show'
        // so it looks like its animating in!
        float3 lerpDown( float timeInBranch, float lerp){

            float lerpVal = lerp;

            lerpVal =  (1.1-lerp)-timeInBranch * .9;
            lerpVal = lerpVal;
            lerpVal *= 9;
            lerpVal = saturate(lerpVal);

            return 1-lerpVal;

        }
        
        

  
      v2f vert (  appdata_full v  )
            {
                v2f o;

                
                float3 worldNor = normalize(mul( unity_ObjectToWorld, float4(v.normal,0)).xyz);

                // Getting our left and up directions 
                // for our billboarded quad

                #ifdef WORLD_NORMAL
                  float3 left = worldNor;//UNITY_MATRIX_V[0].xyz;
                  float3 up = normalize(cross(UNITY_MATRIX_V[2].xyz,left));
                #else
                  float3 up = UNITY_MATRIX_V[0].xyz;
                  float3 left = UNITY_MATRIX_V[1].xyz;;
                #endif
                // we stored the center of our quad
                // as a texture coordinate in the mesh
                float3 centerPos =  mul(unity_ObjectToWorld,float4(v.texcoord1.xyz,1.0f)).xyz;


                // likewise we also stored our scale 
                // in one of the texture coordinates
                float scale = v.texcoord2.y;


                // Setting up the final position
                float3 fPos = centerPos;  
                

                // making it so our single point turns into
                // a quad using the billboarded left and up
                fPos += _SizeMultiplier * scale * up * (v.texcoord.x-.5);
                fPos += _SizeMultiplier * scale * left * (v.texcoord.y-.5);

                float lerpVal = 0;

                // we stored the time that each leaf was
                // created in a a texturecoord as well
                // here we are calling that life
                float life =  v.texcoord2.z; 
               

                // making it so teh leaves can grow in using our "lerpDown"
                // function shown above
                float fLerpVal = saturate(abs(lerpDown(_AmountShown, life)));
                fPos = lerp( centerPos, fPos , fLerpVal);

                // This section creates a 'animation'
                // that will be played out as we change the
                // "FallingAmount" value
                // its always going to go to y = 0 so won't work for
                // pretty ground of any sort
                float falling = _FallingAmount - life * .9;
                falling = saturate(falling*10);
                fPos = lerp( fPos , float3(fPos.x + sin( falling * 12 +hash(life * 402) * 1012) * .1 , hash(life) * .1 , fPos.z + cos(falling * 10 + hash(life * 20) * 2012) * .3 ), falling);

                // pass through our base uv
                o.uv =  v.texcoord.xy;



                // here we are giving each individual particle
                // an individual UV so that they can sample
                // different parts of a texture. the texture
                // will need to be a X by X grid where X is your
                // Sprite Size
                float col = hash( float(life* 10));
                float row = hash( float(life* 20));
                o.uv2 = (o.uv + floor(_SpriteSize * float2( col , row )))/_SpriteSize;
              
       fPos =  mul(unity_WorldToObject, float4(fPos,1)).xyz;

      float4 position = ShadowCasterPos(fPos,v.normal.xyz );
      o.pos = UnityApplyLinearShadowBias(position);

 
        return o;
      }

      float4 frag(v2f v) : COLOR
      {    
          
             // float uvL = length(v.uv - .5);
             //if(uvL > .5){
             //  discard;
             //}
          
          
           float4 spritCol = tex2D(_SpriteTex,v.uv2);
           // if( spritCol.a < .1){discard;}
                     
        SHADOW_CASTER_FRAGMENT(v)
      }
      ENDCG
    }


































    }}






















