# MishkaChelekom

<p align="center">

![Screenshot 2024-10-05 at 01 53 03](https://github.com/user-attachments/assets/16860771-e9e8-43f5-8441-d16ad8793ae6)

</p>

<p align="center">
  <a href="https://github.com/mishka-group/mishka_chelekom/blob/master/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/mishka-group/mishka_chelekom">
  </a>

  <a href="https://hex.pm/packages/mishka_chelekom">
      <img alt="Releases" src="https://img.shields.io/hexpm/v/mishka_chelekom.svg">
  </a>

  <a href="https://hex.pm/packages/mishka_chelekom">
      <img alt="Hex.pm Downloads" src="https://img.shields.io/hexpm/dt/mishka_chelekom">
  </a>

  <a href="https://github.com/mishka-group/mishka_chelekom/releases">
    <img alt="GitHub release (with filter)" src="https://img.shields.io/github/v/release/mishka-group/mishka_chelekom">
  </a>

  <a href="#">
    <img alt="Code Size in Bytes" src="https://img.shields.io/github/languages/code-size/mishka-group/mishka_chelekom">
  </a>

  <a href="https://github.com/mishka-group/mishka_chelekom/issues">
    <img alt="Issues" src="https://img.shields.io/github/issues/mishka-group/mishka_chelekom">
  </a>
</p>

<h2 align="center">Phoenix & Phoenix LiveView components and UI kit library </h2>

<div align="center">
  <pre style="display: inline-block; text-align: left;">
    💖 Hey there! If you like my work, please <b><a href="https://github.com/sponsors/mishka-group">support me financially!</a></b> 💖
  </pre>
</div>

<br />

<p align="center">
  <a href="https://www.buymeacoffee.com/mishkagroup">
    <img src="https://img.buymeacoffee.com/button-api/?text=Donate with Buy Me a Coffee&emoji=☕&slug=mishkagroup&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff" />
  </a>
</p>

## Why you should use Mishka Chelekom as Phoenix component library

**Mishka Chelekom** is a powerful library designed to simplify the process of building UI components in **Phoenix** and **Phoenix LiveView** projects. Unlike other solutions, it generates fully customizable components directly into your project—no hidden dependencies, no complex configurations.

With our rich collection of ready-to-use components, comprehensive documentation, and numerous examples, you can easily tailor every element to fit your needs. All components are generated locally (by Our `mix` generator), giving you full control over the source code without being locked into any external library.

<div align="center">
  <pre style="display: inline-block; text-align: left;">
      <strong>💼 All components are completely free and open-source.🥂</strong>
      For <strong>Pro support</strong> and <strong>enterprise services</strong>, <a href="https://mishka.tools/chelekom/custom-service">click here!</a> to get in touch with us.
  </pre>
</div>

> **Mishka Chelekom** is a library offering various templates for components in **Phoenix** and **Phoenix LiveView** - [Phoenix UI kit and components](https://mishka.tools/chelekom).
>
> This means you can generate any component listed in this project using a `CLI` command with customizable options.
>
> For example, you can create a component with an `info` color and a "shadow" variant without having any unnecessary code clutter.


If you want to add another variant in the future, the project is powered by the [**Igniter**](https://github.com/ash-project/igniter) library, which makes it easy to update the previous code seamlessly.


You will only use this library in your `development` environment, and it will not have any presence in production.

## Installation

```elixir
def deps do
  [
    {:mishka_chelekom, "~> 0.0.4", only: :dev}
  ]
end
```

Generate all components inside the `components` directory of your Phoenix project.

### Creating a Component (Example: Creating an Alert)

```bash
mix mishka.ui.gen.component alert --color info --variant default
mix mishka.ui.gen.component alert
# For Windows users please use `""` when you have more than
# one value for an argument
mix mishka.ui.gen.component alert --color "info,danger"
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
# Install all components along with helper functions and macros for importing
mix mishka.ui.gen.components --import --helpers --yes
mix mishka.ui.gen.components alert,accordion,chat --import --helpers --yes

# Install all components with helper functions and macros for importing,
# and globally replace them with Phoenix core components (**Recommended**)
mix mishka.ui.gen.components --import --helpers --global --yes

# Alternatively, if your project includes Igniter and
# you are using the latest alpha version, you can run:
mix igniter.new my_app --with phx.new --install mishka_chelekom
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
  * `--global` - Makes components accessible throughout the project without explicit imports
  * `--yes` - Makes directly without questions

  ## Options `mishka.ui.add` task

  * `--no-github` - Specifies a URL without github replacing
  * `--headers` - Specifies a repo url request headers

  ---

</details>

---

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

* What does the project name mean?

> One of the frequently asked questions on social media after the release of the first version of Mishka Chelekom was about the meaning behind the library itself. Here's the explanation:
>
> Mishka means "sparrow."
>
> Chelekom refers to "tree logs that are cut and neatly arranged side by side."


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
