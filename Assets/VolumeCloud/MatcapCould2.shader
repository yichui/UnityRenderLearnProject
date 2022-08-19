Shader "Unlit/MatcapCloud2"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_MatCapLight("MatCapLight", 2D) = "white" {}
		_EdgeLight("EdgeLight", 2D) = "white" {}
		_EdgeStrength("EdgeStrength", Float) = 0.0
		//	_CloudColor("CloudColor",Color) = 
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" }
			LOD 100

			//Pass
			//{
			//	CGPROGRAM
			//	#pragma vertex vert
			//	#pragma fragment frag
			//	// make fog work

			//	#include "UnityCG.cginc"

			//	struct appdata
			//	{
			//		float4 vertex : POSITION;
			//		float2 uv : TEXCOORD0;
			//		float4 color : TEXCOORD1;
			//	};

			//	struct v2f
			//	{
			//		float2 uv : TEXCOORD0;
			//		float4 pos : SV_POSITION;
			//		float4 scrPos: TEXCOORD1;
			//		float4 color : TEXCOORD2;
			//	};

			//	sampler2D _MainTex;
			//	float4 _MainTex_ST;
			//	sampler2D _EdgeLight;
			//	float _EdgeStrength;


			//	v2f vert(appdata v) {
			//		v2f o;
			//		o.pos = UnityObjectToClipPos(v.vertex);
			//		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			//		o.scrPos = ComputeScreenPos(o.pos);
			//		o.color = v.color;
			//		return o;
			//	}
			//	fixed4 frag(v2f i) :SV_Target{
			//		fixed4 col = tex2D(_MainTex,i.uv);
			//		col.rgb *= 0;
			//		col.a *= i.color.a;
			//		fixed4 edgeCol = tex2D(_EdgeLight,i.scrPos.xy / i.scrPos.w);
			//		col.rgb = (edgeCol)*col.a * _EdgeStrength;
			//		return col;
			//	}
			//	ENDCG
			//}

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float4 texcoord : TEXCOORD1;
					float3 normal : NORMAL;
					float4 color : COLOR;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 pos : SV_POSITION;
					float4 cap :TEXCOORD1;
					float4 scrPos : TEXCOORD2;
					float4 color  : COLOR;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _MatCapLight;

				v2f vert(appdata v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					//法线变换，转置逆矩阵
					fixed3 worldNormal = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
					//转换法线到视空间
					worldNormal = mul((fixed3x3)UNITY_MATRIX_V, worldNormal);
					o.cap.xyz = worldNormal * 0.5 + 0.5;
					//计算顶点在屏幕空间的位置，未归一化
					o.scrPos = ComputeScreenPos(o.pos);
					//如果使用软粒子效果,计算视空间下的深度值，后续与场景深度值作比较
	//#ifdef SOFTPARTICLES_ON
	//				COMPUTE_EYEDEPTH(o.scrPos.z);
	//#endif
					o.color = v.color;

					return o;
				}
				fixed4 frag(v2f i) :SV_Target{
					//如果使用软粒子效果，通过深度值比较，距离云层近的物体，云层透明度高
					//#ifdef SOFTPARTICLES_ON
					////对相机深度纹理采样（输入的是未归一化的srcPos，方法内部做srcPos.xy/srcPos.w透视除法，得到视口坐标）
					////通过LinearEyeDepth方法转换到视空间下的深度
					//fixed sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.scrPos)));
					////这里的i.scrPos.z经过 COMPUTE_EYEDEPTH(o.scrPos.z) 已经存储的是视空间里的深度
					//fixed partZ = i.scrPos.z;
					//fixed fade = saturate(_ParticleFade * (sceneZ - partZ));
					//i.color.a *= fade;
					//#endif

					//光照纹理采样
					fixed4 mc = tex2D(_MatCapLight,i.cap);// *_CloudColor;
					mc.a = 1;
					//主纹理采样
					fixed4 col = tex2D(_MainTex,i.uv);
					

					col.rgb *= i.color * mc * 3;
					col.a *= i.color.a;


					return col;
				}
				ENDCG
			}
		}
}
