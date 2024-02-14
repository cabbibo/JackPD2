using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.Rendering;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;



namespace FantasyTree {

[ExecuteAlways]
public class Tree : MonoBehaviour
{


    public string saveName;

    
    [Header("Branching Info")]
    // How many points we see on a branch
    
    [Range(1,100)] public int pointsPerBranch = 40;
    
    [Range(0,2)] public float pointsPerBranchReducer = .9f;

    // Max number of spawns per branch
    [Range(1,100)] public int maxNumberBranchesPerBranch = 40;
    
    [Range(0,2)] public float maxNumberBranchesPerBranchReducer = .6f;


    [Range(0,1)]public float branchChance = .6f;
    
    [Range(0,2)] public float branchChanceReducer = .8f;


    [Range(0,1)]public float noisePower = .4f;
    [Range(0,2)] public float noisePowerReducer = 1.1f;


    [Range(0,10)]public float noiseSize = .4f;
    [Range(0,5)] public float noiseSizeReducer = 1.1f;

    


    
    
    // Changes how much branches match the current branches
    // direction
    [Range(0,1)]public float minAngleMatch = 0;
    
    [Range(0,2)] public float minAngleReducer = 1;
    
    [Range(0,1)] public float maxAngleMatch = 1;
    
    [Range(0,2)] public float maxAngleReducer = .9f;





    // If this value is 1, then the length will be reduced
    // by how far up the branch it is. if it is 0, will not matter
    [Range(0,1)] public float baseVsTipLength = 0;
    [Range(0,2)] public float baseVsTipLengthReducer = 1;


    // If this value is 1, then the branch will pull its max length from 
    // its parents length, rather than the current iteration level
    [Range(0,1)] public float parentLengthMax= 0;
    [Range(0,2)] public float parentLengthMaxReducer = 1;



    [Range(0,5)] public float length = 2;
    [Range(0,2)] public float lengthReducer = .9f;


    [Range(0,1)] public float lengthVariation = .3f;
    [Range(0,2)] public float lengthVariationReducer = .9f;

    [Range(0,1)] public float upDesire = 1;    
    [Range(0,2)] public float upDesireReducer = .9f;


    // Where we want branches to start and end
    [Range(0,1)] public float startBranchLocation = .5f;
    [Range(0,1)] public float startBranchLocationReducer = .9f;
    [Range(0,4)] public float endOfBranchWeight = .5f;
    [Range(0,2)] public float endOfBranchWeightReducer = .9f;





    [Header("Bark Info")]
    [Range(0,2)] public float width;
    [Range(0,1)] public float widthReducer;


    // if width smaller than this wont make a branch
    [Range(0,.1f)] public float widthCutoff;

    [Range(1,100)] public int numBarkColumns = 10;
    [Range(0,2)] public float numBarkColumnsReducer = 1;

    [Range(1,100)] public int numBarkRows = 20;
    
    [Range(0,2)] public float numBarkRowsReducer = 1;
    

    
    [Header("Flower Info")]
    [Range(0,100)] public int numFlowers = 40;
    [Range(0,1)] public float flowerSize = .1f;
    [Range(0,1)] public float flowerSizeRandomness = .1f;
    [Range(0,1)] public float flowerMinDirectionMatch = 0;
    [Range(0,1)] public float flowerMaxDirectionMatch = 0;
    [Range(0,1)] public float offsetSize = .1f;


    [Header("Limits ")]
    // Limiting recursion
    [Range(0,5)] public int maxIterationLevel = 3;
    [Range(0,10000)] public int maxBranches = 20;
    [Range(0,100000)] public int maxPoints = 100000;

    
    // Width of just the trunk
    public AnimationCurve trunkCurve;

    // width of branches
    public AnimationCurve branchCurve;
    








    [Header("Data")]
    public int totalPoints;
    public int totalBarkPoints;
    public int totalBarkTris;
    public int totalFlowerPoints;
    public float maxTime;
    public float maxFlowerTime;
    public float minFlowerTime;

    

    public int currentTotalPoints;
    public int currentTotalBranches;

    public List<Branch> branches;//<Branches>

  

