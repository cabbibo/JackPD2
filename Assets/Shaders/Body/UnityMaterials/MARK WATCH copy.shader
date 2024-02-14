Shader "Unlit/markWatch2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainTex1 ("Texture", 2D) = "white" {}
        _MainTex2 ("Texture", 2D) = "white" {}
        _MainTex3 ("Texture", 2D) = "white" {}
        _MainTex4 ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        //ZWrite Off
       // Blend SrcAlpha OneMinusSrcAlpha
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 localCam : TEXCOORD1;
                float3 ro : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _MainTex1;
            sampler2D _MainTex2;
            sampler2D _MainTex3;
            sampler2D _MainTex4;
            float4 _MainTex_ST;

            


// Taken from https://www.shadertoy.com/view/4ts3z2
float tri(in float x){return abs(frac(x)-.5);}
float3 tri3(in float3 p){return float3( tri(p.z+tri(p.y*1.)), tri(p.z+tri(p.x*1.)), tri(p.y+tri(p.x*1.)));}

            

// Taken from https://www.shadertoy.com/view/4ts3z2
float triNoise3D(float3 p,  float spd)
{

    float3 pF = p + float3(4141.122,-4133.441,664.23);
    float z=1.4;
	float rz = 0.;
    float3 bp = p;
	for (float i=0.; i<=3.; i++ )
	{
        float3 dg = tri3(bp*2.);
        pF += (dg+_Time.y*.1*spd);

        bp *= 1.8;
		z *= 1.5;
		pF *= 1.2;
        //p.xz*= m2;
        
        rz+= (tri(pF.z+tri(pF.x+tri(pF.y))))/z;
        bp += 0.14;
	}
	return rz;
}


float3 dTri( float3 p , float s ){

    float3 eps = float3(0.001,0,0);

    float3 nor = float3(
        triNoise3D(p + eps.xyy,s)-triNoise3D(p - eps.xyy,s),
        triNoise3D(p + eps.yxy,s)-triNoise3D(p - eps.yxy,s),
        triNoise3D(p + eps.yyx,s)-triNoise3D(p - eps.yyx,s));


    return normalize(nor);

}


#include "../../Chunks/snoise.cginc"
float GetTextVal( float2 uv , out float which1){

    float which = _Time.x;// floor(_Time.x * 50 +snoise(float3( _Time.x * 10 , 0 , 0))* .5 ) %4;

    //which += floor(((snoise(float3( _Time.x * 5 , 0 , 0))+1)/2)*5);

    which1 = which;

    float v = tex2Dlod( _MainTex1 , float4(uv,0,0)).a;


    return v;

}

float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}

float3 render( float3 ro , float3 rd ){


    float3 col = float3(0,0,0);
    float3 pos = ro;
    float3 fRD = rd;

    float which1;
    float which2;
    
    float outText = GetTextVal( ro.xy, which2 );
    for( int i = 0; i < 50; i++ ){

        float fi = float(i);
        pos += fRD * .002;// lerp( .004 , .001 , (1 +sin(_Time.y * .1  + 424) ) /2 ); 

   // float y = pos.y + .5;

        float2 uv = 1*(pos.xy * (float2(.5, 1))) *3+ float2(.5, .5);

        uv.y += sin( uv.x *10 +_Time.x * 40 + fi/4) * .0;
        
        uv = clamp(uv,0,1);

        //float4 tCol = tex2Dlod(_MainTex, float4(uv,0,0));

        float inVal = GetTextVal( uv , which1);// 1-tCol.x;
        float noiseSize = 1;
        float noiseSpeed = .4;
        float3 noiseNor = dTri(pos*noiseSize,noiseSpeed);
        float noise = triNoise3D(pos*noiseSize,noiseSpeed);

        //fRD += noiseNor * .01;

        

        
        if( inVal > .5 - noise*.8){

           
            col =hsv(fi/100  + _Time * 10,.1,1-fi/120);//lerp(hsv(fi/100  + _Time * 10,1,fi/120), float3(0,0,0),fi/120);

             if( fi == 0 ){
             
                col =.01;//hsv(uv.x+ _Time.x*10+ which1 * .2,1,1);//( (tCol.a-.8+ noise*.5) /.2);//0;

                   if( inVal < 1){
                    
                   // col = 1-2*(inVal-(.5 + noise*.5))/(1-.5 + noise*.5);
                }
            }
            break;
        }

    
    }

    
    
    return col;
}

            v2f vert (appdata v)
            {
                v2f o;
            

                               o.ro  = v.vertex.xyz;
                o.localCam  = mul( unity_WorldToObject, float4( _WorldSpaceCameraPos ,1 )).xyz;
              o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {
                float3 rd =normalize( v.ro - v.localCam);
                float3 col = render( v.ro , rd );

                if( length( col ) <= 0 ){
                    discard;
                }

                float4 f =fixed4(col,length(col));

                if(length(col)> 0 && length(col) <.02){
                    f.a = 1;
                }
                return f;
            }
            ENDCG
        }
    }
}
