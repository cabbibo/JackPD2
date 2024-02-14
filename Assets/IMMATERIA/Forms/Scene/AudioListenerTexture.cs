using UnityEngine;
using System.Collections;
using IMMATERIA;
public class AudioListenerTexture : Form
{

    private int width; // texture width
    private int height; // texture height
    private Color backgroundColor = Color.black;
    //public Color waveformColor = Color.green;
    public int size = 1024; // size of sound segment displayed in texture

    private Color[] blank; // blank image array
    public Texture2D texture;
    public float[] samples; // audio samples array
    public float[] lowRes;
    public int lowResSize;// = 256;


    public LoopbackAudio loopbackAudio;
    public float loopbackMultiplier;
    public float nonloopbackMultiplier;
    public float micMultiplier;

    public float oldMultiplier;
    public float newMultiplier;



    public Color[] pixels;

    public override void SetStructSize()
    {
        structSize = 4;
    }

    public override void SetCount()
    {
        count = size * 2;
    }

    public override void Create()
    {
        width = size;
        height = 1;

        // create the samples array
        samples = new float[size * 8];
        lowRes = new float[64];
        lowResSize = 64;

        // create the AudioTexture and assign to the guiTexture:
        texture = new Texture2D(width, height, TextureFormat.RGBA32, 4, true);
        pixels = texture.GetPixels(0, 0, width, 1);

        // create a 'blank screen' image
        blank = new Color[width * height];

        for (int i = 0; i < blank.Length; i++)
        {
            blank[i] = backgroundColor;
        }

        // refresh the display each 100mS
    }




    public float totalPower;

    public AudioSource source;

    public override void WhileLiving(float v)
    {

        bool mainAudioMuted = false;
        float multiplier = 128;

        multiplier *= nonloopbackMultiplier;




#if UNITY_EDITOR



        // If our audio is muted replace data from the lookback audio!

        samples = loopbackAudio.SpectrumData;

        //                    print(maxSample);
        multiplier = loopbackMultiplier;

        if (source)
        {

            source.GetSpectrumData(samples, 0, FFTWindow.Triangle);

            multiplier = micMultiplier;

        }

#else

        if (source)
        {
            //print( "hello");
            source.GetSpectrumData(samples, 0, FFTWindow.Triangle);
            
        multiplier = micMultiplier;
        }
        else
        {

            //            print( "hello2");
            AudioListener.GetSpectrumData(samples, 0, FFTWindow.Triangle);
        multiplier = nonloopbackMultiplier;
        }
#endif



        float maxSample = 0;
        int sameAsMax = 0;

        float tmpPow = 0;
        for (int i = 0; i < samples.Length; i++)
        {
            samples[i] = samples[i];// * samples[i] * samples[i] * samples[i];

            if (maxSample == samples[i])
            {
                sameAsMax++;
            }
            maxSample = Mathf.Max(maxSample, samples[i]);

            tmpPow += samples[i];


        }

        totalPower = Mathf.Lerp(totalPower, tmpPow / samples.Length, .8f);




        ///                    print(sameAsMax);

        pixels = texture.GetPixels(0, 0, width, 1);


        for (int i = 0; i < size; i++)
        {
            pixels[i].r = pixels[i].r * oldMultiplier + (newMultiplier * (samples[(int)(i * 4) + 0] / maxSample) * multiplier);
            pixels[i].g = pixels[i].g * oldMultiplier + (newMultiplier * (samples[(int)(i * 4) + 1] / maxSample) * multiplier);
            pixels[i].b = pixels[i].b * oldMultiplier + (newMultiplier * (samples[(int)(i * 4) + 2] / maxSample) * multiplier);
            pixels[i].a = pixels[i].a * oldMultiplier + (newMultiplier * (samples[(int)(i * 4) + 3] / maxSample) * multiplier);

            //maxSample = Mathf.Max(maxSample,samples [ ( int ) ( i * 4 ) + 0 ]);





        }
        //print(maxSample);
        texture.SetPixels(pixels);
        texture.Apply();

        if (samples != null && _buffer != null)
        {
            // print("setting");
            SetData(samples);
        }


        Shader.SetGlobalTexture("_AudioMap", texture);
    }

}

