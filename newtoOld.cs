using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class newtoOld : MonoBehaviour
{
    public Material mt;
    public float value = 0;
    public float speed;
    float b;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

        if (Input.GetKeyDown(KeyCode.Space))
        {
             b = 1.2f;
        }
        if (Input.GetKeyDown(KeyCode.Delete))
        {
             b = 0;
        }
        value = Mathf.Lerp(value, b, Time.deltaTime * speed);
        mt.SetFloat("_OTNblend", value);
    }
}
