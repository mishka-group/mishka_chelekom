defmodule MishkaChelekom.Video do
  use Phoenix.Component
  import MishkaChelekomWeb.Gettext

  @doc """
  https://stackoverflow.com/questions/15268604/html5-track-captions-not-showing/15268843#15268843
  https://www.w3schools.com/tags/tag_video.asp

  Ensure your video and .vtt files are served from the same web server.
  Browsers may block captions if accessed from the local file system or different servers.
  Use a local web server for testing to avoid these issues.

  1. When you access an HTML file directly from your file system (file:/// protocol),
      browsers often have restrictions that prevent the proper functioning of certain features,
      including the <track> tag. The captions might not display properly in such cases.

  2. The video source and .vtt file should generally be hosted on the same server to avoid cross-origin issues (CORS).
      If they are on different servers,
      you may need to ensure proper CORS headers are set up to allow the browser to access the caption file.

  Important:  Adding a Base64-encoded subtitle directly to a video won't cause a CORS issue,
              so you can use it in your components even if the subtitle is not from the same origin.
  """

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :thumbnail, :string, default: nil, doc: ""
  attr :width, :string, default: "full", doc: ""
  attr :rounded, :string, default: "none", doc: ""
  attr :height, :string, default: "auto", doc: ""
  attr :caption_size, :string, default: "extra_small", doc: ""
  attr :caption_bakcground, :string, default: "dark", doc: ""
  attr :caption_opacity, :string, default: "solid", doc: ""
  attr :ratio, :string, default: "auto", doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, include: ~w(controls autoplay loop muted preload), doc: ""

  slot :source, required: true do
    attr :src, :string, required: true
    attr :type, :string, required: true
  end

  slot :track, required: false do
    attr :src, :string, required: true
    attr :label, :string
    attr :kind, :string
    attr :srclang, :string
    attr :default, :boolean
  end

  def video(assigns) do
    ~H"""
    <video
      id={@id}
      class={[
        width_class(@width),
        height_class(@height),
        rounded_size(@rounded),
        aspect_ratio(@ratio),
        caption_size(@caption_size),
        caption_bakcground(@caption_bakcground),
        caption_opacity(@caption_opacity),
        @class
      ]}
      poster={@thumbnail}
      {@rest}
    >
      <source :for={source <- @source} src={source.src} type={source.type} />

      <track
        :for={track <- @track}
        src={track.src}
        label={track.label || "English"}
        kind={track.kind || "subtitles"}
        srclang={track.srclang || "en"}
        default={track.default}
      />

      <%= gettext("Your browser does not support the video tag.") %>
    </video>
    """
  end

  defp width_class("extra_small"), do: "w-3/12"
  defp width_class("small"), do: "w-5/12"
  defp width_class("medium"), do: "w-6/12"
  defp width_class("large"), do: "w-9/12"
  defp width_class("extra_large"), do: "w-11/12"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp height_class("extra_small"), do: "h-60"
  defp height_class("small"), do: "h-64"
  defp height_class("medium"), do: "h-72"
  defp height_class("large"), do: "h-80"
  defp height_class("extra_large"), do: "h-96"
  defp height_class("auto"), do: "h-auto"
  defp height_class(params) when is_binary(params), do: params
  defp height_class(_), do: height_class("auto")

  defp aspect_ratio("auto"), do: "aspect-auto"
  defp aspect_ratio("square"), do: "aspect-square"
  defp aspect_ratio("video"), do: "aspect-video"
  defp aspect_ratio("4:3"), do: "aspect-[4/3]"
  defp aspect_ratio("3:2"), do: "aspect-[3/2]"
  defp aspect_ratio("21:9"), do: "aspect-[21/9]"
  defp aspect_ratio(params) when is_binary(params), do: params
  defp aspect_ratio(_), do: aspect_ratio("video")

  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size(_), do: rounded_size("none")

  defp caption_size("extra_small"), do: "[&::cue]:text-xs"
  defp caption_size("small"), do: "[&::cue]:text-sm"
  defp caption_size("medium"), do: "[&::cue]:text-base"
  defp caption_size("large"), do: "[&::cue]:text-lg"
  defp caption_size("extra_large"), do: "[&::cue]:text-xl"
  defp caption_size("double_large"), do: "[&::cue]:text-2xl"
  defp caption_size("triple_large"), do: "[&::cue]:text-3xl"
  defp caption_size("quadruple_large"), do: "[&::cue]:text-4xl"
  defp caption_size(params) when is_binary(params), do: params
  defp caption_size(_), do: caption_size("extra_small")

  defp caption_bakcground("white"),
    do: "[&::cue]:bg-[linear-gradient(#fff,#fff)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("primary"),
    do: "[&::cue]:bg-[linear-gradient(#2441de,#2441de)] [&::cue]:text-white"

  defp caption_bakcground("secondary"),
    do: "[&::cue]:bg-[linear-gradient(#877C7C,#877C7C)] [&::cue]:text-white"

  defp caption_bakcground("success"),
    do: "[&::cue]:bg-[linear-gradient(#6EE7B7,#6EE7B7)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("warning"),
    do: "[&::cue]:bg-[linear-gradient(#FF8B08,#FF8B08)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("danger"),
    do: "[&::cue]:bg-[linear-gradient(#E73B3B,#E73B3B)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("info"),
    do: "[&::cue]:bg-[linear-gradient(#004FC4,#004FC4)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("misc"),
    do: "[&::cue]:bg-[linear-gradient(#52059C,#52059C)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("dawn"),
    do: "[&::cue]:bg-[linear-gradient(#4D4137,#4D4137)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("light"),
    do: "[&::cue]:bg-[linear-gradient(#707483,#707483)] [&::cue]:text-[#1E1E1E]"

  defp caption_bakcground("dark"),
    do: "[&::cue]:bg-[linear-gradient(#1E1E1E,#1E1E1E)] [&::cue]:text-white"

  defp caption_bakcground(params) when is_binary(params), do: params
  defp caption_bakcground(_), do: caption_bakcground("white")

  defp caption_opacity("transparent") do
    "[&::cue]:bg-opacity-10"
  end

  defp caption_opacity("translucent") do
    "bg-opacity-20"
  end

  defp caption_opacity("semi_transparent") do
    "[&::cue]:bg-opacity-30"
  end

  defp caption_opacity("lightly_tinted") do
    "[&::cue]:bg-opacity-40"
  end

  defp caption_opacity("tinted") do
    "[&::cue]:bg-opacity-50"
  end

  defp caption_opacity("semi_opaque") do
    "[&::cue]:bg-opacity-60"
  end

  defp caption_opacity("opaque") do
    "[&::cue]:bg-opacity-70"
  end

  defp caption_opacity("heavily_tinted") do
    "[&::cue]:bg-opacity-80"
  end

  defp caption_opacity("almost_solid") do
    "[&::cue]:bg-opacity-90"
  end

  defp caption_opacity("solid") do
    "[&::cue]:bg-opacity-100"
  end

  defp caption_opacity(params) when is_binary(params), do: params
  defp caption_opacity(_), do: caption_opacity("solid")
end
