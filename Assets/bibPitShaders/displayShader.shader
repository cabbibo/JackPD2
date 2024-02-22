Shader "BibPit/displayShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale", Vector) = (1, 1,1,1)
        _BlurSize("_BlurSize", float) = 1
        _BloomThreshold("Bloom Threshold", float) = 1
        _BloomIntensity("Bloom Intensity", float) = 1
    }


    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            #include "Assets/Shaders/Chunks/snoise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _FrameTexture;

            float2 _Size;
            float2 _Offset;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }



            float _BloomThreshold;
            float _BloomIntensity;
            float _BlurSize;

            float4 _MainTex_TexelSize; // Automatically provided by Unity

            
// A simple Gaussian blur function
float4 GaussianBlur(float2 uv) {
    float3 result = float3(0, 0, 0);
    float weightSum = 0.0;
    float sigma = _BlurSize;
    
    float textureWidth = 1.0 / _MainTex_TexelSize.x;
    float textureHeight = 1.0 / _MainTex_TexelSize.y;

    // Sample around the pixel in a 'kernelSize x kernelSize' region.
    int kernelSize = 10; // Example kernel size
    float2 texelSize = 1/float2(6620,1080);//_MainTex_TexelSize.xy; // Texture size in texels

    for (int x = -kernelSize; x <= kernelSize; x++) {
        for (int y = -kernelSize; y <= kernelSize; y++) {
            float2 sampleUv = uv + float2(x, y) * texelSize * sigma;
            float weight = exp(-(x*x + y*y) / (2*sigma*sigma));
            weightSum += weight;
            result += weight * tex2D(_MainTex, sampleUv).rgb;
        }
    }
    
    return float4(result / weightSum, 1.0);
}

// Function to apply bloom effect
float4 ApplyBloom(float2 uv) {
    float4 origColor = tex2D(_MainTex, uv);
    float3 bloomColor =  GaussianBlur(uv).rgb;
float3 bloomPortion = max(bloomColor.rgb - _BloomThreshold, 0.0);
    // Applying Gaussian blur to the bloom color

    if (any(bloomPortion > 0.01)) {
    bloomColor = GaussianBlur(uv).rgb * _BloomIntensity * bloomPortion;
    }else{
        bloomColor = float3(0,0,0);
    }
   //  bloomColor = bloomColor * _BloomIntensity;

     float4 gb = GaussianBlur(uv);
    // Combine with original color
    return float4(origColor.rgb + bloomColor, 1.0);

   return gb;

    return origColor;
}


            half4 frag (v2f i) : SV_Target
            {
                half2 centeredUV = i.uv * _Size + _Offset + (1.0 - _Size) * 0.5;
                
                float4 frameColor = tex2D(_FrameTexture, i.uv);
                
                float n = snoise(float3(i.uv * float2(10,1),_Time.y * .2));
                float frameVal = abs(cos(frameColor.r * frameColor.r  * 2 + n));
                frameVal *= frameVal * frameVal;
                
                
                float4 mainTextureR = tex2D(_MainTex, centeredUV + frameVal * .001);
                float4 mainTextureG = tex2D(_MainTex, centeredUV+ frameVal * .0015);
                float4 mainTextureB = tex2D(_MainTex, centeredUV+ frameVal * .002);




                
                float4 color = float4(mainTextureR.r, mainTextureG.g, mainTextureB.b, 1);

              //  color = ApplyBloom(i.uv);

           

                return lerp( color , 1-color, frameVal * frameVal * frameVal*frameVal * .2) * saturate(frameColor * frameColor * 10);// saturate(frameVal);
               // return tex2D(_MainTex, centeredUV);
            }
            ENDCG
        }
    }
}