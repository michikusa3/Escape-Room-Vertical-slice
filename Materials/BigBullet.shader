Shader "Custom/BigBullet"{
    Properties{
        _Maintex("Texture",2D) = "white"{}
        _LineColor("Line Color",Color) = (1,1,1,1)
        _LineWidth("Line Width",Range(0.01,0.2)) = 0.1
        _Dsitance ("Distance", float) = 3.0
		_FarColor ("Far Color", Color) = (0, 0, 0, 1) 
		_NearColor ("Near Color", Color) = (1, 1, 1, 1)
        
    }
    SubShader {
        
        Tags {"Queue" = "Transparent"
              "RenderType" = "Transparent"}
              Blend SrcAlpha OneMinusSrcAlpha
        LOD 200
        /* Pass{

            Cull front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 vertex:SV_POSITION;
                float4 vertexW:TEXCOORD0;
                float3 normal:TEXCOORD1;
            };

            sampler2D _Maintex;
            float4 _Maintex_ST;
            float _LineWidth;
            float4 _LineColor;

            v2f vert(appdata v){
                float3 normal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV,v.normal));
                float2 offset = TransformViewToProjection(normal.xy);

                v2f o;
                o.vertexW = mul(unity_ObjectToWorld,v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex.xy = o.vertex.xy + offset * _LineWidth;
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed4 color = _LineColor;

                float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
                float alpha = pow((abs(dot(view,i.normal))),1.5);
                color.a += alpha;
                return color;
            }
            ENDCG
        } */


        Pass{

        CGPROGRAM
        #pragma vertex vert 
        #pragma fragment frag

        #include "UnityCG.cginc"

			float _Dsitance;
			fixed4 _FarColor;
			fixed4 _NearColor;

        struct appdata{
            float4 vertex:POSITION;
            float3 normal:NORMAL;
        };

        struct v2f{
            float4 vertex:SV_POSITION;
            float4 vertexW:TEXCOORD0;
            float3 normal:TEXCOORD1;
            float3 worldPos:TEXCOORD2;
        };

        v2f vert(appdata v){
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.vertexW = mul(unity_ObjectToWorld,v.vertex);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            o.normal = UnityObjectToWorldNormal(v.normal);
            return o;
        }

        fixed4 frag(v2f i):SV_Target{
            fixed4 baseColor = fixed4(4,0,0,1);
            fixed4 rimColor =fixed4(1,1,1,3);
            float3 view = normalize(_WorldSpaceCameraPos - i.vertexW);
            fixed4 albedo = baseColor;
            float alpha = 1 - pow((abs(dot(view,i.normal))),1.5);
            float dist = length(_WorldSpaceCameraPos - i.worldPos);
            fixed4 posColor = fixed4(lerp(_NearColor.rgb, _FarColor.rgb, dist/_Dsitance), 1);
            albedo += posColor * 0.05;
            
            float rim = 1 - saturate(dot(view,i.normal));
            float minus_rim = 1 - saturate(dot(view,i.normal));
            albedo.a = alpha * 1.2;
            albedo += rimColor * pow(rim,2.5);
            
            return albedo;
        }
    ENDCG
    }
    }
    FallBack "Diffuse"
}
