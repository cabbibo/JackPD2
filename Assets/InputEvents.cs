﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

using IMMATERIA;
public class InputEvents : Cycle
{

    public EventTypes.Vector2Event OnSwipe;
    public EventTypes.FloatEvent OnSwipeHorizontal;
    public EventTypes.BaseEvent OnSwipeLeft;
    public EventTypes.BaseEvent OnSwipeRight;
    public EventTypes.BaseEvent OnEdgeSwipeLeft;  // Left refers to direction not edge
    public EventTypes.BaseEvent OnEdgeSwipeRight; // Right refers to direction not edge
    public EventTypes.FloatEvent OnSwipeVertical;
    public EventTypes.BaseEvent OnSwipeUp;
    public EventTypes.BaseEvent OnSwipeDown;
    public EventTypes.BaseEvent OnTap;
    public EventTypes.BaseEvent OnDown;
    public EventTypes.BaseEvent OnUp;
    public EventTypes.BaseEvent NewHover;
    public EventTypes.RayEvent WhileDown;
    public EventTypes.Vector2Event WhileDownDelta;
    public EventTypes.Vector2Event WhileDownDelta2;
    public EventTypes.BaseEvent OnDebugTouch;

    public bool copyCameraPosition;
    public GameObject MainCamera;
    public bool fakeSwipeLeft;
    public bool fakeSwipeRight;
    public bool fakeTapCenter;


    public Vector3 RayOrigin;
    public Vector3 RayDirection;

    public float Down;
    public float oDown;

    public float Down2;
    public float oDown2;

    public float JustDown;
    public float JustUp;
    public Vector2 startPos;
    public Vector2 endPos;

    public Ray ray;

    public Vector3 RO;
    public Vector3 RD;

    public float startTime;
    public float endTime;

    public float swipeSensitivity;
    public float tapSpeed;

    public float minSwipeTime;
    public float maxSwipeTime;
    // Use this for initialization

    public Vector2 p;
    public Vector2 oP;
    public Vector2 vel;

    public Vector2 p2;
    public Vector2 oP2;
    public Vector2 vel2;

    public int touchID = 0;

    public float downTween;
    public float downTween2;

    public RaycastHit hit;
    public string hitTag;
    public Collider hitCollider;

    public Vector3 hitPosition;
    public Vector3 hitNormal;

    public float swipeInCutoff;
    public float canEdgeSwipe;
    public bool swipable;


    public Collider onDownCollider;
    public string onDownTag;

    public RaycastHit onDownHit;




    void Start() { }



    public void DoRaycast()
    {


        if (Physics.Raycast(ray, out hit, Mathf.Infinity))
        {
            hitTag = hit.collider.tag;
            hitCollider = hit.collider;
            hitNormal = hit.normal;
            hitPosition = hit.point;
        }
        else
        {
            // Default if we don't hit anything!!!!
            hitTag = "Untagged";
            hitCollider = null;
            hitNormal = new Vector3(0, 1, 0);
            hitPosition = new Vector3(0, 0, 0);
        }

    }




    public void PropogateOldInfo()
    {
        oP = p;
        oDown = Down;

        oP2 = p2;
        oDown2 = Down2;


    }


    public void SetUpRay()
    {


        if (Application.isPlaying)
        {

            RayOrigin = Camera.main.ScreenToWorldPoint(new Vector3(p.x, p.y, Camera.main.nearClipPlane));
            RayDirection = (Camera.main.transform.position - RayOrigin).normalized;

        }
        else
        {

            RayOrigin = Camera.current.ScreenToWorldPoint(new Vector3(p.x, p.y, Camera.current.nearClipPlane));
            RayDirection = (Camera.current.transform.position - RayOrigin).normalized;

        }


        ray.origin = RayOrigin;
        ray.direction = -RayDirection;//.normalized;


        RO = ray.origin;
        RD = ray.direction;



    }

    public void DownTrigger()
    {

        if (Down == 1 && oDown == 0)
        {


            JustDown = 1;
            touchID++;
            startTime = Time.time;
            startPos = p;

            DoRaycast();
            onDownCollider = hitCollider;
            onDownHit = hit;
            onDownTag = hitTag;



            if (startPos.x < (float)Screen.width * swipeInCutoff)
            {
                canEdgeSwipe = 1;
            }
            else if (startPos.x > (float)Screen.width - (float)Screen.width * swipeInCutoff)
            {
                canEdgeSwipe = 2;
            }
            else
            {
                canEdgeSwipe = 0;
            }

            Shader.SetGlobalFloat("_CanEdgeSwipe", canEdgeSwipe);

            onDown();

            whileDown();
        }

    }

    public void WhileDownTrigger()
    {

        if (Down == 1 && oDown == 1)
        {
            JustDown = 0;

            //if( Time.time - startTime > tapSpeed ){
            whileDown();
            whileDownDelta();
            //} 
        }

        if (Down2 == 1 && oDown2 == 1)
        {
            // whileDown2();
            //if( Time.time - startTime > tapSpeed ){
            whileDownDelta2();
            //}
        }

    }



    public void UpTrigger()
    {

        if (Down == 0 && oDown == 1)
        {
            JustUp = 1;
            endTime = Time.time;
            endPos = p;
            canEdgeSwipe = 0;


            Shader.SetGlobalFloat("_CanEdgeSwipe", canEdgeSwipe);
            onUp();




            onDownCollider = null;
            onDownHit = hit;
            onDownTag = "";
        }

    }


