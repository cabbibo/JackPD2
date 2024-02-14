Shader "Volumetric/fogSteps"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "../../Chunks/noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 world : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.world = mul( unity_ObjectToWorld, v.vertex).xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }



            #define Pi 3.14159265359

#define FogSteps 100    
#define ShadowSteps 8


#define FogRange 4
#define ShadowRange 4

#define ShadowSampleBias 2.
#define FogSampleBias 2.

#define MaxIterations 100

#define Anisotropy .9


    float3 VolumeColor = float3(1,0,0);
    float3 LightColor = float3(0,1,0);


float henyeyGreenstein(float3 dirI, float3 dirO){
   return Pi/4.*(1.-Anisotropy*Anisotropy) / pow(1.+Anisotropy*(Anisotropy-2.*dot(dirI, dirO)), 1.5);
}

float density(float3 pos){

    float ball = (1-saturate(length(pos )));

    ball = saturate(ball*100 );

    return ball * 10;

    

}


float3 directLight(float3 pos, float3 dir, float headStart){
    float3 lightDir = normalize(float3(3*sin(_Time.y),-1,-3*cos(_Time.y)));
    float3 pos0 = pos; 
    float3 oldPos = pos;
    float3 volAbs = 1;
    float stepDist;
    for(int i = 0; i < ShadowSteps; i++){
        oldPos = pos;
        pos = pos0 - lightDir * pow((float(i)+headStart) / float(ShadowSteps), ShadowSampleBias) * ShadowRange;
        volAbs *=  exp(-density(pos)*length(pos-oldPos)*LightColor);
    }
    return LightColor * volAbs * henyeyGreenstein(-lightDir, dir);
}

float random(float2 p)
{
  float3 p3 = frac(float3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return frac((p3.x + p3.y) * p3.z);
}
float3 ACESFilm(float3 x){
    float a = 2.51;
    float b = 0.03;
    float c = 2.43;
    float d = 0.59;
    float e = 0.14;
    return (x*(a*x+b))/(x*(c*x+d)+e);
}




            fixed4 frag (v2f v) : SV_Target
            {

                float3 eye = v.world - _WorldSpaceCameraPos;
    float2 screenPos = ComputeScreenPos(v.vertex).xy;

    float headStartCam   =   random(screenPos+ _Time.x*2);
    float headStartShadow = random(screenPos+ _Time.x);
VolumeColor = float3(1,1,1);
LightColor = float3(1,.4,.4);
    
    float3 volCol = 0;
    float3 volAbs = 1;
    float3 pos = v.world;
    float3 oldPos = v.world;
    float3 stepAbs, stepCol;
    float3 dir = normalize(eye);
    float totalD = 0;
    float3 light = 0;
    for(int i = 0; i < FogSteps; i++){
        oldPos = pos;
        pos = v.world + dir * pow((float(i)+headStartCam) / float(FogSteps), FogSampleBias) * FogRange;
        
        float distVal =  (float(i)+headStartCam) / float(FogSteps) * FogRange;
      
        float delta = length(pos-oldPos);

        float d = density(pos);
       // totalD += length(pos-oldPos) * 1;// exp(-density(pos)*length(pos-oldPos)*VolumeColor);

        stepAbs = exp(-density(pos)*length(pos-oldPos)*VolumeColor);
        //stepAbs = exp(-density(pos * .1) * 10) ;
        totalD += stepAbs;
        stepCol = 1-stepAbs;

        light = directLight(pos, dir, headStartShadow);
        volCol += stepCol*volAbs*light;
        volAbs *= stepAbs;
    }

    
                // sample the texture
                fixed4 col = 1;
                col.xyz= volCol*1;//totalD/10;//volCol;//ACESFilm(volCol);//volAbs;
                return col;
            }
            ENDCG
        }
    }
}










