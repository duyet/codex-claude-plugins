# Gemini Multimodal Prompting Guide

Gemini is natively multimodal - designed from the ground up to understand and generate text, images, audio, video, and code.

## Supported Modalities

| Modality | Input | Output | Notes |
|----------|-------|--------|-------|
| **Text** | ✅ | ✅ | Primary modality |
| **Images** | ✅ | ✅ | JPG, PNG, GIF, WebP |
| **Audio** | ✅ | ✅ | WAV, MP3, FLAC, etc. |
| **Video** | ✅ | ✅ | MP4, MOV, AVI, etc. |
| **Code** | ✅ | ✅ | All major languages |

## Image Understanding

### Basic Image Analysis (Legacy SDK)

```python
import google.generativeai as genai
import PIL.Image

model = genai.GenerativeModel("gemini-2.5-flash")
image = PIL.Image.open("photo.jpg")

response = model.generate_content([
    "Describe what you see in this image.",
    image
])
```

### Basic Image Analysis (New SDK)

```python
from google import genai
import PIL.Image

client = genai.Client()
image = PIL.Image.open("photo.jpg")

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=[
        "Describe what you see in this image.",
        image
    ]
)
```

### Detailed Image Prompting

```
<system_instruction>
You are a visual analysis assistant.
</system_instruction>

Analyze this image and provide:
1. Main subject identification
2. Mood and atmosphere
3. Color palette description
4. Suggested use cases (marketing, editorial, etc.)
5. Technical quality assessment

[image]
```

### Few-Shot with Images

```
Here are examples of how I want you to analyze images:

Example 1:
[Image 1: A sunset over mountains]
Analysis: Landscape photography featuring golden hour lighting. Warm orange and purple tones. Peaceful, serene mood. Suitable for travel marketing or nature publications. Good composition with rule of thirds.

Example 2:
[Image 2: Busy city street]
Analysis: Urban street photography with high contrast. Candid human moment. Dynamic, energetic mood. Editorial or documentary style. Good use of leading lines.

Now analyze this image:
[Your image]
```

## Image Generation

Gemini can describe images for generation tools:

```
Describe an image that would work well for [purpose]. Include:
- Subject and composition
- Lighting and mood
- Color scheme
- Style and aesthetic
```

## Audio Understanding

### Transcription and Analysis

```python
model = genai.GenerativeModel("gemini-2.5-pro")

audio_file = genai.upload_file("recording.mp3")

response = model.generate_content([
    "Transcribe this audio and summarize the key points.",
    audio_file
])
```

### Audio Prompting Template

```
<system_instruction>
You are an audio content analyst.
</system_instruction>

For this audio file, provide:
1. Transcription (if speech)
2. Speaker identification (if multiple)
3. Key topics discussed
4. Sentiment and tone
5. Action items or decisions made

[audio file]
```

## Video Understanding

### Video Analysis

```python
video_file = genai.upload_file("presentation.mp4")

response = model.generate_content([
    "Summarize the main topics covered in this video presentation.",
    video_file
])
```

### Video Prompting Template

```
<system_instruction>
You are a video content analyst.
</system_instruction>

Analyze this video and extract:
1. Main topic and purpose
2. Key segments with timestamps
3. Important visual elements
4. Speaker key points (if applicable)
5. Overall structure and flow

[video file]
```

## Multimodal Combinations

### Text + Image

```
I'm writing a blog post about sustainable architecture.

[image of green building]

Based on this image, write:
1. A catchy headline
2. Opening paragraph
3. 3 key features of sustainable architecture shown
4. Closing call-to-action
```

### Image + Image Comparison

```
Compare these two designs:

[Image A]

[Image B]

Analyze:
- Aesthetic differences
- Functional differences
- Target audience for each
- Which is more effective and why
```

### Text + Image + Audio

```
I have a product photo, customer review audio, and product description.

Product: [description]

Image: [product photo]

Review: [audio file]

Create a comprehensive product summary combining all information.
```

## Code + Multimodal

### Image to Code

```
Convert this UI mockup into HTML/CSS code.

[image]

Requirements:
- Use Tailwind CSS
- Make it responsive
- Include hover states
```

### Diagram to Code

```
[architecture diagram]

Implement this system architecture in Python. Include:
- Class structure
- Key methods
- Error handling
- Example usage
```

## Multimoral RAG

### Image + Text Retrieval

```
<system_instruction>
You are a multimodal search assistant.
</system_instruction>

I have these reference images:
[Image 1: Modern kitchen]
[Image 2: Traditional kitchen]
[Image 3: Industrial kitchen]

Based on my description "bright, minimalist kitchen with white cabinets and marble countertops", which reference image is most similar and why?
```

### Video + Document Q&A

```
<system_instruction>
You are a technical trainer.
</system_instruction>

Reference materials:
[Training manual PDF]
[Training video]

User question: "How do I reset the device if it freezes?"

Answer using information from both the manual and video.
```

## Best Practices for Multimodal

1. **Specify Modality**: Tell Gemini what type of input to expect

2. **Order Matters**: Text prompt usually comes first, then media

3. **Be Specific**: Describe what you want from each modality

4. **Use Few-Shot**: Show examples of desired analysis

5. **Consider File Size**: Large files may need processing time

6. **Combine Intelligently**: Use each modality for its strength

## Modality Selection Guide

| Goal | Best Modality | Why |
|------|---------------|-----|
| Describe scene | Image | Visual context |
| Transcribe | Audio | Speech-to-text |
| Tutorial | Video | Step-by-step visual |
| Explain concept | Text | Precise language |
| Analyze design | Image | Visual elements |
| Code review | Text | Code structure |
| UX feedback | Video | User behavior |

## Common Patterns

### Image Captioning
```
Write a caption for this image suitable for [platform/context].

[image]

Keep it [length] and [tone].
```

### Visual QA
```
<system_instruction>
You answer questions about images.
</system_instruction>

Question: [your question]

[image]

Answer:
```

### Content Generation Based on Image
```
Based on this image, write a [type of content].

[image]

Include:
- [requirement 1]
- [requirement 2]
- [requirement 3]
```

### Style Transfer Description
```
Describe the artistic style of this image so an artist could recreate it.

[image]

Include:
- Art movement or period
- Color palette
- Brush/stroke technique
- Composition style
- Mood and atmosphere
```
