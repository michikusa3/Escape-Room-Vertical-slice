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
            fixed4 baseColor = fixed4(1.3,1.3,1.3,1);
            fixed4 rimColor =fixed4(10,0,0,1);

            o.Albedo = baseColor;
            float alpha = pow((abs(dot(IN.viewDir,IN.worldNormal))),1.5);
            
            float rim = 1 - saturate(dot(IN.viewDir,o.Normal));
            o.Alpha = alpha * 1;
            o.Emission = rimColor * pow(rim,0.9);
        }
        ENDCG
    }
    FallBack "Diffuse"
}