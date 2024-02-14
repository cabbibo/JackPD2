

Shader "BibPit/Crystals"
{

    Properties {

    _BaseColor ("BaseColor", Color) = (1,1,1,1)
    
    _NumSteps("Num Trace Steps",int) = 10
    _ColorMultiplier("ColorMultiplier",float)=1
  
    _Opaqueness("_Opaqueness",float) = 1
    _IndexOfRefraction("_IndexOfRefraction",float) = .8
    _RefractionBackgroundSampleExtraStep("_RefractionBackgroundSampleExtraStep",float) = 0

    _ReflectionColor ("ReflectionColor", Color) = (1,1,1,1)
    _ReflectionSharpness("ReflectionSharpness",float)=1
    _ReflectionMultiplier("_ReflectionMultiplier",float)=1
  

    _SampleColor ("SampleColor", Color) = (1,1,1,1)
    _SampleTexture("SampleTexture", 2D) = "white" {}
    _SampleSize("SampleSize", float) = 1


    _LightFallOffBase("LightFallOffBase", float) = .1
    _LightFallOffPower("LightFallOffPower", float) = 2
    _LightFallOffMultiplier("LightFallOffMultiplier", float) = 1
    _LightColorMultiplier("LightColorMultiplier", float) = 1


        _AudioMultiplier("_AudioMultiplier",float) = 1
        _AudioPow("_AudioPower",float) = 1
    }


  SubShader{

            // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Geometry+10" }

        // Grab the screen behind the object into _BackgroundTexture
        GrabPass
        {
            "_BackgroundTexture"
        }

      Cull Off
    Pass{
CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

    #include "Assets/Shaders/Chunks/SampleFullAudio.cginc"
    sampler2D _ColorMap;
    float _ID;
      
    float4 _BaseColor;
    float4 _SampleColor;
    int _NumSteps;
    float _Opaqueness;
    float _ColorMultiplier;
    float _RefractionBackgroundSampleExtraStep;
    float _IndexOfRefraction;

    float _ReflectionSharpness;
    float _ReflectionMultiplier;
    float4 _ReflectionColor;

        float _LightFallOffBase;
    float _LightFallOffPower;
    float _LightFallOffMultiplier;
    float _LightColorMultiplier;

    sampler2D _SampleTexture;
    float _SampleSize;


      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 nor : NORMAL;
          float3 ro : TEXCOORD1;
          float3 rd : TEXCOORD2;
          float3 eye : TEXCOORD3;
          float3 localPos : TEXCOORD4;
          float3 worldNor : TEXCOORD5;
          float3 lightDir : TEXCOORD6;
          float4 grabPos : TEXCOORD7;
          float3 unrefracted : TEXCOORD8;
          float3 world : TEXCOORD9;
          float3 color: TEXCOORD10;
          
          
      };


            sampler2D _BackgroundTexture;
            sampler2D _FullColorMap;

 

             struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
            };

//Our vertex function simply fetches a point from the buffer corresponding to the vertex index
//which we transform with the view-projection matrix before passing to the pixel program.
varyings vert ( appdata vertex ){


  
                float nID = (_ID % _NumStems)/_NumStems;

  varyings o;
     float4 p = vertex.position;
     float3 n =  vertex.normal;//_NormBuffer[id/3];

        float3 worldPos = mul (unity_ObjectToWorld, float4(p.xyz,1.0f)).xyz;

      float4 aVal = sampleAudio(p.y,nID);
        o.pos = UnityObjectToClipPos (float4(p.xyz + n * length(aVal) * .1,1.0f));
        o.nor = n;//normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f)));; 
        o.ro = p;//worldPos.xyz;
        o.world = worldPos;
        o.localPos = p.xyz;
        o.color = vertex.color;
        
        
        float3 localP = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
        float3 eye = normalize(localP - p.xyz);


        o.unrefracted = eye;
        o.rd = refract( eye , -n , _IndexOfRefraction);
        o.eye = refract( -normalize(_WorldSpaceCameraPos - worldPos) , normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f))) , _IndexOfRefraction);
        //o.worldNor = mul (unity_ObjectToWorld, float4(n.xyz,0.0f)).xyz;
        o.worldNor = normalize(mul (unity_ObjectToWorld, float4(-n,0.0f)).xyz);
        o.lightDir = normalize(mul( unity_ObjectToWorld , float4(1,-1,0,0)).xyz);

        float4 refractedPos = UnityObjectToClipPos( float4(o.ro + o.rd * 1.5,1));
    o.grabPos = ComputeGrabScreenPos(refractedPos);
    
  return o;

}




