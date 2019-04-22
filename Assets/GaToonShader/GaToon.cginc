
struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
	float3 normal : NORMAL;
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
	float3 pos : TEXCOORD1;
	float3 normal : TEXCOORD2;
	float3 worldPos : TEXCOORD3;
	float3 worldNormal : TEXCOORD4;
};

float4 _VirtualLightColor;
float4 _VirtualLightPos;
fixed4 _LightColor0;
float _MinLightPower;

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Color;

float _ShadowPower;
float _ShadowScale;
float _ShadowBlur;

sampler2D _ShadowColorMask;
float4 _ShadowColor1;
float4 _ShadowColor2;

float _Use_RimLight;
sampler2D _RimLightMask;
float4 _RimLightColor;
float _RimLightPower;
float _RimLightScale;

float4 _OutlineColor;
float _OutlineWidth;

sampler2D _Matcap;
float4 _MatcapColor;
sampler2D _MatcapMask;
float _InverseMatcap;

v2f vert_outline (appdata v)
{
	v2f o;

	o.uv = TRANSFORM_TEX(v.uv, _MainTex);

	#ifdef _USE_OUTLINE_ON
	if (unity_StereoEyeIndex != 0)
	{
		o.uv.x += .5;
	}
	v.vertex += float4(normalize(v.normal) * _OutlineWidth, 0);
	#endif

	o.vertex = UnityObjectToClipPos(v.vertex);
	return o;
}

v2f vert (appdata v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.normal = v.normal;
	o.pos = v.vertex;
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);

	return o;
}

float4 AddColor(float4 col, v2f i)
{
	float isExistingDirectionalLight = !(_WorldSpaceLightPos0.x == 0 && _WorldSpaceLightPos0.y == 0 && _WorldSpaceLightPos0.z == 0);
	float3 directionalLightPos = lerp(_VirtualLightPos, _WorldSpaceLightPos0, isExistingDirectionalLight);
	float3 lightDir = normalize(directionalLightPos);
	float3 viewDir = normalize(_WorldSpaceCameraPos-i.worldPos);
	
	float3 ambientLightColor = ShadeSH9(float4(i.worldNormal, 1));

	// albedo
	col.rgb *= _Color.rgb; // + ambientLightColor;

	// shadow
	float3 diffuse = smoothstep(0.5-_ShadowBlur/2.0, 0.5+_ShadowBlur/2.0, max(0, dot(directionalLightPos, i.worldNormal)+(1-_ShadowScale)));
	float3 shadowColor = lerp(_ShadowColor1, _ShadowColor2, tex2D(_ShadowColorMask, i.uv).r) * (1-_ShadowPower);
	col.rgb *= saturate(diffuse + shadowColor);

	// mapcap
	float2 normalProj = normalize(i.worldNormal) * 0.5 + 0.5;
	fixed4 matcapCol = tex2D(_Matcap, normalProj);
	#ifdef _CALCMODE_ADD
	col.rgb += lerp(matcapCol.rgb, 1-matcapCol.rgb, _InverseMatcap) * _MatcapColor * tex2D(_MatcapMask, i.uv).r;
	col.rgb = saturate(col.rgb);
	#else
	col.rgb *= lerp(1, lerp(matcapCol.rgb, 1-matcapCol.rgb, _InverseMatcap) * _MatcapColor, tex2D(_MatcapMask, i.uv).r);
	#endif

	// rim
	col.rgb += saturate(_RimLightColor.rgb * (_RimLightScale-abs(dot(viewDir, normalize(i.worldNormal)))) * max(-dot(lightDir, viewDir), 0) * _RimLightPower) * tex2D(_RimLightMask, i.uv).r * _Use_RimLight * isExistingDirectionalLight;

	return col;
}

float4 AddColorLambert(float4 col, v2f i)
{
	float isExistingDirectionalLight = !(_WorldSpaceLightPos0.x == 0 && _WorldSpaceLightPos0.y == 0 && _WorldSpaceLightPos0.z == 0);
	float3 directionalLightPos = lerp(_VirtualLightPos, _WorldSpaceLightPos0, isExistingDirectionalLight);
	float3 lightDir = normalize(directionalLightPos);
	float3 viewDir = normalize(_WorldSpaceCameraPos-i.worldPos);

	//specular
	//float3 specular = pow(max(0, dot(viewDir, reflect(-lightDir, i.worldNormal))), 2);
	//col.rgb += specular;

	// lambart
	float3 lightColor = saturate(lerp(_VirtualLightColor.rgb, _LightColor0, isExistingDirectionalLight));
	float3 diffuse = pow(max(0, dot(reflect(-lightDir, i.worldNormal), viewDir))*0.5+0.5, 2);
	//float3 diffuse = max(_MinLightPower, dot(reflect(-lightDir, i.worldNormal), viewDir));
	float3 shadowColor = lerp(_ShadowColor1, _ShadowColor2, tex2D(_ShadowColorMask, i.uv).r) * (1-_ShadowPower);
	col.rgb = saturate(tex2D(_MainTex, i.uv) * _Color.rgb * diffuse * lightColor);

	return col;
}