Shader "Custom/Bullet"{
    SubShader {
        Tags {"Queue" = "Transparent"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard alpha:fade
        #pragma target3.0

        struct Input{
            float2 uv_MainTex;
            float3 worldNormal;
            float3 Normal;
            float3 viewDir;
        };

        void surf(Input IN,inout SurfaceOutputStandard o){
            fixed4 baseColor = fixed4(4,0,0,1);
            fixed4 rimColor =fixed4(1,1,1,1);

            o.Albedo = baseColor;
            float alpha = 1 - pow((abs(dot(IN.viewDir,IN.worldNormal))),1.5);
            
            float rim = 1 - saturate(dot(IN.viewDir,o.Normal));
            o.Alpha = alpha * 1.2;
            o.Emission = rimColor * pow(rim,1);
        }
        ENDCG
    }
    FallBack "Diffuse"
}