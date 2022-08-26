Shader "NPRToon/NPRToonFace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightMap ("LightMap", 2D) = "white" {}

        //光照阴影
        _ShadowMultColor("Shadow Color暖色调",Color) = (1,1,1) //暖色调
        _DarkShadowMultColor("Shadow Color冷色调",Color) = (0.7,0.7,0.8) //冷色调

        //控制的即是采样Lanbert的水平长度，同时控制了Ao的强度，也控制了Lambert的强度，而且Ao的数值比Lanbert还要小
        _RampShadowRange ("Ramp Shadow Range(Ramp效果的Width)", range(0.0, 1.0)) = 0.8

        _ShadowRamp ("Shadow Ramp", 2D) = "white" {}
        //柔和过渡AO区域与领域
        _ShadowSmooth ("Shadow Smooth 阴影过度", range(0.0, 1.0)) = 0.05
        //控制过渡效果，从而对存在的锯齿进行再一次的柔和过渡
        _RampAOSmooth("Ramp AO Smooth ", range(0.0, 1.0)) = 0.5
        _BrightIntensity("Bright Intensity亮区强度", range(0.4, 10.0)) = 1
        _DarkIntensity ("Dark Intensity暗区强度", range(0.4, 10.0)) = 1

        [Toggle]_Day("Day白天黑夜",Range(0,1)) = 0 //白天黑夜

        _LightThreshold("LightThreshold(阴影Width)",Range(0,1)) = 0.2 

        _CharacterIntensity("CharacterIntensity(角色整体亮度)",Range(0.1,10)) = 1

        //[KeywordEnum(None,LightMap_R,LightMap_G,LightMap_B,LightMap_A,UV,BaseColor,BaseColor_A,Ramp,RampPlane)] _TestMode("_TestMode",Int) = 0
        [KeywordEnum(None,LightMap_R,LightMap_G,LightMap_B,LightMap_A,halfLambert,rampValue,BaseColor,ShadowAOMask,Ramp,Diffuse)] _TestMode("TestMode测试模式",Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            NAME "CHARACTER_BASE"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 vertexColor : Color;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 positionVS : TEXCOORD3;
            };

            int _TestMode;    

            //base Color
            sampler2D _MainTex,_LightMap;
            float4 _MainTex_ST;
            // Diffuse
            sampler2D _ShadowRamp;
            half3 _ShadowMultColor;
            half3 _DarkShadowMultColor;
            half _ShadowSmooth;
            float _RampShadowRange;
            half _RampAOSmooth;
            half _BrightIntensity;
            half _DarkIntensity;
            float _LightThreshold;
            float _CharacterIntensity;

            half _Day;


            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.positionVS = UnityObjectToViewPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 baseColor = tex2D(_MainTex, i.uv);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 normalDir = normalize(i.worldNormal);
                fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 lightColor = _LightColor0.rgb;
                
                float NdotL = dot(normalDir, lightDir);

                float4 LightMap = tex2D(_LightMap, i.uv);
                // 光照贴图信息含义
                // LightMap.r :高光类型Layer,根据值域选择不同的高光类型(eg:BlinPhong 裁边视角光) 
                // LightMap.g :阴影AO ShadowAOMask 
                // LightMap.b :BlinPhong高光强度Mask SpecularIntensityMask 
                // LightMap.a :Ramp类型Layer，根据值域选择不同的Ramp 
                // VertexColor.g :Ramp偏移值,值越大的区域 越容易"感光"(在一个特定的角度，偏移光照明暗) 
                // VertexColor.a :描边粗细
                float SpecularLayerMask = LightMap.r;       // ⾼光类型Layer
                float ShadowAOMask = LightMap.g;            //ShadowAOMask
                float SpecularIntensityMask = LightMap.b;   //SpecularIntensityMask
                float LayerMask = LightMap.a;               //LayerMask Ramp类型Layer
                // return VertexColor.a;                    //描边⼤⼩
                //float RampOffsetMask = VertexColor.g;       //Ramp偏移值,值越⼤的区域 越容易"感光"(在⼀个特定的⾓度，偏移光照明暗)
                float RampOffsetMask = 0; //Ramp偏移值,值越大的区域 越容易"感光"(在一个特定的角度，偏移光照明暗) 

                

                //亮部颜色
                // half3 ShadowColor = baseColor.rgb * _ShadowMultColor.rgb;      
                // //暗部颜色                       
                // half3 DarkShadowColor = baseColor.rgb * _DarkShadowMultColor.rgb;        

                half lambert = max(0.0, NdotL);
                half halfLambert = lambert*0.5 + 0.5;           
                
                //Ramp阴影
                float rampVmove = 0.0;
                //平滑ShadowAOMask,减弱锯⻮ 
                ShadowAOMask = 1 - smoothstep(saturate(ShadowAOMask), 0.2, 0.6); 
                //为了将ShadowAOMask区域常暗显⽰,使用halflambert采样，由于采样至Ramp边缘会出现黑线，因此_RampShadowRange-0.003避免这种情况
                //float rampValue = halfLambert  * (1.0 / _RampShadowRange - 0.003);
                float rampValue = halfLambert  * lerp(0.5, 1.0, ShadowAOMask) * (1.0 / _RampShadowRange - 0.003);
              

                //_Day大于0.5是白天，则采样上面，否则是夜晚，就采样下面
                rampVmove += step( 0.5, _Day) * 0.5;

                half3 ShadowRamp1 = tex2D(_ShadowRamp, float2(rampValue, 0.45 + rampVmove)).rgb;
                half3 ShadowRamp2 = tex2D(_ShadowRamp, float2(rampValue, 0.35 + rampVmove)).rgb;
                half3 ShadowRamp3 = tex2D(_ShadowRamp, float2(rampValue, 0.25 + rampVmove)).rgb;
                half3 ShadowRamp4 = tex2D(_ShadowRamp, float2(rampValue, 0.15 + rampVmove)).rgb;
                half3 ShadowRamp5 = tex2D(_ShadowRamp, float2(rampValue, 0.05 + rampVmove)).rgb;           
                
                /*0.0 ： 硬的物体 hard/emission/specular/silk
                0.3 ： 软的物体 soft/common
                0.5 ： 金属/金属投影 metal
                0.7： 丝绸/丝袜 tights
                1.0 ： 皮肤/头发 skin
                */

                //step:如果x<a, 返回0；否则返回1
                half3 skinRamp = step(abs(LayerMask - 1),     0.05) * ShadowRamp1;  
                float3 tightsRamp = step(abs(LayerMask - 0.7),     0.05) * ShadowRamp2;          
                float3 softCommonRamp = step(abs(LayerMask  - 0.5), 0.05 ) * ShadowRamp3;            
                half3 hardSilkRamp = step(abs(LayerMask  - 0.3),   0.05) * ShadowRamp4;            
                half3 metalRamp = step(abs(LayerMask - 0),       0.05) * ShadowRamp5;     
                //组合5个Ramp，得到最终的Ramp阴影，并根据rampValue与BaseColor结合。
                half3 finalRamp = skinRamp + tightsRamp + metalRamp  + hardSilkRamp + softCommonRamp;
              
                //分布Ramp，baseMapShadowed就是亮部区域,以ShadowAOMask作为遮罩，用Lerp函数去柔和过渡阴影
                float3 baseMapShadowed = lerp(baseColor.rgb * finalRamp, baseColor.rgb, ShadowAOMask);              
                baseMapShadowed = lerp(baseColor.rgb, baseMapShadowed, _ShadowSmooth);     
                //获得亮部、暗部分布
                float IsBrightSide = ShadowAOMask * step(_LightThreshold, halfLambert);                            

                float3 darkArea = lerp(baseMapShadowed, baseColor.rgb * finalRamp, _RampAOSmooth) * _DarkIntensity ;
                float3 brightArea = _BrightIntensity * baseMapShadowed ;
                //分开亮部
                float RampIntensity = 0.5;
                float3 Diffuse = lerp(darkArea, brightArea, IsBrightSide * RampIntensity) * _CharacterIntensity * lightColor.rgb;
                                
 

                // float3 finalRGB = Diffuse;

                //float3 Diffuse = baseColor.rgb;

                int mode = 1;
                if(_TestMode == mode++)
                    return LightMap.r;
                if(_TestMode ==mode++)
                    return LightMap.g; //阴影 Mask
                if(_TestMode ==mode++)
                    return LightMap.b; //漫反射 Mask
                if(_TestMode ==mode++)
                    return LightMap.a; //漫反射 Mask
                if(_TestMode ==mode++)
                    return halfLambert; //halfLambert
                if(_TestMode ==mode++)
                    return rampValue; //rampValue
                if(_TestMode ==mode++)
                    return baseColor.xyzz; //BaseColor
                if(_TestMode ==mode++)
                    return ShadowAOMask; //ShadowAOMask
                if(_TestMode ==mode++)
                    return float4(finalRamp,0);
                if (_TestMode ==mode++)
                    return float4(Diffuse,1.0);
                // if(_TestMode ==mode++){
                //     float index = 10;
                //     float rampH = RampPixelY * (index * 2 - 1); 
                //     float3 rampC = tex2D(_ShadowRamp, saturate(float2(i.uv.x,rampH))); 
                //     return float4(rampC,0);
                // }

                return float4(Diffuse,1);;
            }
            ENDCG
        }
    }
}
