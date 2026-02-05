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

HLSLPROGRAM
#pragma vertex Vert
#pragma fragment Fragment

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

half3 GammaToLinearSpaceApprox(half3 c)
{
    half3 low = c / 12.92h;
    half3 high = pow((c + 0.055h) / 1.055h, 2.4h);
    return lerp(high, low, step(c, 0.04045h));
}

half4 Fragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    float2 uv = input.texcoord.xy * _BlitScaleBias.xy + _BlitScaleBias.zw;
    half4 col = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);
    col.rgb = GammaToLinearSpaceApprox(col.rgb);
    col.a = saturate(col.a * 1.5);
    return col;
}
ENDHLSL
        }
    }
}
