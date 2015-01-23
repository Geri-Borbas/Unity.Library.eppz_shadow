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
         	#include "Assets/EPPZShadow/Shaders/EPPZ_Shadow.glslinc"

         	uniform vec4 _MainColor; 
 			uniform sampler2D _MainTex;
 			varying vec4 v_textureCoordinates;		
			
			#ifdef VERTEX
			
			void main()
			{
				// Screen projection for vertex output.
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
				v_textureCoordinates = gl_MultiTexCoord0;       	
				
				SHADOW_VERTEX;
			}
			#endif

			#ifdef FRAGMENT
			
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