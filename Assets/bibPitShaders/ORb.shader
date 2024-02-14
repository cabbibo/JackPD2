Shader "BibPit/liquidOrb"{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="AlphaTest" "DisableBatching"="True" "Queue" = "Transparent"}
        LOD 100         // Draw after all opaque geometry
    

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }
            

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 world: TEXCOORD0;
            };

            #include "Assets/Shaders/Chunks/noise.cginc"


            v2f vert (appdata v)
            {
                v2f o;

                // get world position of vertex
                // using float4(v.vertex.xyz, 1.0) instead of v.vertex to match Unity's code
                float3 worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0));

                o.world = worldPos;
            
                o.pos = UnityWorldToClipPos(worldPos);

                return o;
            }

 #include "Assets/Shaders/Chunks/sdfFunctions.cginc"

                float2 map( float3 pos ){  


                     float3 centerPos = mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;
                    
                    float2 res = float2( sdSphere( pos-centerPos, 3 ) , 1. ); 
                    res.x += 1*(noise( pos*2+ float3(0,_Time.y * .35,0)) * .2+noise( pos * 2.3+10+ float3(0,_Time.y * .47,0)) * .2 + noise( pos * 1.5 + float3(0,_Time.y * .3,0)) * 1+ noise( pos * .45 + 10  + float3(0,_Time.y * .4,0)) * 1);// + noise( pos * 3) * .1;
                    
                    return res;
                    
                }

         // Include this AFTER your map function!



float2 calcIntersection( in float3 ro, in float3 rd ){

    
    float h =  0.01*2.0;
    float t = 0.0;
	float res = -1.0;
    float id = -1.;
     int NUM_OF_TRACE_STEPS = 4;
    for( int i=0; i<NUM_OF_TRACE_STEPS; i++ ){
        
        if( h <  0.01 || t > 10 ) break;
	   	float2 m = map( ro+rd*t );
        h = m.x;
        t += h;
        id = m.y;
        
    }

    if( t < 10 ) res = t;
    if( t > 10 ) id =-1.0;
    
    return float2( res , id );
    
}



// Calculates the normal by taking a very small distance,
// remapping the function, and getting normal for that
float3 calcNormal( in float3 pos ){
    
	float3 eps = float3(.01, 0.0, 0.0 );
	float3 nor = float3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}





float2 map2( float3 pos ){  


            float3 centerPos = mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz;
        
        float2 res = float2( sdSphere( pos-centerPos, 1 ) , 1. ); 
        res.x += noise( pos+ float3(0,_Time.y * .35,0)) * .2+noise( pos * 1.3+10+ float3(0,_Time.y * .47,0)) * .2 + noise( pos * .5 + float3(0,_Time.y * .3,0)) * 1+ noise( pos * .45 + 10  + float3(0,_Time.y * .4,0)) * 1;// + noise( pos * 3) * .1;
        

        res.x = -res.x;


        //res = opU( res, float2( sdSphere( pos-centerPos, 2)+ noise(pos * 1), 2. ) );

        return res;
        
    }



float2 calcIntersection2( in float3 ro, in float3 rd ){

    
    float h =  0.0001*2.0;
    float t = 0.0;
	float res = -1.0;
    float id = -1.;
     int NUM_OF_TRACE_STEPS = 10;
    for( int i=0; i<10; i++ ){
        
        if( h <  0.001 || t > 10 ) break;
	   	float2 m = map2( ro+rd*t );
        h = m.x;
        t += h;
        id = m.y;
        
    }

    if( t < 10 ) res = t;
    if( t > 10 ) id =-1.0;
    
    return float2( res , id );
    
}



// Calculates the normal by taking a very small distance,
// remapping the function, and getting normal for that
float3 calcNormal2( in float3 pos ){
    
	float3 eps = float3(.01, 0.0, 0.0 );
	float3 nor = float3(
	    map2(pos+eps.xyy).x - map2(pos-eps.xyy).x,
	    map2(pos+eps.yxy).x - map2(pos-eps.yxy).x,
	    map2(pos+eps.yyx).x - map2(pos-eps.yyx).x );
	return normalize(nor);
}





            sampler2D _BackgroundTexture;

            samplerCUBE _Cube;
  
            half4 frag (v2f v, out float outDepth : SV_Depth) : SV_Target
            {

                float3 ro = v.world;
                float3 rd = normalize(ro - _WorldSpaceCameraPos);

                float3 worldPos = ro;
                float3 col = 0;

                float2 res = calcIntersection( ro, rd );

                float3 refrPos = worldPos;
                float3 worldNor;

                if( res.y > 0 ){
                    worldPos = ro + rd * res.x;
                    refrPos = worldPos;
                    worldNor = calcNormal( res.x * rd + ro );


                    float3 refr = refract( rd , worldNor, .8);


                    /*float2 res2 = calcIntersection2( worldPos + refr * .3, refr );


                    if( res2.y > 1.5 ){

                        
                    float3 p2 =  worldPos + refr * res2.x;
                    float3 n2 = calcNormal2( p2 );

                    float3 refl = reflect(refr, n2 );
                    
                        col = .5+ texCUBElod(_Cube,float4(refl,0));//n2 * .5 + .5;

                        
                    }else{


                    float3 p2 =  worldPos + refr * res2.x;
                    float3 n2 = calcNormal2( p2 );




                    refr = refract( refr , n2, .8); 
                    float3 refrPosR = worldPos + refr * 1;

                     refr = refract( refr , n2, .75); 
                    float3 refrPosG = worldPos + refr * 1;

                       refr = refract( refr , n2, .7); 
                    float3 refrPosB = worldPos + refr * 1;


                    float4 refrClipR = UnityWorldToClipPos(refrPosR);
                    float4 refrClipG = UnityWorldToClipPos(refrPosG);
                    float4 refrClipB = UnityWorldToClipPos(refrPosB);
                    float3 bg = float3(
                       texCUBElod(_Cube,float4(refract( refr , n2, .8),0)).r,
                       texCUBElod(_Cube,float4(refract( refr , n2, .75),0)).g,
                       texCUBElod(_Cube,float4(refract( refr , n2, .7),0)).b
                    );

                    col =  bg; //calcNormal( res.x * rd + ro );//float3(1,0,0);
                   

                        float4 val = texCUBElod(_Cube,float4(reflect(rd, worldNor),0));// UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldNor);
                        col += pow( 1-dot( rd, -worldNor ),2) * val.xyz *2;
                    }*/

                      float4 val = texCUBElod(_Cube,float4(reflect(rd, worldNor),0));// UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldNor);
                        col += pow( 1-dot( rd, -worldNor ),2) * val.xyz *2;

                        
                }

                clip( res.y);

                
                float4 clipPos = UnityWorldToClipPos(worldPos);
                // output modified depth
                outDepth = clipPos.z / clipPos.w;

                return half4( col, 1.0);
            }
            ENDCG
        }
    }
}