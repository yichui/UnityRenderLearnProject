Shader "NPRToon/Toon_Reisalin_skin"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        // _NormalMap("Normal Map",2D) = "bump"{}
        _DiffuseMap("Ramp Map", 2D)= "white" {}
       

        _TintLayer1("TintLayer1 Color" , Color) = (0.5, 0.5, 0.5, 1)
        _TintLayer1_Offset("TintLayer1 Offset",Range(-1, 1)) = 0

        _TintLayer2("TintLayer2 Color" , Color) = (0.5, 0.5, 0.5, 0)
        _TintLayer2_Offset("TintLayer2 Offset",Range(-1, 1)) = 0

        _TintLayer3("TintLayer3 Color" , Color) = (0.5, 0.5, 0.5, 0)
        _TintLayer3_Offset("TintLayer3 Offset",Range(-1, 1)) = 0

       
        _SpecularColor("Specular Color 高光颜色" , Color) = (1, 1, 1, 1)
        _SpecularSkininess("Specular Skininess",float) = 100
        _SpecularIntensity("Specular Intensity",Range(0, 100)) = 1

        _FresnelMin("Fresnel Min",Range(-1, 2)) = 1
        _FresnelMax("Fresnel Max",Range(-1, 2)) = 1

        _EnvMap("Env Map", CUBE) = "white"{}
        _EnvMapHDR ("EnvMap HDR", float) = 1
        _EnvIntensity("EnvIntensity", Range(0, 100)) = 1
        _Roughness ("Roughness", Range(0, 1)) = 0


        _OutlinePower("Outline Power",Range(0,100)) = 1
        _OutLineColor("Outline Color",Color)=(1,1,1,1)

        //输出各种模式颜色
        [KeywordEnum(None,halfLambert)] _TestMode("TestMode测试模式",Int) = 0
    
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags {"LightMode" = "ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float4 color :COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertColor : TEXCOORD3;

                float3 tangentDir:TEXCOORD4;
                float3 binormalDir:TEXCOORD5;

            };


            int _TestMode;    
            sampler2D _BaseMap, _AOMap, _DiffuseMap, _SpecMap;
            //sampler2D _NormalMap;

            float _TintLayer1_Offset,_TintLayer2_Offset,_TintLayer3_Offset;
            float4 _TintLayer1, _TintLayer2, _TintLayer3;

            float4 _SpecularColor;
            float _SpecularIntensity, _SpecularSkininess;


            float _FresnelMin, _FresnelMax;

            samplerCUBE _EnvMap;
            float _EnvMapHDR, _EnvIntensity, _Roughness;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.worldPos =  mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertColor = v.color;

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld,float4(v.tangent.xyz, 0.0)).xyz);
                o.binormalDir = normalize(cross(o.worldNormal, o.tangentDir) * v.tangent.w);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {

                half3 normalDir = normalize(i.worldNormal);
                half3 tangentDir = normalize(i.tangentDir);
                half3 binormalDir = normalize(i.binormalDir);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //贴图数据
                half4 baseColor = tex2D(_BaseMap, i.uv);
                half AO = 1.0;
             
          
                //漫反射
                half NDotL = dot(normalDir, lightDir);
                half halfLambert = (NDotL + 1.0) * 0.5;
                half diffuseTerm = halfLambert * AO;

                half3 finalDiffuse = half3(0,0,0);
                //漫反射第一层上色
                half2 uvRamp1 = half2(diffuseTerm + _TintLayer1_Offset, 0.5);
                half toonDiffuse1 = tex2D(_DiffuseMap, uvRamp1).r;
                half3 tintColor1 = lerp(half3(1, 1, 1), _TintLayer1.rgb, toonDiffuse1 * _TintLayer1.a * i.vertColor.r);
                finalDiffuse = baseColor * tintColor1;

                //漫反射第2层上色
                half2 uvRamp2 = half2(diffuseTerm + _TintLayer2_Offset, 1 - i.vertColor.g);
                half toonDiffuse2 = tex2D(_DiffuseMap, uvRamp2).r;
                half3 tintColor2 = lerp(half3(1, 1, 1), _TintLayer2.rgb, toonDiffuse2 * _TintLayer2.a );
                finalDiffuse = finalDiffuse * tintColor2;

                //漫反射第3层上色
                half2 uvRamp3 = half2(diffuseTerm + _TintLayer3_Offset, 1 - i.vertColor.b);
                half toonDiffuse3 = tex2D(_DiffuseMap, uvRamp3).r;
                half3 tintColor3 = lerp(half3(1 ,1 ,1), _TintLayer3.rgb, toonDiffuse3 * _TintLayer3.a);
                finalDiffuse = finalDiffuse * tintColor3;


                //高光反射
                half3 halfDir = normalize(lightDir + viewDir);
                float NdotH = dot(normalDir, halfDir);
                half specTerm = max(0.0001, pow(NdotH, _SpecularSkininess )) * AO;
                half3 finalSpec = specTerm * _SpecularColor * _SpecularIntensity ;

                


                //环境反射、边缘光
                half fresnel = 1.0 - dot(normalDir, viewDir);
                fresnel = smoothstep(_FresnelMin, _FresnelMax, fresnel);
                half3 reflectDir = reflect(-viewDir, normalDir);
                float rougnness = lerp(0.0, 0.95, saturate(_Roughness));
                rougnness = rougnness * (1.7 - 0.7 * rougnness);
                float mipLevel = rougnness * 6.0;
                half4 colorCubMap = texCUBElod(_EnvMap, float4(reflectDir, mipLevel ));
                //天空盒颜色可能是HDR的，需要转会普通的颜色
                half envColor = DecodeHDR(colorCubMap, _EnvMapHDR);
                half3 finalEnv = envColor * fresnel * _EnvIntensity * toonDiffuse1;
                

                half3 finalColor = finalDiffuse + finalSpec + finalEnv;

                int mode = 1;
                if(_TestMode == mode++)
                    return halfLambert;


                //return finalEnv.xyzz;//finalColor.xyzz;
                return finalColor.xyzz;
            }
            ENDCG
        }

        //描边pass
        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            //开启正向剔除
            Cull Front

            CGPROGRAM
        
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //float2 texcoord : TEXCOORD1;
                float3 normal : NORMAL;
                float4 color :COLOR;
                //float4 tangent :TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
             
                float4 vertColor : TEXCOORD1;
            };

            sampler2D _BaseMap;
             // 描边
            float _OutlinePower;
            float4 _OutLineColor;

            v2f vert(a2v v) 
            {
                v2f o;
                
                float3 viewPos = UnityObjectToViewPos(v.vertex);
                float3 worldNormal =  UnityObjectToWorldNormal(v.normal);
                float3 outlineDir = normalize( mul((float3x3)UNITY_MATRIX_V, worldNormal));
                //o.pos = mul(UNITY_MATRIX_P, float4( viewPos,1));
                viewPos += outlineDir * _OutlinePower * 0.001 * v.color.a;
                o.pos = mul(UNITY_MATRIX_P, float4( viewPos,1));

                //世界空间下做的顶点外扩
                /*float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal =  UnityObjectToWorldNormal(v.normal);
                worldPos += worldNormal * _OutlinePower * 0.01;
                o.pos = mul(UNITY_MATRIX_VP, float4( worldPos,1));*/
                o.uv = v.uv;//TRANSFORM_TEX(v.uv,_BaseMap);
                o.vertColor = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float3 baseColor = tex2D(_BaseMap, i.uv.xy).xyz;
                half maxComponent = max(max(baseColor.r,baseColor.g),baseColor.b) - 0.004;
                half3 saturatedColor = step(maxComponent.rrr, baseColor)* baseColor;
                saturatedColor = lerp(baseColor.rgb, saturatedColor, 0.6);
                half3 outlineColor = 0.8*saturatedColor *baseColor * _OutLineColor.xyz;
                return float4(outlineColor, 1.0);

            }

            ENDCG
        }
    }
}