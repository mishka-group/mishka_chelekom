# Video Component

HTML5 video player with customizable controls and caption support.

**Documentation**: https://mishka.tools/chelekom/docs/video

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
mix mishka.ui.gen.component video
```

## Dependencies

None (necessary, optional, or JavaScript).

## Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `src` | `:string` | `nil` | Video source URL |
| `thumbnail` | `:string` | `nil` | Poster image URL |
| `ratio` | `:string` | `"video"` | Aspect ratio: `video` (16:9), `square` (1:1), or custom |
| `rounded` | `:string` | `"medium"` | `extra_small`, `small`, `medium`, `large`, `extra_large` |
| `controls` | `:boolean` | `true` | Show controls |
| `autoplay` | `:boolean` | `false` | Auto-play video |
| `loop` | `:boolean` | `false` | Loop playback |
| `muted` | `:boolean` | `false` | Mute audio |

## Slots

**`source`** — multiple video sources for different formats: `src` (URL), `type` (MIME type).

**`track`** — subtitle/caption tracks: `src` (file URL), `kind` (`subtitles`, `captions`), `srclang` (language code), `label` (display label).

## Usage Examples

### Basic, thumbnail, multiple sources

```heex
<.video src="/videos/intro.mp4" />

<.video src="/videos/demo.mp4" thumbnail="/images/video-thumbnail.jpg" />

<.video thumbnail="/images/thumbnail.jpg">
  <:source src="/videos/video.webm" type="video/webm" />
  <:source src="/videos/video.mp4" type="video/mp4" />
</.video>
```

### With captions (static and dynamic `:for`)

```heex
<.video src="/videos/tutorial.mp4" thumbnail="/images/tutorial-thumb.jpg">
  <:track src="/captions/en.vtt" kind="subtitles" srclang="en" label="English" />
  <:track src="/captions/es.vtt" kind="subtitles" srclang="es" label="Spanish" />
</.video>

<.video src={@tutorial.video_url} thumbnail={@tutorial.thumbnail}>
  <:track
    :for={caption <- @tutorial.captions}
    src={caption.url}
    kind="subtitles"
    srclang={caption.lang}
    label={caption.label}
  />
</.video>
```

### Autoplay muted (background/hero video)

```heex
<.video
  src="/videos/background.mp4"
  autoplay
  muted
  loop
  controls={false}
/>
```

### Rounded and ratio variants

```heex
<.video src="/video.mp4" rounded="small" />
<.video src="/video.mp4" rounded="large" />
<.video src="/video.mp4" rounded="extra_large" />
<.video src="/video.mp4" ratio="square" />
```

## Common Patterns

### Hero video

```heex
<div class="relative">
  <.video
    src="/videos/hero-background.mp4"
    autoplay
    muted
    loop
    controls={false}
    class="w-full h-96 object-cover"
  />
  <div class="absolute inset-0 bg-black/50 flex items-center justify-center">
    <h1 class="text-white text-4xl font-bold">Welcome</h1>
  </div>
</div>
```

### Video gallery

```heex
<div class="grid grid-cols-2 gap-4">
  <.video
    :for={video <- @videos}
    src={video.src}
    thumbnail={video.thumbnail}
    rounded="large"
  />
</div>
```

### Product demo

```heex
<div class="max-w-3xl mx-auto">
  <.video
    src="/videos/product-demo.mp4"
    thumbnail="/images/demo-poster.jpg"
    rounded="large"
  >
    <:track src="/captions/demo-en.vtt" kind="captions" srclang="en" label="English" />
  </.video>
  <p class="text-center text-gray-600 mt-4">
    Watch our 2-minute product demo
  </p>
</div>
```

## CORS Note

When using captions/subtitles, ensure your video and `.vtt` files are served from the same server or configure proper CORS headers to avoid cross-origin issues.
