using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Selfrotate : MonoBehaviour
{
    public enum State
    {
        xaxis, yaxis, zaxis
    }

    public State current;
    public float rotateSpeed = 1;

    // Start is called before the first frame update
    void Start()
    {
        current = State.yaxis;
    }

    // Update is called once per frame
    void Update()
    {
        if(current == State.xaxis)
            transform.Rotate(Vector3.forward * rotateSpeed * 50 * Time.deltaTime, Space.Self);

        else if(current == State.yaxis)
            transform.Rotate(Vector3.up * rotateSpeed * 50 * Time.deltaTime, Space.Self);

        else if(current == State.zaxis)
            transform.Rotate(Vector3.right * rotateSpeed * 50 * Time.deltaTime, Space.Self);
    }
}
