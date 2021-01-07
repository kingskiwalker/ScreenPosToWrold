Shader "Hidden/Dk/ScreenSpaceToWorldPos"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #include "HLSLSupport.cginc"

    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float4x4 _CamRay;
    TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);

    struct vertexToFrag 
    {
        float4 vertex : SV_POSITION;
        float2 texcoord : TEXCOORD0;
        float2 texcoordStereo : TEXCOORD1;
        float4 ray :color1;
    };


    vertexToFrag Vert(AttributesDefault v)
    {
        vertexToFrag o;
        o.vertex = float4(v.vertex.xy, 0.0, 1.0);
        o.texcoord = TransformTriangleVertexToUV(v.vertex.xy);

        #if UNITY_UV_STARTS_AT_TOP
            o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
        #endif

        o.texcoordStereo = TransformStereoScreenSpaceTex(o.texcoord, 1.0);
        float2 uv = o.texcoord.xy;

        o.ray  = lerp(lerp(_CamRay[2],_CamRay[0],uv.y),lerp(_CamRay[3],_CamRay[1],uv.y),uv.x);

        return o;
    }
    
    
    float4 Frag(vertexToFrag i) : SV_Target
    {
        // return i.ray;
        float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,i.texcoord);
        depth = Linear01Depth(depth);
        float4 worldPos = float4(i.ray.xyz*depth + _WorldSpaceCameraPos,1);
        
        return worldPos;
    }

    


    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert 
            #pragma fragment Frag
            ENDHLSL
        }
    }

    
}