    /*

    //Procedural Update Params


    public bool debugSkeleton;
    public ComputeBuffer skeletonBuffer;
    public Material skeletonMaterial;


    public bool debugBark;
    public Material barkMaterial;
    
    public bool debugMesh;
    public Material meshMaterial;
    public ComputeBuffer barkBuffer;
    public ComputeBuffer barkTriBuffer;


    public bool debugFlower;
    public Material flowerMaterial;
    public ComputeBuffer flowerBuffer;

    
    public MaterialPropertyBlock skeletonMPB;
    public MaterialPropertyBlock barkMPB;
    public MaterialPropertyBlock flowerMPB;
    public MaterialPropertyBlock meshMPB;*/




   /* [Range(0,1)]
    public float skeletonShown;
    */


    /*

        Todo Variables


    */

    //[Header("Todo")]
    //public FastNoise noise;


    [HideInInspector]
    public Vector3 noiseOffset; // every time we recreate teh tree, changing this offset
                                // will make it so that we get a different looking tree very time


        


    public Mesh mesh;
    public MeshFilter meshFilter;
    public MeshRenderer meshRenderer;

    

    /*


         _______  ______    _______  _______          _______  __   __  ___   ___      ______  
        |       ||    _ |  |       ||       |        |  _    ||  | |  ||   | |   |    |      | 
        |_     _||   | ||  |    ___||    ___|        | |_|   ||  | |  ||   | |   |    |  _    |
          |   |  |   |_||_ |   |___ |   |___         |       ||  |_|  ||   | |   |    | | |   |
          |   |  |    __  ||    ___||    ___|        |  _   | |       ||   | |   |___ | |_|   |
          |   |  |   |  | ||   |___ |   |___         | |_|   ||       ||   | |       ||       |
          |___|  |___|  |_||_______||_______|        |_______||_______||___| |_______||______| 



    */
    public void BuildBranches(){
   
        noiseOffset = new Vector3( 0 , Mathf.Sin(Time.time * 10000) * 1000 ,0 );
        branches = new List<Branch>();
    
        int currIterations = 0;
        currentTotalPoints = 0;
        currentTotalBranches = 0;
       
        Vector3 direction = new Vector3(0,1,0);
        Vector3 startPosition = new Vector3(0,0,0);

        Branch trunk = new Branch(  this, currIterations , null  , startPosition , direction , 0 , 0  , length , width );

        //branches.Add( trunk );

        BuildMesh();

    }



    
    private      float[] barkVals;
    private      float[] flowerVals;
    private      int[] barkTris; 
    private      int[] flowerTris; 



/*


 _______  __   __  ___   ___      ______   ___   __    _  _______      __   __  _______  _______  __   __ 
|  _    ||  | |  ||   | |   |    |      | |   | |  |  | ||       |    |  |_|  ||       ||       ||  | |  |
| |_|   ||  | |  ||   | |   |    |  _    ||   | |   |_| ||    ___|    |       ||    ___||  _____||  |_|  |
|       ||  |_|  ||   | |   |    | | |   ||   | |       ||   | __     |       ||   |___ | |_____ |       |
|  _   | |       ||   | |   |___ | |_|   ||   | |  _    ||   ||  |    |       ||    ___||_____  ||       |
| |_|   ||       ||   | |       ||       ||   | | | |   ||   |_| |    | ||_|| ||   |___  _____| ||   _   |
|_______||_______||___| |_______||______| |___| |_|  |__||_______|    |_|   |_||_______||_______||__| |__|



*/

