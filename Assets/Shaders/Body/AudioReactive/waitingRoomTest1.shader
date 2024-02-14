Shader "Unlit/waitingRoomTest"
{
    Properties
    {
         _Audio ("Tex", 2DArray) = "" {}
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
            #pragma require 2darray

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                float3 ro : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;


            float _AudioTime;


            UNITY_DECLARE_TEX2DARRAY(_Audio);

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.ro = mul ( unity_ObjectToWorld , float4(v.vertex));
                return o;
            }





#include "../../Chunks/noise.cginc"
#include "../../Chunks/sdfFunctions.cginc"
//--------------------------------
// Modelling 
//--------------------------------
float2 map( float3 pos ){  
    

    float2 res = float2(1000,-1);

    float n = noise( pos * 3+ float3(0,0,_Time.y * .2) );
    float which = floor( (pos.y+.5)  * 12);
 //   pos.y = ((pos.y+100) % .1)-.05;

    for( int i = 0; i < 12; i++ ){

        float fSample = abs(pos.x) * .1 +  n * .1;

    float4 audio = UNITY_SAMPLE_TEX2DARRAY_LOD(_Audio, float3(fSample, _AudioTime,float(i)),0);

        float box = sdBox( pos - float3( 0, float(i) * .3 , 0) , float3(.85,.01 , .01));
        float d =box -  length(audio) * length(audio)*1/(10*box);
        float id = float(i) + fSample ;
    
        res = opU( float2(d,id), res );// + (length( pos )-.4) - length(audio) * 11.5;
       // res.x -= n * .03;
    //res.y = which + n * .1 + .2 ;

    }

    return res;
    
}
// Calculates the normal by taking a very small distance,
// remapping the function, and getting normal for that
float3 calcNormal( in float3 pos ){
    
	float3 eps = float3( 0.001, 0.0, 0.0 );
	float3 nor = float3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}



float2 calcIntersection( in float3 ro, in float3 rd ){

    
    float h =  0.01*2.0;
    float t = 0.0;
	float res = -1.0;
    float id = -1.;
    
    for( int i=0; i< 100 ; i++ ){
        
        if( h < 0.01 || t > 100.0 ) break;
	   	float2 m = map( ro+rd*t );
        h = m.x;
        t += h;
        id = m.y;
        
    }

    if( t < 100.0 ) res = t;
    if( t > 100.0 ) id =-1.0;
    
    return float2( res , id );
    
}


            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture
                fixed3 col = 0;
                

                float3 ro = v.ro;
                float3 rd = -normalize(_WorldSpaceCameraPos - v.ro);


                float2 res = calcIntersection( ro , rd );
                
                if( res.y > 0 ){

                float3 pos = ro + rd * res.x;
                               // col += .5 + .5*calcNormal( pos );
                float3 nor = calcNormal( pos );

                float3 refl = reflect( rd , nor );

                
                    half4 skyData =UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,refl);
                    half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR);

                    col = skyColor;

                    float4 aCol = UNITY_SAMPLE_TEX2DARRAY_LOD(_Audio, float3(res.y-floor(res.y), _AudioTime, floor(res.y)) , 0);
                    col = 100*aCol * aCol; //saturate(tex2Dlod( _AudioMap , float4( res.y * .04 + .1 , 0,0,0)));
                    //col = nor * .5 + .5;//
                }
                float i = floor( v.uv.x * 12);
                   // col += 4*UNITY_SAMPLE_TEX2DARRAY(_Audio, float3(v.uv.y, _AudioTime, i));
                
                
                return float4(col,1);
            }
            ENDCG
        }
    }
}


