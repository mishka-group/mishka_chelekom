# This file contains the configuration for Credo and you are probably reading
# this after creating it with `mix credo.gen.config`.
#
# If you find anything wrong or unclear in this file, please report an
# issue on GitHub: https://github.com/rrrene/credo/issues
#
%{
  #
  # You can have as many configs as you like in the `configs:` field.
  configs: [
    %{
      #
      # Run any config using `mix credo -C <name>`. If no config name is given
      # "default" is used.
      #
      name: "default",
      #
      # These are the files included in the analysis:
      files: %{
        #
        # You can give explicit globs or simply directories.
        # In the latter case `**/*.{ex,exs}` will be used.
        #
        included: [
          "lib/",
          "src/",
          "test/",
          "web/",
          "apps/*/lib/",
          "apps/*/src/",
          "apps/*/test/",
          "apps/*/web/"
        ],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      #
      # Load and configure plugins here:
      #
      plugins: [],
      #
      # If you create your own checks, you must specify the source files for
      # them here, so they can be loaded by Credo before running the analysis.
      #
      requires: [],
      #
      # If you want to enforce a style guide and need a more traditional linting
      # experience, you can change `strict` to `true` below:
      #
      strict: false,
      #
      # To modify the timeout for parsing files, change this value:
      #
      parse_timeout: 5000,
      #
      # If you want to use uncolored output by default, you can change `color`
      # to `false` below:
      #
      color: true,
      #
      # You can customize the parameters of any check by adding a second element
      # to the tuple.
      #
      # To disable a check put `false` as second element:
      #
      #     {Credo.Check.Design.DuplicatedCode, false}
      #
      checks: %{
        enabled:
          [
            #
            ## Consistency Checks
            #
            {Credo.Check.Consistency.ExceptionNames, []},
            {Credo.Check.Consistency.LineEndings, []},
            {Credo.Check.Consistency.ParameterPatternMatching, []},
            {Credo.Check.Consistency.SpaceAroundOperators, []},
            {Credo.Check.Consistency.SpaceInParentheses, []},
            {Credo.Check.Consistency.TabsOrSpaces, []},

            #
            ## Design Checks
            #
            # You can customize the priority of any check
            # Priority values are: `low, normal, high, higher`
            #
            {Credo.Check.Design.TagFIXME, []},
            {Credo.Check.Design.TagTODO, [exit_status: 2]},

            #
            ## Readability Checks
            #
            {Credo.Check.Readability.FunctionNames, []},
            {Credo.Check.Readability.LargeNumbers, []},
            {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
            {Credo.Check.Readability.ModuleAttributeNames, []},
            {Credo.Check.Readability.ModuleDoc, []},
            {Credo.Check.Readability.ModuleNames, []},
            {Credo.Check.Readability.ParenthesesInCondition, []},
            {Credo.Check.Readability.ParenthesesOnZeroArityDefs, []},
            {Credo.Check.Readability.PipeIntoAnonymousFunctions, []},
            {Credo.Check.Readability.PredicateFunctionNames, []},
            {Credo.Check.Readability.PreferImplicitTry, []},
            {Credo.Check.Readability.RedundantBlankLines, []},
            {Credo.Check.Readability.Semicolons, []},
            {Credo.Check.Readability.SpaceAfterCommas, []},
            {Credo.Check.Readability.StringSigils, []},
            {Credo.Check.Readability.TrailingBlankLine, []},
            {Credo.Check.Readability.TrailingWhiteSpace, []},
            {Credo.Check.Readability.UnnecessaryAliasExpansion, []},
            {Credo.Check.Readability.VariableNames, []},
            {Credo.Check.Readability.WithSingleClause, []},

            #
            ## Refactoring Opportunities
            #
            {Credo.Check.Refactor.Apply, []},
            {Credo.Check.Refactor.CondStatements, []},
            {Credo.Check.Refactor.CyclomaticComplexity, []},
            {Credo.Check.Refactor.FilterCount, []},
            {Credo.Check.Refactor.FilterFilter, []},
            {Credo.Check.Refactor.FunctionArity, []},
            {Credo.Check.Refactor.LongQuoteBlocks, []},
            {Credo.Check.Refactor.MapJoin, []},
            {Credo.Check.Refactor.MatchInCondition, []},
            {Credo.Check.Refactor.NegatedConditionsInUnless, []},
            {Credo.Check.Refactor.NegatedConditionsWithElse, []},
            {Credo.Check.Refactor.Nesting, []},
            {Credo.Check.Refactor.RedundantWithClauseResult, []},
            {Credo.Check.Refactor.RejectReject, []},
            {Credo.Check.Refactor.UnlessWithElse, []},
            {Credo.Check.Refactor.WithClauses, []},

            #
            ## Warnings
            #
            {Credo.Check.Warning.ApplicationConfigInModuleAttribute, []},
            {Credo.Check.Warning.BoolOperationOnSameValues, []},
            {Credo.Check.Warning.Dbg, []},
            {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig, []},
            {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
            {Credo.Check.Warning.IExPry, []},
            {Credo.Check.Warning.IoInspect, []},
            {Credo.Check.Warning.OperationOnSameValues, []},
            {Credo.Check.Warning.OperationWithConstantResult, []},
            {Credo.Check.Warning.RaiseInsideRescue, []},
            {Credo.Check.Warning.SpecWithStruct, []},
            {Credo.Check.Warning.StructFieldAmount, []},
            {Credo.Check.Warning.UnsafeExec, []},
            {Credo.Check.Warning.UnusedEnumOperation, []},
            {Credo.Check.Warning.UnusedFileOperation, []},
            {Credo.Check.Warning.UnusedKeywordOperation, []},
            {Credo.Check.Warning.UnusedListOperation, []},
            {Credo.Check.Warning.UnusedMapOperation, []},
            {Credo.Check.Warning.UnusedPathOperation, []},
            {Credo.Check.Warning.UnusedRegexOperation, []},
            {Credo.Check.Warning.UnusedStringOperation, []},
            {Credo.Check.Warning.UnusedTupleOperation, []},
            {Credo.Check.Warning.WrongTestFilename, []},

            #
            # Jump.CredoChecks (every check except UseObanProWorker: this project has no Oban)
            #
            {Jump.CredoChecks.AssertElementSelectorCanNeverFail, []},
            {Jump.CredoChecks.AssertReceiveTimeout, []},
            {Jump.CredoChecks.AvoidFunctionLevelElse, []},
            {Jump.CredoChecks.AvoidLoggerConfigureInTest, []},
            {Jump.CredoChecks.AvoidModifyingStructBeforeChangeset, []},
            {Jump.CredoChecks.AvoidSocketAssignsInTest, []},
            {Jump.CredoChecks.ConditionalAssertion, []},
            {Jump.CredoChecks.DoctestIExExamples,
             derive_test_path: fn filename ->
               filename
               |> String.replace_leading("lib/", "test/")
               |> String.replace_trailing(".ex", "_test.exs")
             end},
            {Jump.CredoChecks.ForbiddenFunction,
             functions: [
               {:erlang, :binary_to_term,
                "Use Plug.Crypto.non_executable_binary_to_term/2 with :safe instead."}
             ]},
            {Jump.CredoChecks.LiveViewFormCanBeRehydrated, []},
            {Jump.CredoChecks.LiveViewPubSubRequiresConnected, []},
            {Jump.CredoChecks.NoManualContentDisposition, []},
            {Jump.CredoChecks.NoWordSigilInterpolation, []},
            {Jump.CredoChecks.PreferChangeOverUpDownMigrations, start_after: "0"},
            {Jump.CredoChecks.PreferTextColumns, start_after: "0"},
            {Jump.CredoChecks.SafeBinaryToTerm, []},
            {Jump.CredoChecks.TestHasNoAssertions, []},
            {Jump.CredoChecks.TooManyAssertions, []},
            {Jump.CredoChecks.TopLevelAliasImportRequire, []},
            {Jump.CredoChecks.UndeclaredExternalResource, []},
            {Jump.CredoChecks.UnusedLiveViewAssign, []},
            {Jump.CredoChecks.VacuousTest, []},
            {Jump.CredoChecks.WeakAssertion, []}
          ] ++
            Enum.map(
              List.delete(ExSlop.recommended_checks(), ExSlop.Check.Refactor.LengthComparison),
              &{&1, []}
            ) ++
            [
              # A test states the count it expects with `length/1`, and its failure shows both.
              {ExSlop.Check.Refactor.LengthComparison, files: %{excluded: [~r"/test/"]}}
            ],
        disabled: [
          # Switched off because the project's own convention differs, one reason each.
          #
          # Modules are written out in full or aliased as the reader needs (`Igniter.Project.Deps`
          # reads as Igniter's own docs do); 111 aliases for no change in behaviour.
          {Credo.Check.Design.AliasUsage, []},
          # Aliases are grouped by what they belong to (a test's module under test first), not sorted.
          {Credo.Check.Readability.AliasOrder, []},

          #
          # Checks scheduled for next check update (opt-in for now)
          {Credo.Check.Refactor.UtcNowTruncate, []},

          #
          # Controversial and experimental checks (opt-in, just move the check to `:enabled`
          #   and be sure to use `mix credo --strict` to see low priority checks)
          #
          {Credo.Check.Consistency.MultiAliasImportRequireUse, []},
          {Credo.Check.Consistency.UnusedVariableNames, []},
          {Credo.Check.Design.DuplicatedCode, []},
          {Credo.Check.Design.SkipTestWithoutComment, []},
          {Credo.Check.Readability.AliasAs, []},
          {Credo.Check.Readability.BlockPipe, []},
          {Credo.Check.Readability.ImplTrue, []},
          {Credo.Check.Readability.MultiAlias, []},
          {Credo.Check.Readability.NestedFunctionCalls, []},
          {Credo.Check.Readability.OneArityFunctionInPipe, []},
          {Credo.Check.Readability.OnePipePerLine, []},
          {Credo.Check.Readability.SeparateAliasRequire, []},
          {Credo.Check.Readability.SingleFunctionToBlockPipe, []},
          {Credo.Check.Readability.SinglePipe, []},
          {Credo.Check.Readability.Specs, []},
          {Credo.Check.Readability.StrictModuleLayout, []},
          {Credo.Check.Readability.WithCustomTaggedTuple, []},
          {Credo.Check.Refactor.ABCSize, []},
          {Credo.Check.Refactor.AppendSingleItem, []},
          {Credo.Check.Refactor.CondInsteadOfIfElse, []},
          {Credo.Check.Refactor.DoubleBooleanNegation, []},
          {Credo.Check.Refactor.FilterReject, []},
          {Credo.Check.Refactor.IoPuts, []},
          {Credo.Check.Refactor.MapMap, []},
          {Credo.Check.Refactor.ModuleDependencies, []},
          {Credo.Check.Refactor.NegatedIsNil, []},
          {Credo.Check.Refactor.PassAsyncInTestCases, []},
          {Credo.Check.Refactor.PipeChainStart, []},
          {Credo.Check.Refactor.RejectFilter, []},
          {Credo.Check.Refactor.VariableRebinding, []},
          {Credo.Check.Warning.LazyLogging, []},
          {Credo.Check.Warning.LeakyEnvironment, []},
          {Credo.Check.Warning.MapGetUnsafePass, []},
          {Credo.Check.Warning.MixEnv, []},
          {Credo.Check.Warning.UnsafeToAtom, []}
          # {Credo.Check.Warning.UnusedOperation, [{MyMagicModule, [:fun1, :fun2]}]}

          # {Credo.Check.Refactor.MapInto, []},

          #
          # Custom checks can be created using `mix credo.gen.check`.
          #
        ]
      }
    }
  ]
}
