Shader "eppz!/Shadow/Camera"
{
	Properties
	{ }
	
    SubShader
    {   
    	// Depth values into a texture.
        Pass
      	{
      		Lighting Off
      		
			GLSLPROGRAM
			
			#ifdef VERTEX
			void main()
			{
				gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;         	
			}
			#endif

			#ifdef FRAGMENT
			
			vec4 packFloatToVec4(const float value)
			{
  				const vec4 bitShift = vec4(256.0 * 256.0 * 256.0, 256.0 * 256.0, 256.0, 1.0);
  				const vec4 bitMask = vec4(0.0, 1.0 / 256.0, 1.0 / 256.0, 1.0 / 256.0);
  				vec4 result = fract(value * bitShift);
  				result -= result.xxyz * bitMask;
				return result;
			}
			
			void main()
			{
				float depth = gl_FragCoord.z;
				vec4 debugColor = vec4(depth, depth, depth, 1.0);
				vec4 packedFloatColor = packFloatToVec4(depth);
				
				// Output.
				gl_FragColor = debugColor;
			}
			#endif

			ENDGLSL
		}		
   }
}
