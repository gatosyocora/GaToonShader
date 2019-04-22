Shader "GaToon/GatoToonShader_TransparentCutout"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]
        _Cull("Cull", Float) = 2 // Back

		[Space(10)]
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Albedo", Color) = (1, 1, 1, 1)
		_MinLightPower ("Min Light Power", Range(0, 1)) = 0.1
		_CutoutLevel ("Cutout Level", Range(0, 1)) = 1

		[Space(10)]
		[Header(VirtualLight)]
		_VirtualLightColor ("Virtual Light Color", Color) = (1, 0.95, 0.84, 1)
		_VirtualLightPos ("Virtual Light Position", Vector) = (0, 1, 1, 0)

		[Space(10)]
		[Header(Shadow)]
		_ShadowPower ("Shadow Power", Range(0, 1)) = 0
		_ShadowScale ("Shadow Scale", Range(0, 1)) = 1
		_ShadowBlur ("Shadow Blur", Range(0, 1)) = 0

		_ShadowColorMask ("Shadow Color Mask", 2D) = "white" {}

		_ShadowColor1 ("ShadowColor1(black)", Color) = (0, 0, 0, 1)
		_ShadowColor2 ("ShadowColor2(white)", Color) = (0.5, 0.5, 0.5, 1)

		[Space(10)]
		[Header(RimLight)]
		[Toggle]_Use_RimLight ("Use RimLight", Float) = 0
		_RimLightMask ("RimLight Mask", 2D) = "white" {}
		_RimLightColor ("RimLightColor", Color) = (1, 1, 1, 1)
		_RimLightPower ("RimLightPower", Range(0, 1)) = 1
		_RimLightScale ("RimLightScale", Range(0, 1)) = 0.5

		[Space(10)]
		[Header(Matcap)]
		_Matcap ("Matcap", 2D) = "black" {}
		_MatcapColor ("Matcap Color", Color) = (1, 1, 1, 1)
		_MatcapMask ("MatcapMask", 2D) = "white"{}
		[KeywordEnum(ADD, MUL)]_CalcMode("Calc Mode", Float) = 0
		[Toggle]_InverseMatcap ("Inverse", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="AlphaTest" "LightMode"="ForwardBase"}
		LOD 100
		Cull [_Cull]

		Pass
		{

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "GaToon.cginc"
			#pragma multi_compile _CALCMODE_ADD _CALCMODE_MUL

			float _CutoutLevel;
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				clip(col.a - _CutoutLevel);

				col = saturate(AddColor(col, i));

				return col;
			}
			ENDCG
		}
	}
}
