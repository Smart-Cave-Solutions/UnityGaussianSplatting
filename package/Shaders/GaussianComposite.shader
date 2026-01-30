// SPDX-License-Identifier: MIT
Shader "Hidden/Gaussian Splatting/Composite"
{
    SubShader
    {
        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma require compute
#pragma use_dxc
#pragma require 2darray

// Enable proper multi-compile support for all stereo rendering modes
#pragma multi_compile_local _ UNITY_SINGLE_PASS_STEREO STEREO_INSTANCING_ON STEREO_MULTIVIEW_ON

#include "UnityCG.cginc"

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
};

struct appdata
{
    float4 vertex : POSITION;
    uint vtxID : SV_VertexID;
};

v2f vert (uint vtxID : SV_VertexID)
{
    v2f o;
    
    float2 quadPos = float2(vtxID&1, (vtxID>>1)&1) * 4.0 - 1.0;
    o.vertex = float4(quadPos, 1, 1);
    float2 uv = quadPos * 0.5 + 0.5;
    o.uv = uv * _BlitScaleBias.xy + _BlitScaleBias.zw;
    return o;
}

float4 _BlitScaleBias;

// Separate textures for left and right eyes
#if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)
UNITY_DECLARE_TEX2DARRAY(_GaussianSplatRT);
#else
UNITY_DECLARE_TEX2D(_GaussianSplatRT);
#endif

int _CustomStereoEyeIndex;
half4 frag (v2f i) : SV_Target
{
    half4 col;    
    // Check if using separate eye textures
    #if defined(UNITY_SINGLE_PASS_STEREO) || defined(STEREO_INSTANCING_ON) || defined(STEREO_MULTIVIEW_ON)
        col = UNITY_SAMPLE_TEX2DARRAY(_GaussianSplatRT, float3(i.uv, _CustomStereoEyeIndex));
    #else
        // single-texture for non-stereo
        col = UNITY_SAMPLE_TEX2D(_GaussianSplatRT, i.uv);
    #endif

    col.rgb = GammaToLinearSpace(col.rgb);
    col.a = saturate(col.a * 1.5);
    return col;
}
ENDCG
        }
    }
}
