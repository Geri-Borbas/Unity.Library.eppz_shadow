Shader "eppz!/Shadow/Receiver"
{
	Properties
	{
		_MainColor ("Main Color", Color) = (1,1,1,1) 	
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ShadowMap ("Shadow map (RGB)", 2D) = "white" {}	
	}
	
    SubShader
    {   
    	// Test shadow vertex projection depth against shadow map value.
        Pass
      	{
      		Lighting Off
      		
			GLSLPROGRAM
			// #include "UnityCG.glslinc"

         	uniform vec4 _MainColor; 
 			uniform sampler2D _MainTex;
			uniform sampler2D _ShadowMap;
         	
         	uniform mat4 _Object2World; // Advertised by Unity  
         	uniform mat4 _ShadowCameraViewMatrix; // Advertised per shadow camera
         	uniform mat4 _ShadowCameraProjectionMatrix; // Advertised per shadow camera
						
			varying vec4 v_textureCoordinates;				
			varying vec4 v_shadowCamera_Position;
			
			#ifdef VERTEX
			
			void main()
			{
				// Screen projection for vertex output.
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
				v_textureCoordinates = gl_MultiTexCoord0;       	
				
				// Shadow projection (multiplied by shadow camera ModelViewProjection matrix).
				// Simply like this vertex was filmed from the shadow camera point of view.
				v_shadowCamera_Position = (_ShadowCameraProjectionMatrix * (_ShadowCameraViewMatrix * (_Object2World * gl_Vertex)));
			}
			#endif

			#ifdef FRAGMENT
			
			float unpackFloatFromVec4(const vec4 value)
			{
   				const vec4 bitShift = vec4(1.0 / (256.0 * 256.0 * 256.0), 1.0 / (256.0 * 256.0), 1.0 / 256.0, 1.0);
   				return (dot(value, bitShift));
			}
			
			float normalizedDepth(float depth)
			{
				return depth;
//			
//				float m33 = _ShadowProjectionMatrix[2][2];
//				float m34 = _ShadowProjectionMatrix[2][3];
//				float near = 1.0; // m34 / (m33 - 1.0);
//				float far = 6.0; // m34 / (m33 + 1.0);
//				// return (depth - near) / (far - near);
//				return depth / (far - near);
			}
			
			float linearizeDepth(const float depth)
			{
				float far = 10.0;
				float near = 2.5;
				return (2.0 * near) / (far + near - depth * (far - near));
			}
			
			void main()
			
			{
				// vec4 packedFloatColor = packFloatToVec4(depth);
				// vec4 textureColor = texture2D(_MainTex, v_textureCoordinates.xy);
				vec4 debugColor; 
				float position = normalizedDepth(v_shadowCamera_Position.z);
				if (position < -5.0) debugColor = vec4(0, 1, 1, 1.0);
				if (position > -5.0) debugColor = vec4(0, 1, 1, 1.0);
				if (position > -4.0) debugColor = vec4(0, 1, 0.75, 1.0);
				if (position > -3.0) debugColor = vec4(0, 1, 0.5, 1.0);
				if (position > -2.0) debugColor = vec4(0, 1, 0.25, 1.0);
				if (position > -1.0) debugColor = vec4(0, 1, 0, 1.0); // Green
				if (position > 0.0) debugColor = vec4(1, 0, 0, 1.0); // Red
				if (position > 1.0) debugColor = vec4(1, 0.25, 0, 1.0); 
				if (position > 2.0) debugColor = vec4(1, 0.5, 0, 1.0);
				if (position > 3.0) debugColor = vec4(1, 0.75, 0, 1.0);
				if (position > 4.0) debugColor = vec4(1, 1, 0, 1.0);
				
				// Output.
				gl_FragColor = debugColor; // _MainColor;
			}
			#endif

			ENDGLSL
		}		
   }
}