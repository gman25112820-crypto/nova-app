[fal Assets is now live!](https://fal.ai/assets)

[Docs](https://docs.fal.ai/)

[Log-in](https://fal.ai/login?returnTo=/models/fal-ai/flux-pro/kontext) [Sign-up](https://fal.ai/login?returnTo=/models/fal-ai/flux-pro/kontext)

[Home](https://fal.ai/)
[Explore](https://fal.ai/models)
fal-ai/flux-pro/kontext

[Docs](https://docs.fal.ai/)

[Log-in](https://fal.ai/login?returnTo=/models/fal-ai/flux-pro/kontext) [Sign-up](https://fal.ai/login?returnTo=/models/fal-ai/flux-pro/kontext)

1. [Back to Gallery](https://fal.ai/models)

# fal-ai/flux-pro/kontext

Kontext \[pro\] -- Editing

FLUX.1 Kontext \[pro\] handles both text and reference images as inputs, seamlessly enabling targeted, local edits and complex transformations of entire scenes.

Inference

Commercial use

Partner

[Schema](https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=fal-ai/flux-pro/kontext)

[LLMs](https://fal.ai/models/fal-ai/flux-pro/kontext/llms.txt)

[Playground](https://fal.ai/models/fal-ai/flux-pro/kontext) [API](https://fal.ai/models/fal-ai/flux-pro/kontext/api) [Examples](https://fal.ai/models/fal-ai/flux-pro/kontext/examples)

[Try in Sandbox](https://fal.ai/sandbox?models=d10e9u7qn7dbfsbcf8b0&op=image.edit_image&prompt=Change+the+car+color+to+red&image_url=https%3A%2F%2Fv3.fal.media%2Ffiles%2Flion%2FL56XkUqiB_VzebDc9jqoJ_pexels-jmark-253096.webp)

### Input

Form

Prompt\*

Change the car color to red

Type # to reference inputs.

Image URL\*

Choose...

**Hint:** Drag and dropimage files from your computer, images from web pages, paste from clipboard (Ctrl/Cmd+V), or provide a URL.Accepted file types: jpg, jpeg, png, webp, gif, avif

![](https://v3.fal.media/files/lion/L56XkUqiB_VzebDc9jqoJ_pexels-jmark-253096.webp)

Additional Settings

More

Customize your input with more control.

Reset

[Sign in to run](https://fal.ai/login?returnTo=%2Fmodels%2Ffal-ai%2Fflux-pro%2Fkontext%3FrestoreInputKey%3Dfal-ai%2Fflux-pro%2Fkontext)

### Result

Idle

PreviewJSON

![before](https://v3.fal.media/files/lion/L56XkUqiB_VzebDc9jqoJ_pexels-jmark-253096.webp)

![after](https://fal.media/files/elephant/foZaaLzgc--Vlcy3XwrNQ_c51f2cc166534c5997dcc0b072e41e09.jpg)

#### What would you like to do next?

Use Output [Download](https://fal.media/files/elephant/foZaaLzgc--Vlcy3XwrNQ_c51f2cc166534c5997dcc0b072e41e09.jpg)

```
{
  "seed": 123456,
  "images": [\
    {\
      "url": "https://fal.media/files/elephant/foZaaLzgc--Vlcy3XwrNQ_c51f2cc166534c5997dcc0b072e41e09.jpg",\
      "width": 1248,\
      "height": 832,\
      "content_type": "image/jpeg"\
    }\
  ],
  "prompt": "Change the car color to red",
  "timings": {},
  "has_nsfw_concepts": [\
    false\
  ]
}
```

Your requestwill cost$0.04per image.

### Logs

Show

### Readme

#### FLUX.1 Kontext \[pro\] - Advanced Image-to-Image Generation and Editing

Transform your images with intelligent editing using FLUX.1 Kontext \[pro\], a powerful 12-billion parameter multimodal flow transformer designed for in-context image generation and editing. Seamlessly modify existing images with simple text instructions while preserving character consistency and visual quality.

##### Overview

FLUX.1 Kontext \[pro\] delivers exceptional image editing and generation capabilities through its multimodal architecture. Built to understand both text and visual context, it excels at intelligent image modifications, character preservation, and complex scene transformations without requiring fine-tuning or complex workflows.

###### Key Capabilities

- **In-context image editing** with simple text instructions
- **Character consistency** preservation across multiple edits
- **Local and global editing** capabilities in one unified model
- **Text-to-image generation** with state-of-the-art prompt following
- **Typography handling** for text editing within images
- **Commercial-ready output** quality with fast inference

##### Popular Use Cases

**Creative Image Editing**
Modify existing images with natural language instructions. Change styles, swap objects, adjust lighting, or transform scenes while maintaining visual coherence.

**Character Consistency**
Preserve unique characters, objects, or styles across different scenes and environments without any fine-tuning required.

**Typography and Text Editing**
Seamlessly edit text within images - change signs, labels, posters, or any text elements with precision.

**Style Transfer and Remixing**
Transform images from one artistic style to another - oil painting to pencil sketch, modern poster to surreal collage.

##### Getting Started

Getting up and running with FLUX.1 Kontext \[pro\] takes just a few minutes. Here's how to begin:

1. Get your API key at [https://fal.ai/login](https://fal.ai/login)
2. Install the client library for your preferred language
3. Make your first API call

For JavaScript/TypeScript:

```
javascript

import { fal } from "@fal-ai/client";

fal.config({
  credentials: "YOUR_FAL_KEY"
});

const result = await fal.subscribe("fal-ai/flux-pro/kontext", {
  input: {
    prompt: "Change the red car to blue while keeping everything else the same",
    image_url: "https://your-image-url.com/image.jpg"
  }
});
```

For Python:

```
python

from fal_client import FalClient

client = FalClient("YOUR_FAL_KEY")
result = client.subscribe("fal-ai/flux-pro/kontext", {
    "prompt": "Change the red car to blue while keeping everything else the same",
    "image_url": "https://your-image-url.com/image.jpg"
})
```

##### Technical Specifications

###### Model Architecture

- 12 billion parameter multimodal flow transformer
- In-context image generation and editing capabilities
- Handles both text and reference images as inputs
- Supports targeted local edits and complex scene transformations

###### Input Capabilities

- **Image input**: jpg, jpeg, png, webp, gif, avif formats
- **Text prompts**: Natural language editing instructions
- **Multimodal processing**: Simultaneous text and image understanding

###### Performance

- Fast inference optimized for iterative editing
- Up to 8x faster than competing state-of-the-art models
- Minimal latency for real-time creative workflows
- 99.9% uptime guarantee

##### Best Practices

Achieve optimal results with these proven approaches:

###### Write Clear Edit Instructions

Be specific about what you want to change and what should remain the same. Instead of "make it better," try "change the background to a sunset while keeping the person's pose and clothing identical."

###### Leverage Character Consistency

Use Kontext's strength in preserving characters across edits. You can modify lighting, backgrounds, or scenes while maintaining the same person, object, or style.

###### Handle Text Editing Precisely

When editing text in images, specify exactly what text to change and what it should become: "Change 'SALE' to 'SOLD OUT' on the storefront sign."

###### Iterative Refinement

Build upon previous edits through multiple turns while maintaining visual consistency and character identity.

##### Advanced Features

###### Local and Global Editing

- **Targeted edits**: Modify specific regions or objects
- **Scene transformations**: Change entire backgrounds or contexts
- **Style preservation**: Maintain artistic consistency during modifications

###### Multi-turn Editing

Refine images through successive edits while preserving quality and character consistency across multiple editing sessions.

###### Context Understanding

The model reads both image context and text instructions to ensure edits make logical and visual sense.

##### API Reference

The FLUX.1 Kontext \[pro\] API accepts the following core parameters:

```
typescript

interface FluxKontextParameters {
  prompt: string;              // Your editing instruction
  image_url: string;          // Input image to edit
  guidance_scale?: number;     // Prompt adherence strength
  num_inference_steps?: number; // Generation steps
  seed?: number;              // For reproducible results
}
```

##### Pricing and Usage

Your request will cost $0.04 per image. Our transparent, per-image pricing makes it cost-effective for both experimentation and production use:

- Fixed $0.04 cost per image edit
- No hidden fees or minimum commitments
- Commercial usage rights included
- Volume discounts available for enterprise users

[View detailed pricing](https://fal.ai/pricing) or [contact sales](mailto:support@fal.ai) for enterprise solutions.

##### Support and Resources

We're here to help you succeed with FLUX.1 Kontext \[pro\]:

- **Documentation**: Complete API reference at [https://docs.fal.ai/](https://docs.fal.ai/)
- **Community**: Join our Discord for support and creative showcases
- **Examples**: Browse our GitHub repository for sample implementations
- **Support**: Enterprise support available for production deployments

Ready to transform your images with intelligent editing? Sign up now at [https://fal.ai](https://fal.ai/) and start creating with FLUX.1 Kontext \[pro\].

[Get Started with FLUX Kontext Pro](https://fal.ai/login)

## Ready to transform your enterprise with AI?

[Contact Sales](https://fal.ai/enterprise#contact-sales)

#### Learn More

[Status](https://status.fal.ai/) [About Us](https://fal.ai/about) [Documentation](https://docs.fal.ai/) [Trust & Safety](https://fal.ai/legal/trust-and-safety) [Careers](https://job-boards.greenhouse.io/fal) [Pricing](https://fal.ai/pricing) [Blog](https://blog.fal.ai/) [Enterprise](https://fal.ai/enterprise) [Get in touch](mailto:support@fal.ai) [Report Content](https://fal.ai/report-content) [Grants](https://fal.ai/grants) [Events](https://fal.ai/events) [Legal](https://fal.ai/legal) Cookie Settings [Learn](https://fal.ai/learn) [Gen Media Report 2026](https://fal.ai/gen-media-report-volume-1)

Models [GPT Image 2](https://fal.ai/gpt-image-2) [Seedance 2.0](https://fal.ai/seedance-2.0) [Flux 2](https://fal.ai/models/fal-ai/flux-2-flex) [Kling 3.0](https://fal.ai/models/fal-ai/kling-video/o3/standard/image-to-video) [Veo 3.1](https://fal.ai/models/fal-ai/veo3.1) [Nano Banana Pro](https://fal.ai/models/fal-ai/nano-banana-pro/edit) [Ideogram 4](https://fal.ai/ideogram-4) [Krea 2](https://fal.ai/krea-2) [Explore More](https://fal.ai/models)

#### Playgrounds

[Sandbox](https://fal.ai/sandbox) [Workflows](https://fal.ai/workflows) [Training](https://fal.ai/models/fal-ai/flux-lora-fast-training) [Background Remover](https://fal.ai/tools/background-remover)

#### Socials

[Discord](https://discord.gg/fal-ai) [GitHub](https://github.com/fal-ai) [Reddit](https://www.reddit.com/r/fal/) [Twitter](https://twitter.com/fal) [LinkedIn](https://www.linkedin.com/company/features-and-labels/) [YouTube](https://www.youtube.com/@Fal.AI.Official) [Instagram](https://www.instagram.com/madeonfal) [TikTok](https://www.tiktok.com/@madeonfal)

features and labels, 2026. All Rights Reserved. [Terms of Service](https://fal.ai/legal/terms-of-service) and [Privacy Policy](https://fal.ai/legal/privacy-policy)

hCaptcha

1. ### Four top image models, free to try



   Compare GPT Image 2, Nano Banana 2, Ideogram 4.0 and Krea 2 in Sandbox. Your first 10 generations on each are on us.





   [Open Sandbox](https://fal.ai/sandbox?models=d7j7n6kregjeg91t2f6g,d8bab6sregjdc2r4onq0,d6g6vocregj8q96b4p8g,d8fhf5cregjdtdbbdk30&utm_source=slidein&utm_campaign=sandbox-free-credits-v2)


hCaptcha

Please try again. ⚠️

Verify

Afrikaans

Albanian

Amharic

Arabic

Armenian

Azerbaijani

Basque

Belarusian

Bengali

Bulgarian

Bosnian

Burmese

Catalan

Cebuano

Chinese

Chinese Simplified

Chinese Traditional

Corsican

Croatian

Czech

Danish

Dutch

English

Esperanto

Estonian

Finnish

French

Frisian

Gaelic

Galacian

Georgian

German

Greek

Gujurati

Haitian

Hausa

Hawaiian

Hebrew

Hindi

Hmong

Hungarian

Icelandic

Igbo

Indonesian

Irish

Italian

Japanese

Javanese

Kannada

Kazakh

Khmer

Kinyarwanda

Kirghiz

Korean

Kurdish

Lao

Latin

Latvian

Lithuanian

Luxembourgish

Macedonian

Malagasy

Malay

Malayalam

Maltese

Maori

Marathi

Mongolian

Nepali

Norwegian

Nyanja

Oriya

Persian

Polish

Portuguese (Brazil)

Portuguese (Portugal)

Pashto

Punjabi

Romanian

Russian

Samoan

Shona

Sindhi

Sinhalese

Serbian

Slovak

Slovenian

Somali

Southern Sotho

Spanish

Sundanese

Swahili

Swedish

Tagalog

Tajik

Tamil

Tatar

Teluga

Thai

Turkish

Turkmen

Uyghur

Ukrainian

Urdu

Uzbek

Vietnamese

Welsh

Xhosa

Yiddish

Yoruba

Zulu

EN

[hCaptcha logo, opens new window with more information](https://www.hcaptcha.com/what-is-hcaptcha-about?ref=fal.ai&utm_campaign=79e0463a-f79a-4742-b3da-489afd1cbe68&utm_medium=challenge&hl=en "hCaptcha logo, opens new window with more information")