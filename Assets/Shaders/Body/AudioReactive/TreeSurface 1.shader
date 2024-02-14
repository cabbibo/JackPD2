Shader "FantasyTree/Words"
{
    Properties
    {
        _BaseColor ("BaseColor", Color) = (1,1,1,1)
        _TipColor ("TipColor", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bumpmap", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _TipColorMultiplier("Tip color multiplier" , Range(0,10)) = .5            
        _BaseColorMultiplier("Base color multiplier" , Range(0,10)) = .5          
        _AmountShown ("AmountShown", Range (0, 1)) = .5
    }
    SubShader
    {
        Cull Back
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard   vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
            sampler2D _BumpMap;

            sampler2D _AudioMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float  life;
            float3 disform;
            float dis2;
        };

        half _Glossiness;
        half _Metallic;
        float4 _EmissionColor;
        fixed4 _Color;


        
      #include "../../Chunks/hash.cginc"
      #include "../../Chunks/snoise.cginc"

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
    float _FadeFromTop;
    float _AlphaCutoff;
    float _TipColorMultiplier;
    float _BaseColorMultiplier;

    float4 _BaseColor;
    float4 _TipColor;
           
        void vert (inout appdata_full v,out Input o) {
            
            UNITY_INITIALIZE_OUTPUT(Input,o);

            // passing through our time created so we can chang our colors
            o.life = v.texcoord2.z;
            float fLerp = saturate(abs(-1+lerpDown(1-_AmountShown, v.texcoord2.z)));

            // lerping to zero so our shadow bias doesn't
            // falsely draw shapes

            float n = snoise( v.vertex.xyz * 60 + float3(0,_Time.y * .15,0));
            float3 disform = tex2Dlod(_AudioMap, float4(n * .1,0,0,0)).xyz;

            disform = pow( disform , 4);

            o.dis2 = n * length(disform);

       


            v.normal.xyz = v.normal; //lerp( float3(0,0,0), v.normal , fLerp);
            v.vertex.xyz= v.vertex.xyz + float3(0,1,0) * .001 * n + v.normal * o.dis2* .001;// lerp( v.texcoord1.xyz, v.vertex.xyz , fLerp);

            o.disform =  (n+1)/2;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex ) * lerp( _BaseColor , _TipColor , IN.life);

            float3 l = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1.0)).xyz;

            float3 a = tex2D(_AudioMap,float2(length(IN.disform) * .3,0)).xyz;
            o.Albedo =a*a*a*a*a*a*a*20;//IN.dis2 *3 + tex2D(_AudioMap,float2(length(IN.disform) * 2,0)).xyz *10;// * IN.disform *10;// lerp(_BaseColorMultiplier, _TipColorMultiplier, IN.life);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
         o.Emission = a*a*a*a*a* a*a*a*a*a*a*2;// IN.disform * IN.disform  * IN.disform  * 10;
            o.Smoothness = _Glossiness;
            o.Normal = 10*UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
            o.Alpha = c.a;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
