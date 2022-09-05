// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire"
{
	Properties
	{
		_noise("noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_Gradient("Gradient", 2D) = "white" {}
		_TintColor("TintColor", Color) = (0.7075472,0.3117031,0,0)
		_Softness("Softness", Range( 0 , 1)) = 0.5
		_EmissInstensity("EmissInstensity", Float) = 10
		_GradientEndControl("GradientEndControl", Float) = 2
		_EndMiss("EndMiss", Range( 0 , 1)) = 0
		_FireShape("FireShape", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _TintColor;
		uniform float _EmissInstensity;
		uniform float _EndMiss;
		uniform sampler2D _Gradient;
		uniform float _GradientEndControl;
		uniform sampler2D _noise;
		uniform float2 _NoiseSpeed;
		uniform float4 _noise_ST;
		uniform float _Softness;
		uniform sampler2D _FireShape;
		uniform float _NoiseIntensity;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break32 = ( _TintColor * _EmissInstensity );
			float4 GradientEnd27 = ( ( 1.0 - tex2D( _Gradient, i.uv_texcoord ) ) * _GradientEndControl );
			float2 uv_noise = i.uv_texcoord * _noise_ST.xy + _noise_ST.zw;
			float2 panner8 = ( 1.0 * _Time.y * _NoiseSpeed + uv_noise);
			float Noise19 = tex2D( _noise, panner8 ).r;
			float4 appendResult33 = (float4(break32.r , ( break32.g + ( _EndMiss * GradientEnd27 * Noise19 ) ).r , break32.b , 0.0));
			o.Emission = appendResult33.xyz;
			float clampResult16 = clamp( ( Noise19 - _Softness ) , 0.0 , 1.0 );
			float4 temp_cast_2 = (clampResult16).xxxx;
			float4 temp_cast_3 = (Noise19).xxxx;
			float4 Gradient18 = tex2D( _Gradient, i.uv_texcoord );
			float4 smoothstepResult13 = smoothstep( temp_cast_2 , temp_cast_3 , Gradient18);
			float4 appendResult51 = (float4(( ( (Noise19*2.0 + -1.0) * _NoiseIntensity * GradientEnd27 ) + i.uv_texcoord.x ).r , i.uv_texcoord.y , 0.0 , 0.0));
			float4 tex2DNode39 = tex2D( _FireShape, appendResult51.xy );
			float clampResult59 = clamp( ( ( tex2DNode39.r * tex2DNode39.g ) * 3.0 ) , 0.0 , 1.0 );
			float Shape54 = clampResult59;
			o.Alpha = ( smoothstepResult13 * Shape54 ).r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
197;491;1065;465;5197.242;489.3836;4.633686;True;False
Node;AmplifyShaderEditor.CommentaryNode;28;-2706.681,-401.482;Inherit;False;1564.371;591.9843;GradientAndNoise;13;10;7;8;5;1;19;12;6;18;25;24;26;27;;0.5087332,1,0.2122642,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2656.681,-315.847;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;10;-2602.868,62.53821;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;1;0;Create;True;0;0;0;False;0;False;0,0;0,-0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-2654.207,-105.3488;Inherit;False;0;5;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-2391.42,-347.8847;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;d1451a5d2248c544aa3563d9e0f989dd;d1451a5d2248c544aa3563d9e0f989dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;8;-2384.868,16.53823;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;6;-2025.239,-346.9087;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;-2171.021,-13.50072;Inherit;True;Property;_noise;noise;0;0;Create;True;0;0;0;False;0;False;-1;2ebd184bf9d0ba345bde1da5aa344364;8a2d10844b3e73e478f0951f7cffec43;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-1784.602,-69.01223;Inherit;False;Property;_GradientEndControl;GradientEndControl;6;0;Create;True;0;0;0;False;0;False;2;3.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-1728.015,-280.4193;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;55;-2918.354,265.1512;Inherit;False;1780.596;595.2556;FireShape;14;42;45;52;46;44;40;43;51;39;53;54;57;58;59;;0.6603774,0.4280892,0.2087042,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1521.05,-113.4516;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-1837.104,9.098771;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-1366.31,-197.4097;Inherit;True;GradientEnd;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-2965.662,504.816;Inherit;False;19;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;52;-2771.498,513.2018;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-2615.596,654.4872;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;9;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-2611.355,744.4067;Inherit;False;27;GradientEnd;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;40;-2539.671,405.6201;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2400.961,578.4151;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-2256.361,409.8157;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;51;-2143.01,461.1852;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;39;-1979.214,357.1898;Inherit;True;Property;_FireShape;FireShape;8;0;Create;True;0;0;0;False;0;False;-1;None;e39b46ac98584754aa20a59bb5fe21ab;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-1696.726,569.2378;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-1683.75,384.3297;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-966.5555,689.3961;Inherit;False;Property;_Softness;Softness;4;0;Create;True;0;0;0;False;0;False;0.5;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-662.5073,186.4765;Inherit;False;Property;_EmissInstensity;EmissInstensity;5;0;Create;True;0;0;0;False;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;11;-675.6495,-2.415702;Inherit;False;Property;_TintColor;TintColor;3;0;Create;True;0;0;0;False;0;False;0.7075472,0.3117031,0,0;1,0.3497481,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1544.337,513.1865;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-795.431,605.1283;Inherit;False;19;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;59;-1422.558,496.2477;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-539.9399,434.6554;Inherit;False;19;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-479.5134,242.8487;Inherit;False;Property;_EndMiss;EndMiss;7;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-347.2318,95.72031;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-462.9292,313.1682;Inherit;False;27;GradientEnd;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-1715.389,-363.396;Inherit;False;Gradient;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-563.6295,642.1041;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-329.8317,779.6673;Inherit;False;19;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;32;-181.7132,-61.85136;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;16;-403.619,644.5386;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-389.0322,544.4675;Inherit;False;18;Gradient;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-181.1293,248.768;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;-1289.275,461.8951;Inherit;False;Shape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-40.01326,123.9487;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;13;-86.15303,541.9993;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;183.1133,802.0339;Inherit;False;54;Shape;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;392.4467,619.4169;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;33;70.28676,-64.85138;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;684.9562,164.6322;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;1;1;0
WireConnection;8;0;7;0
WireConnection;8;2;10;0
WireConnection;6;0;12;0
WireConnection;5;1;8;0
WireConnection;26;0;6;0
WireConnection;24;0;26;0
WireConnection;24;1;25;0
WireConnection;19;0;5;1
WireConnection;27;0;24;0
WireConnection;52;0;42;0
WireConnection;44;0;52;0
WireConnection;44;1;45;0
WireConnection;44;2;46;0
WireConnection;43;0;44;0
WireConnection;43;1;40;1
WireConnection;51;0;43;0
WireConnection;51;1;40;2
WireConnection;39;1;51;0
WireConnection;53;0;39;1
WireConnection;53;1;39;2
WireConnection;57;0;53;0
WireConnection;57;1;58;0
WireConnection;59;0;57;0
WireConnection;30;0;11;0
WireConnection;30;1;29;0
WireConnection;18;0;6;0
WireConnection;14;0;20;0
WireConnection;14;1;15;0
WireConnection;32;0;30;0
WireConnection;16;0;14;0
WireConnection;37;0;34;0
WireConnection;37;1;36;0
WireConnection;37;2;38;0
WireConnection;54;0;59;0
WireConnection;35;0;32;1
WireConnection;35;1;37;0
WireConnection;13;0;21;0
WireConnection;13;1;16;0
WireConnection;13;2;22;0
WireConnection;41;0;13;0
WireConnection;41;1;56;0
WireConnection;33;0;32;0
WireConnection;33;1;35;0
WireConnection;33;2;32;2
WireConnection;0;2;33;0
WireConnection;0;9;41;0
ASEEND*/
//CHKSM=4B0D5DC794442FC282443E68283DD949D612C8DB