Shader "Toon/Lit Tri Planar Normal" {
	//添加方向
	Properties{
		_Color("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("Top Texture", 2D) = "white" {}
		_MainTexSide("Side/Bottom Texture", 2D) = "white" {}	
		_Scale("Top Scale", Range(-2,2)) = 1
		_SideScale("Side Scale", Range(-2,2)) = 1	
		_TopSpread("TopSpread", Range(-1,3)) = 1

		_RimPower("Rim Power", Range(-2,20)) = 1
		_RimColor("Rim Color Top", Color) = (0.5,0.5,0.5,1)
		_RimColor2("Rim Color Side/Bottom", Color) = (0.5,0.5,0.5,1)
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
			float3 worldPos; // world position built-in value
			float3 worldNormal;  // world normal built-in value
			float3 viewDir;// view direction built-in value we're using for rimlight
		};

		void surf(Input IN, inout SurfaceOutput o) {

			// clamp (saturate) and increase(pow) the worldnormal value to use as a blend between the projected textures
			float3 worldNormalE = WorldNormalVector(IN, o.Normal);
			float3 blendNormal = saturate(pow(worldNormalE * 1.4,4));

			// triplanar for top texture for x, y, z sides
			float3 xm = tex2D(_MainTex, IN.worldPos.zy * _Scale);
			float3 zm = tex2D(_MainTex, IN.worldPos.xy * _Scale);
			float3 ym = tex2D(_MainTex, IN.worldPos.zx * _Scale);

			// lerped together all sides for top texture
			float3 toptexture = zm;
			toptexture = lerp(toptexture, xm, blendNormal.x);
			toptexture = lerp(toptexture, ym, blendNormal.y);

			// triplanar for side and bottom texture, x,y,z sides
			float3 x = tex2D(_MainTexSide, IN.worldPos.zy * _SideScale);
			float3 y = tex2D(_MainTexSide, IN.worldPos.zx * _SideScale);
			float3 z = tex2D(_MainTexSide, IN.worldPos.xy * _SideScale);

			// lerped together all sides for side bottom texture
			float3 sidetexture = z;
			sidetexture = lerp(sidetexture, x, blendNormal.x);
			sidetexture = lerp(sidetexture, y, blendNormal.y);

			// dot product of world normal and surface normal + noise
			float worldNormalDotNoise = dot(o.Normal, worldNormalE.y);

			// if dot product is higher than the top spread slider, multiplied by triplanar mapped top texture
			// step is replacing an if statement to avoid branching :
			// if (worldNormalDotNoise > _TopSpread{ o.Albedo = toptexture}
			float3 topTextureResult = step(_TopSpread, worldNormalDotNoise) * toptexture;
			//topTextureResult = tex2D(_MainTex, IN.uv_MainTex * _Scale);
		
			// if dot product is lower than the top spread slider, multiplied by triplanar mapped side/bottom texture
			float3 sideTextureResult = step(worldNormalDotNoise, _TopSpread) * sidetexture;
		
			o.Albedo = topTextureResult + sideTextureResult;
			o.Albedo *= _Color;
		}
		ENDCG
	}
	Fallback "Diffuse"
}