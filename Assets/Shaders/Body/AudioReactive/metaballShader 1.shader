Shader "audio/metaball"
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

            
#include "../../Chunks/noise.cginc"


#include "../../Chunks/sdfFunctions.cginc"
float3 _VisualizationCenter;
sampler2D _AudioMap;



//--------------------------------
// Modelling 
//--------------------------------
float2 map( float3 pos ){  
    
    pos -= _VisualizationCenter;

   // pos = modit( pos , float3(1,1,1)) - .5;
 	float2 res = 100000;//float2( sdSphere( pos  ,1 ) , 1. ); 
float _Speed = 1;
float _SpeedVariation = .1;
float _MetaballSize = .1;
float _MetaballSizeVariation = .1;
float _MetaballSizeVariationSpeed = 1.1;
float _BlendSize = .4;
float _PositionMultiplier = .3;
float _SizeAudio= .1;


    for( int i = 0; i < 5; i++ ){
        float fi = float(i);
        float3 p =  _PositionMultiplier* float3(  sin(_Time.y * ( _Speed + sin( fi * 134.4140 ) * _SpeedVariation ) + fi * 2401.),
                                        sin(_Time.y * ( _Speed + sin( fi * 66.4140 ) * _SpeedVariation ) + fi * 901.),
                                        sin(_Time.y * ( _Speed + sin( fi * 931.4140 ) * _SpeedVariation ) + fi * 3101.) );

      float3 audio =  tex2Dlod( _AudioMap , float4(fi * .05 , 0,0,0));
       float d= sdSphere( pos - p , length(audio) * _SizeAudio + _MetaballSize +  sin(_Time.y * _MetaballSizeVariationSpeed + fi * 1212 ) * _MetaballSizeVariation );
      //  float d = sdSphere( pos - p , .5 );


        res = smoothU( res , float2( d , fi) , _BlendSize);
       // res = hardU( res , float2( d , 1));// , _BlendSize);
    }

    res.x -= noise( pos *3 + float3(0,0,_Time.y)) * .1;

    res -= tex2Dlod( _AudioMap , float4( res.y * .04 , 0,0,0)) * .04;
    
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
    
    for( int i=0; i< 40 ; i++ ){
        
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
   

  float3 color = 0;

    
    
  if( res.y > -.5){
      
    float3 pos = ro + rd * res.x;
    float3 nor = calcNormal( pos );

    color = nor * .5 + .5;

    float3 refl = reflect( rd , nor );

    
         half4 skyData =UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,refl);
         half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR);

color = skyColor;
    color *= saturate(tex2Dlod( _AudioMap , float4( res.y * .04 + .1 , 0,0,0)));
            
            
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
