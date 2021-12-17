// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tuyoo/FX/Fresnel"
{
	Properties
	{
		_FresnelScale("边缘光亮度", Float) = 1
		_FresnelPower("边缘光宽度", Float) = 5
		[HDR]_FresnelColor("边缘光颜色", Color) = (1,1,1,1)
		_Float0("亮度", Range( 0 , 1)) = 1

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend One One
		Cull Back
		ColorMask RGBA
		ZWrite Off
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
			};

			uniform float _FresnelScale;
			uniform float _FresnelPower;
			uniform float4 _FresnelColor;
			uniform float _Float0;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
#endif
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode1 = ( 0.0 + _FresnelScale * pow( 1.0 - fresnelNdotV1, _FresnelPower ) );
				
				
				finalColor = ( ( saturate( fresnelNode1 ) * _FresnelColor ) * _Float0 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18000
1927;8;1906;1044;1070.319;298.4194;1.125325;True;False
Node;AmplifyShaderEditor.RangedFloatNode;3;-830.192,76.16919;Inherit;False;Property;_FresnelScale;边缘光亮度;0;0;Create;False;0;0;False;0;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-824.9921,155.4691;Inherit;False;Property;_FresnelPower;边缘光宽度;1;0;Create;False;0;0;False;0;5;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1;-561.0922,16.36915;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;9;-200.7068,44.77847;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-234,356;Inherit;False;Property;_FresnelColor;边缘光颜色;2;1;[HDR];Create;False;0;0;False;0;1,1,1,1;1.741101,1.515782,0.7305797,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;42,87;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;11;66.25858,371.1488;Inherit;False;Property;_Float0;亮度;3;0;Create;False;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;340.8379,142.7079;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;565.4013,89.95196;Float;False;True;-1;2;ASEMaterialInspector;100;1;MaJiang/Model/Fresnel;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;4;1;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;1;2;3;0
WireConnection;1;3;4;0
WireConnection;9;0;1;0
WireConnection;5;0;9;0
WireConnection;5;1;6;0
WireConnection;10;0;5;0
WireConnection;10;1;11;0
WireConnection;0;0;10;0
ASEEND*/
//CHKSM=841CA67D53D4A705E6DD8C4903E4B2F561978112