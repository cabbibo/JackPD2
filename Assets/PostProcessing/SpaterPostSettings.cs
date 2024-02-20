using System;
using UnityEngine;

namespace UnityEngine.Rendering.PostProcessing
{


    [Serializable]
    [PostProcess(typeof(SpaterPost), PostProcessEvent.AfterStack, "Custom/SpaterPost")]
    public sealed class SpaterPostSettings : PostProcessEffectSettings
    {
        public FloatParameter blend = new FloatParameter { value = 0.5f };
        public FloatParameter fade = new FloatParameter { value = .5f };
        public FloatParameter audioLookupSize = new FloatParameter { value = .5f };
        public FloatParameter audioPower = new FloatParameter { value = .5f };
        public FloatParameter audioDistort = new FloatParameter { value = .5f };
        public FloatParameter audioBase = new FloatParameter { value = .5f };
        public FloatParameter lookupOffset = new FloatParameter { value = 0f };
        public ColorParameter color = new ColorParameter { value = Color.white };

        public TextureParameter frameTex = new TextureParameter { value = null };

        public FloatParameter frameUpper = new FloatParameter { value = 1f };
        public FloatParameter frameLower = new FloatParameter { value = 0f };
        public Vector2Parameter centerOffset = new Vector2Parameter
        {
            value = new Vector2(0, 0)
        };
    }

    public sealed class SpaterPost : PostProcessEffectRenderer<SpaterPostSettings>
    {
        public override void Render(PostProcessRenderContext context)
        {
            var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/SpaterPost"));




            sheet.properties.SetFloat("_Blend", settings.blend);
            sheet.properties.SetFloat("_Fade", settings.fade);
            sheet.properties.SetFloat("_AudioPower", settings.audioPower);
            sheet.properties.SetFloat("_AudioBase", settings.audioBase);
            sheet.properties.SetFloat("_AudioDistort", settings.audioDistort);
            sheet.properties.SetFloat("_AudioLookupSize", settings.audioLookupSize);
            sheet.properties.SetFloat("_LookupOffset", settings.lookupOffset);
            sheet.properties.SetFloat("_FrameUpper", settings.frameUpper);
            sheet.properties.SetFloat("_FrameLower", settings.frameLower);
            sheet.properties.SetVector("_CenterOffset", settings.centerOffset);
            sheet.properties.SetColor("_Color", settings.color);
            sheet.properties.SetTexture("_FrameTex", settings.frameTex);
            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }

}