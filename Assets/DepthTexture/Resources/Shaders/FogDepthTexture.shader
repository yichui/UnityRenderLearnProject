/*雾的浓度随着深度值的增大而增大，再进行的原图颜色和雾颜色的插值：*/
Shader "DepthTexture/FogDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogColor("Fog Color", Color) = (1,1,1,1)
        _FogDensity("Fog Density", Float) = 1
    }
    SubShader
    {
        ZTest Always Cull Off ZWrite Off

        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed4 _FogColor;
            float _FogDensity;
            sampler2D _CameraDepthTexture;

            float4 AsComputeScreenPos(float4 pos)
            {
                float4 o = pos * 0.5f;
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                o.zw = pos.zw;
                return o;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = float4(v.uv, v.uv);
                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                    o.uv.w = 1 - o.uv.w;
                #endif

                o.screenPos = AsComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                //float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                float linear01Depth = Linear01Depth(depth); //转换成[0,1]内的线性变化深度值
                //float linearEyeDepth = LinearEyeDepth(depth); //转换到摄像机空间
                float fogDensity = saturate(linear01Depth * _FogDensity);
                fixed4 finalColor = lerp(col, _FogColor, fogDensity);
                return finalColor;
            }       
            ENDCG
        }
    }
}
