Shader "BibPit/Moon"
{


    Properties {

   
        _Cubemap ("Cubemap", Cube) = "" { }
    _BaseColor ("BaseColor", Color) = (1,1,1,1)

    
    _NumSteps("Num Trace Steps",int) = 10
    _DeltaStepSize("DeltaStepSize",float) = .01
    _StepRefractionMultiplier("StepRefractionMultiplier", float) = 0
    
    _ColorMultiplier("ColorMultiplier",float)=1
  
    _Opaqueness("_Opaqueness",float) = 1
    _IndexOfRefraction("_IndexOfRefraction",float) = .8
    _RefractionBackgroundSampleExtraStep("_RefractionBackgroundSampleExtraStep",float) = 0

    _ReflectionColor ("ReflectionColor", Color) = (1,1,1,1)
    _ReflectionSharpness("ReflectionSharpness",float)=1
    _ReflectionMultiplier("_ReflectionMultiplier",float)=1
    
    _CenterOrbOffset ("CenterOrbOffset", Vector) = (0,0,0)
    _CenterOrbColor ("CenterOrbColor", Color) = (1,1,1,1)
    _CenterOrbFalloff("CenterOrbFalloff", float) = 6
    _CenterOrbFalloffSharpness("CenterOrbFalloffSharpness", float) = 1

    _CenterOrbImportance("CenterOrbImportance", float) = .3

    _NoiseColor ("NoiseColor", Color) = (1,1,1,1)
    _NoiseOffset ("NoiseOffset", Vector) = (0,0,0)
    _NoiseSize("NoiseSize", float) = 1
    _NoiseSpeed("NoiseSpeed", float) = 1
    _NoiseImportance("NoiseImportance", float) = 1
    _NoiseSharpness("NoiseSharpness",float) = 1
    _NoiseSubtractor("NoiseSubtractor",float)=0
    _OffsetMultiplier("OffsetMu_OffsetMultiplier",float)=0

    _AudioID("AudioID",float) = 0
    _MoonMultiplier("MoonMul_MoonMultiplier",float) = 1
    
      _AudioPow ("_AudioPow", float) = 2
      _AudioMultiplier ("_AudioMultiplier",float) =1000
    }


  SubShader{

            // Draw ourselves after all opaque geometry
        Tags { "Queue" = "Geometry" }



      Cull Off
    Pass{
CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

    samplerCUBE _CubeMap;
      
    float4 _BaseColor;
    float4 _CenterOrbColor;
    float4 _NoiseColor;
    int _NumSteps;
    float _DeltaStepSize;
    float _NoiseSize;
    float _CenterOrbFalloff;
    float _NoiseImportance;
    float _CenterOrbImportance;
    float _CenterOrbFalloffSharpness;
    float _StepRefractionMultiplier;
    float _NoiseSharpness;
    float _NoiseSpeed;
    float _Opaqueness;
    float _NoiseSubtractor;
    float _ColorMultiplier;
    float _RefractionBackgroundSampleExtraStep;
    float _IndexOfRefraction;
    float3 _CenterOrbOffset;
    float3 _NoiseOffset;

    float _ReflectionSharpness;
    float _ReflectionMultiplier;
    float4 _ReflectionColor;

    float _OffsetMultiplier;

    float _AudioID;

    float _MoonMultiplier;

    #include "Assets/Shaders/Chunks/BibPit.cginc"
    #include "Assets/Shaders/Chunks/hsv.cginc"


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
          
          
      };


            sampler2D _BackgroundTexture;


             struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
            };




//Our vertex function simply fetches a point from the buffer corresponding to the vertex index
//which we transform with the view-projection matrix before passing to the pixel program.
varyings vert ( appdata vertex ){



  varyings o;
     float4 p = vertex.position;
     float3 n =  vertex.normal;//_NormBuffer[id/3];

        float3 worldPos = mul (unity_ObjectToWorld, float4(p.xyz,1.0f)).xyz;
        o.pos = UnityObjectToClipPos (float4(p.xyz,1.0f));
        o.nor = n;//normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f)));; 
        o.ro = p;//worldPos.xyz;
        o.localPos = p.xyz;
        
        
        float3 localP = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
        float3 eye = normalize(localP - p.xyz);


        o.unrefracted = eye;
        o.rd = refract( eye , -n , _IndexOfRefraction);
        o.eye = refract( -normalize(_WorldSpaceCameraPos - worldPos) , normalize(mul (unity_ObjectToWorld, float4(n.xyz,0.0f))) , _IndexOfRefraction);
    
        o.worldNor = normalize(mul (unity_ObjectToWorld, float4(-n,0.0f)).xyz);
        o.lightDir = normalize(mul( unity_ObjectToWorld , float4(1,-1,0,0)).xyz);

        float4 refractedPos = UnityObjectToClipPos( float4(o.ro + o.rd * 1.5,1));
    o.grabPos = ComputeGrabScreenPos(refractedPos);
    

  return o;

}




//Pixel function returns a solid color for each point.
float4 frag (varyings v) : COLOR {
  float3 col =0;//hsv( float(v.face) * .3 , 1,1);


  
  float dt = _DeltaStepSize;
  float t = 0;
  float c = 0.;
float3 p = 0;

float totalSmoke = 0;
  float3 rd = normalize(v.rd);

  	//volumetric rendering
	float s=0.1,fade =1;
	col =0;


  float iterations = 17;
float formuparam = 0.93;

float volsteps = 20;
float stepsize = .4;

float zoom  = 0.100;
float tile  = 0.70;

float brightness = 0.0015;
float darkmatter = 0.300;
float distfading = 0.730;
float saturation = 0.850;

float speed = 1.5;
float amount = .3;
float planet = dot( rd , float3(0.6,1,.3));

planet= saturate(planet);

planet = saturate(pow(planet,10) * 100);

  for(int i =0 ; i < _NumSteps; i++ ){



float stepVal = float(i)/float(_NumSteps);
    	float3 p=v.ro+s*rd*stepsize;
		//p = abs( tile - p%(tile*2.)); // tiling fold
		float pa,a=pa=0;
    p += float3(
      sin(_Time.x * speed * 1.7  * sin(float(i) * 10) + float(i)*100 +10),
      sin(_Time.x * speed + float(i)),
      sin(_Time.x * speed * 1.4  * sin(float(i) * 10) + float(i))
     ) * amount;
		for (int j=0; j<iterations; j++) { 
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		//a*=a*a; // add contrast

    a*= 0.1;
		if (i>6) fade*=1.-dm; // dark matter, don't render near
		//v+=float3(dm,dm*.5,0.);
		//col+=fade;

    //float3 aCol = (sampleAudio( a * .1).x) * hsv(stepVal,1,1) * a * .1;
     float3 aCol = tex2D(_ColorMap, stepVal  * .1)  * a *a* .1* (sampleAudio( a * .1 , N_ID(float(i)) ).x) * 1;
      col += planet * .1*  tex2D(_ColorMap, stepVal  * .1 + .5) * 1 * (4* sampleAudio( a * .08 ,N_ID(float(i)) ) + 0) * a;// * (sampleAudio( a * .1 , stepVal ).x) * 1;
		col+=aCol;// .0001 * hsv(stepVal * 1 , 1,1) * a;//float3(s,s*s,s*s*s*s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
	 s+=stepsize;
   
  }

  //col = lerp( col , 1-col, planet);

col *= _MoonMultiplier;
col = saturate( col * .3 )/ .3;



//col = col * .001;

  //col = c;
    return float4( col.xyz , 1);//saturate(float4(col,3*length(col) ));


}

      ENDCG

    }
  }

  Fallback Off


}
