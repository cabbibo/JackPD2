
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FantasyTree {
public class Branch{
        public Tree tree;

        public Vector3 direction;

        public Vector3 startPosition;
        public Vector3 endPosition;

        public float length;

        public Branch parent;
        public List<Branch> children;
        public List<BranchPoint> points;
        public List<FlowerPoint> flowers;
        public float pointAlongParent;

        public float baseWidth;
        public float endWidth;

        public float timeCreated;
        public float positionInBranch;

        public int numPoints;

        public int iterationLevel;



        public float startInBranch;
        public float endInBranch;

        public int numBarkColumns;
        public int numBarkRows;
        public int numFlowers;

      




        public Branch( Tree t, int IL , Branch par , Vector3 startPos , Vector3 dir , float posInBranch , float tCreated , float currentLength , float width ){
            

            //print("branch being made");
            iterationLevel = IL;

            parent = par;
            tree = t;
            startPosition = startPos;
            direction = dir;

            positionInBranch = posInBranch;
            timeCreated = tCreated;

            baseWidth = width * tree.widthReducer;;

        
            numBarkRows = currVal( tree.numBarkRows, tree.numBarkRowsReducer);
            numBarkColumns = currVal( tree.numBarkColumns, tree.numBarkColumnsReducer);
            numFlowers = tree.numFlowers;// currVal( tree.numFlowers , tree.numFlowersReducer );

            children = new List<Branch>();
            points = new List<BranchPoint>();
            flowers = new List<FlowerPoint>();

            // Figures out if we are using the base length wheteher we are inheriting or using from base
            float parentLengthMax = currVal( tree.parentLengthMax , tree.parentLengthMaxReducer );
            length = Mathf.Lerp(  currVal( tree.length , tree.lengthReducer ) , currentLength  , parentLengthMax );
            float lengthVariation = currVal( tree.lengthVariation , tree.lengthVariationReducer );
            length *= Random.Range( 1 , 1 - lengthVariation);

            float baseVsTipLength = currVal( tree.baseVsTipLength , tree.baseVsTipLengthReducer );
            length *= Mathf.Lerp( 1 , 1-posInBranch , baseVsTipLength);

            numPoints = currVal( tree.pointsPerBranch , tree.pointsPerBranchReducer );
            endPosition = startPos + dir * length;;
          
            MakePoints();



            tree.branches.Add(this);
            tree.currentTotalBranches += 1;

            if( iterationLevel < tree.maxIterationLevel ){
                MakeChildren();
            }else{
                 MakeFlowers();
            }


        }



        public void GetBarkData( float x , float y  , out Vector3 pos ,   out Vector3 centerPos , out Vector3 dir ,out Vector3 nor , out Vector3 tang , out float life , out float width ){
                    
                    float v = x * .99f * ((float)numPoints-1);
                    float angle = y * 2 * Mathf.PI;
                    
                    
                    float up = Mathf.Ceil(v);
                    float down = Mathf.Floor(v);
                    float inVal = v - down;

                    Vector3 fPos;
                    Vector3 fPos1;


                    float fLife;
                    float fWidth;
                    
                    if( inVal == 0 || up == down ){

                        v += .0001f;
                        up = Mathf.Ceil(v);
                        down = Mathf.Floor(v);
                        inVal = v - down;

                    }
                    
                    BranchPoint p1 = points[(int)down];
                    BranchPoint p2 = points[(int)up];

                    fPos = cubicPoint( inVal , p1.position , p1.position + p1.normal / 3 , p2.position - p2.normal/3 , p2.position );
                    fPos1 = cubicPoint( inVal + .001f , p1.position , p1.position + p1.normal / 3 , p2.position - p2.normal/3 , p2.position );

                    fLife = Mathf.Lerp( p1.timeCreated , p2.timeCreated, inVal);
                    fWidth = Mathf.Lerp( p1.width , p2.width, inVal);


                    Vector3 fNor = Vector3.Lerp( p1.normal , p2.normal, inVal);
                    Vector3 fTan = Vector3.Lerp( p1.tangent , p2.tangent, inVal);
                    Vector3 fBi = Vector3.Lerp( p1.binormal , p2.binormal, inVal);

                    Vector3 outVec = (fTan * Mathf.Sin( angle )  - fBi * Mathf.Cos(angle)) * fWidth;

                    centerPos = fPos;
                    fPos += outVec;// radius;;

                    pos = fPos;
                    dir = (fPos1-fPos).normalized;
                    nor = outVec.normalized;
                    tang = Vector3.Cross(nor,dir).normalized;
                    life = fLife;
                    width = fWidth;

        }
     

        Vector3 GetPositionAlongPoints(float val , out float w){

            // Reduce by tiny amount so we can still sample up!
            // Also it gives us less of a chance of hitting the points exactly
            float v = val * .99f * ((float)numPoints-1);
        
            float up = Mathf.Ceil(v);
            float down = Mathf.Floor(v);
            float inVal = v - down;

            Vector3 fPos;

                    
            if( inVal == 0 || up == down ){
            
                fPos = points[(int)down].position;
                w = points[(int)down].width;
            
            }else{

                BranchPoint p1 = points[(int)down];
                BranchPoint p2 = points[(int)up];
                fPos = cubicPoint( inVal , p1.position , p1.position + p1.normal / 3 , p2.position - p2.normal/3 , p2.position );
                w = Mathf.Lerp( p1.width , p2.width , inVal);
            }

            return fPos;

        }




        // Making points along each branch
        public void MakePoints(){
        

            Vector3 currPos = startPosition;
            tree.currentTotalPoints += numPoints;
                
            // place the points along the branch
            for( int i = 0; i  < numPoints; i++ ){

                float valInBranch = ((float)i/((float)numPoints-1));

                float widthMultiplier = 1;
                if( iterationLevel == 0 ){
                    widthMultiplier = tree.trunkCurve.Evaluate( valInBranch );
                }else{
                    widthMultiplier = tree.branchCurve.Evaluate( valInBranch );
                }


                if( i != 0 ){

                    float currNoiseSize = currVal( tree.noiseSize , tree.noiseSizeReducer );
                    float currNoisePower = currVal( tree.noisePower , tree.noisePowerReducer );


                    float currUp = currVal( tree.upDesire , tree.upDesireReducer );

                    if( i != 1 ){

                        Vector3 dir = points[i-1].position - points[i-2].position;
                        currPos += dir.normalized * length  * ((float)1/((float)numPoints-1));  
                    }else{

                        currPos += length * direction * ((float)1/((float)numPoints-1));  
                    }
                    
                    currPos += currUp * Vector3.up * .003f;

                    Vector3 noiseDir = Perlin.CurlNoise(  currPos  * currNoiseSize + tree.noiseOffset );

                    currPos += noiseDir  * currNoisePower * .04f;
                    
                }

                float fWidth = baseWidth * widthMultiplier;
                
                BranchPoint p = new BranchPoint( currPos , valInBranch , timeCreated + valInBranch , fWidth ); 
                points.Add( p );
                // TODO ADD NOISE
            }

            // Gets Tangents for each of the points for sake of
            // cubic beziers
            for( int i = 0; i < numPoints; i++ ){

                BranchPoint p = points[i];

                if( i == 0 ){
                    p.normal = (points[1].position - p.position);
                }else if( i == points.Count-1 ){
                    p.normal = (p.position - points[points.Count-2].position);
                }else{
                    p.normal = -(points[i-1].position - points[i +1].position);
                }


                if( i == 0 ){
                    p.tangent = (Vector3.Cross( p.normal.normalized , Vector3.left )).normalized;
                    p.binormal = (Vector3.Cross( p.normal , p.tangent )).normalized;
                }else{
                    p.tangent = -(Vector3.Cross( p.normal.normalized , points[i-1].binormal )).normalized;
                    p.binormal = (Vector3.Cross( p.normal , p.tangent )).normalized;
                }

                points[i] = p;
            
            
            }

        }


        public void MakeFlowers(){
            for( int i = 0; i< numFlowers; i ++ ){
                flowers.Add( new FlowerPoint( Random.Range(0.001f,.999f) , Random.Range(0.001f,.999f) , Random.Range(0.001f,.999f), tree.flowerSize * Random.Range(1-tree.flowerSizeRandomness,1)));
            }
        }

        public void  MakeChildren(){


          
            int currMaxBranches = currVal( tree.maxNumberBranchesPerBranch, tree.maxNumberBranchesPerBranchReducer);
            float currChance = currVal( tree.branchChance, tree.branchChanceReducer  );

            bool childrenSkipped = false;

            for( int i = 0;  i < currMaxBranches; i++ ){
                
                float chance = Random.Range(0f,1f);
                if( chance < currChance ){


                    float pAlongPath = (float)i / (float)currMaxBranches;
                    
                
                    float pointAlongPath = Random.Range(0,1f);;



                    float weight = currVal( tree.endOfBranchWeight , tree.endOfBranchWeightReducer );

                    pointAlongPath = Mathf.Pow( pointAlongPath,weight );

                    float start = currVal( tree.startBranchLocation , tree.startBranchLocationReducer );

                    pointAlongPath = start + (1-start) * pointAlongPath * .999f;
                    //pointAlongPath *= pointAlongPath;

                    //pointAlongPath = 1-pointAlongPath;

                    //pointAlongPath = pAlongPath;
                 
                    float width;
            
                    Vector3 startDir = GetPositionAlongPoints(pointAlongPath + .01f , out width);
                            // TODO this needs to be from start to end point not full along
                    Vector3 startPosition = GetPositionAlongPoints( pointAlongPath , out width);
                    
                    Vector3 fPos; Vector3 fCenter; Vector3 fDir; Vector3 fNor; Vector3 fTan; float fWidth; float fLife; 

                    GetBarkData( pointAlongPath , Random.Range(0.0f,1.0f), out fPos, out fCenter,out fDir, out fNor , out fTan , out fWidth , out fLife);
                 
                    startDir -= startPosition;
                    startDir  = startDir.normalized;

                   // startPosition = fPos - fNor * fWidth * .02f;
                    //startDir = fNor;

                    Vector3 addVal =  Vector3.Cross( Random.insideUnitSphere, direction.normalized ).normalized;


                    Vector3 newDir = Vector3.Lerp( fNor , startDir, Random.Range(tree.minAngleMatch, tree.maxAngleMatch) );

                    Vector3 startDirection = newDir;//newDir;

                    if( width > tree.widthCutoff  && tree.branches.Count < tree.maxBranches && tree.currentTotalPoints < tree.maxPoints ){
                        children.Add( new Branch( tree , iterationLevel + 1 , this  , startPosition , startDirection , pointAlongPath , timeCreated + pointAlongPath , length , width ));
                    }else{
                        childrenSkipped = true;
                    }

                }

            }

            // If a bunch of the child branches dont get made
            // then we will make flowers on it so the branch 
            // isn't strangely barren....
            if( childrenSkipped ){
                MakeFlowers();
            }
        }

        private void print(string s){
            Debug.Log(s);
        }


        float currVal( float val , float reducer){
            return val * Mathf.Pow( reducer , iterationLevel );          
        }

        int currVal( int val , float reducer ){
            return (int)Mathf.Ceil((float)val * Mathf.Pow( reducer, iterationLevel));
        }




   


        Vector3 cubicPoint( float v , Vector3 p1 , Vector3 p2 , Vector3 p3 , Vector3 p4 ){
            	float c = 1.0f - v;

                float w1 = c*c*c;
                float w2 = 3*v*c*c;
                float w3 = 3*v*v*c;
                float w4 = v*v*v;

                return p1 * w1 + p2 * w2 + p3 * w3 + p4 * w4;

        }


        
        float cubicPoint( float v , float p1 , float p2 , float p3 , float p4 ){
            	float c = 1.0f - v;

                float w1 = c*c*c;
                float w2 = 3*v*c*c;
                float w3 = 3*v*v*c;
                float w4 = v*v*v;

                return p1 * w1 + p2 * w2 + p3 * w3 + p4 * w4;

        }

}




    public struct FlowerPoint{
        public float row;
        public float col;
        public float offset;

        public float size;

        public FlowerPoint( float a , float b , float c , float d ){
            row = a;
            col = b;
            offset = c;
            size = d;
        }
    }


  public struct BranchPoint{
            public Vector3 position;
            public float timeCreated;
            public float positionInBranch;
            public Vector3 tangent;
            public Vector3 normal;

            public Vector3 binormal;

           public float width;

            public BranchPoint(Vector3 pos , float p , float t , float w ){
                this.timeCreated = t;
                this.positionInBranch = p;
                this.position = pos;
                this.tangent = Vector3.one;
                this.normal = Vector3.one;
                this.binormal  = Vector3.one;
                this.width = w;
            }

        }}