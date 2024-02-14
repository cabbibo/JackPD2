using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class SetGlobalColorMap : MonoBehaviour
{

    public Texture2D colorMap;
    public Texture2D colorMap1;
    public Texture2D colorMap2;
    public Texture2D colorMap3;


    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

        Shader.SetGlobalTexture("_ColorMap", colorMap);
        Shader.SetGlobalTexture("_ColorMap1", colorMap1);
        Shader.SetGlobalTexture("_ColorMap2", colorMap2);
        Shader.SetGlobalTexture("_ColorMap3", colorMap3);
    }
}
