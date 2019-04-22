Shader "GaToon/GaToonShaderVoxel_Unlit"
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
		[Header(Voxel)]
		_VoxelScale("VoxelScale", Range(0, 1)) = 0.1

		[Space(10)]
		[Header(Tessellation)]
		_TessVector ("Tessellation Vector", Vector) = (1, 1, 1, 1)
		_TessFactor("Tessellation", Range(1, 50)) = 1
		_TessMask ("Tessllation Mask", 2D) = "white" {}
		_TessRaito ("Tessellation Raito", Range(0, 1))  = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma exclude_renderers gles
			#pragma target 5.0
			#pragma vertex vert_voxel
			#pragma hull hull_voxel
			#pragma domain domain_voxel
			#pragma geometry geom_voxel
			#pragma fragment frag_voxel
			
			#include "UnityCG.cginc"
			#include "GaToon.cginc"
			#include "GatoFunc.cginc"
			#include "Tessellation.cginc"

			float _VoxelScale;

			float4 _TessVector;
			float _TessFactor;
			sampler2D _TessMask;
			float _TessRaito;

			struct v2h
			{
				float2 uv : TEXCOORD0;
				float3 pos : POS;
				float3 normal : NORMAL;
			};

			struct h2d_main
			{
				float3 pos : POS;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct h2d_const
			{
				float tessFactor[3] : SV_TessFactor;
				float insideTessFactor : SV_InsideTessFactor;
			};

			struct d2g
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 pos : TEXCOORD1;
				float3 normal : TEXCOORD2;
			};

			struct g2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 pos : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				float3 worldNormal : TEXCOORD4;
			};
			
			v2h vert_voxel (appdata v)
			{
				v2h o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.pos = v.vertex;
				o.normal = v.normal;
				return o;
			}

			[domain("tri")]
			[partitioning("integer")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("hullConst_voxel")]
			[outputcontrolpoints(3)]
			h2d_main hull_voxel(InputPatch<v2h, 3> i, uint id : SV_OutputControlPointID)
			{
				h2d_main o = (h2d_main)0;
				o.pos = i[id].pos.xyz;
				o.normal = i[id].normal;
				o.uv = i[id].uv;
				return o;
			}

			h2d_const hullConst_voxel(InputPatch<v2h, 3> i)
			{
				h2d_const o = (h2d_const)0;

				float4 p0 = float4(i[0].pos, 1);
				float4 p1 = float4(i[1].pos, 1);
				float4 p2 = float4(i[2].pos, 1);
				float4 uv = float4((i[0].uv + i[1].uv + i[2].uv)/3, 0, 0);
				//float4 workTessFactor;
				//workTessFactor = lerp(1, UnityDistanceBasedTess(p0, p1, p2, _MinDist, _MaxDist, _TessFactor), _TessFactor > 1 && tex2Dlod(_TessMask, uv).r == 1);

				float id = rand(uv+5);

				float4 workTessFactor = lerp (1, _TessVector, _TessFactor > 1 && tex2Dlod(_TessMask, uv).r == 1 && id < _TessRaito);

				o.tessFactor[0] = workTessFactor.x;
				o.tessFactor[1] = workTessFactor.y;
				o.tessFactor[2] = workTessFactor.z;
				o.insideTessFactor = workTessFactor.w;

				return o;
			}

			[domain("tri")]
			d2g domain_voxel (h2d_const hsConst, const OutputPatch<h2d_main, 3> i, float3 bary : SV_DomainLocation)
			{
				d2g o = (d2g)0;

				o.pos = bary.x * i[0].pos + bary.y * i[1].pos + bary.z * i[2].pos;
				o.vertex = UnityObjectToClipPos(float4(o.pos, 1));
				o.normal = normalize(bary.x * i[0].normal + bary.y * i[1].normal + bary.z * i[2].normal);
				o.uv = bary.x * i[0].uv + bary.y * i[1].uv + bary.z * i[2].uv;

				return o;
			}

			[maxvertexcount(48)]
			void geom_voxel(triangle d2g input[3], inout TriangleStream<g2f> outStream)
			{
				g2f o;

				d2g v1 = input[0];
				d2g v2 = input[1];
				d2g v3 = input[2];

				float3 center = (v1.pos+v2.pos+v3.pos)/3.0;

				o.pos = center;
				o.worldPos = mul(unity_ObjectToWorld, o.pos);

				float scale = _VoxelScale;

				float4x3 offsetMat = float4x3(
										float3( 1,  1,  1),
										float3(-1,  1,  1),
										float3( 1, -1,  1),
										float3(-1, -1,  1)
									 );

				o.uv = (v1.uv+v2.uv+v3.uv)/3.0;;

				[unroll]
				for (int i = 0; i < 3; i++)
				{
					float3 vpos = input[i].pos;

					// ポリゴンを追加
					[unroll]
					for (int m = 0; m < 6; m++) 
					{
						o.normal = (offsetMat[0].xyz+offsetMat[1].xyz+offsetMat[2].xyz+offsetMat[3].xyz)/4.0;
						o.worldNormal = UnityObjectToWorldNormal(o.normal);

						// 頂点を追加
						[unroll]
						for (int v = 0; v < 4; v++) 
						{
							o.vertex = UnityObjectToClipPos(float4(vpos+ offsetMat[v] * scale, 1));
							outStream.Append(o);
							offsetMat[v].xyz = offsetMat[v].yzx;

							if (m == 2) offsetMat[v].xyz = offsetMat[v].yxz * float3(1, 1, -1);
						}
						outStream.RestartStrip();
					}
					
				}

			}
			
			fixed4 frag_voxel (g2f i) : SV_Target
			{

				fixed4 col = tex2D(_MainTex, i.uv);

				v2f data;
				data.uv = i.uv;
				data.vertex = float4(i.pos, 1);
				data.pos = i.pos;
				data.normal = i.normal;
				data.worldPos = i.worldPos;
				data.worldNormal = i.worldNormal;

				col = saturate(AddColor(col, data));
				
				return col;
			}
			ENDCG
		}
	}
}
