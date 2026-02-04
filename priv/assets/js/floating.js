const Floating = {
  mounted() {
    this.initElements();

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

    this.showDelay = parseInt(this.el.getAttribute("data-show-delay")) || 0;
    this.hideDelay = parseInt(this.el.getAttribute("data-hide-delay")) || 400;

    this.showTimeout = null;
    this.hideTimeout = null;

    this.floatingType = this.getFloatingType();

    this.isRTL = getComputedStyle(document.documentElement).direction === "rtl";

    this.cleanupDuplicateIds();

    this.setupFloatingContent();
    this.setupEventListeners();

    this.forcedWidth = null;
    this.updatePosition();
  },

  cleanupDuplicateIds() {
    if (this.floatingContent && this.floatingContent.id) {
      const duplicates = document.body.querySelectorAll(
        `#${this.floatingContent.id}`,
      );
      duplicates.forEach((duplicate) => {
        if (
          duplicate !== this.floatingContent &&
          duplicate.parentNode === document.body
        ) {
          try {
            document.body.removeChild(duplicate);
          } catch (e) {}
        }
      });
    }
  },

  setVisibility(element, visible) {
    if (!element) return;

    if (visible) {
      element.removeAttribute("hidden");
      element.classList.remove("invisible", "opacity-0");
      element.classList.add("visible", "opacity-100", "show-dropdown");
    } else {
      element.classList.remove("visible", "opacity-100", "show-dropdown");
      element.classList.add("invisible", "opacity-0");
      element.setAttribute("hidden", "");
    }
  },

  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  },

  beforeUpdate() {
    if (this.showTimeout) {
      clearTimeout(this.showTimeout);
      this.showTimeout = null;
    }
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
    }

    if (
      this.floatingContent &&
      this.movedToBody &&
      document.body.contains(this.floatingContent)
    ) {
      if (!this.clickable) {
        this.floatingContent.removeEventListener(
          "mouseenter",
          this.boundHandleMouseEnter,
        );
        this.floatingContent.removeEventListener(
          "mouseleave",
          this.boundHandleMouseLeave,
        );
      }

      document.body.removeChild(this.floatingContent);
      this.movedToBody = false;
      this.floatingContent = null;
    }
  },

  updated() {
    this.initElements();

    if (this.floatingContent) {
      this.floatingType = this.getFloatingType();
      this.setupFloatingContent();

      if (!this.clickable) {
        this.floatingContent.addEventListener(
          "mouseenter",
          this.boundHandleMouseEnter,
        );
        this.floatingContent.addEventListener(
          "mouseleave",
          this.boundHandleMouseLeave,
        );
      }

      this.updatePosition();
    }
  },

  initElements() {
    this.floatingContent =
      this.el.querySelector("[data-floating-content]") ||
      this.el.querySelector(".dropdown-content");

    this.trigger =
      this.el.querySelector("[data-floating-trigger]") ||
      this.el.querySelector(".dropdown-trigger");
  },

  setupFloatingContent() {
    if (this.floatingContent) {
      this.originalParent = this.floatingContent.parentElement;
      this.originalIndex = Array.from(this.originalParent.children).indexOf(
        this.floatingContent,
      );

      document.body.appendChild(this.floatingContent);
      this.movedToBody = true;

      this.setupAria();

      this.floatingContent.setAttribute("hidden", "");
    }
  },

  cleanupFloatingContent() {
    if (this.floatingContent) {
      if (!this.clickable) {
        this.floatingContent.removeEventListener(
          "mouseenter",
          this.boundHandleMouseEnter,
        );
        this.floatingContent.removeEventListener(
          "mouseleave",
          this.boundHandleMouseLeave,
        );
      }

      if (document.body.contains(this.floatingContent)) {
        document.body.removeChild(this.floatingContent);
      }
    }
  },

  setupEventListeners() {
    if (this.trigger) {
      if (this.clickable) {
        this.trigger.addEventListener("click", this.boundHandleClick);
      } else {
        this.trigger.addEventListener("mouseenter", this.boundHandleMouseEnter);
        this.trigger.addEventListener("mouseleave", this.boundHandleMouseLeave);
        this.trigger.addEventListener("focusin", this.boundHandleMouseEnter);
        this.trigger.addEventListener("focusout", this.boundHandleMouseLeave);
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

    this.updatePositionDebounced = this.debounce(this.boundUpdatePosition, 16);

    document.addEventListener("click", this.boundHandleOutsideClick);
    document.addEventListener("keydown", this.boundHandleKeydown);
    window.addEventListener("resize", this.updatePositionDebounced);
    window.addEventListener("scroll", this.updatePositionDebounced, true);
  },

  getFloatingType() {
    const role = this.floatingContent?.getAttribute("role");
    if (role === "tooltip") return "tooltip";
    if (role === "dialog" || role === "menu") return "dropdown";
    return "generic";
  },

  setupAria() {
    if (!this.trigger || !this.floatingContent) return;

    const timestamp = Date.now();
    const random = Math.random().toString(36).slice(2, 8);
    const id = this.floatingContent.id || `floating-${timestamp}-${random}`;
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
    const allContents = document.querySelectorAll(
      ".dropdown-content.show-dropdown",
    );

    allContents.forEach((content) => {
      if (content && content !== this.floatingContent) {
        this.setVisibility(content, false);

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
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
    }

    if (this.showTimeout) {
      clearTimeout(this.showTimeout);
      this.showTimeout = null;
    }

    if (this.showDelay > 0) {
      this.showTimeout = setTimeout(() => {
        this.show();
        this.showTimeout = null;
      }, this.showDelay);
    } else {
      this.show();
    }
  },

  handleMouseLeave() {
    if (this.showTimeout) {
      clearTimeout(this.showTimeout);
      this.showTimeout = null;
    }

    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
    }

    if (this.hideDelay > 0) {
      this.hideTimeout = setTimeout(() => {
        this.hide();
        this.hideTimeout = null;
      }, this.hideDelay);
    } else {
      this.hide();
    }
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

    const originalDisplay = this.trigger.style.display;
    const isSpan = this.trigger.tagName.toLowerCase() === "span";

    if (isSpan && (!originalDisplay || originalDisplay === "inline")) {
      this.trigger.style.display = "inline-block";
    }

    const rect = this.trigger.getBoundingClientRect();
    const content = this.floatingContent;
    const gap = 5;
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
      left = this.isRTL
        ? rect.right + window.scrollX + gap
        : rect.left + window.scrollX - content.offsetWidth - gap;
      content.style.transform = "none";
    } else if (pos === "right") {
      top =
        rect.top + window.scrollY + (rect.height - content.offsetHeight) / 2;
      left = this.isRTL
        ? rect.left + window.scrollX - content.offsetWidth - gap
        : rect.right + window.scrollX + gap;
      content.style.transform = "none";
    }

    // Clamp to viewport to prevent content from overflowing screen edges.
    // This runs regardless of smartPositioning to always keep content visible.
    const contentWidth = content.offsetWidth;
    const contentHeight = content.offsetHeight;
    const viewportLeft = window.scrollX;
    const viewportRight = window.scrollX + window.innerWidth;
    const viewportTop = window.scrollY;
    const viewportBottom = window.scrollY + window.innerHeight;

    if (pos === "top" || pos === "bottom") {
      // left is the center point (CSS translateX(-50%) shifts it), so actual edges are:
      const actualLeft = left - contentWidth / 2;
      const actualRight = left + contentWidth / 2;

      if (actualRight > viewportRight) {
        left = viewportRight - contentWidth - gap;
        content.style.transform = "none";
      } else if (actualLeft < viewportLeft) {
        left = viewportLeft + gap;
        content.style.transform = "none";
      }

      // When content is wider than viewport, the right-edge clamp pushes left off-screen.
      // Always anchor to left edge so the start of content stays visible (LTR).
      if (left < viewportLeft + gap) {
        left = viewportLeft + gap;
        content.style.transform = "none";
      }
    } else if (pos === "left" || pos === "right") {
      if (top + contentHeight > viewportBottom) {
        top = viewportBottom - contentHeight - gap;
      }
      if (top < viewportTop) {
        top = viewportTop + gap;
      }

      // Horizontal clamping for left/right positions
      if (left + contentWidth > viewportRight) {
        left = viewportRight - contentWidth - gap;
      }
      if (left < viewportLeft + gap) {
        left = viewportLeft + gap;
      }
    }

    content.style.position = "absolute";
    content.style.top = `${top}px`;
    content.style.left = `${left}px`;

    if (isSpan && originalDisplay !== "inline-block") {
      this.trigger.style.display = originalDisplay || "";
    }
  },

  show() {
    if (!this.floatingContent) return;

    const content = this.floatingContent;

    const transition = content.style.transition;
    content.style.transition = "none";

    this.setVisibility(content, true);
    this.updatePosition();

    const triggerWidth = this.trigger.offsetWidth;
    if (!this.forcedWidth) {
      const contentWidth = content.offsetWidth;
      if (contentWidth < triggerWidth) {
        this.forcedWidth = triggerWidth;
      }
    }

    content.style.width = this.forcedWidth ? `${this.forcedWidth}px` : "auto";

    content.offsetHeight;
    content.style.transition = transition;

    if (this.enableAria) {
      content.removeAttribute("aria-hidden");
      if (this.trigger && this.floatingType === "dropdown") {
        this.trigger.setAttribute("aria-expanded", "true");
      }
    }

    if (this.floatingType === "dropdown") {
      const firstItem = content.querySelector('[role="menuitem"]');
      firstItem?.focus();
    }
  },

  hide() {
    if (!this.floatingContent) return;

    const isCurrentlyVisible =
      this.floatingContent.classList.contains("show-dropdown");

    this.setVisibility(this.floatingContent, false);

    if (this.enableAria && isCurrentlyVisible) {
      setTimeout(() => {
        if (
          this.floatingContent &&
          !this.floatingContent.classList.contains("show-dropdown")
        ) {
          this.floatingContent.setAttribute("aria-hidden", "true");
        }
      }, 0);
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
    if (this.showTimeout) {
      clearTimeout(this.showTimeout);
      this.showTimeout = null;
    }
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
    }

    if (this.updatePositionDebounced) {
      this.updatePositionDebounced.cancel?.();
    }

    document.removeEventListener("click", this.boundHandleOutsideClick);
    document.removeEventListener("keydown", this.boundHandleKeydown);
    window.removeEventListener(
      "resize",
      this.updatePositionDebounced || this.boundUpdatePosition,
    );
    window.removeEventListener(
      "scroll",
      this.updatePositionDebounced || this.boundUpdatePosition,
      true,
    );

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
      this.trigger.removeEventListener("focusin", this.boundHandleMouseEnter);
      this.trigger.removeEventListener("focusout", this.boundHandleMouseLeave);
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

    this.cleanupAria();

    if (
      this.floatingContent &&
      this.movedToBody &&
      document.body.contains(this.floatingContent)
    ) {
      document.body.removeChild(this.floatingContent);

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

    this.floatingContent = null;
    this.trigger = null;
    this.originalParent = null;
  },
};

export default Floating;
