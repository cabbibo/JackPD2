using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FantasyTree {


[ExecuteAlways]
public class ControlTreeMaterialValues : MonoBehaviour
{




    [Range(0,1)]
    public float barkShown;
    
    [Range(0,1)]
    public float flowersShown;

    [Range(0,1)]
    public float flowersFallen;


    public Material flowersMaterial;
    public Material barkMaterial;


    public Renderer renderer;

    MaterialPropertyBlock flowersMPB;
    MaterialPropertyBlock barkMPB;


    public Color _BaseColor;
    public Color _TipColor;

    public float _TipColorMultiplier;
    public float _BaseColorMultiplier;

    void OnEnable(){
        renderer = GetComponent<MeshRenderer>();


    }

    // Update is called once per frame
    void Update()
    {


        if( barkMPB == null ){ 
            barkMPB = new MaterialPropertyBlock();
            renderer.GetPropertyBlock(barkMPB,1);
        }

        if( flowersMPB == null ){ 
            flowersMPB = new MaterialPropertyBlock();
            renderer.GetPropertyBlock(flowersMPB,1);
        }

        barkMPB.SetFloat("_AmountShown",barkShown);

        barkMPB.SetFloat("_TipColorMultiplier",_TipColorMultiplier);
        barkMPB.SetFloat("_BaseColorMultiplier",_BaseColorMultiplier);
        barkMPB.SetColor("_TipColor",_TipColor);
        barkMPB.SetColor("_BaseColor",_BaseColor);
      
        flowersMPB.SetFloat("_AmountShown",flowersShown);
        flowersMPB.SetFloat("_FallingAmount",flowersFallen);

        renderer.SetPropertyBlock( barkMPB ,0);
        renderer.SetPropertyBlock( flowersMPB ,1);
    
    
    
    
    }
}}