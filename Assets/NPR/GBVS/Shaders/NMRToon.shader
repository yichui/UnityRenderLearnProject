Shader "NPRToon/NMRToon"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _SSSMap ("Black Base Map", 2D) = "black" {}
        _IlmMap("ILM Map", 2D) = "grey" {}
        _ToonThesHold("ToonThesHold", Range(0,1)) = 0.5
        _ToonHardness("ToonHardness", float) = 20

        _SpecSize("Spec Size", Range(0,1)) = 0.1
        _SpecularIntensity("Specular Intensity", Range(0,10)) = 1
         //输出各种模式颜色
        [KeywordEnum(None,IlmMap_R,IlmMap_G,IlmMap_B,IlmMap_A,halfLambert,BaseColor)] _TestMode("TestMode测试模式",Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 texcoord : TEXCOORD1;
                float3 normal : NORMAL;
                float4 color :COLOR;

            };

            struct v2f
            {
                float4 pos : SV_POSITION;

                float2 uv : TEXCOORD0;

                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertColor : TEXCOORD3;
            };


            int _TestMode; 
            sampler2D _BaseMap, _SSSMap, _IlmMap;
            float _ToonThesHold, _ToonHardness;
            float _SpecSize, _SpecularIntensity;
            // float4 _BaseMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;// TRANSFORM_TEX(v.uv, _BaseMap);

                o.worldPos =  mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.vertColor = v.color;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //向量
                float3 normalDir = normalize(i.worldNormal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                half4 baseMap = tex2D(_BaseMap, i.uv);
                half3 baseColor = baseMap.rgb;


                half4 sssMap = tex2D(_SSSMap, i.uv);
                half3 sssColor = sssMap.rgb;

                //ILM贴图
                half4 ILMMap = tex2D(_IlmMap, i.uv);
                float specIntensity = ILMMap.r;//控制高光的强度
                float diffuseContorl = ILMMap.g * 2.0 - 1.0;//控制NdotL光照的偏移值
                float specSize = ILMMap.b;//控制高光的大小（范围或者形状），类似光滑度，越黑的部分高光越小
                float innnerLine = ILMMap.a;//内描线


                //顶点色
                float ao = i.vertColor.r;

                //diffuse漫反射
                half NDotL = dot(normalDir,lightDir );//-1~1
                half halfLambert = NDotL * 0.5 + 0.5;
                half lambertTerm = halfLambert * ao + diffuseContorl;
                //half toonDiffuse = step(0.1, halfLambert);
                half toonDiffuse =  saturate((lambertTerm - _ToonThesHold) * _ToonHardness);
                half3 finalDiffuse = lerp(sssColor,baseColor ,toonDiffuse);

                //卡通高光
                float NDotV = (dot(normalDir, viewDir) + 1.0) * 0.5;
                float specTerm = NDotV * ao +  diffuseContorl;
                specTerm = halfLambert * 0.9 + specTerm * 0.1;
                half toonSpec =  saturate((specTerm - (1.0 - specSize * _SpecSize)) * 500);
                half3 finalSpec = baseColor * toonSpec * _SpecularIntensity;


                half3 finalColor = finalSpec + finalDiffuse;

                //测试模式使用
                int mode = 1;
                if(_TestMode == mode++)
                    return ILMMap.r;//控制高光的强度
                if(_TestMode ==mode++)
                    return diffuseContorl;  //控制NdotL光照的偏移值
                if(_TestMode ==mode++)
                    return specSize;//控制高光的大小
                if(_TestMode ==mode++)
                    return innnerLine; //内描线
                if(_TestMode ==mode++)
                    return halfLambert; //halfLambert
                
                if(_TestMode ==mode++)
                    return baseColor.xyzz; //BaseColor
              

                return half4(finalColor,1);//half4(finalDiffuse,1);// toonDiffuse.xxxx;//NDotL.xxxx;
            }
            ENDCG
        }
    }
}
