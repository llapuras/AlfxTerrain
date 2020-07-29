Shader "Toon/Sparkles_x2" {
	Properties{
		[Header(Main)]
		_ToonRamp("Main Color", Color) = (0.5,0.5,0.5,1)
		_Atten("Attenuation", Range(0,1))= 0.5

		[Space]
		[Header(Texture)]
		_Color("Texture Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("Texture", 2D) = "white" {}
		_TextureOpacity("Texture Opacity", Range(0,2)) = 1.5
		_TextureScale("Texture Scale", Range(0,2)) = 0.5

		[Space]
		[Header(Sparkles)]
		_SparkleColor("Sparkle Color", Color) = (0.5,0.5,0.5,1)
		_SparkleScale("Sparkle Scale", Range(0,200)) = 10
		_SparkCutoff("Sparkle Cutoff", Range(0,0.5)) = 0.1
		_SparkleNoise("Sparkle Noise", 2D) = "gray" {}

		[Space]
		[Header(Rim)]
		_RimPower("Rim Power", Range(0,20)) = 20
		_RimColor("Rim Color Snow", Color) = (0.5,0.5,0.5,1)
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM

		#pragma surface surf ToonRamp vertex:vert addshadow nolightmap 
		#pragma target 4.0

			//用了自定义的Toon光照模型
			float4 _ToonRamp;
			inline half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half atten)
			{
				#ifndef USING_DIRECTIONAL_LIGHT
				lightDir = normalize(lightDir);
				#endif

				float d = dot(s.Normal, lightDir);
				float3 ramp = smoothstep(0, d + 0.06, d) + _ToonRamp;
				half4 c;
			
				c.rgb = s.Albedo * _LightColor0.rgb * (ramp) * (atten);
				c.a = 0;
				return c;
			}

			uniform float3 _Position;
			sampler2D _MainTex, _Noise, _SparkleNoise;
			float4 _Color, _RimColor, _SparkleColor;
			float _RimPower, _Scale, _TextureScale, _TextureOpacity, _Atten, _SparkleScale, _SparkCutoff;

			struct Input {
				float2 uv_MainTex : TEXCOORD0;
				float3 worldPos; //内置变量
				float3 viewDir;//内置变量，用于Rim计算
				float4 vertexColor : COLOR;
			};

			void vert(inout appdata_full v)
			{
			
			}

			void surf(Input IN, inout SurfaceOutput o) {
				//贴图
				float3 uvnew = tex2D(_MainTex, IN.uv_MainTex).rgb;

				//rim
				half rim = 1.0 - dot((IN.viewDir), BlendNormals(o.Normal, uvnew));

				// 沙粒闪耀效果
				float4 sparklesStatic = tex2D(_SparkleNoise, IN.uv_MainTex * _SparkleScale *10);
				float4 sparklesResult = tex2D(_SparkleNoise, (IN.uv_MainTex ) * _SparkleScale) * sparklesStatic;

				o.Albedo += step(_SparkCutoff, sparklesResult) * _SparkleColor;			
				o.Emission += step(_SparkCutoff, sparklesResult) * _RimColor * pow(rim, _RimPower);
			}
			ENDCG
		}
		Fallback "Diffuse"
}