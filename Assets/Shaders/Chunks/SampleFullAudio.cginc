

float _AudioMultiplier;
float _AudioPow;
float _UpperMultiplier;
float _LowerMultiplier;

float _NumStems;
float _Timeline;
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
    float id = floor( nID * _NumStems);

    float v1 = (v)/(_NumStems+1);
    float v2 = floor((id%(_NumStems+1)))/(_NumStems+1);
    float4 aVal = tex2Dlod(_AudioMap, float4((v1+ v2),_Timeline,0,0));

    float m = LinearScale(v);

    aVal *= m;
    aVal = pow( aVal , _AudioPow );
    aVal *= _AudioMultiplier;

    return aVal;

}

float4 sampleAudio( float v ){

    float id = 1;
    return sampleAudio(v,id);

}
