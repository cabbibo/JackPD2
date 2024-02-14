
float3 _SDFDimensions;
float3 _SDFExtents;
float3 _SDFCenter;

float4x4 _SDFTransform;
float4x4 _SDFInverseTransform;

Texture3D<float4> _SDFTexture;
SamplerState _LinearClamp;


float4 SampleSDF( float3 pos ){

    float3 tPos = mul( _SDFInverseTransform ,float4(pos,1));
    tPos -= _SDFCenter;
    tPos /= _SDFExtents;

    tPos += 1;
    tPos /= 2;

    float4 t = _SDFTexture.SampleLevel(_LinearClamp,tPos , 0);

    return t;

}


float SampleSDFDepth( float3 pos ){

    float4 t = SampleSDF(pos);
    return t.x;

}


float SampleSDFNormal( float3 pos ){

    float4 t = SampleSDF(pos);
    return t.yzw;

}

float3 SampleSDFVector( float3 pos ){

    float4 t = SampleSDF(pos);
    return t.yzw * t.x;

}