Shader "FantasyTree/BillboardedSurface"
{

  
        Properties {
    _SizeMultiplier ("SizeMultiplier", Float) = 1
    _SpriteSize ("SpriteSize", Int) = 6

    _SpriteTex ("tex" , 2D )  = "white" {}


    
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    _BaseColor ("BaseColor" , Color )  =(1,1,1,1)
    _TipColor  ("TipColor" , Color )  = (1,1,1,1)
    _ShadowStrength("_ShadowStrength" , Range(0,1)) = .5
    _AmountShown("AmountShown" , Range(0,1)) = .5
    _FallingAmount("falling amount" , Range(0,1)) = .5
    [Toggle(WORLD_NORMAL)] _RandomNormal("RandomNormal", Float) = 0

  }
    SubShader
    {
        Cull Back
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard   vertex:vert addshadow
#pragma shader_feature WORLD_NORMAL
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
            sampler2D _BumpMap;
             float4 MainTex_ST;

        struct Input
        {
           float2 spriteUV;
            float2 uv_BumpMap;
            float  life;
            float2 uv_MainTex;
        };




        
    // little randomness funciton
      float hash( float n ){
        return frac(sin(n)*43758.5453);
      }


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // We use this value to blend every
        // vert from its center position
        // to its final position, based on 
        // how much of it should be 'show'
        // so it looks like its animating in!
        float3 lerpDown( float timeInBranch, float lerp){

            float lerpVal = lerp;

            lerpVal =  (.9-lerp * .9)-timeInBranch * .9;
            lerpVal = lerpVal;
            lerpVal *= 10;
            lerpVal = saturate(lerpVal);

            return 1-lerpVal;

        }
        
        
 

        float _AmountShown;
          float _FallingAmount;
          float4 _Color;
          float _SizeMultiplier;
          float _ShadowStrength;
          float4 _BaseColor;
          float4 _TipColor;
          int _SpriteSize;
        half _Glossiness;
        half _Metallic;

           
        void vert (inout appdata_full v,out Input o) {
            
            UNITY_INITIALIZE_OUTPUT(Input,o);


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

   



                // here we are giving each individual particle
                // an individual UV so that they can sample
                // different parts of a texture. the texture
                // will need to be a X by X grid where X is your
                // Sprite Size
                float col = hash( float(life* 10));
                float row = hash( float(life* 20));
                o.spriteUV= (v.texcoord.xy+ floor(_SpriteSize * float2( col , row )))/_SpriteSize;
                

            


            // passing through our time created so we can chang our colors
            o.life = v.texcoord2.z;
            


o.life = life;

float fLerp = saturate(abs(-1+lerpDown(1-_AmountShown, v.texcoord2.z)));
            // lerping to zero so our shadow bias doesn't
            // falsely draw shapes
            v.normal.xyz = lerp( float3(0,0,0), v.normal , fLerp);
            v.vertex.xyz=  mul( unity_WorldToObject, float4(fPos,1)).xyz;//lerp( v.texcoord1.xyz, v.vertex.xyz , fLerp);
          
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color

            //float2 val = IN.uv2.xy;
            float4 tCol = tex2D (_MainTex, IN.spriteUV );
            fixed4 c = lerp( _BaseColor , _TipColor , IN.life);
            o.Albedo = c.rgb;// *  lerp(_BaseColorMultiplier, _TipColorMultiplier, IN.life);

            if( tCol.a < .1 ){discard;}
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
            o.Alpha = c.a;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
