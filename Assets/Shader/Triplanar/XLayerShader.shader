Shader "Custom/XLayerShader"
{
    //一个基础的n层夹心贴图shader 
	Properties{
		_Color("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("Top Texture", 2D) = "white" {}
		_MainTexSide("Side/Bottom Texture", 2D) = "white" {}
		_Scale("Top Scale", Range(0.01,5)) = 1
		_SideScale("Side Scale", Range(0.01,5)) = 1
		_TopSpread("TopSpread", Range(-1,3)) = 1
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex, _MainTexSide;
		float4 _Color;
		float  _TopSpread;
		float _Scale, _SideScale;

		struct Input {
			float2 uv_MainTex : TEXCOORD0;
			float3 worldPos; 
			float3 worldNormal;
			float3 viewDir;
		};

		void surf(Input IN, inout SurfaceOutput o) {

			float3 worldNormalE = WorldNormalVector(IN, o.Normal);
			float3 blendNormal = saturate(pow(worldNormalE * 1.4,4));

			float worldNormalDotNoise = dot(o.Normal, worldNormalE.y);
			float3 topTextureResult = step(_TopSpread, worldNormalDotNoise) * tex2D(_MainTex, IN.uv_MainTex * _Scale);
			float3 sideTextureResult = step(worldNormalDotNoise, _TopSpread) * tex2D(_MainTexSide, IN.uv_MainTex * _SideScale);

			o.Albedo = topTextureResult + sideTextureResult;
			o.Albedo *= _Color;
		}
		ENDCG
	}
	Fallback "Diffuse"
}