    public void BuildMesh(){        


        maxTime = 0;
        maxFlowerTime = 0;
        minFlowerTime = 10000000;
        totalPoints = 0;


        totalBarkPoints = 0;
        totalBarkTris = 0;
        totalFlowerPoints = 0;


        foreach( Branch b in branches ){
            
            totalBarkPoints += b.numBarkRows * b.numBarkColumns;

            totalBarkTris +=  (b.numBarkRows-1) * (b.numBarkColumns-1) * 3 * 2;

            totalFlowerPoints += b.flowers.Count;        

            // Getting a max time of every point created
            // so we can normalize creation times!
            for( int i = 0; i < b.points.Count; i++ ){

                maxTime = Mathf.Max(maxTime , b.points[i].timeCreated);

                totalPoints ++;
            }


    // generating our info for our flower points lives
              foreach( FlowerPoint p in b.flowers ){
                    Vector3 fPos;
                    Vector3 fDir;
                    Vector3 fTang;
                    Vector3 fNor;
                    Vector3 fCenter;
                    float fLife;
                    float fWidth;
                  b.GetBarkData( p.row , p.col , out fPos , out fCenter , out fDir , out fNor , out fTang,  out fLife,out fWidth);

                maxFlowerTime = Mathf.Max(maxFlowerTime , fLife);
                minFlowerTime = Mathf.Min(minFlowerTime , fLife);
            }
        
        
        }

    
        barkVals = new float[ totalBarkPoints * 16 ];
        flowerVals = new float[ totalFlowerPoints*4* 16 ];

        barkTris = new int[totalBarkTris]; 
        flowerTris = new int[totalFlowerPoints*3*2]; 

        // float[] vals = new float[ totalPoints * 16 ];

    
        int id = 0;
        int branchID = 0;
        int baseBarkID =0;
        int baseFlowerID =0;
        int baseTri = 0;


        foreach( Branch b in branches ){

            // Gets our base point from the flattened
            // point array
            int baseVal = id;

            // tells us how many points are in our current
            // branch!
            int totalPoints = b.numPoints;


            for( int i = 0; i < b.numBarkRows-1; i++){
                for( int j = 0; j < b.numBarkColumns-1; j++){

                    barkTris[ baseTri * 6 + 0 ] = baseBarkID +     i * b.numBarkColumns + j + 0;
                    barkTris[ baseTri * 6 + 1 ] = baseBarkID +     i * b.numBarkColumns + j + 1;
                    barkTris[ baseTri * 6 + 2 ] = baseBarkID + (i+1) * b.numBarkColumns + j + 1;
                    barkTris[ baseTri * 6 + 3 ] = baseBarkID +     i * b.numBarkColumns + j + 0;
                    barkTris[ baseTri * 6 + 4 ] = baseBarkID + (i+1) * b.numBarkColumns + j + 1;
                    barkTris[ baseTri * 6 + 5 ] = baseBarkID + (i+1) * b.numBarkColumns + j + 0;

                    baseTri ++;

                }
            }

            for( int i = 0; i < b.numBarkRows; i++ ){
                for( int j = 0; j < b.numBarkColumns; j++ ){

                    float normalizedRowID = (float)i/((float)b.numBarkRows-1);
                    float normalizedColID = (float)j/((float)b.numBarkColumns-1);

                    Vector3 fPos;
                    Vector3 fDir;
                    Vector3 fTang;
                    Vector3 fNor;
                    Vector3 fCenter;
                    float fLife;
                    float fWidth;

                    b.GetBarkData( normalizedRowID , normalizedColID, out fPos , out fCenter , out fDir , out fNor , out fTang,  out fLife,out fWidth);


                    barkVals[ baseBarkID * 16 + 0 ] = fPos.x;
                    barkVals[ baseBarkID * 16 + 1 ] = fPos.y;
                    barkVals[ baseBarkID * 16 + 2 ] = fPos.z;

                    barkVals[ baseBarkID * 16 + 3 ] = fNor.x;
                    barkVals[ baseBarkID * 16 + 4 ] = fNor.y;
                    barkVals[ baseBarkID * 16 + 5 ] = fNor.z;

                    barkVals[ baseBarkID * 16 + 6 ] = fCenter.x;
                    barkVals[ baseBarkID * 16 + 7 ] = fCenter.y;
                    barkVals[ baseBarkID * 16 + 8 ] = fCenter.z;
                    
                    barkVals[ baseBarkID * 16 + 9 ] = normalizedColID;
                    barkVals[ baseBarkID * 16 + 10 ] = normalizedRowID;
                    
                    barkVals[ baseBarkID * 16 + 11 ] = baseVal;
                    barkVals[ baseBarkID * 16 + 12 ] = totalPoints;
                    barkVals[ baseBarkID * 16 + 13 ] = fLife/maxTime;
                    
                    barkVals[ baseBarkID * 16 + 14 ] = 0;
                    barkVals[ baseBarkID * 16 + 15 ] = 0;
                 
                    baseBarkID ++;
                }


            }



            foreach( FlowerPoint p in b.flowers ){

                Vector3 fPos;
                Vector3 fDir;
                Vector3 fTang;
                Vector3 fNor = Vector3.left;
                Vector3 fCenter;
                float fLife;
                float fWidth;
                

                b.GetBarkData( p.row , p.col , out fPos , out fCenter , out fDir , out fNor , out fTang,  out fLife,out fWidth);


                Vector3 newNor = Vector3.Lerp( fNor ,  Vector3.Cross(fDir,fTang) ,Random.Range(flowerMinDirectionMatch , flowerMaxDirectionMatch));
                Vector3 x = Random.onUnitSphere;
                float fSize= flowerSize * p.size;
                for( int j = 0;  j < 4; j ++ ){

                    Vector3 left = Vector3.Cross( newNor , Vector3.up ).normalized;

                    Vector2 uv2 = new Vector2( j/2 , j%2 );
                    //float
                    Vector3 fOffset = p.offset * newNor  * offsetSize + newNor * fSize  * .5f+ fPos;
                    Vector3 ffPos =  fOffset +  left *(uv2.x - .5f) * fSize  + newNor  * (uv2.y-.5f) * fSize;

            
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 0  ] = ffPos.x;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 1  ] = ffPos.y;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 2  ] = ffPos.z;

                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 3  ] = newNor.x;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 4  ] = newNor.y;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 5  ] = newNor.z;

                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 6  ] = fOffset.x;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 7  ] = fOffset.y;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 8  ] = fOffset.z;
                    
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 9  ] = uv2.x;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 10 ] = uv2.y;

                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 11 ] = baseVal;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 12 ] = fSize;   

                    // have to normalize based on our min and max time
                    float life = (fLife - minFlowerTime) / (maxFlowerTime-minFlowerTime);    
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 13 ] = life;

                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 14 ] = p.offset;
                    flowerVals[  ( baseFlowerID * 4 + j) * 16 + 15 ] = p.row;
                    
                   

                }



                // Adding the trisss
                flowerTris[baseFlowerID * 6 + 0] = baseFlowerID * 4 + 0 + totalBarkPoints;
                flowerTris[baseFlowerID * 6 + 1] = baseFlowerID * 4 + 1 + totalBarkPoints;
                flowerTris[baseFlowerID * 6 + 2] = baseFlowerID * 4 + 3 + totalBarkPoints;
                flowerTris[baseFlowerID * 6 + 3] = baseFlowerID * 4 + 0 + totalBarkPoints;
                flowerTris[baseFlowerID * 6 + 4] = baseFlowerID * 4 + 3 + totalBarkPoints;
                flowerTris[baseFlowerID * 6 + 5] = baseFlowerID * 4 + 2 + totalBarkPoints;

                baseFlowerID += 1;


            }


        
     
          /*  foreach( BranchPoint p in b.points ){
                
                vals[ id  * 16 + 0] = p.position.x;
                vals[ id  * 16 + 1] = p.position.y;
                vals[ id  * 16 + 2] = p.position.z;
                vals[ id  * 16 + 3] = p.normal.x;
                vals[ id  * 16 + 4] = p.normal.y;
                vals[ id  * 16 + 5] = p.normal.z;
                vals[ id  * 16 + 6] = p.tangent.x;
                vals[ id  * 16 + 7] = p.tangent.y;
                vals[ id  * 16 + 8] = p.tangent.z;
                
                vals[ id  * 16 + 9] = p.positionInBranch;
                vals[ id  * 16 + 10] = p.timeCreated;
                vals[ id  * 16 + 11] = p.timeCreated/maxTime;
                vals[ id  * 16 + 12] = 0;
                vals[ id  * 16 + 13] = 0;
                vals[ id  * 16 + 14] = 0;
                vals[ id  * 16 + 15] = 0;

                id ++;
            }*/

            branchID ++;
        }

     /* skeletonBuffer = new ComputeBuffer( totalPoints , 16 * sizeof(float));
        skeletonBuffer.SetData(vals);


        barkBuffer = new ComputeBuffer( totalBarkPoints ,16 * sizeof(float));
        barkBuffer.SetData(barkVals);



        flowerBuffer = new ComputeBuffer( totalFlowerPoints ,16 * sizeof(float) );
        flowerBuffer.SetData(flowerVals);


        barkTriBuffer = new ComputeBuffer( totalBarkTris , sizeof(int));
        barkTriBuffer.SetData(barkTris);*/





        RebuildMeshFromData( barkVals , barkTris, flowerVals , flowerTris );
     



    }



    public void RebuildMeshFromData( float[] data_Verts , int[] data_Tris , float[] data_Flowers , int[] data_FlowersTris ){


        // our verts we dont need to recreate
        // but our flowers we DO ( 1 quad per flower! )
        int total = (data_Verts.Length / 16) + (data_Flowers.Length/16);
     
        mesh = new Mesh();

        Vector3[] verts     = new Vector3[total];
        Vector3[] normals   = new Vector3[total];
        Vector2[] uvs       = new Vector2[total];
        Vector3[] data1     = new Vector3[total];
        Vector3[] data2     = new Vector3[total];
        Vector2[] data3     = new Vector2[total];

        int index = 0;

        for( int i = 0; i < data_Verts.Length/16; i++ ){

            verts[index] = new Vector3(     data_Verts[index * 16  + 0],
                                            data_Verts[index * 16  + 1],
                                            data_Verts[index * 16  + 2] );

            normals[index] = new Vector3(   data_Verts[index * 16  + 3],
                                            data_Verts[index * 16  + 4],
                                            data_Verts[index * 16  + 5] );

            data1[index] = new Vector3(     data_Verts[index * 16  + 6],
                                            data_Verts[index * 16  + 7],
                                            data_Verts[index * 16  + 8] );
            
            uvs[index]      = new Vector2(  data_Verts[index * 16  + 9],
                                            data_Verts[index * 16  + 10] );

            data2[index]    = new Vector3(  data_Verts[index * 16  + 11],
                                            data_Verts[index * 16  + 12],
                                            data_Verts[index * 16  + 13] );

            data3[index]    = new Vector2(  data_Verts[index * 16  + 14],
                                            data_Verts[index * 16  + 15] );

            index ++;

        }

    

        int baseIndex = index;
 


        for( int i = 0; i < data_Flowers.Length/16; i++ ){

            verts[index] = new Vector3(     data_Flowers[i * 16  + 0],
                                            data_Flowers[i * 16  + 1],
                                            data_Flowers[i * 16  + 2] );

            normals[index] = new Vector3(   data_Flowers[i * 16  + 3],
                                            data_Flowers[i * 16  + 4],
                                            data_Flowers[i * 16  + 5] );

            data1[index] = new Vector3(     data_Flowers[i * 16  + 6],
                                            data_Flowers[i * 16  + 7],
                                            data_Flowers[i * 16  + 8] );
        
            uvs[index]      = new Vector2(  data_Flowers[i * 16  + 9],
                                            data_Flowers[i * 16  + 10] );

            data2[index]    = new Vector3(  data_Flowers[i * 16  + 11],
                                            data_Flowers[i * 16  + 12],
                                            data_Flowers[i * 16  + 13] );

            data3[index]    = new Vector2(  data_Flowers[i * 16  + 14],
                                            data_Flowers[i * 16  + 15] );

            index ++;
        }

        for( int i = 0; i < data_FlowersTris.Length; i++ ){
           // data_FlowersTris[i] = data_FlowersTris[i] + baseIndex;
        }

        mesh.vertices = verts;
        mesh.normals  = normals;
        mesh.uv = uvs;

        mesh.SetUVs(1 ,data1);
        mesh.SetUVs(2 ,data2);
        mesh.SetUVs(3 ,data3);

        mesh.indexFormat = IndexFormat.UInt32;
        mesh.subMeshCount = 2;
       


        //print("bark indiceesss ---------------");
        //for( int i = 0; i < data_Tris.Length; i++ ){
        //    print(data_Tris[i]);
        //}

        mesh.SetTriangles( data_Tris , 0 );


        //print("tri indiceesss ---------------");
        //for( int i = 0; i < data_FlowersTris.Length; i++ ){
        //    print(data_FlowersTris[i]);
        //}

        mesh.SetTriangles( data_FlowersTris , 1 );


        meshFilter.mesh = mesh;


    }






