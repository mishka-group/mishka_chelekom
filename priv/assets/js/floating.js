const Floating = {
  mounted() {
    this.enableAria = true;
    const ariaSetting = this.el.getAttribute("data-enable-aria");
    if (ariaSetting !== null) {
      this.enableAria = ariaSetting === "true";
    }

    this.floatingContent =
      this.el.querySelector("[data-floating-content]") ||
      this.el.querySelector(".dropdown-content");
    if (this.floatingContent) {
      document.body.appendChild(this.floatingContent);
      this.updatePosition();
      if (
        this.enableAria &&
        this.floatingContent.getAttribute("aria-hidden") !== null
      ) {
        this.floatingContent.setAttribute("aria-hidden", "true");
      }
    }

    this.trigger =
      this.el.querySelector("[data-floating-trigger]") ||
      this.el.querySelector(".dropdown-trigger");

    // Use click if data-clickable is "true", otherwise use hover
    const clickable = this.el.getAttribute("data-clickable") === "true";

    if (this.trigger) {
      if (clickable) {
        this.trigger.addEventListener("click", this.handleClick.bind(this));
      } else {
        this.trigger.addEventListener(
          "mouseenter",
          this.handleMouseEnter.bind(this),
        );
        this.trigger.addEventListener(
          "mouseleave",
          this.handleMouseLeave.bind(this),
        );
        if (this.floatingContent) {
          this.floatingContent.addEventListener(
            "mouseenter",
            this.handleMouseEnter.bind(this),
          );
          this.floatingContent.addEventListener(
            "mouseleave",
            this.handleMouseLeave.bind(this),
          );
        }
      }
      if (this.enableAria) {
        if (!this.trigger.getAttribute("aria-haspopup")) {
          this.trigger.setAttribute("aria-haspopup", "menu");
        }
        this.trigger.setAttribute("aria-expanded", "false");
      }
    }

    this.handleOutsideClick = (e) => {
      if (this.trigger && !this.trigger.contains(e.target)) {
        this.hide();
      }
    };
    document.addEventListener("click", this.handleOutsideClick);
    window.addEventListener("resize", () => this.updatePosition());
    window.addEventListener("scroll", () => this.updatePosition(), true);

    // We'll store forcedWidth if needed.
    this.forcedWidth = null;
  },

  handleClick(e) {
    e.stopPropagation();
    document
      .querySelectorAll(".dropdown-content.show-dropdown")
      .forEach((content) => {
        if (content !== this.floatingContent) {
          content.classList.remove("visible", "opacity-100", "show-dropdown");
          content.classList.add("invisible", "opacity-0");
          if (this.enableAria && content.getAttribute("aria-hidden") !== null) {
            content.setAttribute("aria-hidden", "true");
          }
          const triggerId = content.getAttribute("aria-labelledby");
          if (triggerId) {
            const otherTrigger = document.getElementById(triggerId);
            if (otherTrigger) {
              otherTrigger.setAttribute("aria-expanded", "false");
            }
          }
        }
      });
    if (
      this.floatingContent &&
      this.floatingContent.classList.contains("show-dropdown")
    ) {
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

  updated() {
    this.updatePosition();
  },

  destroyed() {
    document.removeEventListener("click", this.handleOutsideClick);
  },

  updatePosition() {
    if (!this.trigger || !this.floatingContent) return;
    const rect = this.trigger.getBoundingClientRect();
    const isRTL =
      getComputedStyle(document.documentElement).direction === "rtl";
    const gap = 4;
    const defaultPosition = this.el.dataset.position || "bottom";
    const smart = this.el.getAttribute("data-smart-position") === "true";
    let effectivePosition = defaultPosition;

    if (smart && this.floatingContent.offsetHeight) {
      const contentHeight = this.floatingContent.offsetHeight;
      const contentWidth = this.floatingContent.offsetWidth;
      const bottomSpace = window.innerHeight - rect.bottom;
      const topSpace = rect.top;
      const rightSpace = window.innerWidth - rect.right;
      const leftSpace = rect.left;
      if (defaultPosition === "bottom" || defaultPosition === "top") {
        if (
          defaultPosition === "bottom" &&
          bottomSpace < contentHeight + gap &&
          topSpace >= contentHeight + gap
        ) {
          effectivePosition = "top";
        } else if (
          defaultPosition === "top" &&
          topSpace < contentHeight + gap &&
          bottomSpace >= contentHeight + gap
        ) {
          effectivePosition = "bottom";
        }
      } else if (defaultPosition === "left" || defaultPosition === "right") {
        if (
          defaultPosition === "left" &&
          leftSpace < contentWidth + gap &&
          rightSpace >= contentWidth + gap
        ) {
          effectivePosition = "right";
        } else if (
          defaultPosition === "right" &&
          rightSpace < contentWidth + gap &&
          leftSpace >= contentWidth + gap
        ) {
          effectivePosition = "left";
        }
      }
      if (bottomSpace < contentHeight + gap && topSpace < contentHeight + gap) {
        effectivePosition = "bottom";
      }
    }

    let top, left;
    if (effectivePosition === "top") {
      top = rect.top + window.scrollY - this.floatingContent.offsetHeight - gap;
      left = (rect.left + rect.right) / 2 + window.scrollX;
      this.floatingContent.style.transform = "translateX(-50%)";
    } else if (effectivePosition === "bottom") {
      top = rect.bottom + window.scrollY + gap;
      left = (rect.left + rect.right) / 2 + window.scrollX;
      this.floatingContent.style.transform = "translateX(-50%)";
    } else if (effectivePosition === "left") {
      top = rect.top + window.scrollY;
      if (isRTL) {
        left = rect.right + window.scrollX + gap;
      } else {
        left =
          rect.left + window.scrollX - this.floatingContent.offsetWidth - gap;
      }
      this.floatingContent.style.transform = "none";
    } else if (effectivePosition === "right") {
      top = rect.top + window.scrollY;
      if (isRTL) {
        left =
          rect.left + window.scrollX - this.floatingContent.offsetWidth - gap;
      } else {
        left = rect.right + window.scrollX + gap;
      }
      this.floatingContent.style.transform = "none";
    } else {
      top = rect.bottom + window.scrollY + gap;
      left = (rect.left + rect.right) / 2 + window.scrollX;
      this.floatingContent.style.transform = "translateX(-50%)";
    }

    this.floatingContent.style.position = "absolute";
    this.floatingContent.style.top = top + "px";
    this.floatingContent.style.left = left + "px";
  },

  show() {
    if (this.floatingContent) {
      const originalTransition = this.floatingContent.style.transition;
      this.floatingContent.style.transition = "none";

      this.floatingContent.removeAttribute("hidden");
      this.floatingContent.classList.remove("invisible", "opacity-0");
      this.floatingContent.classList.add(
        "visible",
        "opacity-100",
        "show-dropdown",
      );

      this.updatePosition();

      const triggerWidth = this.trigger.offsetWidth;
      // Only force width if content is narrower than trigger.
      if (!this.forcedWidth) {
        const contentWidth = this.floatingContent.offsetWidth;
        if (contentWidth < triggerWidth) {
          this.forcedWidth = triggerWidth;
        }
      }
      if (this.forcedWidth) {
        this.floatingContent.style.width = this.forcedWidth + "px";
      } else {
        this.floatingContent.style.width = "auto";
      }

      this.floatingContent.offsetHeight; // force reflow
      this.floatingContent.style.transition = originalTransition;

      if (this.enableAria && this.trigger) {
        this.trigger.setAttribute("aria-expanded", "true");
      }
      if (
        this.enableAria &&
        this.floatingContent.getAttribute("aria-hidden") !== null
      ) {
        this.floatingContent.setAttribute("aria-hidden", "false");
      }
    }
  },

  hide() {
    if (this.floatingContent) {
      // Do not reset the width so that on hover the forced width remains.
      this.floatingContent.classList.remove(
        "visible",
        "opacity-100",
        "show-dropdown",
      );
      this.floatingContent.classList.add("invisible", "opacity-0");
      if (this.enableAria && this.trigger) {
        this.trigger.setAttribute("aria-expanded", "false");
      }
      if (
        this.enableAria &&
        this.floatingContent.getAttribute("aria-hidden") !== null
      ) {
        this.floatingContent.setAttribute("aria-hidden", "true");
      }
    }
  },
};

export default Floating;
