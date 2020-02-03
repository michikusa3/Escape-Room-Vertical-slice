Shader "Custom/Bullet_Outline"{
    Properties{
        
        _LineColor("LineColor",Color) = (0,0,0,1)
        _LineWidth("LineWidth",Range(0.001,0.2)) = 0.01
    }

    SubShader {
        Tags {"Queue" = "Transparent"
              "RenderType" = "Transparent"}
              Blend SrcAlpha OneMinusSrcAlpha
        LOD 200

        Pass{
            Cull Front

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                //#pragma multi_compile_fog

                #include "UnityCG.cginc"

                struct appdata{
                    float4 vertex:POSITION;
                    float3 normal:NORMAL;
                };

                struct v2f{
                    //UNITY_FOG_COORDS(1)
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _LineWidth;
                fixed4 _LineColor;

                v2f vert(appdata v){
                    float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
                    float2 offset = TransformViewToProjection(normal.xy);

                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.vertex.xy = o.vertex.xy + offset * _LineWidth;
                    //UNITY_TRANSFER_FOG(o,o.vertex);
                    return o;
                }

                fixed4 frag(v2f i):SV_Target{
                    fixed4 col = _LineColor;
                    //UNITY_APPLY_FOG(i.fogcoord,col);
                    return col;
                }
            
            ENDCG
        }

        Pass{
            Cull Back
        CGPROGRAM
        #pragma vertex vert 
        #pragma fragment frag
        #pragma target3.0

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
            fixed4 baseColor = fixed4(0,0,0.5,1);
            fixed4 rimColor =fixed4(0,0,0.2,1);
            float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
            fixed4 albedo = baseColor;
            float alpha = pow((abs(dot(view,i.normal))),1.5);
            
            
            float rim = saturate(dot(view,i.normal));
            float minus_rim = 1 - saturate(dot(view,i.normal));
            albedo.a = alpha ;
            albedo.rgb += pow(rim,0.6);
              ;
            return albedo;
        }
    ENDCG
    }
    }
    FallBack "Diffuse"
}