    public void Triggers()
    {

        DownTrigger();
        WhileDownTrigger();
        UpTrigger();

        if (Down == 0 && oDown == 0)
        {
            JustDown = 0;
        }

        if (JustDown == 1) { oP = p; }
        vel = p - oP;

    }

    // Update is called once per frame
    public override void WhileLiving(float v)
    {

        if (fakeSwipeLeft)
        {

            OnSwipeLeft.Invoke();
            fakeSwipeLeft = !fakeSwipeLeft;

        }

        if (fakeSwipeRight)
        {

            OnSwipeRight.Invoke();
            fakeSwipeRight = !fakeSwipeRight;

        }

        // We will use this input if its playing. if its in edit mode will be in the editor script?
        if (Application.isPlaying)
        {
            PropogateOldInfo();


#if UNITY_EDITOR
                    MouseInput();
#elif UNITY_STANDALONE
                    MouseInput();
#else
            TouchInput();
#endif


            SetUpRay();

            // Does the ray intersect any objects excluding the player layer
            DoRaycast();

            Triggers();



        }

        downTween = Mathf.Lerp(downTween, Down, .3f);
        downTween2 = Mathf.Lerp(downTween, Down, .1f);

    }

    void MouseInput()
    {


        p = Input.mousePosition;

        if (Input.GetMouseButton(0))
        {
            Down = 1;
            p = Input.mousePosition;///Input.GetTouch(0).position;
        }
        else
        {
            Down = 0;
            oP = p;
        }

        if (Input.GetMouseButtonDown(0) && Input.GetKey("space"))
        {
            OnDebugTouch.Invoke();
        }

        if (Input.GetMouseButton(1))
        {
            p2 = Input.mousePosition;
            Down2 = 1;
        }
        else
        {
            Down2 = 0;
            oP2 = oP;
        }
    }

    void TouchInput()
    {
        if (Input.touchCount == 1)
        {
            Down = 1;
            p = Input.GetTouch(0).position;

            if (Input.touchCount > 2)
            {
                if (Input.GetTouch(0).phase == TouchPhase.Began || Input.GetTouch(1).phase == TouchPhase.Began || Input.GetTouch(2).phase == TouchPhase.Began)
                {
                    OnDebugTouch.Invoke();
                }
            }
        }
        else
        {
            Down = 0;
            oP = p;
        }

        if (Input.touchCount == 2)
        {
            Down2 = 1;
            p2 = Input.GetTouch(0).position;

            if (Input.touchCount > 2)
            {
                if (Input.GetTouch(0).phase == TouchPhase.Began || Input.GetTouch(1).phase == TouchPhase.Began || Input.GetTouch(2).phase == TouchPhase.Began)
                {
                    OnDebugTouch.Invoke();
                }
            }
        }
        else
        {
            Down2 = 0;
            oP2 = p2;
        }
    }

    public void whileDown()
    {

        if (Time.time - startTime > maxSwipeTime && canEdgeSwipe != 0)
        {
            canEdgeSwipe = 0;
            Shader.SetGlobalFloat("_CanEdgeSwipe", canEdgeSwipe);
        }

        //if( swipable ){ CheckSwipes(); }
        WhileDown.Invoke(ray);
    }

    public void whileDownDelta()
    {
        WhileDownDelta.Invoke(p - oP);
    }

    public void whileDownDelta2()
    {
        WhileDownDelta2.Invoke(p2 - oP2);
    }


    public void onDown()
    {
        OnDown.Invoke();

    }

    public void onUp()
    {
        OnUp.Invoke();

        float difT = endTime - startTime;
        Vector2 difP = endPos - startPos;


        float ratio = .01f * difP.magnitude / difT;

        //  print( ratio );
        //    print( difT );

        CheckSwipes();

        // now checking this every frame instead of just on up

        if (ratio > swipeSensitivity && difT > minSwipeTime && difT < maxSwipeTime)
        {
        }
        else
        {

            //print(difP.magnitude);
            if (difT < tapSpeed && difP.magnitude < .1)
            {
                OnTap.Invoke();
            }

        }

        swipable = true;

        //print( difT );
        //print( difP );
        //print( ratio );
    }



    public void CheckSwipes()
    {

        //print("Checking swipes");
        float difT = endTime - startTime;
        Vector2 difP = endPos - startPos;


        float ratio = .01f * difP.magnitude / difT;


        if (ratio > swipeSensitivity && difT > minSwipeTime && difT < maxSwipeTime)
        {

            OnSwipe.Invoke(difP);


            if (Mathf.Abs(difP.x) > Mathf.Abs(difP.y))
            {
                OnSwipeHorizontal.Invoke(difP.x);

                if (difP.x < 0)
                {
                    OnSwipeLeft.Invoke();

                    if (Screen.width - startPos.x < (float)Screen.width * swipeInCutoff)
                    {
                        OnEdgeSwipeLeft.Invoke();
                    }
                }
                else
                {


                    OnSwipeRight.Invoke();

                    if (startPos.x < (float)Screen.width * swipeInCutoff)
                    {
                        OnEdgeSwipeRight.Invoke();
                    }
                }


            }
            else
            {
                OnSwipeVertical.Invoke(difP.y);

                if (difP.y > 0)
                {
                    OnSwipeUp.Invoke();
                }
                else
                {
                    OnSwipeDown.Invoke();
                }
            }

            swipable = false;
        }


    }

}