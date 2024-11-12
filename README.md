# MishkaChelekom

<a href="https://www.buymeacoffee.com/mishkagroup" target="_blank">
  <img src="https://img.buymeacoffee.com/button-api/?text=Buy us coffee&emoji=☕&slug=mishkagroup&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff" alt="Buy Me A Coffee" height="50" width="210">
</a>

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
mix mishka.ui.gen.components alert,accordion,chat
```

### Generating All Components with an Import File

```bash
mix mishka.ui.gen.components --import --yes
mix mishka.ui.gen.components alert,accordion,chat --import --yes
```

> This command creates all the components along with a file where all the components are imported.

### Generating All Components Using an Import File with Helper Functions

```bash
mix mishka.ui.gen.components --import --helpers --yes
mix mishka.ui.gen.components alert,accordion,chat --import --helpers --yes
```

<details>
  <summary>All options</summary>


  ## Options `mishka.ui.gen.component` task

  * `--variant` or `-v` - Specifies component variant
  * `--color` or `-c` - Specifies component color
  * `--size` or `-s` - Specifies component size
  * `--padding` or `-p` - Specifies component padding
  * `--space` or `-sp` - Specifies component space
  * `--type` or `-t` - Specifies component type
  * `--rounded` or `-r` - Specifies component type
  * `--no-sub-config` - Creates dependent components with default settings
  * `--module` or `-m` - Specifies a custom name for the component module
  * `--sub` - Specifies this task is a sub task
  * `--no-deps` - Specifies this task is created without sub task
  * `--yes` - Makes directly without questions

  ## Options `mishka.ui.gen.components` task

  * `--import` - Generates import file
  * `--helpers` - Specifies helper functions of each component in import file
  * `--yes` - Makes directly without questions

  ## Options `mishka.ui.add` task

  * `--no-github` - Specifies a URL without github replacing
  * `--headers` - Specifies a repo url request headers

  ---

</details>

### Optimized for Minimal Dependencies

This project ensures optimal performance by minimizing dependencies and leveraging the advanced features of **Tailwind CSS**.

### Links:

- Project Page: https://mishka.tools/chelekom
- Project Documentation: https://mishka.tools/chelekom/docs
- Created components list: [Heex file and configs](https://github.com/mishka-group/mishka_chelekom/tree/master/priv/templates/components)
- Hex.pm: https://hex.pm/packages/mishka_chelekom

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

You can support this project through the "[Sponsor](https://github.com/sponsors/mishka-group)" button on GitHub or via cryptocurrency donations. All our projects are **open-source** and **free**, and we rely on community contributions to enhance and improve them further.

| **BTC**                                                                                                                            | **ETH**                                                                                                                            | **DOGE**                                                                                                                           | **TRX**                                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://mishka.tools/images/donate/BTC.png" width="200"> | <img src="https://mishka.tools/images/donate/ETH.png" width="200"> | <img src="https://mishka.tools/images/donate/DOGE.png" width="200"> | <img src="https://mishka.tools/images/donate/TRX.png" width="200"> |

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
