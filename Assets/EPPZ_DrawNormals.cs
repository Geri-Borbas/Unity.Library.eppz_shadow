using UnityEngine;
using System.Collections;

public class EPPZ_DrawNormals : MonoBehaviour
{


	public Camera projectionCamera;
	private Mesh mesh;


	void Start()
	{
		mesh = GetComponent<MeshFilter>().mesh;
	}

	void Update()
	{
		Apply();
	}

	void Apply()
	{
		for (int index = 0; index < mesh.vertexCount; index++)
		{
			// Cartesian coordinates.
			Vector3 eachVertex = mesh.vertices[index];
			Vector3 eachNormal = mesh.normals[index];
			Matrix4x4 _ObjectToWorld = this.transform.localToWorldMatrix;

			Vector3 eachTransformedVertex = _ObjectToWorld.MultiplyPoint(eachVertex);

			Vector3 translatedNormal = eachVertex + eachNormal; 
			float amount = Vector3.Dot(
				eachNormal,
				projectionCamera.transform.forward
				);

			Vector3 scaledNormal = translatedNormal * amount;

			Debug.DrawLine(
				eachTransformedVertex,
				eachTransformedVertex + scaledNormal,
				Color.white
				);

			Debug.DrawLine(
				eachTransformedVertex,
				eachTransformedVertex + projectionCamera.transform.forward,
				Color.white
				);
		}
	}
}
