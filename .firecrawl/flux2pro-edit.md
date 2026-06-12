[fal Assets is now live!](https://fal.ai/assets)

[Docs](https://docs.fal.ai/)

[Log-in](https://fal.ai/login?returnTo=/models/fal-ai/flux-2-pro/edit) [Sign-up](https://fal.ai/login?returnTo=/models/fal-ai/flux-2-pro/edit)

[Home](https://fal.ai/)
[Explore](https://fal.ai/models)
fal-ai/flux-2-pro/edit

[Docs](https://docs.fal.ai/)

[Log-in](https://fal.ai/login?returnTo=/models/fal-ai/flux-2-pro/edit) [Sign-up](https://fal.ai/login?returnTo=/models/fal-ai/flux-2-pro/edit)

1. [Back to Gallery](https://fal.ai/models)

# fal-ai/flux-2-pro/edit

Image Editing

Text-to-image generation with FLUX.2 \[pro\] from Black Forest Labs. Optimized for maximum quality, exceptional photorealism and artistic images.

[Learn more about Flux 2 Pro](https://fal.ai/flux-2)

Inference

Commercial use

Partner

[Schema](https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=fal-ai/flux-2-pro/edit)

[LLMs](https://fal.ai/models/fal-ai/flux-2-pro/edit/llms.txt)

[Playground](https://fal.ai/models/fal-ai/flux-2-pro/edit) [API](https://fal.ai/models/fal-ai/flux-2-pro/edit/api)

[Try in Sandbox](https://fal.ai/sandbox?models=d4h53dcregje9t38oqp0&op=image.edit_multi_images&prompt=Place+realistic+flames+emerging+from+the+top+of+the+coffee+cup%2C+dancing+above+the+rim&aspect_ratio=auto&image_urls=https%3A%2F%2Fstorage.googleapis.com%2Ffalserverless%2Fexample_inputs%2Fflux2_pro_edit_input.png)

### Input

Form

Prompt\*

Place realistic flames emerging from the top of the coffee cup, dancing above the rim

You can type#{field}to reference a core field.

Image Size

Auto`×`

Image URLs\*

Add Image

Add URL

**Hint:** Drag and drop files from your computer, images from web pages, paste from clipboard (Ctrl/Cmd+V), or provide a URL.

Image 1

![](https://storage.googleapis.com/falserverless/example_inputs/flux2_pro_edit_input.png)

1image added

Additional Settings

More

Customize your input with more control.

Reset

[Sign in to run](https://fal.ai/login?returnTo=%2Fmodels%2Ffal-ai%2Fflux-2-pro%2Fedit%3FrestoreInputKey%3Dfal-ai%2Fflux-2-pro%2Fedit)

### Result

Idle

PreviewJSON

![flux2_pro_edit_output.png](https://storage.googleapis.com/falserverless/example_outputs/flux2_pro_edit_output.png)

#### What would you like to do next?

```
{
  "images": [\
    {\
      "url": "https://storage.googleapis.com/falserverless/example_outputs/flux2_pro_edit_output.png"\
    }\
  ]
}
```

Your request will cost **$0.03** for the first megapixel of output, plus **$0.015** per extra megapixel of input and output, rounded up to the nearest megapixel. For example, a **1024x1024** image will cost **$0.03**, and a **1920x1080** image will cost **$0.045** ( **$0.03** for first megapixel + **$0.015** for the second megapixel). Similarly, a **512x512** output will cost **$0.03** ( **$0.03** for **0.25** megapixels, rounded to **1** megapixel)

### Logs

Show

### FLUX.2 \[pro\] - Image Editing

**Production-grade multi-reference editing** optimized for speed and reliability. FLUX.2 \[pro\] combines up to 9 reference images (9 MP total input) through a streamlined pipeline that delivers professional edits without parameter complexity. Whether compositing product shots, replacing backgrounds, or blending multiple style references, pro handles context-aware transformations through pure natural language—no inference tuning required, just consistent, production-ready results.

**Built for:** Production editing pipelines \| E-commerce asset workflows \| Automated image processing \| High-volume editing operations \| Teams prioritizing reliability over experimentation

#### Multi-Reference Editing Without Configuration Overhead

FLUX.2 \[pro\] brings its streamlined production philosophy to image editing, understanding relationships between multiple input images while maintaining the zero-configuration approach that makes pro ideal for automated workflows and API integrations.

**What this means for you:**

- **Multi-image composition**: Combine up to 9 reference images (9 MP total input) in a single edit. Reference specific images by index ("replace the background with image 3") or describe elements naturally
- **Production consistency**: Fixed internal optimization delivers predictable edit quality without requiring expertise in inference parameter tuning
- **Streamlined workflow**: No steps or guidance parameters to configure—pure prompt-to-edit transformation optimized for speed and reliability
- **Natural language precision**: Describe complex edits without masks or technical setup. "Change the jacket to match image 2 while keeping the original lighting" executes directly
- **Explicit image indexing**: Reference specific inputs by number for precise multi-image control—"the person from image 1 wearing the outfit from image 4"
- **Sequential editing capability**: Chain edits together with consistent quality, ideal for iterative refinement in production workflows

### Advanced Prompting Techniques

#### JSON Structured Prompts

For precise control over complex generations, use structured JSON prompts instead of natural language. JSON prompting enables granular specification of scene elements, subjects, camera settings, and composition.

**Basic JSON structure:**

```
json

{
  "scene": "Overall setting description",
  "subjects": [\
    {\
      "type": "Subject category",\
      "description": "Physical attributes and details",\
      "pose": "Action or stance",\
      "position": "foreground/midground/background"\
    }\
  ],
  "style": "Artistic rendering approach",
  "color_palette": ["color1", "color2", "color3"],
  "lighting": "Lighting conditions and direction",
  "mood": "Emotional atmosphere",
  "composition": "rule of thirds/centered/dynamic diagonal",
  "camera": {
    "angle": "eye level/low angle/high angle",
    "distance": "close-up/medium shot/wide shot",
    "lens": "35mm/50mm/85mm"
  }
}
```

JSON prompts excel at controlling multiple subjects, precise positioning, and maintaining specific attributes across complex compositions.

#### HEX Color Code Control

Specify exact colors using HEX codes for precise color matching and brand consistency. Include the keyword "color" or "hex" before the code for best results.

**Examples:**

- ```"a wall painted in color #2ECC71"```
- ```"gradient from hex #FF6B6B to hex #4ECDC4"```
- ```"the car in color #1A1A1A with accents in #FFD700"```

For enhanced accuracy, reference a color swatch image alongside the HEX code in your prompt.

#### Image Referencing with @

Reference uploaded images directly in prompts using the ```@``` symbol for intuitive multi-image workflows.

**Usage patterns:**

- ```"@image1 wearing the outfit from @image2"```
- ```"combine the style of @image1 with the composition of @image2"```
- ```"the person from @image1 in the setting from @image3"```

The ```@``` syntax provides a natural way to reference multiple images without explicit index notation, while maintaining support for traditional "image 1", "image 2" indexing.

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