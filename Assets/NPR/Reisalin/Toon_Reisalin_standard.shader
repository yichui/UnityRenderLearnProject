Shader "NPRToon/Toon_Reisalin_standard"
{
    Properties
    {
        _BaseMap ("Base Map", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump"{}
        _AOMap("AO Map", 2D)= "white" {}
        _DiffuseMap("Diffuse Map", 2D)= "white" {}
        _SpecMap("Spec Map", 2D)= "white" {}
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

            sampler2D _BaseMap, _NormalMap, _AOMap, _DiffuseMap, _SpecMap;


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
                half aoColor = tex2D(_AOMap, i.uv).r;
                half4 specMap = tex2D(_SpecMap, i.uv);
                half specMask = specMap.b;
                half specSmoothness = specMap.a;
                //法线贴图
                half4 normalMap = tex2D(_NormalMap, i.uv);
                half3 normalData = UnpackNormal(normalMap);


                return baseColor;
            }
            ENDCG
        }
    }
}
