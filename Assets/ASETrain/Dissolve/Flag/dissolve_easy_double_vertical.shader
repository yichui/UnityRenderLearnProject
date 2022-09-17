// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "dissolve_easy_double_vertical"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_ChaneAmount("ChaneAmount", Range( 0 , 1)) = 0
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (1,1,1,0)
		_EdgeIntensity("EdgeIntensity", Float) = 2
		[Toggle(_MANUCONTROL_ON)] _MANUCONTROL("MANUCONTROL", Float) = 1
		_Spread("Spread", Range( 0 , 1)) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Float) = 0
		_ObjectScale("ObjectScale", Float) = 3.5
		[Toggle(_DEV_INV_ON)] _DEV_INV("DEV_INV", Float) = 0
		[Toggle(_ISSPHERE_ON)] _ISSPHERE("IS SPHERE", Float) = 0
		_Radius("Radius", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _DEV_INV_ON
		#pragma shader_feature_local _ISSPHERE_ON
		#pragma shader_feature_local _MANUCONTROL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float4 _EdgeColor;
		uniform float _EdgeIntensity;
		uniform float _Radius;
		uniform float _ObjectScale;
		uniform float _ChaneAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		uniform float _NoiseSpeed;
		uniform float _EdgeWidth;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 temp_cast_0 = (0.18).xxx;
			o.Albedo = temp_cast_0;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld50 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 objToWorld65 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			#ifdef _ISSPHERE_ON
				float staticSwitch69 = ( length( ( ase_worldPos - objToWorld65 ) ) - _Radius );
			#else
				float staticSwitch69 = ( ase_worldPos.y - objToWorld50.y );
			#endif
			float clampResult53 = clamp( ( staticSwitch69 / _ObjectScale ) , 0.0 , 1.0 );
			#ifdef _DEV_INV_ON
				float staticSwitch60 = ( 1.0 - clampResult53 );
			#else
				float staticSwitch60 = clampResult53;
			#endif
			float mulTime27 = _Time.y * 0.2;
			#ifdef _MANUCONTROL_ON
				float staticSwitch29 = _ChaneAmount;
			#else
				float staticSwitch29 = frac( mulTime27 );
			#endif
			float Gradient21 = ( 2.0 * ( ( staticSwitch60 - (-_Spread + (staticSwitch29 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) );
			float2 temp_cast_1 = (_NoiseSpeed).xx;
			float2 panner38 = ( 1.0 * _Time.y * temp_cast_1 + i.uv_texcoord);
			float Noise40 = ( 1.0 - tex2D( _Noise, panner38 ).r );
			float temp_output_41_0 = ( Gradient21 - Noise40 );
			float clampResult18 = clamp( ( 1.0 - ( distance( temp_output_41_0 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 temp_output_17_0 = ( _EdgeColor * _EdgeIntensity * clampResult18 );
			o.Emission = temp_output_17_0.rgb;
			o.Alpha = 1;
			clip( step( 0.5 , temp_output_41_0 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
-20.66667;606.6667;1218;583;3238.937;632.034;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;72;-3606.261,-918.8062;Inherit;False;3065.723;1182.897;Gradient;28;68;21;45;33;46;4;60;6;59;32;29;30;5;28;53;27;55;56;69;70;51;71;67;49;50;66;64;65;;0.5355241,0.1732526,0.6886792,1;0;0
Node;AmplifyShaderEditor.TransformPositionNode;65;-3317.552,-581.2033;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;64;-3298.852,-740.1025;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-3025.846,-634.9542;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;50;-3095.596,-205.9267;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;49;-3108.939,-389.2054;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LengthOpNode;67;-2872.012,-626.1389;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2878.811,-545.9424;Inherit;False;Property;_Radius;Radius;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-2776.397,-353.962;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-2735.81,-621.3424;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;69;-2506.096,-537.9518;Inherit;False;Property;_ISSPHERE;IS SPHERE;13;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2579.04,-289.7956;Inherit;False;Property;_ObjectScale;ObjectScale;11;0;Create;True;0;0;0;False;0;False;3.5;3.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2524.322,-190.0972;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;55;-2370.17,-396.7761;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;53;-1978.417,-360.5133;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;28;-2281.322,-201.0972;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2214.363,16.97004;Inherit;False;Property;_ChaneAmount;ChaneAmount;2;0;Create;True;0;0;0;False;0;False;0;0.978;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2128.901,122.2673;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;0;False;0;False;0;0.142;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;29;-1900.826,-95.27551;Inherit;False;Property;_MANUCONTROL;MANUCONTROL;6;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;32;-1795.141,41.57412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-1819.559,-281.5875;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;6;-1595.214,-88.04505;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-2467.963,970.4759;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-2346.695,1165.283;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;60;-1645.736,-348.3073;Inherit;False;Property;_DEV_INV;DEV_INV;12;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;38;-2143.363,1010.822;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1380.731,-270.9305;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-1149.224,-253.4418;Inherit;False;Constant;_Float0;Float 0;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-1862.298,967.7393;Inherit;True;Property;_Noise;Noise;8;0;Create;True;0;0;0;False;0;False;-1;None;7da82abd63ecc064d9280c270463f4ef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;33;-1184.582,-32.7315;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;-1534.622,1080.325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-964.5776,-174.0132;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-832.2249,-306.1987;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-1357.246,1027.787;Inherit;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-714.9317,587.7551;Inherit;True;21;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-723.1948,791.192;Inherit;False;40;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-294.7196,777.7957;Inherit;False;1076.535;443.9261;EdgeColor;5;10;8;11;12;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;-469.9781,616.9067;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-440.074,851.1588;Inherit;False;Constant;_Softness;Softness;8;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-160.7259,1080.65;Inherit;False;Property;_EdgeWidth;EdgeWidth;3;0;Create;True;0;0;0;False;0;False;0.1;0.72;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;8;-70.9341,827.7957;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;167.9258,901.7218;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;411.9799,898.7374;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;314.914,149.7424;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;5;0;Create;True;0;0;0;False;0;False;2;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;18;610.8157,985.7156;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;152.7809,-43.4623;Inherit;False;Property;_EdgeColor;EdgeColor;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,1,0.9802451,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;419.0864,-247.9893;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;577.5219,37.55616;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;47;-139.9847,-338.7441;Inherit;False;Property;_MainColor;MainColor;10;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.4528302,0.4528302,0.4528302,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;68;-2934.706,-798.3472;Inherit;False;SphereMask;-1;;1;988803ee12caf5f4690caee3c8c4a5bb;0;3;15;FLOAT3;0,0,0;False;14;FLOAT;0;False;12;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;54;-21.43223,498.5986;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-431.9507,-100.8423;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;f42a623e1100b47459655eb1503642e3;9f8d9d9e60979574ea22974d2e2c08d4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;1016.895,-235.4926;Inherit;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;0;False;0;False;0.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;15;777.6322,-188.3969;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1226.116,-109.3308;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;dissolve_easy_double_vertical;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Opaque;;AlphaTest;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;66;0;64;0
WireConnection;66;1;65;0
WireConnection;67;0;66;0
WireConnection;51;0;49;2
WireConnection;51;1;50;2
WireConnection;70;0;67;0
WireConnection;70;1;71;0
WireConnection;69;1;51;0
WireConnection;69;0;70;0
WireConnection;55;0;69;0
WireConnection;55;1;56;0
WireConnection;53;0;55;0
WireConnection;28;0;27;0
WireConnection;29;1;28;0
WireConnection;29;0;5;0
WireConnection;32;0;30;0
WireConnection;59;0;53;0
WireConnection;6;0;29;0
WireConnection;6;3;32;0
WireConnection;60;1;53;0
WireConnection;60;0;59;0
WireConnection;38;0;37;0
WireConnection;38;2;39;0
WireConnection;4;0;60;0
WireConnection;4;1;6;0
WireConnection;36;1;38;0
WireConnection;33;0;4;0
WireConnection;33;1;30;0
WireConnection;58;0;36;1
WireConnection;45;0;46;0
WireConnection;45;1;33;0
WireConnection;21;0;45;0
WireConnection;40;0;58;0
WireConnection;41;0;23;0
WireConnection;41;1;42;0
WireConnection;8;0;41;0
WireConnection;8;1;35;0
WireConnection;11;0;8;0
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;18;0;12;0
WireConnection;48;0;1;0
WireConnection;48;1;47;0
WireConnection;17;0;14;0
WireConnection;17;1;16;0
WireConnection;17;2;18;0
WireConnection;54;1;41;0
WireConnection;15;0;48;0
WireConnection;15;1;17;0
WireConnection;15;2;18;0
WireConnection;0;0;57;0
WireConnection;0;2;17;0
WireConnection;0;10;54;0
ASEEND*/
//CHKSM=B5FDC6468B08EA34B78CBE49E2DE0754BA4B5E52