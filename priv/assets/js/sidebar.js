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

  Sidebar(elements, config) {
    const { sidebar, labels } = elements;
    const { expandedWidth, collapsedWidth, isMinimized } = config;

    sidebar.style.transition = `width ${this.defaults.transitionDuration} ease`;

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
