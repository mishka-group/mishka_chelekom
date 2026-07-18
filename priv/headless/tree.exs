[
  tree: [
    name: "tree",
    category: "navigation",
    doc_url: "https://mishka.tools/chelekom/docs/headless/tree",
    spec_url: "https://www.w3.org/WAI/ARIA/apg/patterns/treeview/",
    args: [type: ["tree"], only: ["tree"], helpers: [], module: ""],
    optional: [],
    necessary: [],
    scripts: [
      %{
        module: "Tree",
        type: "file",
        file: "tree.js",
        imports: "import Tree from \"./tree.js\";"
      }
    ],
    headless: [
      anatomy: [
        root: [
          element: "ul",
          role: "tree",
          aria: ["aria-label", "aria-multiselectable"],
          data_attributes: ["data-tree-root", "data-with-lines", "data-with-checkboxes"],
          css_vars: ["--level-offset"],
          note:
            "carries the Tree hook; reads every behaviour option and the pushed event names from data-*",
          required: true
        ],
        parts: [
          node: [
            element: "li",
            role: "treeitem",
            aria: [
              "aria-level",
              "aria-setsize",
              "aria-posinset",
              "aria-expanded",
              "aria-selected",
              "aria-checked",
              "aria-disabled"
            ],
            data_attributes: [
              "data-value",
              "data-level",
              "data-expanded",
              "data-has-children",
              "data-selected",
              "data-checked",
              "data-indeterminate",
              "data-disabled",
              "data-selectable",
              "data-loading",
              "data-focus-ring"
            ],
            css_vars: ["--label-offset"],
            note:
              "roving tabindex (one node in the tab order); `aria-selected` and `aria-checked` are mutually exclusive per the APG; " <>
                "`selectable: false` nodes (category headers) omit aria-selected — click/Enter toggles the branch instead"
          ],
          label: [
            element: "div",
            data_attributes: ["data-selected", "data-dragging", "data-drag-over"],
            note: "the clickable row; `data-drag-over` is before|after|inside while dragging"
          ],
          subtree: [
            element: "ul",
            role: "group",
            data_attributes: ["data-level"],
            note: "collapsed subtrees carry `hidden` when kept mounted"
          ],
          checkbox: [
            element: "input",
            aria: ["aria-checked", "aria-hidden"],
            note: "native checkbox, `tabindex=\"-1\"` — the node owns the tab stop; submits as `name`"
          ],
          "expand-icon": [
            element: "span",
            aria: ["aria-hidden"],
            data_attributes: ["data-has-children"],
            note: "the `expand_icon` slot renders inside it, for nodes with children only"
          ],
          "drag-handle": [
            element: "span",
            aria: ["aria-label"],
            note: "only with `draggable` + `with_drag_handle`; the `drag_icon` slot renders inside it"
          ],
          "label-text": [element: "span", note: "the node slot (or the node's label) renders here"],
          loader: [
            element: "span",
            note: "reveal it on the node's `data-loading` while async children are fetched"
          ]
        ]
      ],
      aria_pattern: [
        pattern: "Tree View",
        keyboard: [
          "ArrowDown/ArrowUp: move focus through the visible nodes",
          "ArrowRight: expand a collapsed node, else focus its first child",
          "ArrowLeft: collapse an expanded node, else focus its parent",
          "Home/End: focus the first/last visible node",
          "Enter: select the focused node",
          "Space: expand/collapse (`expand_on_space`) or check (`check_on_space`)",
          "Shift+click / Shift+Arrow: select a range (`allow_range_selection`)"
        ]
      ],
      state_attributes: [
        "data-expanded",
        "data-has-children",
        "data-selected",
        "data-checked",
        "data-indeterminate",
        "data-disabled",
        "data-loading",
        "data-focus-ring",
        "data-dragging",
        "data-drag-over",
        "data-level"
      ],
      hooks: ["Tree"]
    ]
  ]
]
