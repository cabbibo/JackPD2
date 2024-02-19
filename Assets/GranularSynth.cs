using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GranularSynth : MonoBehaviour
{

    public AudioClip clip;

    public int playbackSpeed = 1;
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

        accent = signatureHi;
        double startTick = AudioSettings.dspTime;
        sampleRate = AudioSettings.outputSampleRate;
        nextTick = startTick * sampleRate;
        running = true;
        positionInGrain = 0;

        grains = new List<Grain>();

        for (int i = 0; i < 1; i++)
        {
            Grain g = new Grain();
            g.startPositionInSample = Random.Range(0, sampleLength);
            g.currentPositionInSample = 0;
            g.playbackSpeed = 2;
            g.totalNumberOfSamples = sampleLength / 20;
            g.active = 1;
            grains.Add(g);
        }

        print(grains[0].startPositionInSample);
    }

    // Start is called before the first frame update
    void Start()
    {

    }



    public float lastGrainTime;

    public float timeBetweenGrains = 1;

    // Update is called once per frame
    void Update()
    {

        print(grains.Count);

        if (Time.time - lastGrainTime > timeBetweenGrains)
        {
            lastGrainTime = Time.time;
            Grain g = new Grain();
            g.startPositionInSample = Random.Range(0, sampleLength);
            g.currentPositionInSample = 0;
            g.playbackSpeed = Random.Range(1, 4);
            g.totalNumberOfSamples = sampleLength / 20;
            g.active = 1;
            grains.Add(g);
        }


    }

    public struct Grain
    {
        public int startPositionInSample;
        public int currentPositionInSample;

        public int fPositionInSample;
        public int playbackSpeed;

        public int totalNumberOfSamples;
        public int active;

        Grain(int startPositionInSample, int currentPositionInSample, int fPositionInSample, int playbackSpeed, int totalNumberOfSamples)
        {
            this.startPositionInSample = startPositionInSample;
            this.currentPositionInSample = currentPositionInSample;
            this.fPositionInSample = fPositionInSample;
            this.playbackSpeed = playbackSpeed;
            this.totalNumberOfSamples = totalNumberOfSamples;
            this.active = 1;
        }

    }


    int positionInGrain;
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

            for (int i = 0; i < grains.Count; i++)
            {
                Grain g = grains[i];

                int fPositionInSample = (g.startPositionInSample + g.currentPositionInSample) % sampleLength;
                float nInSample = (float)g.currentPositionInSample / (float)g.totalNumberOfSamples;

                float env = (1 - Mathf.Abs(nInSample - .5f) * 2);

                data[n * 2] += samples[fPositionInSample] * env;
                data[n * 2 + 1] += samples[fPositionInSample + 1] * env;
                g.currentPositionInSample += 2 * playbackSpeed;

                if (g.currentPositionInSample >= g.totalNumberOfSamples)
                {
                    g.active = 0;
                }

                grains[i] = g;



            }




            for (int i = grains.Count - 1; i >= 0; i--)
            {
                if (grains[i].active == 0)
                {
                    print("REMOVING");
                    grains.RemoveAt(i);
                }
            }


            n++;

        }

    }

}