Shader "NPRToon/NPRToonBody"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"

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


            sampler2D _MainTex;
            float4 _MainTex_ST;

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
                return baseColor;
            }
            ENDCG
        }
    }
}
