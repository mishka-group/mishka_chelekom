# MishkaChelekom

Mishka Chelekom is a library offering various templates for components in **Phoenix** and **Phoenix LiveView** - [Phoenix UI kit and components](https://mishka.tools/chelekom).

This means you can generate any component listed in this project using a `CLI` command with customizable options.

> For example, you can create a component with an `info` color and a "shadow" variant without having any unnecessary code clutter.

![Screenshot 2024-10-05 at 01 53 03](https://github.com/user-attachments/assets/16860771-e9e8-43f5-8441-d16ad8793ae6)

If you want to add another variant in the future, the project is powered by the [**Igniter**](https://github.com/ash-project/igniter) library, which makes it easy to update the previous code seamlessly.

You will only use this library in your `development` environment, and it will not have any presence in production.

## Installation

```elixir
def deps do
  [
    {:mishka_chelekom, "~> 0.0.1", only: :dev}
  ]
end
```

Generate all components inside the `components` directory of your Phoenix project.

### Creating a Component (Example: Creating an Alert)

```bash
mix mishka.ui.gen.component alert --color info --variant default
mix mishka.ui.gen.component alert
```

### Generating All Components

```bash
mix mishka.ui.gen.components
```

### Generating All Components with an Import File

```bash
mix mishka.ui.gen.components --import --yes
```

> This command creates all the components along with a file where all the components are imported.

### Optimized for Minimal Dependencies

This project ensures optimal performance by minimizing dependencies and leveraging the advanced features of **Tailwind CSS**.

### Links:

- Project Page: https://mishka.tools/chelekom
- Project Documentation: https://mishka.tools/chelekom/docs
- Created components list: [Heex file and configs](https://github.com/mishka-group/mishka_chelekom/tree/master/priv/templates/components)

---

### Our stacks:

1. [Elixir](https://github.com/elixir-lang/elixir)
2. [Phoenix](https://github.com/phoenixframework/phoenix)
3. [Phoenix LiveView](https://github.com/phoenixframework/phoenix_live_view)
4. [Tailwind CSS](https://github.com/tailwindlabs/tailwindcss)
5. Pure JavaScript

---

### FAQ

* Do I need any config or external project?

> The Chelekom library is fully zero-configuration, meaning you don't need to install anything other than the library itself

* What does the generator do?

> The generator does all the work for you, from building to updating and transferring the heex, ex files to your Phoenix project.

* What should be done for Phoenix umbrella projects?

> Just go to the path of your desired Phoenix project and execute the required Mix commands there.

* How much will this project be updated?

> In the initial versions, we managed to create more than 80 components for Phoenix and LiveView, and our goal is up to 200 components. After that, we are going to build complete templates as well as a very useful API for programmers.

* Are these components not developed after offering the paid version?

> Our paid services are not about components at all, but more facilities, including exclusive support, as well as complete templates, etc., and as long as the Mishka team exists, this project will be developed and maintained for free and open source.

---

### Contributing

We appreciate any contribution to MishkaChelekom. Just create a PR!! 🎉🥳

---

### Community & Support

- Create issue: https://github.com/mishka-group/mishka_chelekom/issues
- Ask question in elixir forum: https://elixirforum.com ➝ mention `@shahryarjb`
- Ask question in elixir Slack: https://elixir-slack.community ➝ mention `@shahryarjb`
- Ask question in elixir Discord: https://discord.gg/elixir ➝ mention `@shahryarjb`
- For commercial & sponsoring communication: `shahryar@mishka.tools`

---

# Donate

If the project was useful for you, the only way you can donate to me is the following ways

| **BTC**                                                                                                                            | **ETH**                                                                                                                            | **DOGE**                                                                                                                           | **TRX**                                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/230ea4bf-7e8f-4f18-99c9-0f940dd3c6eb" width="200"> | <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/0c8e677b-7240-4b0d-8b9e-bd1efca970fb" width="200"> | <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/3de9183e-c4c0-40fe-b2a1-2b9bb4268e3a" width="200"> | <img src="https://github.com/mishka-group/mishka_developer_tools/assets/8413604/aaa1f103-a7c7-43ed-8f39-20e4c8b9975e" width="200"> |

<details>
  <summary>Donate addresses</summary>

**BTC**:‌

```
bc1q24pmrpn8v9dddgpg3vw9nld6hl9n5dkw5zkf2c
```

**ETH**:

```
0xD99feB9db83245dE8B9D23052aa8e62feedE764D
```

**DOGE**:

```
DGGT5PfoQsbz3H77sdJ1msfqzfV63Q3nyH
```

**TRX**:

```
TBamHas3wAxSEvtBcWKuT3zphckZo88puz
```

</details>
