//a Unity implementation of a simple distortion shader I found on YouTube
Shader "Custom/ScreenShockwave"
{
    Properties
    {
    	[PerRendererData] _MainTex ("Main Texture", 2D) = "white" {}
        _InnerRadius ("Inner Radius", Float) = 0 //local coord
        _OuterRadius ("Outer Radius", Float) = 0 //local coord

        //centre positions of the two circles in uv coordinates
        _CentreX ("Centre X", Float) = 0.5
        _CentreY ("Centre Y", Float) = 0.5

        _CurrentDuration ("Current Duration", Float) = 0

        _DistortionStrengthBase ("Distortion Strength Base", Float) = 1
        _DistortionStrengthPower ("Distortion Strength Power", Float) = 1
    }

    SubShader
    {
        Pass
        {
            Cull Off 
			ZWrite Off
            
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex   : POSITION;
                float2 uv : TEXCOORD0;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_centre : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            float _CentreX;
            float _CentreY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv_centre = float2(_CentreX, _CentreY);
                return o;
            }

            sampler2D _MainTex;
            half _InnerRadius;
            half _OuterRadius;
            float _CurrentDuration;
            half _DistortionStrengthBase;
            half _DistortionStrengthPower;

            fixed4 frag (v2f i) : COLOR
            {
	        float dist = distance(i.uv_centre * unity_OrthoParams, i.uv * unity_OrthoParams);

            	//distortion
            	float diff = dist - _CurrentDuration;
            	float powDiff = 1 - pow(abs(diff * _DistortionStrengthBase), _DistortionStrengthPower);
            	float diffTime = diff * powDiff;
            	float diffUV = normalize(i.uv - i.uv_centre);

            	float offset = diffUV * diffTime * (1-step(_OuterRadius, dist)) * step(_InnerRadius, dist);

            	//step functions return 1 if dist is between inner and outer radius
            	return tex2D(_MainTex, i.uv + offset);
            }
            ENDCG
        }
    }
}
