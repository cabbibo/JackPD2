
float _AudioMultiplier;
float _AudioPow;
float _UpperMultiplier;
float _LowerMultiplier;

float _NumStems;
float _Timeline;

float _AudioSizeMultiplier;
float _AudioMultiplierExtra;
float _AudioLookupSizeMultiplier;

#ifndef IS_COMPUTE

sampler2D _AudioMap;
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
 //v *= .8;
 //v = v%.999;
    v *= _AudioSizeMultiplier;
     v %= .999;
    v = clamp(v,0.001,.99);

    float id = floor( nID * _NumStems);

    float v1 = (v)/(_NumStems+1);

    float v2 = floor((id%(_NumStems+1)))/(_NumStems+1) ;
    float4 aVal = tex2Dlod(_AudioMap, float4((v1 + v2),_Timeline,0,0));

    float m = LinearScale(v);

    aVal *= m;
    aVal = pow( aVal , _AudioPow );
    aVal *= _AudioMultiplier;
    aVal *= _AudioMultiplierExtra;

    return aVal;

}


float4 sampleAudioCustomPowerMultiplier( float v , float nID , float power , float mul ){
    
    
    v *= _AudioSizeMultiplier;
   v %= .999;
    v = clamp(v,0.001,.999);


    float id = floor( nID * _NumStems);

    float v1 = (v)/(_NumStems+1);
    float v2 = floor((id%(_NumStems+1)))/(_NumStems+1);
    float4 aVal = tex2Dlod(_AudioMap, float4((v1+ v2),_Timeline,0,0));

    float m = LinearScale(v);

    aVal *= m;
    aVal = pow( aVal , power );
    aVal *= mul;
    aVal *= _AudioMultiplierExtra;

    return aVal;


}

float4 sampleAudio( float v ){

    float id = 1;
    return sampleAudio(v,id);

}

sampler2D _ColorMap;
float _ID;

float N_ID(float id){

    return (id % _NumStems)/_NumStems;

}

#endif


#ifdef IS_COMPUTE
Texture2D<float4> _AudioMap;
SamplerState linearClampSampler;




float LinearScale(float v)
{
    // Ensure v is in the range [0, 1]
    v = clamp(v, 0.0, 1.0);

    // Compute the scale factor
    float m = sqrt(v);

    return m;
}

float4 sampleAudio( float v , float nID){


     v *= _AudioSizeMultiplier;
    v = v%.95;

    float id = floor( nID * _NumStems);

    float v1 = (v)/(_NumStems+1);
    float v2 = floor((id%(_NumStems+1)))/(_NumStems+1);
    float4 aVal = _AudioMap.SampleLevel(linearClampSampler,float2(v1+ v2,_Timeline),0);

    float m = LinearScale(v);

    aVal *= m;
    aVal = pow( aVal , _AudioPow );
    aVal *= _AudioMultiplier;
    aVal *= _AudioMultiplierExtra;


    return aVal;

}

float4 sampleAudio( float v ){

    float id = 1;
    return sampleAudio(v,id);

}

float N_ID(float id){

    return (id % _NumStems)/_NumStems;

}

#endif

