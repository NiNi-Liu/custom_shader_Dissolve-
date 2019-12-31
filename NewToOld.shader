Shader "kenny_effect/OldToNew"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_EmissionColor("EmissionColor", Color) = (1,1,1,1)
		_EmissionPower("EmissionPower", Range(0,100)) = 20
		//_EmissionEdge("EmissionEdge", Range(0,0.1)) = 0.02
        _MainTex ("New-tex", 2D) = "white" {}
		_BumpMap("New-Normal",2D) = "bump"{}
		_OldTex("OldTex",2D) = "white"{}
		_OldBumpMap("Old-Normal",2D) = "bump"{}
		_OldTexAlpha("Alpha",2D) = "white"{}
		_OTNblend("OTN blend", Range(0,1)) = 0

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _OldTexAlpha;
		sampler2D _OldBumpMap;
		sampler2D _OldTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_OldTexAlpha;
			float2 uv_OldBumpMap;
			float2 uv_OldTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
		half _OTNblend;
		fixed4 _EmissionColor;
		half _EmissionPower;
		//half _EmissionEdge;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) ;
			fixed3 n = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			fixed4 oc = tex2D(_OldTex, IN.uv_OldTex) * _Color;
			fixed4 oca = tex2D(_OldTexAlpha, IN.uv_OldTexAlpha);
			fixed3 on = UnpackNormal(tex2D(_OldBumpMap, IN.uv_OldBumpMap));			
			//Diffuse  ~~ smooth把值訂為smoothstep(a, b, c) 把c訂為a~b之間 ~~ lerp轉換兩張圖
			fixed4 diffuse_bend = lerp(oc, c, smoothstep(0.5, 1, _OTNblend));
			//alpha clip
			//fixed blendClamp = clamp(_OTNblend, 0, 0.5);
			float AlphaClip = oca.rgb - (1-_OTNblend);
			clip(AlphaClip);			
			//Normal_bend
			fixed3 Normal_bend = lerp(on, n, _OTNblend);  
			// color set
			o.Albedo = diffuse_bend.rgb;
			o.Normal = Normal_bend;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			//Emission
			//EdgeWidth
			float Edge = step(oca.rgb, (1 - _OTNblend) + 0.03);
			//fix end problem 最後拉到底的時候還是會部分發光 所以要把拉到最後一刻時 亮度瞬間降為0
			half em_limit = saturate(1- _OTNblend);
			half em_limit2 = step(0.001, em_limit);
			fixed power = em_limit2 * _EmissionPower;
			//powersmooth
			half powersmooth = smoothstep(1.2, 0, _OTNblend);
            o.Alpha = oca.a;
			o.Emission = Edge * power *_EmissionColor *powersmooth;
			
        }
        ENDCG
    }
    FallBack "Diffuse"
}
