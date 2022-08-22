Shader "NPR/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Facetor("Facetor", float) = 0.5
        _OutLineWidth("OutLineWidth", float) = 0.5
        _OutLineColor("OutLineColor", Color) = (1,1,1,1)

        _RampTex("Ramp Texture",2D) = "white"{}//Ramp贴图,使用一个Ramp贴图来对色阶进行控制，Ramp贴图记录了冷暖色调的过渡（mhy用法）

        _MainColor("Main Color",Color) = (1,1,1) //主色调
        _ShadowColor("Shadow Color",Color) = (0.7,0.7,0.8) //冷色调
        _ShadowRange("Shadow Range",Range(0,1)) = 0.5 //占比控制

        _ShadowSmooth("Shadow Smooth",Range(0,1)) = 0.2 //交接平滑度

        //高光部分
        [Space(10)]
        _SpecularGloss("Specular Gloss",Range(0,128)) = 32
        _SpecularColor("Speuclar Color",Color) = (0.7,0.7,0.8)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        pass
        {
           Tags {"LightMode" = "ForwardBase"}

            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                //half4 vertColor: COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal:TEXCOORD2;
                //half3 vertColor: TEXCOORD1;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RampTex;

            half3 _MainColor;
            half3 _ShadowColor;

            half _ShadowRange;
            half _ShadowSmooth;

            half _SpecularGloss;
            half4 _SpecularColor;

            v2f vert(appdata v) 
            {
                v2f o;

                //漫反射计算部分
                // float3 ramp = tex2D(_RampTex, float2(halfLambert, halfLambert)).rgb;//上面这样采样会出现不正常的高光区域
                // float3 ramp = tex2D(_RampTex,float2(saturate(halfLambert-_ShadowRange),0.5));
                // float3 rampStart = tex2D(_RampTex, float2(0,0)).rgb;
                // half rampNum = smoothstep(0,_ShadowSmooth,halfLambert - _ShadowRange);
                // half3 RampColor = lerp(rampStart,ramp,rampNum);


                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                //o.vertColor.xyz = v.vertColor.rgb;
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                half4 col = 1;
                half4 mainTex = tex2D(_MainTex, i.uv);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //半蘭伯特光照經驗模型
                half halfLambert = dot(worldLightDir,worldNormal) * 0.5 + 0.5;
                //half ramp = smoothstep(0, _ShadowSmooth, halfLambert - _ShadowRange);
                
               
              
                float3 ramp =  tex2D(_RampTex, float2(saturate(halfLambert - _ShadowRange), 0.5));
                float3 rampStart = tex2D(_RampTex, float2(0,0)).rgb;
                half rampNum = smoothstep(0, _ShadowSmooth, halfLambert - _ShadowRange);
                half3 RampColor = lerp(rampStart,ramp,rampNum);

                //漫反射
                //half3 diffuse = halfLambert > _ShadowRange ? _MainColor : _ShadowColor;//這裏是選擇冷暖色調
                //插值做冷暖色調圓滑過渡
                //half3 diffuse = lerp(_ShadowColor, _MainColor, ramp);

                
                half3 diffuse = RampColor;
                //diffuse *= LightMapShadow.a ==0 ? 1 : ShallowShadowColor; 
                diffuse *= mainTex.a == 0 ? 1 : mainTex.rgb;//用三目运算符替代IF执行裁剪操作

                 //高光计算部分
                half3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specularColor = _SpecularColor.rgb*pow(max(0,dot(worldNormal,halfDir)),_SpecularGloss);
                //fixed3 specular = metalTex.a == 0 ? 0 : specularColor * metalTex.rgb;


                col.rgb = (diffuse + specularColor ) * _LightColor0.rgb;
                col.a = mainTex.a;

                //return fixed4(1,1,1,1);
                return col;
                
            }

            ENDCG
        }

        //outline的pass
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                half4 vertColor: COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                half3 vertColor: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Facetor;
            half _OutLineWidth;
            float4 _OutLineColor;

            v2f vert (appdata v)
            {
                v2f o;

                float3 pos = normalize(v.vertex.xyz);
                float3 normal = normalize(v.normal);


                //点积是为了确定顶点对于几何中心的指向，判断此处的顶点是位于模型的凹处还是凸处
                float D = dot(pos,normal);
                //矫正顶点的方向值，判定是否是轮廓线
                pos *= sign(D);
                //描边的朝向插值，决定是偏向法线方向还是顶点方向
                pos = lerp(normal,pos,_Facetor);
                //将顶点往指定方向挤出
                v.vertex.xyz += pos*_OutLineWidth;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertColor.xyz = v.vertColor.rgb;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                i.vertColor = tex2D(_MainTex, i.uv).rgb;
                //fixed4 col = tex2D(_MainTex, i.uv);
                
                return fixed4(_OutLineColor*i.vertColor, 0);

            }
            ENDCG
        }
    }
}
