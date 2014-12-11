﻿Shader "eppz!/Shadow/Receiver"
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

         	uniform vec4 _MainColor; 
 			uniform sampler2D _MainTex;
			uniform sampler2D _ShadowMap;
         	
         	uniform mat4 _Object2World; // Advertised by Unity  
         	uniform mat4 _ShadowCameraViewMatrix; // Advertised per shadow camera
         	uniform mat4 _ShadowCameraProjectionMatrix; // Advertised per shadow camera
         	uniform float _ShadowCameraNearClipPlane;
         	uniform float _ShadowCameraFarClipPlane;
						
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
			
			float normalizedDepth(vec4 position)
			{
				float near = _ShadowCameraNearClipPlane;
				float far = _ShadowCameraFarClipPlane;
				return ((position.z / position.w) + 1.0) / 2.0; // / (far - near);
			}
			
			void main()
			{
				// Get shadow camera z-buffer sample for this fragment position.
				// vec4 packedFloatColor = packFloatToVec4(depth);
				// vec4 textureColor = texture2D(_MainTex, v_textureCoordinates.xy);
				
				// Get shadow camera fragment depth.
				float depth = normalizedDepth(v_shadowCamera_Position);
				
				// Debug.
				vec4 debugColor; 
				if (depth < 0.0) debugColor = vec4(0, 0, 0, 1);
				debugColor = vec4(depth, depth, depth, 1);
				if (depth > 0.75 && depth < 0.755) debugColor = vec4(0.1, 1, 0.5, 1);				
				if (depth > 1.0) debugColor = vec4(1, 1, 1, 1);
				
				// Output.
				gl_FragColor = debugColor; // _MainColor;
			}
			#endif

			ENDGLSL
		}		
   }
}