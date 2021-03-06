﻿Shader "GaToon/GaToonShader_Unlit"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)]
        _Cull("Cull", Float) = 2 // Back

		/*
		[Space(10)]
		_EyeBrowsMask ("EyeBrowsMask", 2D) = "black" {}
		[IntRange]_Stencil ("Stencil No", Range(0, 255)) = 184
		[Enum(UnityEngine.Rendering.CompareFunction)]
		_StencilComp1 ("Stencil Comp1", Int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]
		_StencilComp2 ("Stencil Comp2", Int) = 0
		[Enum(UnityEngine.Rendering.StencilOp)]
        _StencilOp("Stencil Type", Float) = 0
		*/

		[Space(10)]
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Albedo", Color) = (1, 1, 1, 1)
		_MinLightPower ("Min Light Power", Range(0, 1)) = 0.1

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
		[Header(Outline)]
		[Toggle]_Use_Outline ("Use Outline", Float) = 0
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth ("Outline Width", Float) = 0.001

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
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100
		Cull [_Cull]

		CGINCLUDE
		#pragma fragment frag
		#include "UnityCG.cginc"
		#include "GaToon.cginc"
		#pragma multi_compile _CALCMODE_ADD _CALCMODE_MUL
        ENDCG

		// 眉毛の位置を消す
		/*Pass
		{
			Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp1]
				Pass [_StencilOp]
            }

			CGPROGRAM

			#pragma vertex vert
			
			fixed4 frag (v2f i) : SV_Target
			{
				discard;

				return fixed4(0, 1, 0, 1);
			}

			ENDCG
		}*/

		// Outline
		Pass
		{
			Cull Front

			CGPROGRAM
			#pragma vertex vert_outline
			
			#pragma shader_feature _USE_OUTLINE_ON
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}

		Pass
		{
		    /*Stencil
            {
                Ref [_Stencil]
                Comp NotEqual
            }*/

			CGPROGRAM
			#pragma vertex vert
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				//col = AddColor(col, i);
				col = AddColor(col, i);

				return col;
			}
			ENDCG
		}

		// 眉毛の位置を登録する
		/*Pass
		{
		    Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp2]
                Pass [_StencilOp]
            }
			
			Cull [_Cull]

			CGPROGRAM
			#pragma vertex vert

			sampler2D _EyeBrowsMask;
			
			fixed4 frag (v2f i) : SV_Target
			{
				if (tex2D(_EyeBrowsMask, i.uv).r < 1) discard;

				fixed4 col = tex2D(_MainTex, i.uv);
				col = saturate(AddColor(col, i));

				return col;
			}
			ENDCG
		}*/
	}
}
