//1. Transparent
//2. Rim
//3. Intersection Highlight
Shader "DepthTexture/FocusFiled"
{
    Properties
    {
        _MainColor ("MainColor", Color) = (1,1,1,1)
        //_MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("NoiseTexture", 2D) = "white" {}
        _RimStrength("RimStrength",Range(0, 10)) = 1
        _IntersectPower("IntersectPower", Range(0, 3)) = 0.5
        //_IntersectionColor("_IntersectionColor", Color) = (1,1,1,1)

        _DistortStrength("DistortStrength", Range(0,1)) = 0.2
        _DistortTimeFactor("DistortTimeFactor", Range(0,1)) = 0.2
    }
    SubShader
    {
        //Cull Off
        ZWrite Off

        Blend SrcAlpha OneMinusSrcAlpha
        Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }

        GrabPass
        {
            "_GrabTex"
        }

        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldViewDir : TEXCOORD1;
                float2 noiseUV : TEXCOORD2;
                float4 screenPos: TEXCOORD3;
                float eyeZ : TEXCOORD4;
                float4 grabPos : TEXCOORD5;
            };
       

            sampler2D _GrabTex;
            float4 _GrabTex_ST;
           /* sampler2D _MainTex;
            float4 _MainTex_ST;*/
            float4 _MainColor;
            sampler2D _CameraDepthTexture;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _IntersectPower;
            float _RimStrength;
            float _DistortStrength;
            float _DistortTimeFactor;

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
                o.noiseUV = TRANSFORM_TEX(v.uv, _NoiseTex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldDir(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
                
                o.screenPos = AsComputeScreenPos(o.vertex);
                    

                COMPUTE_EYEDEPTH(o.eyeZ);//计算顶点摄像机空间的深度：距离裁剪平面的距离，线性变化；


                return o;
            }

          

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv.xy);
               
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldViewDir = normalize(i.worldViewDir);

                float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                
                //float linear01Depth = Linear01Depth(depth); //转换成[0,1]内的线性变化深度值
                float linearEyeDepth = LinearEyeDepth(depth); //转换到摄像机空间

                //相交高亮代码
                //float halfWidth = _IntersectionWidth / 2;
                //float diff = saturate(abs(i.eyeZ - screenZ) / halfWidth);
                //fixed4 finalColor = lerp(_IntersectionColor, col, diff);


          
                //圆环
                //float rim = 1 - saturate(dot(worldNormal, worldViewDir)) * _RimStrength;//计算边缘
                float rim = 1 - abs(dot(worldNormal, worldViewDir)) * _RimStrength;//计算边缘
                float intersect = (1 - (linearEyeDepth - i.eyeZ)) * _IntersectPower;
                float v = max(rim, intersect);
                //圆环
                float3 viewDir = normalize(UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, i.vertex)));
               
             



                //扭曲
                float4 offset = tex2D(_NoiseTex, i.noiseUV - _Time.xy * _DistortTimeFactor);
                i.grabPos.xy -= offset.xy * _DistortStrength;
                fixed4 grabColor = tex2Dproj(_GrabTex, i.grabPos);
               
                return _MainColor * v + grabColor;
            }
            ENDCG
        }
    }
}
