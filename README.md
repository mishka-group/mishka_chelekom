# MishkaChelekom

<p align="center">
<img src="https://github.com/user-attachments/assets/16860771-e9e8-43f5-8441-d16ad8793ae6">
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
    <img src="https://github.com/user-attachments/assets/f4d4df7e-dcc4-4d1a-80e1-59c4d99725ab" alt="Support Mishka by Buy Me a Coffee" />
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
    {:mishka_chelekom, "~> 0.0.9", only: :dev}
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

  Generates a single component with specified options like color, variant, and size.

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

  Generates multiple components at once, optionally with an import file and helper functions.

  * `--import` - Generates import file
  * `--helpers` - Specifies helper functions of each component in import file
  * `--global` - Makes components accessible throughout the project without explicit imports
  * `--yes` - Makes directly without questions
  * `--exclude` - Comma-separated list of components to exclude (e.g., `--exclude alert,badge`)

  ## Options `mishka.ui.add` task

  Imports components from external sources using JSON configuration files or URLs.

  * `--no-github` - Specifies a URL without github replacing
  * `--headers` - Specifies a repo url request headers

  ## Options `mishka.ui.export` task

  Generates a JSON file from a directory of components for sharing or use with `mishka.ui.add`.

  * `--base64` or `-b` - Converts component content to Base64
  * `--name` or `-n` - Defines a name for JSON file, if it is not set default is template.json
  * `--org` or `-o` - It is only for structuring the file and has no effect on your export
  * `--template` or `-t` - Creates a default JSON file for manual processing steps

  ## Options `mishka.assets.install` task

  This task runs package manager install or remove commands in assets directory. It supports npm, yarn, bun and mix package managers.

  Examples:
  * `mix mishka.assets.install npm` - Runs npm install in assets directory
  * `mix mishka.assets.install npm pkg remove lodash` - Removes lodash package
  * `mix mishka.assets.install yarn mix install` - Runs mix yarn install

  ## Options `mishka.ui.css.config` task

  Manages CSS configuration for customizing component styles and CSS variables.

  * `--init` or `-i` - Creates a sample configuration file
  * `--force` or `-f` - Force overwrite existing configuration file (use with --init)
  * `--regenerate` or `-r` - Regenerates CSS files with current configuration
  * `--validate` or `-v` - Validates the current configuration
  * `--show` or `-s` - Shows the current configuration

  ---

</details>

---

### Optimized for Minimal Dependencies

This project ensures optimal performance by minimizing dependencies and leveraging the advanced features of **Tailwind CSS**.

### Links:

- Project Page: https://mishka.tools/chelekom
- Project Documentation: https://mishka.tools/chelekom/docs
- Created components list: [Heex file and configs](https://github.com/mishka-group/mishka_chelekom/tree/master/priv/components)
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
- Ask question in elixir Slack: https://elixir-slack.community ➝ find `#mishka` channel [Link](https://elixir-lang.slack.com/archives/C08N0U2697W)
- Ask question in elixir Discord: https://discord.gg/elixir ➝ mention `@shahryarjb`
- For commercial & sponsoring communication: `shahryar@mishka.tools`

---

# Donate

You can support this project through the "[Sponsor](https://github.com/sponsors/mishka-group)" button on GitHub. All our projects are **open-source** and **free**, and we rely on community contributions to enhance and improve them further.

---

#### 🏆 Logo Tier Sponsors

<a href="https://croox.com/" target="_blank" rel="noopener noreferrer">
  <img width="267" height="100" alt="croox" src="https://github.com/user-attachments/assets/6a885323-3a8a-4141-aa67-a6329605adf1" />
</a>
