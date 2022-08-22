Shader "NPR/OutlineToon"
{
    Properties
    {
        _OutlineWidth("Outline Width", Range(0.01, 1)) = 0.24
        _OutLineColor("OutLine Color", Color) = (0.5,0.5,0.5,1)
      /*  _NoiseTillOffset("NoiseTillOffset", Vector) = (0,0,1,1)
        _NoiseAmp("NoiseAmp", float) = 0.02*/
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        pass
        {
           Tags {"LightMode" = "ForwardBase"}

            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 vert(appdata_base v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            half4 frag() : SV_TARGET
            {
                return half4(1,1,1,1);
            }

            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            half _OutlineWidth;
            half4 _OutLineColor;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 vertColor : COLOR;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };


            v2f vert(a2v v)
            {
                //v2f o;
                //UNITY_INITIALIZE_OUTPUT(v2f, o);
                ////顶点沿着法线方向外扩
                //o.pos = UnityObjectToClipPos(float4(v.vertex.xyz + v.normal * _OutlineWidth * 0.1 ,1));
                //return o;

               
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                float4 pos = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal.xyz);
                //将法线变换到NDC空间
                float3 ndcNormal = normalize(TransformViewToProjection(viewNormal.xyz)) * pos.w;
                //将近裁剪面右上角位置的顶点变换到观察空间
                float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));
                float aspect = abs(nearUpperRight.y / nearUpperRight.x);//求得屏幕宽高比
                ndcNormal.x *= aspect;
                pos.xy += 0.01 * _OutlineWidth * ndcNormal.xy;
                o.pos = pos;
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                return _OutLineColor;
            }
            ENDCG

            //Cull Front
            //ZWrite On
            //ColorMask RGB
            //Blend SrcAlpha OneMinusSrcAlpha

            //CGPROGRAM
            //#pragma vertex vert
            //#pragma fragment frag

            //#include "UnityCG.cginc"

            //struct appdata {
            //    float4 vertex : POSITION;
            //    float3 normal : NORMAL;
            //    float4 texCoord : TEXCOORD0;

            //};

            //struct v2f {
            //    float4 pos : SV_POSITION;
            //    float4 color : COLOR;
            //    float4 tex : TEXCOORD0;
            //};

            //uniform half _OutlineWidth;
            //uniform half4 _OutlineColor;
            //uniform half4 _NoiseTillOffset;
            //uniform half _NoiseAmp;

            //float2 hash22(float2 p) {
            //    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
            //    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            //}

            //float2 hash21(float2 p) {
            //    float h = dot(p, float2(127.1, 311.7));
            //    return -1.0 + 2.0 * frac(sin(h) * 43758.5453123);
            //}

            ////perlin
            //float perlin_noise(float2 p) {
            //    float2 pi = floor(p);
            //    float2 pf = p - pi;
            //    float2 w = pf * pf * (3.0 - 2.0 * pf);
            //    return lerp(lerp(dot(hash22(pi + float2(0.0, 0.0)), pf - float2(0.0, 0.0)),
            //        dot(hash22(pi + float2(1.0, 0.0)), pf - float2(1.0, 0.0)), w.x),
            //        lerp(dot(hash22(pi + float2(0.0, 1.0)), pf - float2(0.0, 1.0)),
            //            dot(hash22(pi + float2(1.0, 1.0)), pf - float2(1.0, 1.0)), w.x), w.y);
            //}

            //v2f vert(appdata v) 
            //{
            //    // just make a copy of incoming vertex data but scaled according to normal direction
            //    v2f o;
            //    o.pos = UnityObjectToClipPos(v.vertex);
            //    float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
            //    float2 extendDir = normalize(TransformViewToProjection(norm.xy));

            //    float2 noiseSampleTex = v.texCoord;
            //    noiseSampleTex = noiseSampleTex * _NoiseTillOffset.xy + _NoiseTillOffset.zw;
            //    float nosieWidth = perlin_noise(noiseSampleTex);
            //    nosieWidth = nosieWidth * 2 - 1;	// ndc Space (-1, 1)

            //    half outlineWidth = _OutlineWidth + _OutlineWidth * nosieWidth * _NoiseAmp;

            //    o.pos.xy += extendDir * (o.pos.w * outlineWidth * 0.1);

            //    o.tex = v.texCoord;

            //    o.color = _OutlineColor;
            //    return o;
            //}

            //half4 frag(v2f i) :SV_TARGET{
            //    return i.color;
            //}

            //ENDCG 
        }
    }
}