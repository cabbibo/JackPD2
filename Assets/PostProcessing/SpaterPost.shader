Shader "Hidden/Custom/SpaterPost"
{
       HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        TEXTURE2D_SAMPLER2D(_FrameTex, sampler_FrameTex);
        float _Blend;

        float4 _Color;

        float _AudioPower;
        float _AudioBase;
        float _Fade;
        float _AudioLookupSize;
        float _AudioDistort;

    float _LookupOffset ;
    float2 _CenterOffset;

    

float _AudioMultiplier;
float _AudioPow;

float _NumStems;
float _Timeline;

        TEXTURE2D_SAMPLER2D(_AudioMap, sampler_AudioMap);



float LinearScale(float v)
{
    // Ensure v is in the range [0, 1]
    v = clamp(v, 0.0, 1.0);

    // Compute the scale factor
    float m = sqrt(v);

    return m;
}

float4 sampleAudio( float v , float nID){

  // dont sample from the end of the audio
  v *= .99;
  v = v%.99;;
    float id = floor( nID * _NumStems);

    float v1 = (v)/(_NumStems+1);
    float v2 = (id%(_NumStems+1))/(_NumStems+1);
    float4 aVal = SAMPLE_TEXTURE2D(_AudioMap,sampler_AudioMap, float4(v1+ v2,_Timeline,0,0));

    float m = LinearScale(v);

    float aP = _AudioPower;
    float aM = _AudioMultiplier;

    aP = 1;
    aM = 1;

    aVal *= m;
    aVal = pow( aVal , aP );
    aVal *= aM;

    return aVal;

}

float4 sampleAudio( float v ){

    float id = 1;
    return sampleAudio(v,id);

}

        float4 Frag(VaryingsDefault i) : SV_Target
        {

            float2 fUV = i.texcoord + _CenterOffset;

            float frameVal = SAMPLE_TEXTURE2D(_FrameTex, sampler_FrameTex, i.texcoord).x;

            frameVal = frameVal * 1;
            frameVal = saturate(frameVal);
            //frameVal = 1-frameVal;

            float2 dir = float2(
                SAMPLE_TEXTURE2D(_FrameTex, sampler_FrameTex, i.texcoord + float2(.01 , 0 )).x - SAMPLE_TEXTURE2D(_FrameTex, sampler_FrameTex, i.texcoord - float2(.01 , 0 )).x,
                SAMPLE_TEXTURE2D(_FrameTex, sampler_FrameTex, i.texcoord + float2(0 , 0.01 )).x - SAMPLE_TEXTURE2D(_FrameTex, sampler_FrameTex, i.texcoord - float2(0 , 0.01 )).x
            );

            dir *= 10000;

            if( length(dir) > .01 ){
            dir = normalize(dir);
            }else{
                dir = float2(1,0);
            }
            




            float2 fromCenter= (fUV-.5);

            float dist = length(fromCenter);

            float lookup = (_AudioLookupSize*(1-length((fUV-.5)* float2(6220/1080,1))))+_LookupOffset;
            lookup = frameVal;
            float4 aCol = sampleAudio(lookup * _AudioLookupSize + _LookupOffset);//SAMPLE_TEXTURE2D(_AudioMap, sampler_AudioMap, float2(frameVal * .5,_Timeline));

            float2 newTexCoord;

            //dir = normalize(fUV-.5);


           // dir *= (-length(aCol)+.8) * dist * .01;//dist;


    float4 bg = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord  );
            float2 distortionAmount = (1-frameVal) * dir;

            float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - distortionAmount * -.1 * aCol.xz * _AudioDistort  );
            color.g = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - distortionAmount * -.2 * aCol.xz * _AudioDistort  ).g;
            color.b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - distortionAmount * -.3 * aCol.xz * _AudioDistort  ).b;
           
            float luminance = dot(color.rgb, float3(0.2126729, 0.7151522, 0.0721750));
            color.rgb = lerp(color.rgb, color.rgb * _Color.xyz, _Blend.xxx);


            color.rgb = lerp( color.rgb , color.rgb * _Color.xyz * 2 , _Fade);

            color.rgb *= _AudioBase + _AudioPower * aCol.xyz * _Color.xyz * (1-frameVal);//lookup * lookup*lookup * lookup*10;// * (1-frameVal);
            color.rgb *= 1;


            
            color.rgb *= saturate(frameVal * 4 - 0);




            //color.rgb = (1-frameVal) * dir.x;

            /*if( frameVal == 0 ){
                color.rgb = float3(0,0,0);
            }*/


       // color.rg = dir;


           // color = frameVal * 3;//* frameVal * 2;

    //color.rgb= aCol.xyz;

            color.rgb = lerp( bg,color.rgb  , _Fade);
            color = saturate(color);
            
            return color;
        }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}