using UnityEngine;
using System.Collections;


public class EPPZ_ShadowCamera : MonoBehaviour
{


	public string viewMatrixPropertyName = "_ShadowCameraViewMatrix";
	public string projectionMatrixPropertyName = "_ShadowCameraProjectionMatrix";
	public Material depthMapGeneratingMaterial;


	void Start()
	{
		// Setup.
		camera.clearFlags = CameraClearFlags.Color;
		camera.backgroundColor = Color.white;
		camera.renderingPath = RenderingPath.Forward;
		camera.SetReplacementShader(depthMapGeneratingMaterial.shader, "");
	}

	void OnDrawGizmos()
	{
		AdvertiseProjection(); // In Editor
	}

	void Update()
	{
		AdvertiseProjection(); // In Game
	}

	void AdvertiseProjection()
	{
		Shader.SetGlobalMatrix(viewMatrixPropertyName, camera.worldToCameraMatrix);
		Shader.SetGlobalMatrix(projectionMatrixPropertyName, camera.projectionMatrix);
	}
}
