Shader "custom/raytraceBasic"
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNor : TEXCOORD2;
                float3 localPos : TEXCOORD3;
                float3 localNor : TEXCOORD4;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.localPos = v.vertex;
                o.localNor = v.normal;
                o.worldPos = mul( unity_ObjectToWorld , v.vertex).xyz;
                o.worldNor = normalize(mul( unity_ObjectToWorld , float4(v.normal,0)).xyz);
                o.uv = v.uv;

                return o;
            }

            
const float MAX_TRACE_DISTANCE = 100.0;           // max trace distance
const float INTERSECTION_PRECISION = 0.001;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 100;

#include "../../Chunks/noise.cginc"


#include "../../Chunks/sdfFunctions.cginc"
float3 _CenterPos;

//--------------------------------
// Modelling 
//--------------------------------
float2 map( float3 pos ){  
    
    //pos -= _CenterPos;

    pos = modit( pos , float3(1,1,1)) - .5;
 	float2 res = float2( sdSphere( pos  , .5 ) , 1. ); 

  //  res.x += noise( pos );
    
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





float3 render( float2 res , float3 ro , float3 rd ){
   

  float3 color = 1;

    
    
  if( res.y > -.5){
      
    float3 pos = ro + rd * res.x;
    float3 nor = calcNormal( pos );

    color = nor * .5 + .5;
        
        
  }
   
  return color;
    
    
}




            fixed4 frag (v2f v) : SV_Target
            {
              

                float3 ro = v.worldPos;
                float3 rd = normalize(v.worldPos - _WorldSpaceCameraPos);
            
                float2 res = calcIntersection( ro , rd  );
                float3 col = render( res , ro , rd );


                return float4( col, 1);
            }
            ENDCG
        }
    }
}