/*






 _______  _______  __   __  ___   __    _  _______        _______  __    _  ______         ___      _______  _______  ______   ___   __    _  _______ 
|       ||   _   ||  | |  ||   | |  |  | ||       |      |   _   ||  |  | ||      |       |   |    |       ||   _   ||      | |   | |  |  | ||       |
|  _____||  |_|  ||  |_|  ||   | |   |_| ||    ___|      |  |_|  ||   |_| ||  _    |      |   |    |   _   ||  |_|  ||  _    ||   | |   |_| ||    ___|
| |_____ |       ||       ||   | |       ||   | __       |       ||       || | |   |      |   |    |  | |  ||       || | |   ||   | |       ||   | __ 
|_____  ||       ||       ||   | |  _    ||   ||  |      |       ||  _    || |_|   |      |   |___ |  |_|  ||       || |_|   ||   | |  _    ||   ||  |
 _____| ||   _   | |     | |   | | | |   ||   |_| |      |   _   || | |   ||       |      |       ||       ||   _   ||       ||   | | | |   ||   |_| |
|_______||__| |__|  |___|  |___| |_|  |__||_______|      |__| |__||_|  |__||______|       |_______||_______||__| |__||______| |___| |_|  |__||_______|







*/



    public void SaveMesh(){
        SaveTree(barkVals,barkTris,flowerVals,flowerTris);
    }
    public void SaveAll(){
        SaveTree(barkVals,barkTris,flowerVals,flowerTris);
        SaveParameters();
    }


    public void LoadMesh(){
        LoadTree();
    }


    public void CreateAsset(){

        if( mesh == null ){
            BuildMesh();
        }
        

    }




    public string basePath(){
        return  Application.dataPath + "/Plugins/FantasyTree/Trees/";
    }
    public string GetDataPath(){
        
        string path = basePath() + saveName;

        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }

        return path  + "/" + saveName;
 

    }


    public void LoadParameters(){

        
        string saveName_Params = GetDataPath() + ".treeParams";

         BinaryFormatter bf = new BinaryFormatter();
        FileStream stream = new FileStream(saveName_Params,FileMode.Open);
        float[] data_Params = bf.Deserialize(stream) as float[];
        stream.Close();


        UnflattenParams(data_Params);
    }

    public void LoadAll(){
        LoadParameters();
        LoadTree();

    }


    public void SaveParameters(){

        string saveName_Params = GetDataPath() + ".treeParams";

        BinaryFormatter bf = new BinaryFormatter();
        FileStream stream = new FileStream(saveName_Params,FileMode.Create);
        bf.Serialize(stream,FlattenParams().ToArray());
        stream.Close();

    }


    public void SaveTree(  float[] verts , int[] tris , float[] flowers , int[] flowersTris  ){

        string saveName_Verts           = GetDataPath() + ".treeBarkVert";
        string saveName_Tris            = GetDataPath() + ".treeBarkTri";
        string saveName_Flowers         = GetDataPath() + ".treeFlowerVert";
        string saveName_FlowersTris     = GetDataPath() + ".treeFlowerTris";



   

        BinaryFormatter bf = new BinaryFormatter();
        FileStream stream = new FileStream(saveName_Verts,FileMode.Create);
        bf.Serialize(stream,verts);
        stream.Close();

        stream = new FileStream(saveName_Tris,FileMode.Create);
        bf.Serialize(stream,tris);
        stream.Close();

        
        stream = new FileStream(saveName_Flowers,FileMode.Create);
        bf.Serialize(stream,flowers);
        stream.Close();


        stream = new FileStream(saveName_FlowersTris,FileMode.Create);
        bf.Serialize(stream,flowersTris);
        stream.Close();
        

    }

    public void LoadTree(){
        
      
        string saveName_Verts = GetDataPath() + ".treeBarkVert";
        string saveName_Tris = GetDataPath() + ".treeBarkTri";
        string saveName_Flowers = GetDataPath() + ".treeFlowerVert";
        string saveName_FlowersTris = GetDataPath() + ".treeFlowerTris";
       
        BinaryFormatter bf = new BinaryFormatter();
        FileStream stream = new FileStream(saveName_Verts,FileMode.Open);
        float[] data_Verts = bf.Deserialize(stream) as float[];
        stream.Close();

        stream = new FileStream(saveName_Tris,FileMode.Open);
        int[] data_Tris = bf.Deserialize(stream) as int[];
        stream.Close();

        stream = new FileStream(saveName_Flowers,FileMode.Open);
        float[] data_Flowers = bf.Deserialize(stream) as float[];
        stream.Close();

        stream = new FileStream(saveName_FlowersTris,FileMode.Open);
        int[] data_FlowersTris = bf.Deserialize(stream) as int[];
        stream.Close();

        RebuildMeshFromData( data_Verts, data_Tris , data_Flowers, data_FlowersTris );


    }

    
    public List<float> FlattenParams(){

        List<float> paramList = new List<float>();

        paramList.Add((float)pointsPerBranch);
        paramList.Add((float)pointsPerBranchReducer);
        paramList.Add((float)maxNumberBranchesPerBranch);
        paramList.Add((float)maxNumberBranchesPerBranchReducer);
        paramList.Add((float)branchChance);
        paramList.Add((float)branchChanceReducer);
        paramList.Add((float)noisePower);
        paramList.Add((float)noisePowerReducer);
        paramList.Add((float)noiseSize);
        paramList.Add((float)noiseSizeReducer);
        paramList.Add((float)minAngleMatch);
        paramList.Add((float)minAngleReducer);
        paramList.Add((float)maxAngleMatch);    
        paramList.Add((float)maxAngleReducer);
        paramList.Add((float)baseVsTipLength);
        paramList.Add((float)baseVsTipLengthReducer);
        paramList.Add((float)parentLengthMax);
        paramList.Add((float)parentLengthMaxReducer);
        paramList.Add((float)length);
        paramList.Add((float)lengthReducer);
        paramList.Add((float)lengthVariation);
        paramList.Add((float)lengthVariationReducer);
        paramList.Add((float)upDesire);    
        paramList.Add((float)upDesireReducer);
        paramList.Add((float)startBranchLocation);
        paramList.Add((float)startBranchLocationReducer);
        paramList.Add((float)endOfBranchWeight);
        paramList.Add((float)endOfBranchWeightReducer);
        paramList.Add((float)width);
        paramList.Add((float)widthReducer);
        paramList.Add((float)widthCutoff);
        paramList.Add((float)numBarkColumns);
        paramList.Add((float)numBarkColumnsReducer);
        paramList.Add((float)numBarkRows);
        paramList.Add((float)numBarkRowsReducer);
        paramList.Add((float)numFlowers);
        paramList.Add((float)flowerSize);
        paramList.Add((float)flowerSizeRandomness);
        paramList.Add((float)flowerMinDirectionMatch);
        paramList.Add((float)flowerMaxDirectionMatch);
        paramList.Add((float)offsetSize);
        paramList.Add((float)maxIterationLevel);
        paramList.Add((float)maxBranches);
        paramList.Add((float)maxPoints);
        

        return paramList;

    }


    public void UnflattenParams(float[] P ){

        pointsPerBranch                         = (int)P[0];
        pointsPerBranchReducer                  = P[1];
        maxNumberBranchesPerBranch              = (int)P[2];
        maxNumberBranchesPerBranchReducer       = P[3];
        branchChance                            = P[4];
        branchChanceReducer                     = P[5];
        noisePower                              = P[6];
        noisePowerReducer                       = P[7];
        noiseSize                               = P[8];
        noiseSizeReducer                        = P[9];
        minAngleMatch                           = P[10];
        minAngleReducer                         = P[11];
        maxAngleMatch                           = P[12];    
        maxAngleReducer                         = P[13];
        baseVsTipLength                         = P[14];
        baseVsTipLengthReducer                  = P[15];
        parentLengthMax                         = P[16];
        parentLengthMaxReducer                  = P[17];
        length                                  = P[18];
        lengthReducer                           = P[19];
        lengthVariation                         = P[20];
        lengthVariationReducer                  = P[21];
        upDesire                                = P[22];    
        upDesireReducer                         = P[23];
        startBranchLocation                     = P[24];
        startBranchLocationReducer              = P[25];
        endOfBranchWeight                       = P[26];
        endOfBranchWeightReducer                = P[27];
        width                                   = P[28];
        widthReducer                            = P[29];
        widthCutoff                             = P[30];
        numBarkColumns                          = (int)P[31];
        numBarkColumnsReducer                   = P[32];
        numBarkRows                             = (int)P[33];
        numBarkRowsReducer                      = P[34];
        numFlowers                              = (int)P[35];
        flowerSize                              = P[36];
        flowerSizeRandomness                    = P[37];
        flowerMinDirectionMatch                 = P[38];
        flowerMaxDirectionMatch                 = P[39];
        offsetSize                              = P[40];
        maxIterationLevel                       = (int)P[41];
        maxBranches                             = (int)P[42];
        maxPoints                               = (int)P[43];

    }

    /*



    */









