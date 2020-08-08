﻿using UnityEngine;
using UnityEngine.SocialPlatforms;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class GridHeightMap : MonoBehaviour
{

	[Range(1, 1000)]
	public int xSize;
	[Range(1, 1000)]
	public int ySize;
	[Range(0, 1)]
	public float range;
	[Range(0, 1000)]
	public float height;

	private Mesh mesh;
	private Vector3[] vertices;

	public Texture2D heightmap;

	private void Awake()
	{
		Generate();
		GetComponent<MeshCollider>().sharedMesh = mesh;
	}
	private void Update()
    {

    }

	float GetHeightFromHeightMap(int xpos, int zpos)
	{
		int x = (xpos * heightmap.width / xSize);
		int z = (zpos * heightmap.height / ySize);
		Debug.Log(xpos);
		return (heightmap.GetPixel(x, z).grayscale);
	}

	private void Generate()
	{
		Destroy(GetComponent<MeshFilter>().mesh);

		GetComponent<MeshFilter>().mesh = mesh = new Mesh();
		mesh.name = "HeightMap Grid";

		vertices = new Vector3[(xSize + 1) * (ySize + 1)];
		Vector2[] uv = new Vector2[vertices.Length];
		Vector4[] tangents = new Vector4[vertices.Length];
		Vector4 tangent = new Vector4(1f, 0f, 0f, -1f);
		for (int i = 0, y = 0; y <= ySize; y++)
		{
			for (int x = 0; x <= xSize; x++, i++)
			{
				vertices[i] = new Vector3(x, 0, y);

				//从heightmap获取高度
				vertices[i].y = GetHeightFromHeightMap(x,y) * height;
				uv[i] = new Vector2((float)x / xSize, (float)y / ySize);
				tangents[i] = tangent;
			}
		}
		mesh.vertices = vertices;
		mesh.uv = uv;
		mesh.tangents = tangents;

		int[] triangles = new int[xSize * ySize * 6];
		for (int ti = 0, vi = 0, y = 0; y < ySize; y++, vi++)
		{
			for (int x = 0; x < xSize; x++, ti += 6, vi++)
			{
				triangles[ti] = vi;
				triangles[ti + 3] = triangles[ti + 2] = vi + 1;
				triangles[ti + 4] = triangles[ti + 1] = vi + xSize + 1;
				triangles[ti + 5] = vi + xSize + 2;
			}
		}
		mesh.triangles = triangles;
		mesh.RecalculateNormals();
	}
}
