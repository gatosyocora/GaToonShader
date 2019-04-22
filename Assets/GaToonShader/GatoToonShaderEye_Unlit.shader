Shader "GaToon/GaToonShaderEye_Unlit"
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
		_MinEnvLightPower ("Min Environment Light Power", Range(0, 1)) = 0

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

		[Space(10)]
		[Header(Eye)]
		[Toggle]_Is_Quiche_Eye ("Is Quiche Eye", Float) = 0
		[Toggle]_Is_Mirror ("Is Mirror", Float) = 0
		_ULevel ("U Level", Range(0, 0.5)) = 0
		_VLevel ("V Level", Range(0, 1)) = 0

		_TopLevel ("Top Level", Range(0, 1)) = 0
		_BottomLevel ("Bottom Level", Range(0, 1)) = 0
		_LeftLevel ("Left Level", Range(0, 1)) = 0
		_RightLevel ("Right Level", Range(0, 1)) = 0

		_EyeTex ("Eye Texture", 2D) = "white" {}
		_BlackLevel ("Black Level", Range(0, 1)) = 0
		_Speed ("Speed", Float) = 1

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
		#pragma shader_feature _STENCILWRITE_ON
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
			
			#include "UnityCG.cginc"
			
			fixed4 frag (v2f i) : SV_Target
			{
				discard;

				return fixed4(0, 1, 0, 1);
			}
			ENDCG
		}*/

		/*Pass
		{
		    Stencil
            {
                Ref 0
                Comp Equal
            }

			Cull Front

			CGPROGRAM
			#pragma vertex vert_outline
			#pragma shader_feature _USE_OUTLINE_ON
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}*/

		Pass
		{
			/*Stencil
            {
                Ref [_Stencil]
                Comp NotEqual
            }*/

			Cull [_Cull]

			CGPROGRAM
			#pragma vertex vert
			#include "GatoFunc.cginc"
			#pragma shader_feature _IS_QUICHE_EYE_ON
			#pragma shader_feature _Is_Mirror_ON

			float _ULevel;
			float _VLevel;
			sampler2D _EyeTex;
			float _BlackLevel;
			float _Speed;

			float _TopLevel;
			float _BottomLevel;
			float _LeftLevel;
			float _RightLevel;
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				col = AddColor(col, i);

				// ここから
				float2 eyeUV;
				#ifdef _IS_QUICHE_EYE_ON
					eyeUV = float2(0.2298, 0.696);
				#else
					eyeUV = float2(_ULevel, _VLevel);
				#endif

				float2 uv = i.uv;

				if (uv.x < eyeUV.x && uv.y > eyeUV.y) 
				{
					col = tex2D(_EyeTex, (uv-float2(0, eyeUV.y))*float2(1/eyeUV.x, 1/(1-eyeUV.y)));
				}
				else if (uv.x > 1-eyeUV.x && uv.y > eyeUV.y)
				{
					col = tex2D(_EyeTex, (uv-float2(1-eyeUV.x, eyeUV.y))*float2(1/eyeUV.x, 1/(1-eyeUV.y)));
				}
				else
				{
					return col;
				}

				float a = 2 * UNITY_PI * _Time.y * _Speed;
				
				float3 hsv = float3((cos(a)+1)/2.0, 1, 1);

				float3 color = hsv2rgb(hsv);

				col = lerp(col, 0, (uv.y-eyeUV.y)*1/(1-eyeUV.y)*1/(1-_BlackLevel)) * float4(color, 1);
				// ここまで

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
				col = AddColor(col, i);

				return col;
			}
			ENDCG
		}*/

	}
}
