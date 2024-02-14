

float _GlobalColorSchemeID;
sampler2D _ColorScheme;

float4 GetSchemeColor( float lookup , float colorSchemeID ){
  return tex2D(_ColorScheme , float2(lookup , (colorSchemeID+.5)/16)  );
}

float4 GetGlobalColor(float lookup ){
  return GetSchemeColor(lookup,_GlobalColorSchemeID); 
}


float4 GetGlobalColorWithID(float lookup , float id ){
  return GetSchemeColor(lookup,_GlobalColorSchemeID); 
}


