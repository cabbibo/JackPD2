using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GranularSynth : MonoBehaviour
{

    public AudioClip clip;

    public float playbackSpeed = 1;
    public int grainSize = 1000;
    public int grainStep = 1;

    int sampleLength;
    float[] samples;

    public double bpm = 140.0F;
    public float gain = 0.5F;
    public int signatureHi = 4;
    public int signatureLo = 4;

    private double nextTick = 0.0F;
    private float amp = 0.0F;
    private float phase = 0.0F;
    private double sampleRate = 0.0F;
    private int accent;
    private bool running = false;

    public List<Grain> grains;
    void OnEnable()
    {

        print("hii");
        sampleLength = clip.samples;
        print(clip.channels);
        samples = new float[clip.samples * clip.channels];
        clip.GetData(samples, 0);

        GetComponent<AudioSource>().Play();

        accent = signatureHi;
        double startTick = AudioSettings.dspTime;
        sampleRate = AudioSettings.outputSampleRate;
        nextTick = startTick * sampleRate;
        running = true;
        positionInGrain = 0;

        grains = new List<Grain>();
        tmpGrains = new List<Grain>();

        for (int i = 0; i < 1; i++)
        {
            Grain g = new Grain();
            g.startPositionInSample = Random.Range(0, sampleLength);
            g.currentPositionInSample = 0;
            g.playbackSpeed = 2;
            g.totalNumberOfSamples = sampleLength / 20;
            g.active = 1;
            g.loudness = 1;
            grains.Add(g);
        }

        lastGrainTime = Time.time;

        print(grains[0].startPositionInSample);
    }



    // Start is called before the first frame update
    void Start()
    {

    }



    public float lastGrainTime;

    public float timeBetweenGrains = 1;

    public int numGrains;

    public int maxGrains = 30;

    public bool newGrains = false;
    // Update is called once per frame
    void Update()
    {

        numGrains = grains.Count;

        /*if (Time.time - lastGrainTime > timeBetweenGrains)
        {
            lastGrainTime = Time.time;
            Grain g = new Grain();
            g.startPositionInSample = Random.Range(0, sampleLength);
            g.currentPositionInSample = 0;
            g.playbackSpeed = Random.Range(.4f, 2.1f);
            g.totalNumberOfSamples = sampleLength / 20;
            g.active = 1;
            grains.Add(g);
        }*/

        if (newGrains == false)
        {

            for (int i = 0; i < tmpGrains.Count; i++)
            {
                for (int j = 0; j < grains.Count; j++)
                {
                    if (tmpGrains[i].id == grains[j].id)
                    {
                        grains[j] = tmpGrains[i];
                    }
                }
            }
            newGrains = true;


            for (int i = grains.Count - 1; i >= 0; i--)
            {
                if (grains[i].active == 0)
                {
                    //                    print("REMOVING");
                    grains.RemoveAt(i);
                }
            }
        }



    }

    public struct Grain
    {
        public int startPositionInSample;
        public float currentPositionInSample;

        public int fPositionInSample;
        public float playbackSpeed;
        public float loudness;

        public int totalNumberOfSamples;
        public int active;
        public int id;


        Grain(int startPositionInSample, int currentPositionInSample, int fPositionInSample, float playbackSpeed, int totalNumberOfSamples, float loudness)
        {
            this.startPositionInSample = startPositionInSample;
            this.currentPositionInSample = 0;
            this.fPositionInSample = fPositionInSample;
            this.playbackSpeed = playbackSpeed;
            this.totalNumberOfSamples = totalNumberOfSamples;
            this.active = 1;
            this.id = Random.Range(0, 100000000);
            this.loudness = loudness;
        }

    }


    public void NewGrain()
    {
        if (grains.Count >= maxGrains)
        {
            return;
        }
        Grain g = new Grain();
        g.startPositionInSample = Random.Range(0, sampleLength);
        g.currentPositionInSample = 0;
        g.playbackSpeed = Random.Range(.4f, 2.1f);
        g.totalNumberOfSamples = sampleLength / 20;
        g.active = 1;
        g.loudness = 1;
        g.id = Random.Range(0, 100000000);
        grains.Add(g);

    }

    public void NewGrain(float length, float speed, float loudness)
    {

        if (grains.Count >= maxGrains)
        {
            return;
        }
        Grain g = new Grain();
        g.startPositionInSample = Random.Range(0, sampleLength);
        g.currentPositionInSample = 0;
        g.playbackSpeed = speed;
        g.totalNumberOfSamples = (int)((float)sampleLength * length);
        g.active = 1;
        g.loudness = loudness;
        g.id = Random.Range(0, 100000000);
        grains.Add(g);


    }


    public void NewGrain(float length, float speed, float loudness, float positionInSample)
    {

        if (grains.Count >= maxGrains)
        {
            return;
        }


        Grain g = new Grain();
        g.totalNumberOfSamples = (int)((float)sampleRate * length);
        g.startPositionInSample = (int)(positionInSample * (float)(sampleLength - g.totalNumberOfSamples));
        g.currentPositionInSample = 0;
        g.playbackSpeed = speed;
        g.totalNumberOfSamples = (int)((float)sampleRate * length);
        g.active = 1;
        g.loudness = loudness;
        g.id = Random.Range(0, 100000000);
        grains.Add(g);

    }



    int positionInGrain;
    List<Grain> tmpGrains;


    float sample1;
    float sample2;
    float fSample;
    int fPositionInSampleCeil;
    int fPositionInSampleFloor;

    float fPositionInSample;
    float nInSample;
    float env;
    float lerpVal;
    Grain g;
    void OnAudioFilterRead(float[] data, int channels)
    {

        /*for (var i = 0; i < data.Length; i += 2)
        {
            data[i] = samples[position];
            data[i + 1] = samples[position];

            if (--interval <= 0)
            {
                interval = grainSize;
                position += grainStep;
            }
            else
            {
                position += playbackSpeed;
            }

            while (position >= sampleLength)
            {
                position -= sampleLength;
            }
            while (position < 0)
            {
                position += sampleLength;
            }
        }*/

        if (newGrains == true)
        {
            tmpGrains = new List<Grain>(grains);
            newGrains = false;

        }
        if (!running)
            return;

        double samplesPerTick = sampleRate * 60.0F / bpm * 4.0F / signatureLo;
        double sample = AudioSettings.dspTime * sampleRate;
        int dataLen = data.Length / channels;
        /*
                int n = 0;
                amp = 1.0F;
                while (n < dataLen)
                {
                    float x = Mathf.Sin(phase); //
                    int i = 0;
                    while (i < channels)
                    {
                        data[n * channels + i] += x;
                        i++;
                    }

                    phase += amp * 0.04f;
                    //amp *= 0.993F;
                    n++;

                }


                n = 0;
                while (n < dataLen)
                {
                    while (positionInGrain >= samples.Length)
                    {
                        positionInGrain -= samples.Length;
                    }

                    data[n * 2] = samples[positionInGrain];
                    data[n * 2 + 1] = samples[positionInGrain + 1];
                    positionInGrain += 2;
                    while (positionInGrain >= samples.Length)
                    {
                        positionInGrain -= samples.Length;
                    }


                    n++;
                }
        */

        int n = 0;
        while (n < dataLen)
        {
            for (int i = 0; i < tmpGrains.Count; i++)
            {
                g = tmpGrains[i];

                fPositionInSample = ((float)g.startPositionInSample + g.currentPositionInSample) % ((float)sampleLength / 2);
                nInSample = (float)g.currentPositionInSample / (float)g.totalNumberOfSamples;

                env = Mathf.Clamp((1 - Mathf.Abs(nInSample - .5f) * 2) * 4, 0, g.loudness); ;


                fPositionInSampleCeil = (int)Mathf.Ceil(fPositionInSample);
                fPositionInSampleFloor = (int)Mathf.Ceil(fPositionInSample);

                if (fPositionInSampleCeil * 2 + 1 >= sampleLength)
                {
                    fPositionInSampleCeil -= sampleLength / 2;
                    fPositionInSampleFloor -= sampleLength / 2;
                }



                lerpVal = fPositionInSample - (float)fPositionInSampleFloor;

                sample1 = samples[2 * fPositionInSampleFloor];
                sample2 = samples[2 * fPositionInSampleCeil];
                fSample = sample1 + (sample2 - sample1) * lerpVal;

                data[n * 2] += fSample * env;


                sample1 = samples[2 * fPositionInSampleFloor + 1];
                sample2 = samples[2 * fPositionInSampleCeil + 1];
                fSample = sample1 + (sample2 - sample1) * lerpVal;

                data[n * 2 + 1] += fSample * env;

                g.currentPositionInSample += g.playbackSpeed;

                if (g.currentPositionInSample >= g.totalNumberOfSamples / 2)
                {
                    g.active = 0;
                }

                tmpGrains[i] = g;



            }





            data[n * 2] = Mathf.Clamp(data[n * 2], -1, 1);
            data[n * 2 + 1] = Mathf.Clamp(data[n * 2 + 1], -1, 1);

            n++;

        }

    }

}