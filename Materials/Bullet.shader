Shader "Custom/Bullet"{
    SubShader {
        Tags {"Queue" = "Transparent"
              "RenderType" = "Transparent"}
              Blend SrcAlpha OneMinusSrcAlpha
        LOD 200
        Pass{
        CGPROGRAM
        #pragma vertex vert 
        #pragma fragment frag
        

        #include "UnityCG.cginc"

        struct appdata{
            float4 vertex:POSITION;
            float3 normal:NORMAL;
        };

        struct v2f{
            float4 vertex:SV_POSITION;
            float4 vertexW:TEXCOORD0;
            float3 normal:TEXCOORD1;
        };

        v2f vert(appdata v){
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.vertexW = mul(unity_ObjectToWorld,v.vertex);
            o.normal = UnityObjectToWorldNormal(v.normal);
            return o;
        }

        fixed4 frag(v2f i):SV_Target{
            fixed4 baseColor = fixed4(0.45,0.45,0.5,1);
            fixed4 rimColor =fixed4(0,0,1,1);
            float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
            fixed4 albedo = baseColor;
            float alpha = pow((abs(dot(view,i.normal))),1.5);
            
            
            float rim = 1 - saturate(dot(view,i.normal));
            albedo.a = alpha ;
            albedo += rimColor  ;
            return albedo;
        }
    ENDCG
    }
    }
    FallBack "Diffuse"
}
