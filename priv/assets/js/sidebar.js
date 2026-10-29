const Sidebar = {
  defaults: {
    expandedWidth: "250px",
    collapsedWidth: "60px",
    transitionDuration: "0.3s",
    labelAnimationDelay: 10,
  },

  getElements(el) {
    const sidebarSelector = el.getAttribute("data-sidebar-selector");
    if (!sidebarSelector) return null;

    if (!this.isValidSelector(sidebarSelector)) return null;

    const sidebar = document.querySelector(sidebarSelector);
    if (!sidebar) return null;

    return {
      sidebar,
      labels: sidebar.querySelectorAll("[data-item-label]"),
    };
  },

  isValidSelector(selector) {
    try {
      document.querySelector(selector);
      return true;
    } catch (e) {
      console.error("Invalid selector:", selector);
      return false;
    }
  },

  getConfig(sidebar) {
    const expandedWidth = sidebar.getAttribute("data-expanded-width");
    const collapsedWidth = sidebar.getAttribute("data-collapsed-width");

    return {
      expandedWidth:
        this.sanitizeCssValue(expandedWidth) || this.defaults.expandedWidth,
      collapsedWidth:
        this.sanitizeCssValue(collapsedWidth) || this.defaults.collapsedWidth,
      isMinimized: sidebar.getAttribute("data-minimized") === "true",
    };
  },

  sanitizeCssValue(value) {
    if (!value) return null;

    const validPattern = /^[0-9]+(px|em|rem|%|vh|vw)$/;
    return validPattern.test(value) ? value : null;
  },

  expandSidebar(sidebar, labels, expandedWidth) {
    sidebar.style.width = expandedWidth;
    sidebar.setAttribute("data-minimized", "false");

    this.animateLabels(labels, true);
  },

  collapseSidebar(sidebar, labels, collapsedWidth) {
    sidebar.style.width = collapsedWidth;
    sidebar.setAttribute("data-minimized", "true");

    this.hideLabels(labels);
  },

  animateLabels(labels, show) {
    if (show) {
      labels.forEach((label) => {
        label.classList.remove("hidden");
        label.classList.add("opacity-0");

        setTimeout(() => {
          label.classList.add(
            "transition-opacity",
            "duration-200",
            "opacity-100",
          );
          label.classList.remove("opacity-0");
        }, this.defaults.labelAnimationDelay);
      });
    }
  },

  hideLabels(labels) {
    labels.forEach((label) => {
      label.classList.add("hidden");
      label.classList.remove(
        "opacity-100",
        "transition-opacity",
        "duration-200",
      );
    });
  },

  // Adds width to the transitions the sidebar's classes give it. An inline `transition` would
  // replace them, and after the first toggle the slide and the visibility change of opening and
  // closing would happen at once. Each list is repeated to the length of the property list, as
  // CSS repeats it, and width's values are added at the end.
  addWidthTransition(sidebar) {
    const style = getComputedStyle(sidebar);
    const properties = this.splitList(style.transitionProperty).filter(
      (property) => property !== "none",
    );
    if (properties.includes("width") || properties.includes("all")) return;

    const width = {
      transitionDuration: this.defaults.transitionDuration,
      transitionTimingFunction: "ease",
      transitionDelay: "0s",
      transitionBehavior: "normal",
    };

    for (const [longhand, value] of Object.entries(width)) {
      const list = this.splitList(style[longhand]);
      const repeated = properties.map((_property, i) => list[i % list.length] || value);
      sidebar.style[longhand] = [...repeated, value].join(", ");
    }
    sidebar.style.transitionProperty = [...properties, "width"].join(", ");
  },

  // A computed list split at its own commas, not at those inside `cubic-bezier(...)`.
  splitList(value) {
    const items = [];
    let depth = 0;
    let item = "";
    for (const char of value || "") {
      if (char === "(") depth++;
      if (char === ")") depth--;
      if (char === "," && depth === 0) {
        items.push(item.trim());
        item = "";
      } else {
        item += char;
      }
    }
    if (item.trim()) items.push(item.trim());
    return items;
  },

  Sidebar(elements, config) {
    const { sidebar, labels } = elements;
    const { expandedWidth, collapsedWidth, isMinimized } = config;

    this.addWidthTransition(sidebar);

    if (isMinimized) {
      this.expandSidebar(sidebar, labels, expandedWidth);
    } else {
      this.collapseSidebar(sidebar, labels, collapsedWidth);
    }
  },

  mounted() {
    this.clickHandler = this.handleClick.bind(this);
    this.el.addEventListener("click", this.clickHandler);
  },

  handleClick() {
    const elements = this.getElements(this.el);
    if (!elements) return;

    const config = this.getConfig(elements.sidebar);
    this.Sidebar(elements, config);

    const icon = this.el.querySelector(".minimize-icon");
    if (icon) {
      icon.classList.toggle("rotate-180");
    }
  },

  destroy() {
    if (this.el && this.clickHandler) {
      this.el.removeEventListener("click", this.clickHandler);
      this.clickHandler = null;
    }
  },
};

export default Sidebar;
