defmodule MishkaChelekom.Test.Runtime.Compilers.ModuleCompiler do
  @moduledoc """
  Runtime module compiler for dynamically compiling and loading Elixir modules from AST.

  The `ModuleCompiler` provides a safe and robust foundation for runtime compilation
  within the MishkaCms ecosystem. It handles the entire lifecycle of module compilation,
  from AST validation and module name extraction to compilation with diagnostic collection
  and proper cleanup through module unloading.

  ## Features

  * **Safe Runtime Compilation**: Compiles Elixir modules from quoted expressions with comprehensive error handling
  * **Diagnostic Collection**: Gathers warnings and errors during compilation using `Code.with_diagnostics/1`
  * **Module Lifecycle Management**: Provides utilities for module unloading and cleanup
  * **AST Pattern Matching**: Supports various module definition patterns and aliases
  * **Integration Ready**: Designed to work seamlessly with MishkaCms runtime compilers

  ## Basic Usage

      # Compile a simple module from quoted expression
      quoted = quote do
        defmodule MyApp.DynamicModule do
          def hello, do: "Hello, World!"
        end
      end

      case ModuleCompiler.compile_module(quoted, "dynamic.ex") do
        {:ok, module, diagnostics} ->
          IO.puts("Successfully compiled \#{inspect(module)}")
          IO.puts("Diagnostics: \#{length(diagnostics)} items")

        {:error, module, {error, diagnostics}} ->
          IO.puts("Failed to compile \#{inspect(module)}: \#{inspect(error)}")

        {:error, error} ->
          IO.puts("Invalid module definition: \#{inspect(error)}")
      end


  ## Module Cleanup

      # Unload a module when no longer needed
      ModuleCompiler.unload(MyApp.DynamicModule)


  ## Safety and Best Practices

  * Always handle both success and error cases when compiling modules
  * Use meaningful file names for better error reporting and debugging
  * Collect and review diagnostics even for successful compilations
  * Unload modules when they're no longer needed to prevent memory leaks
  * Use `Code.put_compiler_option(:ignore_module_conflict, true)` for dynamic recompilation

  ## Performance Considerations

  * Module compilation is relatively expensive - cache compiled modules when possible
  * Diagnostics collection adds minimal overhead but provides valuable debugging information
  * Module unloading is necessary for long-running applications with dynamic modules
  * Consider batching multiple module compilations when building complex systems
  """
  require Logger

  @typedoc """
  A list of compilation diagnostics containing warnings and errors generated during the compilation process.
  """
  @type diagnostics :: [Code.diagnostic(:warning | :error)]

  @doc """
  Compiles a module from a quoted expression with comprehensive error handling and diagnostics collection.

  This function serves as the main entry point for runtime module compilation. It first extracts
  the module name from the provided quoted expression, then proceeds with compilation while
  gathering diagnostic information throughout the process.

  The compilation process includes:
  * Module name extraction and validation
  * Compiler option configuration for dynamic recompilation
  * AST compilation using Elixir's compiler infrastructure
  * Comprehensive diagnostic collection (warnings and errors)
  * Proper error handling with detailed context

  ## Parameters

  * `quoted` - A quoted expression containing a valid module definition (typically from `quote do`)
  * `file` - Optional source file name for error reporting and debugging (defaults to "nofile")

  ## Return Values

  * `{:ok, module, diagnostics}` - Successful compilation with the loaded module and any diagnostics
  * `{:error, module, {error, diagnostics}}` - Compilation failed for a valid module with error details
  * `{:error, :invalid_module}` - The quoted expression doesn't contain a valid module definition

  ## Examples

      # Basic successful compilation
      quoted = quote do
        defmodule MyApp.TestModule do
          def greet(name), do: "Hello, \#{name}!"
        end
      end

      case ModuleCompiler.compile_module(quoted, "test_module.ex") do
        {:ok, module, diagnostics} ->
          IO.puts("Compiled: \#{inspect(module)}")
          # MyApp.TestModule.greet("World") => "Hello, World!"

        {:error, module, {error, diagnostics}} ->
          IO.puts("Failed to compile \#{module}: \#{inspect(error)}")

        {:error, :invalid_module} ->
          IO.puts("Invalid module structure provided")
      end

      # Compilation with warnings
      quoted_with_warning = quote do
        defmodule MyApp.WarningModule do
          def test do
            unused_var = "this will generate a warning"
            :ok
          end
        end
      end

      {:ok, module, diagnostics} = ModuleCompiler.compile_module(quoted_with_warning)
      # diagnostics will contain unused variable warnings

  ## Error Scenarios

      # Invalid module structure
      invalid = {:not_a_module, :definition}
      {:error, :invalid_module} = ModuleCompiler.compile_module(invalid)

      # Compilation error with context
      broken = quote do
        defmodule BrokenModule do
          def broken, do: undefined_function()
        end
      end

      {:error, module, {error, diagnostics}} = ModuleCompiler.compile_module(broken)
  """
  @spec compile_module(Macro.t(), String.t()) ::
          {:ok, module(), diagnostics()}
          | {:error, module(), {Exception.t(), diagnostics()}}
          | {:error, Exception.t() | :invalid_module}
  def compile_module(quoted, file \\ "nofile") do
    :telemetry.span(
      [:mishka_cms, :runtime, :compilers, :module],
      %{file: file},
      fn ->
        result =
          case module_name(quoted) do
            {:ok, module} ->
              Logger.debug("compiling #{inspect(module)}")
              Code.put_compiler_option(:ignore_module_conflict, true)
              compile_quoted(quoted, file, module)

            {:error, error} ->
              {:error, error}
          end

        {result, %{}}
      end
    )
  end

  @doc """
  Extracts the module name from a quoted module definition with support for multiple AST patterns.

  This function analyzes the structure of a quoted expression to identify and extract
  the module name from various forms of module definitions. It handles different
  patterns that can occur in Elixir AST, including simple modules, aliased modules,
  and modules with different structural representations.

  ## Supported AST Patterns

  * `{:defmodule, _, [{:__aliases__, _, [ModuleName]}, _]}` - Simple module with alias
  * `{:defmodule, _, [module_atom, _]}` - Direct module atom reference
  * `{module_atom, {:defmodule, _, _}}` - Module with metadata tuple

  ## Parameters

  * `quoted` - A quoted expression that should contain a module definition

  ## Return Values

  * `{:ok, module}` - Successfully extracted module name as an atom
  * `{:error, :invalid_module}` - The quoted expression doesn't match any supported module pattern

  ## Examples

      # Standard module definition
      quoted = quote do
        defmodule MyApp.UserModule do
          def hello, do: "world"
        end
      end

      {:ok, MyApp.UserModule} = ModuleCompiler.module_name(quoted)

      # Module with alias pattern
      alias_quoted = quote do
        defmodule SomeModule do
          def test, do: :ok
        end
      end

      {:ok, SomeModule} = ModuleCompiler.module_name(alias_quoted)

      # Invalid module structure
      invalid = {:not_a_module, :at_all}
      {:error, :invalid_module} = ModuleCompiler.module_name(invalid)

  ## Notes

  This function performs pattern matching on the AST structure and does not
  validate that the extracted module name is valid or that the module definition
  is syntactically correct. It only extracts the name portion of the module
  definition for use in the compilation process.

  If no supported pattern is matched, the function logs an error with the
  problematic quoted expression for debugging purposes.
  """
  def module_name({:defmodule, _, [{:__aliases__, _, [module]}, _]}) do
    {:ok, Module.concat([module])}
  end

  def module_name({:defmodule, _, [module, _]}) do
    {:ok, Module.concat([module])}
  end

  def module_name({module, {:defmodule, _, _}}) do
    {:ok, Module.concat([module])}
  end

  def module_name(quoted) do
    Logger.error("""
    invalid module given to Compiler,
    expected a quoted expression containing a single module.

    Got:

      #{inspect(quoted)}

    """)

    {:error, :invalid_module}
  end

  @doc """
  Safely unloads a module from the Erlang code server with proper cleanup.

  This function provides a clean way to remove dynamically compiled modules from
  memory when they are no longer needed. It performs a two-step process to ensure
  complete removal of the module from the runtime system.

  The unloading process:
  1. **Purge**: Removes all references to the old module code
  2. **Delete**: Removes the module definition from the code server

  This is essential for long-running applications that frequently compile and
  discard modules to prevent memory leaks and module conflicts.

  ## Parameters

  * `module` - The module atom to unload (e.g., `MyApp.DynamicModule`)

  ## Return Value

  * `:ok` - Always returns `:ok` regardless of whether the module existed

  ## Examples

      # Compile and then unload a module
      quoted = quote do
        defmodule MyApp.TemporaryModule do
          def temp_function, do: "temporary"
        end
      end

      {:ok, module, _diagnostics} = ModuleCompiler.compile_module(quoted)

      # Use the module
      result = module.temp_function()  # => "temporary"

      # Clean up when done
      :ok = ModuleCompiler.unload(module)

      # Module is now removed from memory
      # module.temp_function() would raise UndefinedFunctionError

      # Safe to call on non-existent modules
      :ok = ModuleCompiler.unload(NonExistentModule)

  ## Use Cases

  * **Dynamic Content Management**: Remove old page modules when content is updated
  * **Testing Environments**: Clean up test modules between test runs
  * **Hot Code Reloading**: Remove old versions before loading new ones
  * **Memory Management**: Prevent memory leaks in long-running CMS applications

  ## Notes

  This function is safe to call multiple times on the same module or on
  modules that don't exist. The Erlang code server handles these cases
  gracefully without raising errors.

  After unloading, any existing processes or references holding onto the
  module will need to be updated, as calls to the unloaded module will
  result in `UndefinedFunctionError`.
  """
  def unload(module) do
    :code.purge(module)
    :code.delete(module)
    :ok
  end

  ####################################################################################
  ############################ (▰˘◡˘▰) Helpers (▰˘◡˘▰) ###############################
  ####################################################################################
  # Compiles quoted code and collects diagnostics
  defp compile_quoted(quoted, file, module) do
    {result, diagnostics} = Code.with_diagnostics(fn -> do_compile_and_load(quoted, file) end)
    diagnostics = Enum.uniq(diagnostics)

    case result do
      {:ok, module} -> {:ok, module, diagnostics}
      {:error, error} -> {:error, module, {error, diagnostics}}
    end
  end

  # Performs the actual compilation and loading.
  #
  # `:elixir_compiler.quoted/3` returns `[{module, binary}]` but does not
  # itself install the binary into the BEAM's loaded-modules table, so
  # subsequent `:erlang.module_loaded/1` and `apply/3` calls would fail.
  # We follow up with an explicit `:code.load_binary/3` to make the
  # compiled module callable. Already-loaded modules are purged first to
  # avoid the "module already loaded" warning Erlang emits.
  defp do_compile_and_load(quoted, file) do
    results = :elixir_compiler.quoted(quoted, file, fn _, _ -> :ok end)

    case results do
      [_ | _] = mods ->
        Enum.each(mods, fn {module, binary} ->
          if :code.is_loaded(module) != false, do: :code.purge(module)

          case :code.load_binary(module, String.to_charlist(file), binary) do
            {:module, ^module} -> :ok
            {:error, reason} -> throw({:load_failed, module, reason})
          end
        end)

        # Return the LAST module (the user-facing component module — its
        # related Version/PaperTrail modules come earlier in the list).
        {final_module, _} = List.last(mods)
        {:ok, final_module}

      [] ->
        {:error, :no_modules_compiled}
    end
  rescue
    error -> {:error, error}
  catch
    {:load_failed, module, reason} -> {:error, {:load_failed, module, reason}}
  end

  ####################################################################################
  ##################### (▰˘◡˘▰) Maintenance functions (▰˘◡˘▰) ########################
  ####################################################################################

  @doc """
  Formats and prints AST as readable Elixir code for debugging and inspection.

  This utility function converts an Abstract Syntax Tree (AST) back into formatted
  Elixir source code and prints it to the console. This is particularly useful for
  debugging complex AST transformations, inspecting generated code, or understanding
  the structure of dynamically created modules.

  ## Process

  1. **AST to String**: Converts the AST back to Elixir source code using `Macro.to_string/1`
  2. **Format**: Applies Elixir's code formatter for consistent styling
  3. **Output**: Prints the formatted code to the console with proper indentation

  ## Parameters

  * `ast` - Any valid Elixir AST (quoted expression, module definition, etc.)

  ## Return Value

  * `:ok` - Always returns `:ok` after printing (return value from `IO.puts/1`)

  ## Examples

      # Format a simple function definition
      ast = quote do
        def hello(name) do
          "Hello, \#{name}!"
        end
      end

      ModuleCompiler.ast_to_format_string!(ast)
      # Outputs:
      # def hello(name) do
      #   "Hello, \#{name}!"
      # end

      # Format a complete module
      module_ast = quote do
        defmodule MyApp.Example do
          @moduledoc "Example module"

          def greet(name), do: "Hi \#{name}"

          def farewell(name) do
            "Goodbye, \#{name}!"
          end
        end
      end

      ModuleCompiler.ast_to_format_string!(module_ast)
      # Outputs properly formatted module with consistent indentation

  ## Use Cases

  * **Development Debugging**: Inspect AST generated by other compilers
  * **Code Generation Verification**: Ensure generated code looks correct
  * **Learning Tool**: Understand how Elixir represents code internally
  * **Template Development**: Debug dynamic template compilation
  * **AST Transformation**: Verify transformations produce expected results

  ## Notes

  This function will raise an exception if the AST cannot be converted to valid
  Elixir code or if the code cannot be formatted. Ensure the AST is well-formed
  before calling this function.

  The output goes directly to the console and is not captured or returned as a
  string. For capturing formatted code as a string, use `Macro.to_string/1` and
  `Code.format_string!/1` directly.
  """
  def ast_to_format_string!(ast) do
    Macro.to_string(ast)
    |> Code.format_string!()
    |> IO.puts()
  end
end
