Shader "NPRToon/NMRToon"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _SSSMap ("Black Base Map", 2D) = "black" {}
        _IlmMap("ILM Map", 2D) = "grey" {}
        _DetailMap("Detail Map", 2D) = "white" {}
        _ToonThesHold("ToonThesHold", Range(0,1)) = 0.5
        _ToonHardness("ToonHardness", float) = 20

        _SpecAddColor("Spec Color", Color) = (1,1,1,1)
        _SpecSize("Spec Size", Range(0,1)) = 0.1


        _OutlinePower("Outline Power",Range(0,100)) = 7
        _LineColor("Outline Color",Color)=(1,1,1,1)
         _Factor("Outline Factor", float) = 1
        //_SpecularIntensity("Specular Intensity", Range(0,10)) = 1
         //输出各种模式颜色
        [KeywordEnum(None,IlmMap_R,IlmMap_G,IlmMap_B,IlmMap_A,halfLambert,BaseColor)] _TestMode("TestMode测试模式",Int) = 0
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags {"LightMode" = "ForwardBase"}

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

                float4 uv : TEXCOORD0;

                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertColor : TEXCOORD3;
            };


            int _TestMode; 
            sampler2D _BaseMap, _SSSMap, _IlmMap, _DetailMap;
            float _ToonThesHold, _ToonHardness;

           
            float _SpecSize;
            float4 _SpecAddColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;// TRANSFORM_TEX(v.uv, _BaseMap);
                o.uv.zw = v.texcoord;// TRANSFORM_TEX(v.uv, _BaseMap);

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

                float2 uv1 = i.uv.xy;
                float2 uv2 = i.uv.zw;


                half4 baseMap = tex2D(_BaseMap, uv1);
                half3 baseColor = baseMap.rgb;


                half4 sssMap = tex2D(_SSSMap, uv1);
                half3 sssColor = sssMap.rgb;

                //ILM贴图
                half4 ILMMap = tex2D(_IlmMap, uv1);
                float specIntensity = ILMMap.r;//控制高光的强度
                float diffuseContorl = ILMMap.g * 2.0 - 1.0;//控制NdotL光照的偏移值
                float specSize = ILMMap.b;//控制高光的大小（范围或者形状），类似光滑度，越黑的部分高光越小
                float innnerLine = ILMMap.a;//内描线

                half4 DetailMap = tex2D(_DetailMap, uv2);
                half3 detailColor = DetailMap.rgb;

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
                half3 specColor = (_SpecAddColor.xyz + baseColor ) * 0.5;
                half3 finalSpec = specColor * toonSpec * specIntensity;

                //内描线
                half3 innerLineColor = lerp(baseColor * 0.2, fixed3(1,1,1), innnerLine) ;//innnerLine.xxx;
                // half3 innerLineColor = innnerLine.xxx;
                half3 finalLine = innerLineColor * detailColor;
              
                half3 finalColor = (finalSpec + finalDiffuse)* finalLine;
                //颜色校正
                finalColor = sqrt(max(exp2(log2(max(finalColor, 0.0))*2.2),0.0));
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
            float4 _LineColor;
            float _Factor;

            v2f vert(a2v v) 
            {
                v2f o;
                
                float3 viewPos = UnityObjectToViewPos(v.vertex);
                float3 worldNormal =  UnityObjectToWorldNormal(v.normal);
                float3 outlineDir = normalize( mul((float3x3)UNITY_MATRIX_V, worldNormal));
                //o.pos = mul(UNITY_MATRIX_P, float4( viewPos,1));
                viewPos += outlineDir* _OutlinePower * 0.001;
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
                half3 outlineColor = 0.8*saturatedColor *baseColor * _LineColor.xyz;
                return float4(outlineColor, 1.0);

            }

            ENDCG
        }
    }
}
