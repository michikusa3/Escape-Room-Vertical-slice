Shader "Custom/Bullet_Outline"{
    Properties{
        _Speed("Speed",Range(0,100)) = 1
        _Frequency("Frequency",Range(0,3)) = 1
        _Amplitude("Amplitude",Range(0,1)) = 1
        _LineColor("LineColor",Color) = (0,0,0,1)
        _LineWidth("LineWidth",Range(0.001,0.2)) = 0.01
    }

    SubShader {
        Tags {//"Queue" = "Transparent"
              //"RenderType" = "Transparent"
              "RenderType" = "Opaque"
              }
              //Blend SrcAlpha OneMinusSrcAlpha
        LOD 200

        Pass{
            Cull Front

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fog

                #include "UnityCG.cginc"

                struct appdata{
                    float4 vertex:POSITION;
                    float3 normal:NORMAL;
                };

                struct v2f{
                    UNITY_FOG_COORDS(1)
                    float4 vertex : SV_POSITION;
                    float offsetRate: TEXCOORD2;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _LineWidth;
                fixed4 _LineColor;
                float _Speed;
                float _Frequency;
                float _Amplitude;



                v2f vert(appdata v){
                    float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
                    float2 offset = TransformViewToProjection(normal.xy);
                    
                    
                    v2f o;
                    float time = _Time * _Speed;
                    //v.vertex = sin(time) * 0.5;
                    float offsetY  = sin(time + v.vertex.x * _Frequency) + sin(time + v.vertex.z * _Frequency);
                    //float offsetZ  = sin(time + v.vertex.x * _Frequency) + sin(time + v.vertex.z * _Frequency);
                    o.offsetRate    = offsetY * 0.5 + 0.5;
                    offsetY         *= _Amplitude;
                    v.vertex.x      += offsetY ;
                    v.vertex.z      += offsetY * 2;

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
            float offsetRate: TEXCOORD2;
        };

        float _Speed;
        float _Frequency;
        float _Amplitude;

        v2f vert(appdata v){
            v2f o;
            /* float time = _Time * _Speed;
            //v.vertex = sin(time) * 0.5;
            float offsetY  = sin(time + v.vertex.x * _Frequency) + sin(time + v.vertex.z * _Frequency);
            o.offsetRate    = offsetY * 0.5 + 0.5;
            offsetY         *= _Amplitude;
            v.vertex.xz      += offsetY;
 */

            o.vertex = UnityObjectToClipPos(v.vertex);
            o.vertexW = mul(unity_ObjectToWorld,v.vertex);
            o.normal = UnityObjectToWorldNormal(v.normal);
            return o;
        }

        fixed4 frag(v2f i):SV_Target{
            fixed4 baseColor = fixed4(4,1,1,1);
            fixed4 rimColor =fixed4(0.1,0,0,1);
            fixed4 albedo = baseColor;

            float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
            float alpha = pow((abs(dot(view,i.normal))),1.5);
            
            
            float rim = saturate(dot(view,i.normal));
            float minus_rim = 1 - saturate(dot(view,i.normal));
            albedo.a = alpha ;
            albedo -= pow(minus_rim,3);
            return albedo;
        }
    ENDCG
    }
    }
    FallBack "Diffuse"
}
