  
  Shader "IMMAT/Surface/AV1" {
    Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _BumpMap ("Bumpmap", 2D) = "bump" {}
    _Albedo ( "_Albedo" , Color) = (1,1,1,1)
    _Emission ( "_Emission" , Color) = (1,1,1,1)
      _Smoothness ("Smoothness", Range(0,1)) = 0.5
      _Metallic ("Metallic", Range(0,1)) = 0.5

    }
    SubShader {
        Cull Off
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM


        #pragma target 3.5
        #pragma require compute
#include "UnityCG.cginc"
#include "../../Chunks/hsv.cginc"
     #pragma vertex vert
      #pragma surface surf Standard addshadow

    
 struct appdata{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float4 texcoord : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
    float4 texcoord2 : TEXCOORD2;
    uint id : SV_VertexID;
};

struct Vert {
    float3 pos;
    float3 vel;
    float3 normal;
    float3 tangent;
    float2 uv;
    float2 debug;
};

// have to make sure platform supports compute shaders!
#if SHADER_API_D3D11 || SHADER_API_METAL || SHADER_API_VULKAN || SHADER_API_GLES3 || SHADER_API_GLCORE
      StructuredBuffer<Vert> _VertBuffer;
      StructuredBuffer<int> _TriBuffer;
#endif

      struct Input {
          float2 texcoord1;
          float2 texcoord2;
          float3 tangent;
          float3 world;
          float2 debug;
      };


      float _Metallic;
      float _Smoothness;
      float4 _Albedo;
      float4 _Emission;


sampler2D _AudioMap;


      sampler2D _MainTex;
      float4 _MainTex_ST;
      sampler2D _BumpMap;
      float4 _BumpMap_ST;

      void vert (inout appdata vert, out Input data  ) {


        
 
        UNITY_INITIALIZE_OUTPUT( Input , data );
#if SHADER_API_D3D11 || SHADER_API_METAL || SHADER_API_VULKAN || SHADER_API_GLES3 || SHADER_API_GLCORE
Vert v = _VertBuffer[_TriBuffer[vert.id]];


  float4 aVal = pow(tex2Dlod(_AudioMap , float4( v.uv.x ,0,0,0) ),10) *.1;
            vert.vertex = float4(v.pos + v.normal * aVal * .1,1);// float4(v.vertex.xyz,1.0f);
            vert.normal = v.normal;
            vert.tangent = float4(v.tangent,1);


          data.world = v.pos;
  
            data.texcoord1 = TRANSFORM_TEX(v.uv , _MainTex);//float2(1,1);
            data.texcoord2 = TRANSFORM_TEX(v.uv , _BumpMap);//float2(1,1);
            data.tangent = v.tangent;
            data.debug = v.debug;
       
#endif
 
         }

         sampler2D _OSCMap;
         float _Timeline;
 
      void surf (Input IN, inout SurfaceOutputStandard o) {
               // float3 nor = -cross(normalize(ddx(IN.world)),normalize(ddy(IN.world)));

        float3 mainCol = tex2D (_MainTex, IN.texcoord1.xy).rgb;
        float3 nor = UnpackNormal (tex2D (_BumpMap, IN.texcoord2.xy));
        
          //half rim = 1.0 - saturate(dot (normalize(v.vertex._WorldSpaceCameraPosition), o.Normal));
          //o.Emission =UnpackNormal (tleex2D (_BumpMap, IN.texcoord1.xy * float2( 1 , 1))) * .5 + .5;// _RimColor.rgb * pow (rim, _RimPower);
          o.Albedo =  pow(tex2D(_AudioMap , float2( IN.texcoord1.x , _Timeline)  ) ,2)* 10000;//_Albedo * mainCol ;//(nor * .5 + .5) * mainCol * hsv( length(mainCol) * .3 + _Time.x * 5 + IN.debug,1,1);// 1000*(UnpackNormal (tex2D (_BumpMap, IN.texcoord1.xy * float2( 1 , 1)))-float3(0,0,1));// * .5 + .5; //tex2D (_MainTex, IN.texcoord1.xy).rgb;
         o.Smoothness = _Smoothness;//0.8f;
         o.Metallic = _Metallic;//.9f;
          o.Normal = nor;
        o.Emission = pow(tex2D(_AudioMap , IN.debug.x/100 * .2 + IN.debug.y * .2 ),10) * 20;
      // o.Albedo = IN.texcoord1.x * 1 * hsv(  IN.debug.x/100 * .1-.1 + IN.debug.y * .05 , .5,1)*5* tex2D(_OSCMap, IN.debug.x/100)*pow(tex2D(_AudioMap , IN.debug.x/100 * .2 + IN.debug.y * .2 ),10) * 4*pow(tex2D(_AudioMap , IN.texcoord1.y ),3) * 4;
       // o.Emission = pow(tex2D(_AudioMap , IN.texcoord1.x * 1+ mainCol.x * .2 ),4) * hsv(  IN.debug.x/100 * .1-.1 + IN.debug.y * .05 , .5,1);
         // o.Emission = hsv( IN.debug.y  , 1,1);// IN.debug.xy;//tex2D(_AudioMap, IN.texcoord1.xy).rgb;
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }