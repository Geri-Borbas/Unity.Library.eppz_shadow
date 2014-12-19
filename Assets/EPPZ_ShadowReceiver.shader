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

         	uniform vec4 _MainColor; 
 			uniform sampler2D _MainTex;
			uniform sampler2D _ShadowMap;
         	
         	uniform mat4 _Object2World; // Advertised by Unity  
         	uniform mat4 _ShadowCameraViewMatrix; // Advertised per shadow camera
         	uniform mat4 _ShadowCameraProjectionMatrix; // Advertised per shadow camera
         	uniform float _ShadowCameraNearClipPlane;
         	uniform float _ShadowCameraFarClipPlane;
						
			varying vec4 v_textureCoordinates;				
			varying vec4 v_shadowProjection_Position;
			varying float v_attenuation;		
			
			#ifdef VERTEX
			
			void main()
			{
				// Screen projection for vertex output.
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
				v_textureCoordinates = gl_MultiTexCoord0;       	
				
				// Shadow projection (multiplied by shadow camera ModelViewProjection matrix).
				// Simply like this vertex was filmed from the shadow camera point of view.
				mat4 shadow_ModelViewMatrix = _ShadowCameraViewMatrix * _Object2World;				
				mat4 shadow_ModelViewProjectionMatrix = _ShadowCameraProjectionMatrix * _ShadowCameraViewMatrix * _Object2World;
				mat4 shadow_NormalMatrix = shadow_ModelViewMatrix; // transpose(inverse(shadow_ModelViewMatrix));
				v_shadowProjection_Position = shadow_ModelViewProjectionMatrix * gl_Vertex;
								
				// Light.
				v_attenuation = dot(gl_Normal, vec3(0.0, -1.0, 0.0));
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
				vec4 outputColor; 
				float bias = 0.025;
				
				// Normalize shadow projection positions.
				vec4 shadowProjection_Position = v_shadowProjection_Position / v_shadowProjection_Position.w;
			
				// Get scene depth sample for this fragment position.
				vec2 shadowMap_UV = vec2(
					(shadowProjection_Position.x + 1.0) * 0.5,
					(shadowProjection_Position.y + 1.0) * 0.5
					);
			
				vec4 sceneDepthSample = texture2D(_ShadowMap, shadowMap_UV);
				float shadowCameraDepth = sceneDepthSample.r; // unpackFloatFromVec4(sceneDepthSample);
				
				// Get shadow camera fragment depth.
				float shadowProjectionDepth = normalizedDepth(v_shadowProjection_Position);
				
				// Shadow tests.
				bool shadowed = (shadowCameraDepth + bias < shadowProjectionDepth);				
				float shadowDepth = shadowProjectionDepth - shadowCameraDepth;
				
				// Lighting.
				vec4 lightColor;
				if (v_attenuation > 0.0)
				{
					 lightColor = vec4(0, 0, 0, 1);
				}
				else
				{
					float lightAttenution = v_attenuation * -1.0;
					lightColor = vec4(lightAttenution, lightAttenution, lightAttenution, 1.0);
				}
				
				// Blend.
				vec4 unlitColor = vec4(0, 0, 0, 1);
				vec4 litColor = lightColor;
				outputColor = (shadowed) ? unlitColor : litColor;
				
				// Unlit fragments outside shadow camera frustum.
				if (shadowProjection_Position.x > 1.0) outputColor =  unlitColor;
				if (shadowProjection_Position.x < -1.0) outputColor =  unlitColor;
				if (shadowProjection_Position.y > 1.0) outputColor =  unlitColor;
				if (shadowProjection_Position.y < -1.0) outputColor =  unlitColor;		
				
				// Output.
				gl_FragColor = outputColor;
			}
			#endif

			ENDGLSL
		}		
   }
}