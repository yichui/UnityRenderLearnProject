using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoateLight : MonoBehaviour
{


    public float x = 0f;
    public float y = 0f;
    public float z = 0f;

    void Update()
    {
        transform.Rotate(Time.deltaTime * x, 0, 0, Space.World);
        transform.Rotate(0, Time.deltaTime * y, 0, Space.World);
        transform.Rotate(0, 0, Time.deltaTime * z, Space.World);
    }
}
