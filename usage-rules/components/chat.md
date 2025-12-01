# Chat Component

Interactive chat bubble components for messaging interfaces with avatars, status, and metadata support.

**Documentation**: https://mishka.tools/chelekom/docs/chat

> **For LLM Agents**: If you need more details, examples, or edge cases not covered here, fetch the full documentation from the URL above.

## Generate

```bash
# Generate with all options
mix mishka.ui.gen.component chat

# Generate with specific options
mix mishka.ui.gen.component chat --variant default,bordered --color primary,natural

# Generate specific component types only
mix mishka.ui.gen.component chat --type chat,chat_section

# Generate with custom module name
mix mishka.ui.gen.component chat --module MyAppWeb.Components.CustomChat
```

## Dependencies

| Type | Components |
|------|------------|
| **Necessary** | None |
| **Optional** | `avatar` |
| **JavaScript** | None |

## Component Types

| Component | Description |
|-----------|-------------|
| `chat/1` | Main chat wrapper |
| `chat_section/1` | Individual chat message bubble |

## Attributes

### `chat/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `variant` | `:string` | `"default"` | Style variant |
| `color` | `:string` | `"natural"` | Color theme |
| `border` | `:string` | `"extra_small"` | Border width |
| `rounded` | `:string` | `"extra_large"` | Border radius |
| `size` | `:string` | `"medium"` | Padding and font size |
| `space` | `:string` | `"extra_small"` | Space between elements |
| `padding` | `:string` | `"small"` | Padding size |
| `position` | `:string` | `"normal"` | Layout: `normal`, `flipped` |
| `class` | `:any` | `nil` | Custom CSS class |

### `chat_section/1` Attributes

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `id` | `:string` | `nil` | Unique identifier |
| `font_weight` | `:string` | `"font-normal"` | Font weight class |
| `class` | `:any` | `nil` | Custom CSS class |

## Slots

### `status` Slot (for chat_section)

| Attribute | Type | Description |
|-----------|------|-------------|
| `time` | `:string` | Message timestamp |
| `deliver` | `:string` | Delivery status |
| `time_class` | `:string` | Time styling class |
| `deliver_class` | `:string` | Delivery status class |

### `meta` Slot (for chat_section)

Custom HTML content for message metadata.

### `inner_block` Slot

Message content.

## Available Options

### Variants
`base`, `default`, `outline`, `transparent`, `shadow`, `bordered`, `gradient`

### Colors
`base`, `white`, `natural`, `dark`, `primary`, `secondary`, `success`, `warning`, `danger`, `info`, `silver`, `misc`, `dawn`

### Sizes
`extra_small`, `small`, `medium`, `large`, `extra_large`

### Rounded
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Space / Padding
`extra_small`, `small`, `medium`, `large`, `extra_large`, `none`

### Position
`normal`, `flipped`

## Usage Examples

### Basic Chat Message

```heex
<.chat>
  <.chat_section>
    Hello! How can I help you today?
  </.chat_section>
</.chat>
```

### Chat with Avatar

```heex
<.chat>
  <.avatar src="/images/user.jpg" size="small" rounded="full" />
  <.chat_section>
    Hi there! I have a question about your product.
  </.chat_section>
</.chat>
```

### With Status and Time

```heex
<.chat color="primary">
  <.chat_section>
    Your order has been shipped!
    <:status time="10:30 AM" deliver="Delivered" />
  </.chat_section>
</.chat>
```

### Flipped Position (Sender's Messages)

```heex
<.chat position="flipped" color="primary">
  <.chat_section>
    Thanks for the update!
    <:status time="10:32 AM" deliver="Seen" />
  </.chat_section>
  <.avatar src="/images/me.jpg" size="small" rounded="full" />
</.chat>
```

### Full Conversation

```heex
<%# Received message %>
<.chat>
  <.avatar src="/images/support.jpg" size="small" rounded="full" />
  <.chat_section>
    Welcome to our support chat!
    <:status time="9:00 AM" />
  </.chat_section>
</.chat>

<%# Sent message %>
<.chat position="flipped" color="primary">
  <.chat_section>
    Hi, I need help with my order.
    <:status time="9:01 AM" deliver="Seen" />
  </.chat_section>
  <.avatar src="/images/me.jpg" size="small" rounded="full" />
</.chat>

<%# Received message %>
<.chat>
  <.avatar src="/images/support.jpg" size="small" rounded="full" />
  <.chat_section>
    Of course! What's your order number?
    <:status time="9:02 AM" />
  </.chat_section>
</.chat>
```

### Different Variants

```heex
<.chat variant="default" color="natural">
  <.chat_section>Default variant</.chat_section>
</.chat>

<.chat variant="outline" color="primary">
  <.chat_section>Outline variant</.chat_section>
</.chat>

<.chat variant="shadow" color="success">
  <.chat_section>Shadow variant</.chat_section>
</.chat>

<.chat variant="gradient" color="primary">
  <.chat_section>Gradient variant</.chat_section>
</.chat>
```

### With Custom Metadata

```heex
<.chat>
  <.avatar src="/images/user.jpg" size="small" rounded="full" />
  <.chat_section>
    Here's the document you requested.
    <:meta>
      <div class="mt-2 p-2 bg-gray-100 rounded flex items-center gap-2">
        <.icon name="hero-document" class="size-5" />
        <span>report.pdf</span>
        <.link href="/downloads/report.pdf" class="text-primary-500">Download</.link>
      </div>
    </:meta>
    <:status time="2:45 PM" deliver="Sent" />
  </.chat_section>
</.chat>
```

### Different Sizes

```heex
<.chat size="small">
  <.chat_section>Small chat bubble</.chat_section>
</.chat>

<.chat size="large">
  <.chat_section>Large chat bubble</.chat_section>
</.chat>
```

## Common Patterns

### Message List

```heex
<div class="space-y-4">
  <.chat
    :for={message <- @messages}
    position={if message.sender_id == @current_user.id, do: "flipped", else: "normal"}
    color={if message.sender_id == @current_user.id, do: "primary", else: "natural"}
  >
    <.avatar
      :if={message.sender_id != @current_user.id}
      src={message.sender.avatar}
      size="small"
      rounded="full"
    />
    <.chat_section>
      {message.content}
      <:status time={format_time(message.inserted_at)} deliver={message.status} />
    </.chat_section>
    <.avatar
      :if={message.sender_id == @current_user.id}
      src={@current_user.avatar}
      size="small"
      rounded="full"
    />
  </.chat>
</div>
```

### Typing Indicator

```heex
<.chat :if={@other_user_typing}>
  <.avatar src={@other_user.avatar} size="small" rounded="full" />
  <.chat_section class="animate-pulse">
    <span class="flex gap-1">
      <span class="size-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0ms" />
      <span class="size-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 150ms" />
      <span class="size-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 300ms" />
    </span>
  </.chat_section>
</.chat>
```

### System Message

```heex
<div class="text-center text-sm text-gray-500 my-4">
  <.chat variant="transparent" class="justify-center">
    <.chat_section class="bg-gray-100 dark:bg-gray-800">
      John joined the conversation
    </.chat_section>
  </.chat>
</div>
```
