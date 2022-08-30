Shader "NPRToon/NPRToonBody"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightMap ("LightMap", 2D) = "white" {}

        [HDR]_EmissionColor("Emission Color",Color)=(1,1,1,1)

        //光照阴影
        // _ShadowMultColor("Shadow Color暖色调",Color) = (1,1,1) //暖色调
        // _DarkShadowMultColor("Shadow Color冷色调",Color) = (0.7,0.7,0.8) //冷色调

        
        [Space(20)]
        [Main(ShadowRamp, _, 3)]_ShadowRamp ("Shadow Ramp", 2D) = "white" {}
        //控制的即是采样Lanbert的水平长度，同时控制了Ao的强度，也控制了Lambert的强度，而且Ao的数值比Lanbert还要小
        [Sub(ShadowRamp)]_RampShadowRange ("Ramp Shadow Range(Ramp效果的Width)", range(0.0, 1.0)) = 0.8
        //柔和过渡AO区域与领域
        [Sub(ShadowRamp)]_ShadowSmooth ("Shadow Smooth 阴影过度", range(0.0, 1.0)) = 0.05
        //控制过渡效果，从而对存在的锯齿进行再一次的柔和过渡
        [Sub(ShadowRamp)]_RampAOSmooth("Ramp AO Smooth ", range(0.0, 1.0)) = 0.5
        [Sub(ShadowRamp)]_BrightIntensity("Bright Intensity亮区强度", range(0.4, 10.0)) = 1
        [Sub(ShadowRamp)]_DarkIntensity ("Dark Intensity暗区强度", range(0.4, 10.0)) = 1

        [Space(20)]
        [Main(MetalMap, _, 3)]_MetalMap ("MetalMap", 2D) = "white" {}
        [Sub(MetalMap)]_MetalMapV ("_MetalMapV", Range(0,1)) = 0
        [Sub(MetalMap)]_MetalMapIntensity ("_MetalMapIntensity", Range(0,5)) = 0

        [Space(20)]
        [Main(Specular, _, 3)]_StepSpecularWidth ("丝袜裁边⾼光Width", Range(0,10)) = 0
        [Sub(Specular)]_StepSpecularWidth2 ("布料边缘高光Width", Range(0,10)) = 0
        [Sub(Specular)]_StepSpecularWidth3 ("头发高光Width", Range(0,10)) = 0
        //[Sub(Specular)]_StepSpecularWidth4 ("_StepSpecularWidth4", Range(0,10)) = 0
        [Sub(Specular)]_SpecularPower ("Specular Power", Range(0,10)) = 8
        [Sub(Specular)]_SpecularColor("Specular Color",Color)=(0.5, 0.5, 0.5)

        [Space(20)]
        [Toggle]_Day("Day白天黑夜",Range(0,1)) = 0 //白天黑夜
        [Space(20)]
        _LightThreshold("LightThreshold(阴影宽度)",Range(0,1)) = 0.2 
        [Space(20)]
        _CharacterIntensity("CharacterIntensity(角色整体亮度)",Range(0.1,10)) = 1

        //边缘光
         [Space(20)]
        // [Toggle]_EnableLambert("Enable Lambert",Range(0,1)) = 1 
        // _RimPow ("Rim Pow", Range(0,10)) = 1
        // _RimSmooth("Rim Smooth", Range(0,10)) = 0
        // [Toggle]_EnableRim("Enable Rim",Range(0,1)) = 1 
        // _RimColor("Rim Color",Color) = (1,1,1,1)
        // _DarkSideRimPow("DarkSideRimPow", Range(0,10)) = 0
        // _DarkSideRimSmooth("Dark Side Rim Smooth", Range(0,10)) = 0.5
        // _DarkSideRimColor("DarkSideRimColor",Color) = (1,1,1,1)
        // [Toggle] _EnableRimDS("Enable RimDS",Range(0,1)) = 1
        [Main(Rim Color, _, 3)]_RimColor("Rim Color",Color) = (1,1,1,1)
        [Sub(Rim Color)]_RimSmooth("Rim Smooth", Range(0,10)) = 0 
        [Sub(Rim Color)]_OffsetMul("Rim Width",Range(0,0.1)) = 0.012

        //描边
        [Space(20)]
        [Main(outline, _, 3)] _group_outline ("描边", float) = 1
        [Sub(outline)] _OutlinePower("Outline Power",Range(0,0.1)) = 0.05
        [Sub(outline)]_LineColor("Outline Color",Color)=(1,1,1,1)
        [Sub(outline)] _Factor("Outline Factor", float) = 1

        //输出各种模式颜色
        [KeywordEnum(None,LightMap_R,LightMap_G,LightMap_B,LightMap_A,halfLambert,rampValue,BaseColor,ShadowAOMask,Ramp,Diffuse,Specular,RimLight)] _TestMode("TestMode测试模式",Int) = 0
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    //顶点着色器输入结构体
    struct a2v
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal:NORMAL;
        float4 tangent : TANGENT;
        float4 vertexColor : Color;
      
        
    };
    //顶点着色器输出结构体
    struct v2f
    {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 worldNormal : TEXCOORD1;
        float3 worldPos : TEXCOORD2;
        float3 positionVS : TEXCOORD3;
        float3 vertColor : TEXCOORD4;
    };

     int _TestMode;    

    //base Color
    sampler2D _MainTex,_LightMap;
    float4 _MainTex_ST;

    fixed4 _EmissionColor;

    // Diffuse
    sampler2D _ShadowRamp;
    // half3 _ShadowMultColor;
    // half3 _DarkShadowMultColor;
    half _ShadowSmooth;
    float _RampShadowRange;
    half _RampAOSmooth;
    half _BrightIntensity;
    half _DarkIntensity;
    float _LightThreshold;
    float _CharacterIntensity;
    // 高光
    float4 _SpecularColor;
    sampler2D _MetalMap;
    float _MetalMapV,_MetalMapIntensity;

    float _StepSpecularWidth,_StepSpecularWidth2,_StepSpecularWidth3;//,_StepSpecularWidth4;
    float _SpecularPower;

    half _Day;

    //边缘光
    float _RimSmooth;
    fixed4 _RimColor;
    float _OffsetMul;
    // float  _EnableLambert;
    // float _RimPow;
    // float _RimSmooth;
    // float _EnableRim;
    // float _DarkSideRimPow;
    // float _DarkSideRimSmooth;
    // fixed4 _DarkSideRimColor;
    // float _EnableRimDS;
   
     // 描边
    float _OutlinePower;
    float4 _LineColor;
    float _Factor;

    sampler2D _CameraDepthTexture;

    ENDCG


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

            float4 TransformClipToViewPortPos(float4 positionCS)
            {
                float4 o = positionCS * 0.5f;
                o.xy = float2(o.x,o.y*_ProjectionParams.x) + o.w;
                o.zw = positionCS.zw;
                return o/o.w;
            }

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
                
                fixed3 halfDir = normalize(lightDir + viewDir);
                float NdotL = dot(normalDir, lightDir);
                float NdotV = dot(normalDir, viewDir);
                float NdotH = dot(normalDir, halfDir);

                float4 LightMap = tex2D(_LightMap, i.uv);
                // 光照贴图信息含义
                // LightMap.r :高光类型Layer,根据值域选择不同的高光类型(eg:BlinPhong 裁边视角光) 
                // LightMap.g :阴影AO ShadowAOMask 
                // LightMap.b :BlinPhong高光强度Mask遮罩 SpecularIntensityMask 
                // LightMap.a :Ramp类型Layer，根据值域选择不同的Ramp 
                // VertexColor.g :Ramp偏移值,值越大的区域 越容易"感光"(在一个特定的角度，偏移光照明暗) 
                // VertexColor.a :描边粗细
                float SpecularLayerMask = LightMap.r;       // ⾼光分层类型Layer
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
                float4 MetalMap = tex2D(_MetalMap, mul((float3x3)UNITY_MATRIX_V, normalDir).xy).r ;
                MetalMap = saturate(MetalMap);
                MetalMap = step(_MetalMapV, MetalMap) * _MetalMapIntensity;


                float3 Specular = 0;
                float3 StepSpecular = 0;
                float3 StepSpecular2 = 0;
                //图⽚格式全部去掉勾选SRGB ⾼光类型Layer
                float LinearMask = pow(LightMap.r, 1 / 2.2);   
                //高光类型         
                float SpecularLayer = LinearMask * 255;            
                 //内部遮罩LightMap.b     
                //float StepSpecularMask = step(200, pow(SpecularIntensityMask, 1 / 2.2) * 255);     

                // 裁边⾼光 (⾼光在暗部消失)
                if (SpecularLayer > 0 && SpecularLayer < 50)//丝袜
                {
                    // x<=y返回1，否则返回0
                    StepSpecular = step(1 - _StepSpecularWidth, saturate(NdotV)) * _SpecularColor;//*_StepSpecularIntensity;//可做修改* SpecularIntensityMask                  
                    StepSpecular *= baseColor;           
                }
                // 裁边⾼光 (⾼光在暗部消失)
                if (SpecularLayer > 50 && SpecularLayer < 150)//布料边缘高光               
                {
                    // x<=y返回1，否则返回0
                    StepSpecular = step(1 - _StepSpecularWidth2, saturate(NdotV)) * 1 * _SpecularColor;//*_StepSpecularIntensity2 ;//* SpecularIntensityMask
                    StepSpecular *= baseColor;           
                }

                //裁边⾼光 (StepSpecular2常亮 ⽆视明暗部分)
                if (SpecularLayer > 150 && SpecularLayer < 250)//头发高光
                {
                    // StepSpecular = step(1 - _StepSpecularWidth3, saturate(NdotV)) * 1 * _StepSpecularIntensity3 ;
                    // StepSpecular = lerp(StepSpecular, 0, SpecularIntensityMask);//反向失去头发高光控制 

                    // StepSpecular2 = step(1 - _StepSpecularWidth4 * 5, saturate(NdotV)) * SpecularIntensityMask * _StepSpecularIntensity4;
                    // StepSpecular2 *= baseColor;
                    // StepSpecular *= baseColor;

                    StepSpecular = step(1 - _StepSpecularWidth3, saturate(NdotV)) * 1 * _SpecularColor;//* _StepSpecularIntensity3 ;
                    StepSpecular *= baseColor;
                }

                // BlinPhong⾼光
                if (SpecularLayer >= 250 && SpecularLayer <260)     //上金属高光
                {
                    Specular = pow(saturate(NdotH), 1 * _SpecularPower) * SpecularIntensityMask * _SpecularColor;//*_SpecularIntensity;
                    Specular = max(0, Specular);
                    Specular += MetalMap; 
                    Specular *= baseColor;
                }

                //边缘光计算(视向量做法)
                /*float lambertD = max(0, -lambert);
                float rim = 1 - saturate(dot(viewDir, i.worldNormal)); //Fresnel
                float rimDot = pow(rim, _RimPow);
                rimDot = _EnableLambert * lambert * rimDot + (1 - _EnableLambert) * rimDot;//开启平滑

                float rimIntensity = smoothstep(0, _RimSmooth,  rimDot);               // 平滑0 , 1
                half4 Rim = _EnableRim * pow(rimIntensity, 5) * _RimColor * baseColor ;//开启染色

                rimDot = pow(rim, _DarkSideRimPow);//fresnel边缘光延伸
                rimDot = _EnableLambert * lambertD * rimDot + (1 - _EnableLambert) * rimDot;//阴影面边缘光
                rimIntensity = smoothstep(0, _DarkSideRimSmooth, rimDot);                   //阴影面边缘光平滑
                half4 RimDS = _EnableRimDS * pow(rimIntensity, 5) * _DarkSideRimColor * baseColor;

                RimDS.a = 0.1;                
                half4 RimLight = Rim + RimDS;
                */

                //边缘光计算部分(屏幕空间深度边缘光)
                float3 normalWS = i.worldNormal;
                float3 normalVS = UnityWorldToViewPos(normalWS);
                float3 positionVS = i.positionVS;
                float3 samplePositionVS = float3(positionVS.xy + normalVS.xy*_OffsetMul,positionVS.z);
                float4 samplePositionCS = UnityViewToClipPos(samplePositionVS);
                float4 samplePositionVP = TransformClipToViewPortPos(samplePositionCS);

                float depth = i.pos.z /i.pos.w;
                float linearEyeDepth = LinearEyeDepth(depth);
                float offsetDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture,samplePositionVP));
                float linearEyeOffsetDepth = LinearEyeDepth(offsetDepth);
                float depthDiff = linearEyeOffsetDepth - linearEyeDepth;
                float rimIntensity = step(_RimSmooth,depthDiff);
                half3 RimColor = rimIntensity * _RimColor.rgb * _RimColor.a;
                //half4 RimLight = half4(RimColor, 1);

                //float3 emission = baseColor.a * _EmissionColor;

                //高光融合

                //⾼光类型Layer 截断分布
                Specular = lerp(StepSpecular, Specular, LinearMask);     
                Specular = lerp(0, Specular, LinearMask);
                //亮暗分布rampValue 加上AO暗部影响
                Specular = lerp(0, Specular, rampValue);                 
                //float3 FinalColor = Specular + RampShadowColor;         //Diffuse + Specular;
                fixed3 result = Diffuse + Specular + RimColor;

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
                if (_TestMode ==mode++)
                    return float4(Specular,1.0);
                if (_TestMode ==mode++)
                    return float4(RimColor,1.0);;
                    
                return float4(result,1);;
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


            v2f vert(a2v v) 
            {
                v2f o;
                float3 pos = normalize(v.vertex.xyz);
                // float3 normal = normalize(v.normal);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz);

                //点积是为了确定顶点对于几何中心的指向，判断此处的顶点是位于模型的凹处还是凸处
                float D = dot(pos,normal);
                //矫正顶点的方向值，判定是否是轮廓线
                pos *= sign(D);
                //描边的朝向插值，决定是偏向法线方向还是顶点方向
                pos = lerp(normal,pos,_Factor);
                //将顶点往指定方向挤出
                v.vertex.xyz += pos*_OutlinePower;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertColor = v.vertexColor.rgb;//如果有顶点色才使用
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                i.vertColor = tex2D(_MainTex,i.uv).rgb;
                return fixed4(_LineColor*i.vertColor,0);
            }

            ENDCG
        }

        //该pass是为了使得屏幕空间深度生效
        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}

            CGPROGRAM

            #pragma vertex Shadowvert
            #pragma fragment ShadowFrag

            #include "UnityCG.cginc"

            struct VertexData{
                float4 position : POSITION; 
            };

            float4 Shadowvert(VertexData v) : SV_POSITION{
                return UnityObjectToClipPos(v.position);
            }

            half4 ShadowFrag() : SV_TARGET{
                return 0;
            }
 
            ENDCG

        }
    }
}
