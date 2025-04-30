const Floating = {
  mounted() {
    this.initElements();

    // Flag to track if we moved the content to body
    this.movedToBody = false;

    this.boundHandleOutsideClick = this.handleOutsideClick.bind(this);
    this.boundHandleKeydown = this.handleKeydown.bind(this);
    this.boundHandleClick = this.handleClick.bind(this);
    this.boundHandleMouseEnter = this.handleMouseEnter.bind(this);
    this.boundHandleMouseLeave = this.handleMouseLeave.bind(this);
    this.boundUpdatePosition = this.updatePosition.bind(this);

    this.enableAria = this.el.getAttribute("data-enable-aria") !== "false";
    this.smartPositioning =
      this.el.getAttribute("data-smart-position") === "true";
    this.clickable = this.el.getAttribute("data-clickable") === "true";
    this.position = this.el.getAttribute("data-position") || "bottom";

    this.floatingType = this.getFloatingType();

    if (this.floatingContent) {
      // Store original parent for restoration on destroy
      this.originalParent = this.floatingContent.parentElement;
      this.originalIndex = Array.from(this.originalParent.children).indexOf(
        this.floatingContent,
      );

      // Move to body
      document.body.appendChild(this.floatingContent);
      this.movedToBody = true;

      this.setupAria();
      if (this.enableAria && this.floatingContent.hasAttribute("aria-hidden")) {
        this.floatingContent.setAttribute("aria-hidden", "true");
      }
    }

    if (this.trigger) {
      if (this.clickable) {
        this.trigger.addEventListener("click", this.boundHandleClick);
      } else {
        this.trigger.addEventListener("mouseenter", this.boundHandleMouseEnter);
        this.trigger.addEventListener("mouseleave", this.boundHandleMouseLeave);
        this.floatingContent?.addEventListener(
          "mouseenter",
          this.boundHandleMouseEnter,
        );
        this.floatingContent?.addEventListener(
          "mouseleave",
          this.boundHandleMouseLeave,
        );
      }

      if (this.enableAria && this.floatingType === "dropdown") {
        this.trigger.setAttribute("aria-haspopup", "menu");
        this.trigger.setAttribute("aria-expanded", "false");
      }
    }

    document.addEventListener("click", this.boundHandleOutsideClick);
    document.addEventListener("keydown", this.boundHandleKeydown);
    window.addEventListener("resize", this.boundUpdatePosition);
    window.addEventListener("scroll", this.boundUpdatePosition, true);

    this.forcedWidth = null;
    this.updatePosition();
  },

  initElements() {
    this.floatingContent =
      this.el.querySelector("[data-floating-content]") ||
      this.el.querySelector(".dropdown-content");

    this.trigger =
      this.el.querySelector("[data-floating-trigger]") ||
      this.el.querySelector(".dropdown-trigger");
  },

  getFloatingType() {
    const role = this.floatingContent?.getAttribute("role");
    if (role === "tooltip") return "tooltip";
    if (role === "dialog" || role === "menu") return "dropdown"; // treat dialog/popover/menu as dropdown-like
    return "generic";
  },

  setupAria() {
    if (!this.trigger || !this.floatingContent) return;

    const id =
      this.floatingContent.id ||
      `floating-${Math.random().toString(36).substr(2, 9)}`;
    this.floatingContent.id = id;

    if (this.floatingType === "tooltip") {
      this.trigger.setAttribute("aria-describedby", id);
      this.floatingContent.setAttribute("role", "tooltip");
    }

    if (this.floatingType === "dropdown") {
      this.trigger.setAttribute("aria-controls", id);
      this.trigger.setAttribute("aria-haspopup", "menu");
      this.floatingContent.setAttribute(
        "aria-labelledby",
        this.trigger.id || id,
      );
    }

    if (this.floatingType === "popover") {
      this.trigger.setAttribute("aria-haspopup", "dialog");
      this.trigger.setAttribute("aria-controls", id);
    }
  },

  handleClick(e) {
    e.stopPropagation();
    const allContents = document.querySelectorAll(
      ".dropdown-content.show-dropdown",
    );

    allContents.forEach((content) => {
      if (content !== this.floatingContent) {
        content.classList.remove("visible", "opacity-100", "show-dropdown");
        content.classList.add("invisible", "opacity-0");

        if (this.enableAria && content.hasAttribute("aria-hidden")) {
          content.setAttribute("aria-hidden", "true");
        }

        const triggerId = content.getAttribute("aria-labelledby");
        if (triggerId) {
          const triggerEl = document.getElementById(triggerId);
          triggerEl?.setAttribute("aria-expanded", "false");
        }
      }
    });

    if (this.floatingContent?.classList.contains("show-dropdown")) {
      this.hide();
    } else {
      this.show();
    }
  },

  handleMouseEnter() {
    this.show();
  },

  handleMouseLeave() {
    this.hide();
  },

  handleOutsideClick(e) {
    if (
      this.trigger &&
      !this.trigger.contains(e.target) &&
      (!this.floatingContent || !this.floatingContent.contains(e.target))
    ) {
      this.hide();
    }
  },

  handleKeydown(e) {
    if (!this.floatingContent?.classList.contains("show-dropdown")) return;

    const role = this.floatingContent.getAttribute("role");
    if (role !== "menu") return;

    const items = Array.from(
      this.floatingContent.querySelectorAll(
        '[role="menuitem"]:not([disabled]):not([hidden])',
      ),
    );
    if (!items.length) return;

    const currentIndex = items.indexOf(document.activeElement);

    if (e.key === "Escape") {
      e.preventDefault();
      this.hide();
      this.trigger?.focus();
    } else if (e.key === "ArrowDown") {
      e.preventDefault();
      const next = items[(currentIndex + 1) % items.length];
      next?.focus();
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      const prev = items[(currentIndex - 1 + items.length) % items.length];
      prev?.focus();
    } else if (
      e.key === "Tab" &&
      !e.shiftKey &&
      currentIndex === items.length - 1
    ) {
      e.preventDefault();
      this.hide();
    } else if (e.key === "Tab" && e.shiftKey && currentIndex === 0) {
      e.preventDefault();
      this.hide();
    }
  },

  updatePosition() {
    if (!this.trigger || !this.floatingContent) return;

    const rect = this.trigger.getBoundingClientRect();
    const content = this.floatingContent;
    const gap = 4;
    const isRTL =
      getComputedStyle(document.documentElement).direction === "rtl";
    let pos = this.position;

    if (this.smartPositioning && content.offsetHeight) {
      const { top, bottom, left, right } = rect;
      const { innerHeight, innerWidth } = window;
      const height = content.offsetHeight;
      const width = content.offsetWidth;

      const spaceTop = top;
      const spaceBottom = innerHeight - bottom;
      const spaceLeft = left;
      const spaceRight = innerWidth - right;

      if (pos === "bottom" && spaceBottom < height && spaceTop >= height) {
        pos = "top";
      } else if (pos === "top" && spaceTop < height && spaceBottom >= height) {
        pos = "bottom";
      } else if (pos === "left" && spaceLeft < width && spaceRight >= width) {
        pos = "right";
      } else if (pos === "right" && spaceRight < width && spaceLeft >= width) {
        pos = "left";
      }
    }

    let top, left;
    if (pos === "top") {
      top = rect.top + window.scrollY - content.offsetHeight - gap;
      left = (rect.left + rect.right) / 2 + window.scrollX;
      content.style.transform = "translateX(-50%)";
    } else if (pos === "bottom") {
      top = rect.bottom + window.scrollY + gap;
      left = (rect.left + rect.right) / 2 + window.scrollX;
      content.style.transform = "translateX(-50%)";
    } else if (pos === "left") {
      top =
        rect.top + window.scrollY + (rect.height - content.offsetHeight) / 2;
      left = isRTL
        ? rect.right + window.scrollX + gap
        : rect.left + window.scrollX - content.offsetWidth - gap;
      content.style.transform = "none";
    } else if (pos === "right") {
      top =
        rect.top + window.scrollY + (rect.height - content.offsetHeight) / 2;
      left = isRTL
        ? rect.left + window.scrollX - content.offsetWidth - gap
        : rect.right + window.scrollX + gap;
      content.style.transform = "none";
    }

    content.style.position = "absolute";
    content.style.top = `${top}px`;
    content.style.left = `${left}px`;
  },

  show() {
    if (!this.floatingContent) return;

    const content = this.floatingContent;
    const transition = content.style.transition;
    content.style.transition = "none";

    content.removeAttribute("hidden");
    content.classList.remove("invisible", "opacity-0");
    content.classList.add("visible", "opacity-100", "show-dropdown");

    this.updatePosition();

    const triggerWidth = this.trigger.offsetWidth;
    if (!this.forcedWidth) {
      const contentWidth = content.offsetWidth;
      if (contentWidth < triggerWidth) {
        this.forcedWidth = triggerWidth;
      }
    }

    content.style.width = this.forcedWidth ? `${this.forcedWidth}px` : "auto";

    content.offsetHeight; // force reflow
    content.style.transition = transition;

    if (this.enableAria && this.trigger && this.floatingType === "dropdown") {
      this.trigger.setAttribute("aria-expanded", "true");
    }
    if (this.enableAria && content.hasAttribute("aria-hidden")) {
      content.setAttribute("aria-hidden", "false");
    }

    if (this.floatingType === "dropdown") {
      const firstItem = content.querySelector('[role="menuitem"]');
      firstItem?.focus();
    }
  },

  hide() {
    if (!this.floatingContent) return;

    this.floatingContent.classList.remove(
      "visible",
      "opacity-100",
      "show-dropdown",
    );
    this.floatingContent.classList.add("invisible", "opacity-0");

    if (this.enableAria && this.trigger && this.floatingType === "dropdown") {
      this.trigger.setAttribute("aria-expanded", "false");
    }
    if (this.enableAria && this.floatingContent.hasAttribute("aria-hidden")) {
      this.floatingContent.setAttribute("aria-hidden", "true");
    }
  },

  cleanupAria() {
    if (this.trigger) {
      if (this.floatingType === "tooltip") {
        this.trigger.removeAttribute("aria-describedby");
      } else if (this.floatingType === "dropdown") {
        this.trigger.removeAttribute("aria-controls");
        this.trigger.removeAttribute("aria-haspopup");
        this.trigger.removeAttribute("aria-expanded");
      } else if (this.floatingType === "popover") {
        this.trigger.removeAttribute("aria-haspopup");
        this.trigger.removeAttribute("aria-controls");
      }
    }
  },

  destroyed() {
    // Remove event listeners
    document.removeEventListener("click", this.boundHandleOutsideClick);
    document.removeEventListener("keydown", this.boundHandleKeydown);
    window.removeEventListener("resize", this.boundUpdatePosition);
    window.removeEventListener("scroll", this.boundUpdatePosition, true);

    if (this.trigger && this.clickable) {
      this.trigger.removeEventListener("click", this.boundHandleClick);
    }
    if (!this.clickable && this.trigger) {
      this.trigger.removeEventListener(
        "mouseenter",
        this.boundHandleMouseEnter,
      );
      this.trigger.removeEventListener(
        "mouseleave",
        this.boundHandleMouseLeave,
      );
    }

    if (!this.clickable && this.floatingContent) {
      this.floatingContent.removeEventListener(
        "mouseenter",
        this.boundHandleMouseEnter,
      );
      this.floatingContent.removeEventListener(
        "mouseleave",
        this.boundHandleMouseLeave,
      );
    }

    // Clean up ARIA attributes
    this.cleanupAria();

    // Only restore floating content if it was moved to body
    if (
      this.floatingContent &&
      this.movedToBody &&
      document.body.contains(this.floatingContent)
    ) {
      // Remove from body
      document.body.removeChild(this.floatingContent);

      // Restore to original parent if available
      if (this.originalParent) {
        if (
          this.originalIndex >= 0 &&
          this.originalIndex < this.originalParent.children.length
        ) {
          this.originalParent.insertBefore(
            this.floatingContent,
            this.originalParent.children[this.originalIndex],
          );
        } else {
          this.originalParent.appendChild(this.floatingContent);
        }
      }
    }

    // Clear references
    this.floatingContent = null;
    this.trigger = null;
    this.originalParent = null;
  },
};

export default Floating;
