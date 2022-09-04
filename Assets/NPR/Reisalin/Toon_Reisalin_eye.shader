Shader "NPRToon/Toon_Reisalin_Eye"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump"{}
        _DetalMap("Detal Map", 2D)= "white" {}


        _EnvMap("Env Map", CUBE) = "white"{}
        //_EnvMapHDR ("EnvMap HDR", Range(-1, 1)) = 0
        _EnvIntensity("EnvIntensity", Range(0, 100)) = 1
        _Roughness ("Roughness", Range(0, 1)) = 0
        _EnvRotate("Env Rotate", Range(0, 360)) = 0


        _ParallaxIntensity("Parallax Intensity", float) = -0.1

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
            sampler2D _BaseMap, _NormalMap, _DetalMap;

            samplerCUBE _EnvMap;
            //float _EnvMapHDR;
            float _EnvIntensity, _Roughness, _EnvRotate;

            float _ParallaxIntensity;

            float3 RotateAround(float degree , float3 target)
            {
                float rad = degree * UNITY_PI / 180;
                float2x2 m_rotate = float2x2(cos(rad), -sin(rad), sin(rad), cos(rad));

                float2 dir_rotate = mul(m_rotate , target.xz);
                target = float3(dir_rotate.x, target.y, dir_rotate.y);
                return target;
            }

            inline float3 ACESFilm(float3 x)
            {
                float a = 2.51f;
                float b = 0.003f;
                float c = 2.41f;
                float d = 0.59f;
                float e = 0.14f;
                return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
            }

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


               
              
                half4 detalMap = tex2D(_DetalMap, i.uv);
                half3 detalColor = detalMap.rgb;

                //法线贴图
                half4 normalMap = tex2D(_NormalMap, i.uv);
                half3 normalData = UnpackNormal(normalMap);
                float3x3 TBN = float3x3(tangentDir, binormalDir, normalDir);

                //视差偏移
                float2 parallaxDepth = saturate(distance(i.uv, float2(0.5, 0.5)) * 5) ;//获取当前uv到中心点的距离
                parallaxDepth = smoothstep(0.5, 1, parallaxDepth);
                parallaxDepth = 1.0 - parallaxDepth;//反向
                //求出切线空间下的观察方向
                float3 tanViewDir = normalize(mul(TBN, viewDir));
                //视差偏移的偏移值
                // float2 parallax_offset = tanViewDir.xy * _ParallaxIntensity;
                // float2 parallax_offset = tanViewDir.xy / (tanViewDir.z) * _ParallaxIntensity;
                float2 parallax_offset = tanViewDir.xy / (tanViewDir.z + 0.42f) * _ParallaxIntensity * parallaxDepth;

                half4 baseColor = tex2D(_BaseMap, i.uv + parallax_offset);

                normalDir = normalize(mul(normalData,TBN));
                //取反法线方向，获得虹膜内凸法线
                normalData.xy = -normalData.xy;
                float3 normalDir_Iris = normalize(mul(normalData, TBN));

                //漫反射
                half NDotL = max(0.0,  dot(normalDir_Iris, lightDir));
                half halfLambert =  (NDotL + 1.0) * 0.5;
                half3 finalDiffuse = halfLambert  * baseColor * baseColor;


                //环境反射、边缘光
                half3 reflectDir = reflect(-viewDir, normalDir);
                reflectDir = RotateAround(_EnvRotate, reflectDir);

                float rougnness = lerp(0.0, 0.95, saturate(_Roughness));
                rougnness = rougnness * (1.7 - 0.7 * rougnness);
                float mipLevel = rougnness * 6.0;
                half4 colorCubMap = texCUBElod(_EnvMap, float4(reflectDir, mipLevel ));
                //天空盒颜色可能是HDR的，需要转会普通的颜色
                float _EnvMapHDR = 1;
                half envColor = DecodeHDR(colorCubMap, _EnvMapHDR);
                half3 finalEnv = envColor  * _EnvIntensity;
                //明度
                half envLumin = dot(finalEnv, float3(0.299f, 0.587f, 0.114f));
                //调整环境色明度
                finalEnv = envLumin * finalEnv;

                //利用视差偏移，模拟眼球玻璃体


                half3 finalColor = finalDiffuse + finalDiffuse * finalEnv * finalEnv + detalColor;//finalDiffuse + finalEnv;
                half3 encodeColor = sqrt( ACESFilm(finalColor));
                int mode = 1;       
                if(_TestMode == mode++)
                    return halfLambert;


                //return finalEnv.xyzz;//finalColor.xyzz;
                return float4(encodeColor,1);//finalEnv.xyzz;
                //return parallaxDepth.xyyy;
            }
            ENDCG
        }
    }
}
