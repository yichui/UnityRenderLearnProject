// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "dissolve_easy"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChaneAmount("ChaneAmount", Range( 0 , 1)) = 0.3613173
		_EdgeWidth("EdgeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (1,1,1,0)
		_EdgeIntensity("EdgeIntensity", Float) = 2
		[Toggle(_MANUCONTROL_ON)] _MANUCONTROL("MANUCONTROL", Float) = 1
		_Spread("Spread", Range( 0 , 1)) = 0.3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MANUCONTROL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EdgeColor;
		uniform float _EdgeIntensity;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChaneAmount;
		uniform float _Spread;
		uniform float _EdgeWidth;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime27 = _Time.y * 0.2;
			#ifdef _MANUCONTROL_ON
				float staticSwitch29 = _ChaneAmount;
			#else
				float staticSwitch29 = frac( mulTime27 );
			#endif
			float Gradient21 = ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (staticSwitch29 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread );
			float clampResult18 = clamp( ( 1.0 - ( distance( Gradient21 , 0.5 ) / _EdgeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult15 = lerp( tex2DNode1 , ( _EdgeColor * tex2DNode1 * _EdgeIntensity ) , clampResult18);
			o.Emission = lerpResult15.rgb;
			o.Alpha = 1;
			clip( ( tex2DNode1.a * step( 0.5 , Gradient21 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
109;529;1218;595;3605.139;547.9456;4.015975;True;False
Node;AmplifyShaderEditor.CommentaryNode;24;-2880.659,131.7052;Inherit;False;1757.092;664.7321;Gradient;11;21;4;6;2;29;5;28;27;30;32;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2792.09,329.0292;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2583.388,706.5691;Inherit;False;Property;_Spread;Spread;8;0;Create;True;0;0;0;False;0;False;0.3;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;28;-2549.09,318.0292;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2668.85,601.2719;Inherit;False;Property;_ChaneAmount;ChaneAmount;3;0;Create;True;0;0;0;False;0;False;0.3613173;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;32;-2249.628,625.876;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;29;-2355.313,489.0266;Inherit;False;Property;_MANUCONTROL;MANUCONTROL;7;0;Create;True;0;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-2186.623,211.4137;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;06790fd623e1f5b45bedb9245558f5dd;870b0127bd0608a45a8c4ce044af3a84;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;6;-2049.701,496.2571;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1835.218,313.3715;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;33;-1578.208,555.6967;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;25;-294.7196,777.7957;Inherit;False;1076.535;443.9261;EdgeColor;6;9;10;8;11;12;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-1347.572,265.7248;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-497.666,611.0515;Inherit;False;21;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-266.2084,857.5829;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-160.7259,1080.65;Inherit;False;Property;_EdgeWidth;EdgeWidth;4;0;Create;True;0;0;0;False;0;False;0.1;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;8;-70.9341,827.7957;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;167.9258,901.7218;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-431.9507,-100.8423;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;f42a623e1100b47459655eb1503642e3;f42a623e1100b47459655eb1503642e3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;314.914,149.7424;Inherit;False;Property;_EdgeIntensity;EdgeIntensity;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;411.9799,898.7374;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;244.7809,-41.4623;Inherit;False;Property;_EdgeColor;EdgeColor;5;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;18;610.8157,985.7156;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;7;-50.43085,503.9981;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;495.1505,45.11758;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;15;847.9559,-127.0983;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;182.481,217.7216;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1231.316,-132.7308;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;dissolve_easy;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;28;0;27;0
WireConnection;32;0;30;0
WireConnection;29;1;28;0
WireConnection;29;0;5;0
WireConnection;6;0;29;0
WireConnection;6;3;32;0
WireConnection;4;0;2;1
WireConnection;4;1;6;0
WireConnection;33;0;4;0
WireConnection;33;1;30;0
WireConnection;21;0;33;0
WireConnection;8;0;23;0
WireConnection;8;1;9;0
WireConnection;11;0;8;0
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;18;0;12;0
WireConnection;7;1;23;0
WireConnection;17;0;14;0
WireConnection;17;1;1;0
WireConnection;17;2;16;0
WireConnection;15;0;1;0
WireConnection;15;1;17;0
WireConnection;15;2;18;0
WireConnection;3;0;1;4
WireConnection;3;1;7;0
WireConnection;0;2;15;0
WireConnection;0;10;3;0
ASEEND*/
//CHKSM=5FCD1CBC96320B720CF9335E7D613D7FB001EC63