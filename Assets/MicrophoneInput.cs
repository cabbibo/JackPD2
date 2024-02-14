using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(AudioSource))]
public class MicrophoneInput : MonoBehaviour
{
    private AudioSource audioSource;
    private string microphone;

    void Start()
    {
        // Get the AudioSource component
        audioSource = GetComponent<AudioSource>();

        // Check if there is at least one microphone connected
        if (Microphone.devices.Length <= 0)
        {
            Debug.LogWarning("No microphone detected!");
            return;
        }

        microphone = Microphone.devices[0]; // Selects the first available microphone.
        audioSource.clip = Microphone.Start(microphone, true, 10, 44100); // Loops a 10-second AudioClip at a 44100 Hz sample rate.
        audioSource.loop = true; // Loop the audio source.

        // Wait until the microphone starts recording
        while (!(Microphone.GetPosition(microphone) > 0)) { }

        audioSource.Play(); // Play the audio source without any audio listeners to hear it.
    }

    void Update()
    {
        // Optional: Add logic to process the audio data or control the AudioSource.
        // Remember, the audio is not being outputted through speakers.
    }
}