
float2 map( float3 pos ){  

    float2 res;
    res = float2( sdPlane( pos , float4(0,1,0,0)) , 1 );
    res.x += noise( pos  * .04 + float3(0,_Time.y * .1,0) ) * 8;
    res.x += noise( pos  * .1 + float3(0,_Time.y,0) ) * 4;
    res.x += noise( pos  * .3 + float3(0,_Time.y * .3,0) ) * 1;
    res.x += noise( pos * 100) * .03;


    float2 orb = float2(sdSphere(pos, 10),2);
    orb.x += noise( pos *2) * .4;
    res = smoothU(res,orb,11);

    float2 orb2 = float2(sdSphere(pos- float3(10,10,0), 10),2);
    orb2.x += noise( pos *2) * .4;
    res = smoothU(res,orb2,11);
    return res;
    
}