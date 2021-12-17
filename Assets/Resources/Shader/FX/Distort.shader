Shader "Tuyoo/FX/Distort"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		[HDR]_MainColor("Main Color",Color) = (1,1,1,1)
		_AddTex("Add Tex", 2D) = "white" {}
		[HDR]_AddColor("Add Color",Color) = (0,0,0,1)
		_RefractionNoise("Refraction Noise", 2D) = "white" {}
		_RefractionNoiseFlowX("Refraction Noise Flow X", Range( -1 , 1)) = 0
		_RefractionNoiseFlowY("Refraction Noise Flow Y", Range( -1 , 1)) = 0
		_RefractionNoiseFlowSpeed("Refraction Noise Flow Speed",Range(0,3)) = 0.5
		_NormalTex("NormalTex", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range(0,5)) = 1
		_RefractionMask("Refraction Mask (Red * Alpha)", 2D) = "white" {}
		_RefractionIntensity("Refraction Mask Intensity", Range( 0 , 1)) = 0.8366607

		[HideInInspector]SrcMode("SrcMode", int) = 5
		[HideInInspector]DstMode("DstMode", int) = 10
		[HideInInspector]CullMode("CullMode", int) = 2
		
	}
	
	SubShader
	{
		Tags 
		{
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane" 
			"RFX4" = "Particle"
		}
		LOD 200
		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend[SrcMode][DstMode]
		Cull [CullMode]
		ColorMask RGB
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		GrabPass{ "_GrabTex" }


		Pass
		{
			Name "Unlit"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv_screen : TEXCOORD1;
				float4 uv : TEXCOORD2;
				float4 ase_color : COLOR;
			};

			uniform sampler2D _GrabTex;

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _MainColor;
			uniform sampler2D _AddTex;
			uniform float4 _AddTex_ST;
			uniform float4 _AddColor;
			uniform sampler2D _RefractionNoise;
			uniform float4 _RefractionNoise_ST;
			uniform float _RefractionNoiseFlowX;
			uniform float _RefractionNoiseFlowY;
			uniform float _RefractionNoiseFlowSpeed;
			uniform sampler2D _NormalTex;
			uniform float4 _NormalTex_ST;
			uniform float _NormalIntensity;
			uniform sampler2D _RefractionMask;
			uniform float4 _RefractionMask_ST;
			uniform float _RefractionIntensity;

			inline float4 ASE_ComputeGrabScreenPos( float4 pos )
			{
				#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
				#else
				float scale = 1.0;
				#endif
				float4 o = pos;
				o.y = pos.w * 0.5f;
				o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
				return o;
			}
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ASE_ComputeGrabScreenPos(ComputeScreenPos(ase_clipPos));
				o.uv_screen = screenPos;
				
				o.uv.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.uv.zw = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				

				float4 screenPos = i.uv_screen;
				float4 ase_grabScreenPos = screenPos;//ASE_ComputeGrabScreenPos( screenPos );
				float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;

				float3 refractionFlow = float3(-_RefractionNoiseFlowX, -_RefractionNoiseFlowY, 1);
				float time = _Time.y * _RefractionNoiseFlowSpeed;

				float2 panner3 = ( 1.0 * time * float2( 0,0.3 ) + i.uv.xy);
				float2 panner4 = ( 1.0 * time * float2( 0.5,0 ) + i.uv.xy);

				float cos6 = cos( 0.8 * time );
				float sin6 = sin( 0.8 * time );
				float2 rotator6 = mul( i.uv.xy - float2( 0.5,0.5 ) , float2x2( cos6 , -sin6 , sin6 , cos6 )) + float2( 0.5,0.5 );

				float cos7 = cos( -1.0 * time );
				float sin7 = sin( -1.0 * time );
				float2 rotator7 = mul( i.uv.xy - float2( 0.5,0.5 ) , float2x2( cos7 , -sin7 , sin7 , cos7 )) + float2( 0.5,0.5 );

				

				half3 noiseFlow = (( ( tex2D( _RefractionNoise, (panner3*_RefractionNoise_ST.xy + _RefractionNoise_ST.zw) ) + 
					tex2D( _RefractionNoise, (panner4*_RefractionNoise_ST.xy + _RefractionNoise_ST.zw) ) + 0.5 ) * 
					( 0.5 + tex2D( _RefractionNoise, (rotator6*_RefractionNoise_ST.xy + _RefractionNoise_ST.zw) ) + 
					tex2D( _RefractionNoise, (rotator7*_RefractionNoise_ST.xy + _RefractionNoise_ST.zw) ) )
					* refractionFlow)).rgb;

				float2 uv_NormalTex = i.uv.xy * _NormalTex_ST.xy + _NormalTex_ST.zw;
				float2 uv_mask = i.uv.xy * _RefractionMask_ST.xy + _RefractionMask_ST.zw;

				float4 ref = tex2D(_RefractionMask, uv_mask) ;
				float mask = ref.r * ref.a;

				float3 normal = lerp(float3(0,0,1),UnpackNormal(tex2D(_NormalTex, uv_NormalTex)), _NormalIntensity);

				float2 uv_refraction = ( noiseFlow + normal).xy * mask * _RefractionIntensity * 0.1 * i.ase_color.r;

				float4 screenColor50 = tex2D( _GrabTex, ( ( (ase_grabScreenPosNorm).xy / ase_grabScreenPosNorm.a ) + uv_refraction ) );

				float4 refractionCol = (float4(screenColor50.rgb , saturate( screenColor50.a )));
				fixed4 finalColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv + uv_refraction, _MainTex)) * _MainColor;
				//finalColor = lerp(finalColor,finalColor * _MainColor,refractionCol.a);
				fixed alpha = finalColor.a * abs(sign(mask)) * i.ase_color.a;
				float4 add = tex2D(_AddTex, TRANSFORM_TEX(i.uv + uv_refraction, _AddTex))* _AddColor;
				add.rgb *= add.a;
				finalColor = refractionCol * lerp(float4(1,1,1,1),finalColor,mask) + add;
				finalColor.a = alpha;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "CustomMaterialInspector_Particle"
	
	
}