float4 projectOnPlane( float3 pos, float3 nor , float3 ro , float3 rd ){

    float hit = 0.0;
    float dotP = dot(rd,nor);

    
    float distToHit = dot(pos - ro, nor) / dotP;

    hit = distToHit;
    if( distToHit < 0 ){
        hit = 0;
    }

    return float4(hit * rd + ro,hit);

}


float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}

float3 ClosestPointOnLine(float3 a, float3 b, float3 p){
    float3 ap = p-a;
    float3 ab = b-a;
    return a + dot(ap,ab)/dot(ab,ab) * ab;
}

float DistToPoint(float3 a, float3 b, float3 p){
    float3 ap = p-a;
    float3 ab = b-a;
    return dot(ap,ab)/dot(ab,ab);
}

//Pixel function returns a solid color for each point.
float4 frag (varyings v) : COLOR {
  float3 col =0;//hsv( float(v.face) * .3 , 1,1);


float c = 0.;
float totalSmoke = 0;
  float3 rd = v.rd;
  
                float nID = (_ID % _NumStems)/_NumStems;
  for(int i =0 ; i < _NumSteps; i++ ){


    float3 planePos = float3(sin(float(i+1) * 11240),sin(float(i+1) * 5151),sin(float(i+1) * 9250)) *1;
    float3 planeUp = normalize(float3(sin(float(i+1) * 1410),sin(float(i+1) * 4100),sin(float(i+1) * 41050)));
    float3 planeLeft = normalize(cross( planeUp , float3(0,1,0) ));
    float3 planeForward = normalize(cross( planeUp , planeLeft ));

    float match = abs(dot( planeUp , normalize(v.rd) ));

  float4 PP = projectOnPlane( planePos, planeUp , v.ro , -v.rd );
  float3 fPos = PP.xyz;
  float x =DistToPoint(planePos , planePos + planeLeft , fPos);
  float y = DistToPoint(planePos , planePos + planeForward , fPos);

  float2 xy = float2(x+sin(float(i) * 5121.), y+sin(float(i) * 4421.));
  float3 newCol = 10*tex2D(_SampleTexture, xy * _SampleSize)* saturate( length(fPos - v.ro)) * match * saturate((1/(20*abs(PP.w)*abs(PP.w))));//abs(dot( normalize(planeUp), normalize(v.rd)));

  newCol = pow( newCol , 3) * 10;
    c = length( newCol);
    totalSmoke += c;

  


    
    col = col * .99 + sampleAudio(c * .01 , nID )* newCol * tex2D(_ColorMap,c * .01 + nID);// hsv(float(i) * .1+ x ,1,1);//_SampleColor;///lerp( lerp(_BaseColor,_CenterOrbColor , saturate(centerOrbDensity)), _NoiseColor , saturate(noiseDensity));// saturate(dot(v.lightDir , nor)) * .1 *c;//hsv(c,.4, dT3D(p*3,float3(0,-1,0))) * c;//hsv(c * .8 + .3,1,1)*c;;// hsv(smoke,1,1) * saturate(smoke);

 
  }





 col *= _ColorMultiplier;

  col = tex2D(_ColorMap, nID);



 float m = dot( normalize(v.unrefracted), normalize(v.nor) );
 //col += pow((1-m),_ReflectionSharpness) * _ReflectionMultiplier * _ReflectionColor;

 col *= 10*sampleAudio(v.ro.y , nID);//

      //  col = tex2D(_AudioMap,float2(totalSmoke *1 + .5,0))  * tex2D(_FullColorMap,float2(totalSmoke *1 + .5,0)) * col;

 // col *= float3(1,0.2,.5) * .5 + .5;

 // col = sampleAudio(totalSmoke * .1,nID)  * tex2D(_ColorMap , nID);//
 // col = sampleAudio(totalSmoke * .01,nID)  * tex2D(_ColorMap , nID);//


    return float4( col.xyz , 1);//saturate(float4(col,3*length(col) ));




}

      ENDCG

    }
  }

  Fallback Off


}