/*



 _______  ______    _______  _______  _______  ______   __   __  ______    _______  ___                  __   __  _______  ______   _______  _______  _______ 
|       ||    _ |  |       ||       ||       ||      | |  | |  ||    _ |  |   _   ||   |                |  | |  ||       ||      | |   _   ||       ||       |
|    _  ||   | ||  |   _   ||       ||    ___||  _    ||  | |  ||   | ||  |  |_|  ||   |                |  | |  ||    _  ||  _    ||  |_|  ||_     _||    ___|
|   |_| ||   |_||_ |  | |  ||       ||   |___ | | |   ||  |_|  ||   |_||_ |       ||   |                |  |_|  ||   |_| || | |   ||       |  |   |  |   |___ 
|    ___||    __  ||  |_|  ||      _||    ___|| |_|   ||       ||    __  ||       ||   |___             |       ||    ___|| |_|   ||       |  |   |  |    ___|
|   |    |   |  | ||       ||     |_ |   |___ |       ||       ||   |  | ||   _   ||       |            |       ||   |    |       ||   _   |  |   |  |   |___ 
|___|    |___|  |_||_______||_______||_______||______| |_______||___|  |_||__| |__||_______|            |_______||___|    |______| |__| |__|  |___|  |_______|



*/
    
 /*
    void Update(){

       if( debugSkeleton ){

            if( skeletonMPB == null ){
                skeletonMPB = new MaterialPropertyBlock();
            }

            skeletonMPB.SetBuffer("_VertBuffer", skeletonBuffer);
            skeletonMPB.SetInt("_Count",totalPoints);
            skeletonMPB.SetFloat("_AmountShown", skeletonShown );
            skeletonMPB.SetMatrix("_World", transform.localToWorldMatrix );

            Graphics.DrawProcedural( skeletonMaterial ,  new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles,totalPoints * 3 * 3 , 1, null, skeletonMPB, ShadowCastingMode.On, true, LayerMask.NameToLayer("Default"));
            
        }



        if( debugBark ){

            if( barkMPB == null ){
                barkMPB = new MaterialPropertyBlock();
            }

            barkMPB.SetBuffer("_VertBuffer", barkBuffer);
            barkMPB.SetInt("_Count",totalBarkPoints);
            barkMPB.SetFloat("_AmountShown", barkShown );
            barkMPB.SetMatrix("_World", transform.localToWorldMatrix );

        //Graphics.DrawProcedural( barkMaterial ,  new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles,totalBarkPoints * 6 , 1, null, barkMPB, ShadowCastingMode.On, true, LayerMask.NameToLayer("Default"));
        
        }


        if( debugMesh ){

            if( meshMPB == null ){
                meshMPB = new MaterialPropertyBlock();
            }

            meshMPB.SetBuffer("_VertBuffer", barkBuffer);
            meshMPB.SetBuffer("_TriBuffer", barkTriBuffer);
            meshMPB.SetInt("_Count",totalBarkPoints);
            meshMPB.SetFloat("_AmountShown", barkShown );
            
            meshMPB.SetMatrix("_World", transform.localToWorldMatrix );

            Graphics.DrawProcedural( meshMaterial ,  new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles,totalBarkTris , 1, null, meshMPB, ShadowCastingMode.On, true, LayerMask.NameToLayer("Default"));
            
        }


        if( debugFlower ){

            if( flowerMPB == null ){
                flowerMPB = new MaterialPropertyBlock();
            }

            flowerMPB.SetBuffer("_VertBuffer", flowerBuffer);
            flowerMPB.SetInt("_Count",totalFlowerPoints);
            flowerMPB.SetFloat("_AmountShown", flowersShown );
            flowerMPB.SetFloat("_FallingAmount", flowersFallen );
            
            flowerMPB.SetMatrix("_World", transform.localToWorldMatrix );

            Graphics.DrawProcedural( flowerMaterial ,  new Bounds(transform.position, Vector3.one * 5000), MeshTopology.Triangles,totalFlowerPoints * 3 * 2 , 1, null, flowerMPB, ShadowCastingMode.On, true, LayerMask.NameToLayer("Default"));
            
        }


    }*/


}

}

