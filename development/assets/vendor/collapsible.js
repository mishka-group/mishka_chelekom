const Collapsible = {
  mounted() {
    this.initElements();
    this.setupEventListeners();
    this.config = this.getConfig();
    this.state = {
      openItems: new Set(),
      animating: new Set(),
      reducedMotion: window.matchMedia("(prefers-reduced-motion: reduce)")
        .matches,
    };

    this.setupAccessibility();
    this.processInitialState();
  },

  initElements() {
    this.triggers = this.el.querySelectorAll("[data-collapsible-trigger]");
    this.panels = this.el.querySelectorAll("[data-collapsible-panel]");

    // Create mapping for easy lookup
    this.itemMap = new Map();
    this.triggers.forEach((trigger) => {
      const itemId = trigger.getAttribute("data-collapsible-trigger");
      const panel = this.el.querySelector(
        `[data-collapsible-panel="${itemId}"]`,
      );
      if (panel) {
        this.itemMap.set(itemId, { trigger, panel });
      }
    });
  },

  getConfig() {
    return {
      multiple: this.el.getAttribute("data-multiple") === "true",
      collapsible: this.el.getAttribute("data-collapsible") !== "false",
      duration: parseInt(this.el.getAttribute("data-duration")) || 200,
      keepMounted: this.el.getAttribute("data-keep-mounted") === "true",
      serverEvents: this.el.getAttribute("data-server-events") === "true",
      eventHandler: this.el.getAttribute("data-event-handler"),
    };
  },

  setupAccessibility() {
    const collapsibleId =
      this.el.id || `collapsible-${Math.random().toString(36).substring(2, 9)}`;
    this.el.id = collapsibleId;

    this.itemMap.forEach((elements, itemId) => {
      const { trigger, panel } = elements;
      const headerId = `${collapsibleId}-header-${itemId}`;
      const panelId = `${collapsibleId}-panel-${itemId}`;

      trigger.setAttribute("role", "button");
      trigger.setAttribute("aria-controls", panelId);
      trigger.setAttribute("aria-expanded", "false");
      trigger.setAttribute("id", headerId);
      trigger.setAttribute("tabindex", "0");

      panel.setAttribute("role", "region");
      panel.setAttribute("aria-labelledby", headerId);
      panel.setAttribute("id", panelId);
    });
  },

  setupEventListeners() {
    this.boundHandleClick = this.handleClick.bind(this);
    this.boundHandleKeydown = this.handleKeydown.bind(this);

    this.el.addEventListener("click", this.boundHandleClick);
    this.el.addEventListener("keydown", this.boundHandleKeydown);
  },

  processInitialState() {
    const initialOpen = this.el.getAttribute("data-initial-open");

    // Clear all items first
    this.state.openItems.clear();

    // Only process if we have a non-empty initial-open value
    if (initialOpen && initialOpen.trim() !== "") {
      const openIds = initialOpen
        .split(",")
        .map((id) => id.trim())
        .filter(Boolean);
      openIds.forEach((id) => {
        // Verify the item actually exists before adding it
        if (this.itemMap.has(id)) {
          this.state.openItems.add(id);
        }
      });
    }

    // Always sync UI to ensure consistent state
    this.syncUI();
  },

  handleClick(e) {
    const trigger = e.target.closest("[data-collapsible-trigger]");
    if (!trigger || !this.el.contains(trigger)) return;

    e.preventDefault();
    const itemId = trigger.getAttribute("data-collapsible-trigger");
    this.toggle(itemId);
  },

  handleKeydown(e) {
    const trigger = e.target.closest("[data-collapsible-trigger]");
    if (!trigger || !this.el.contains(trigger)) return;

    const itemId = trigger.getAttribute("data-collapsible-trigger");
    const triggers = Array.from(this.triggers);
    const currentIndex = triggers.indexOf(trigger);

    switch (e.key) {
      case " ":
      case "Enter":
        e.preventDefault();
        this.toggle(itemId);
        break;
      case "ArrowDown":
        e.preventDefault();
        this.focusNextTrigger(currentIndex, triggers);
        break;
      case "ArrowUp":
        e.preventDefault();
        this.focusPrevTrigger(currentIndex, triggers);
        break;
      case "Home":
        e.preventDefault();
        triggers[0]?.focus();
        break;
      case "End":
        e.preventDefault();
        triggers[triggers.length - 1]?.focus();
        break;
    }
  },

  focusNextTrigger(currentIndex, triggers) {
    const nextIndex = currentIndex < triggers.length - 1 ? currentIndex + 1 : 0;
    triggers[nextIndex]?.focus();
  },

  focusPrevTrigger(currentIndex, triggers) {
    const prevIndex = currentIndex > 0 ? currentIndex - 1 : triggers.length - 1;
    triggers[prevIndex]?.focus();
  },

  toggle(itemId) {
    if (this.state.animating.has(itemId)) return;

    if (this.state.openItems.has(itemId)) {
      this.close(itemId);
    } else {
      this.open(itemId);
    }
  },

  open(itemId) {
    if (this.state.openItems.has(itemId)) return;

    if (!this.config.multiple) {
      Array.from(this.state.openItems).forEach((id) => this.close(id));
    }

    this.state.openItems.add(itemId);
    this.animatePanel(itemId, true);
    this.updateAria(itemId, true);
    this.pushServerEvent("collapsible_open", itemId);
  },

  close(itemId) {
    if (!this.state.openItems.has(itemId)) return;
    if (!this.config.collapsible && this.state.openItems.size === 1) return;

    this.state.openItems.delete(itemId);
    this.animatePanel(itemId, false);
    this.updateAria(itemId, false);
    this.pushServerEvent("collapsible_close", itemId);
  },

  animatePanel(itemId, opening) {
    const elements = this.itemMap.get(itemId);
    if (!elements) return;

    const { panel } = elements;
    const content = panel.querySelector("[data-collapsible-content]") || panel;

    if (this.state.reducedMotion) {
      content.style.maxHeight = opening ? "none" : "0";
      content.style.overflow = opening ? "visible" : "hidden";
      return;
    }

    this.state.animating.add(itemId);

    if (opening) {
      content.style.overflow = "hidden";
      content.style.maxHeight = "0";

      requestAnimationFrame(() => {
        const height = content.scrollHeight;
        content.style.maxHeight = `${height}px`;

        setTimeout(() => {
          if (this.state.openItems.has(itemId)) {
            content.style.maxHeight = "none";
            content.style.overflow = "visible";
          }
          this.state.animating.delete(itemId);
        }, this.config.duration);
      });
    } else {
      const height = content.scrollHeight;
      content.style.overflow = "hidden";
      content.style.maxHeight = `${height}px`;

      requestAnimationFrame(() => {
        content.style.maxHeight = "0";

        setTimeout(() => {
          this.state.animating.delete(itemId);
        }, this.config.duration);
      });
    }
  },

  updateAria(itemId, expanded) {
    const elements = this.itemMap.get(itemId);
    if (!elements) return;

    elements.trigger.setAttribute("aria-expanded", expanded.toString());
  },

  syncUI() {
    this.itemMap.forEach((elements, itemId) => {
      const isOpen = this.state.openItems.has(itemId);
      const { panel } = elements;
      const content =
        panel.querySelector("[data-collapsible-content]") || panel;

      this.updateAria(itemId, isOpen);

      if (isOpen) {
        content.style.maxHeight = "none";
        content.style.overflow = "visible";
      } else {
        content.style.maxHeight = "0";
        content.style.overflow = "hidden";
      }
    });
  },

  pushServerEvent(event, itemId) {
    if (!this.config.serverEvents) return;

    const payload = {
      component_id: this.el.id,
      item_id: itemId,
      action: event === "collapsible_open" ? "open" : "close",
      open_ids: Array.from(this.state.openItems),
    };

    if (this.config.eventHandler) {
      this.pushEvent(this.config.eventHandler, payload);
    } else {
      this.pushEvent(event, payload);
    }
  },

  // Public API
  getOpenIds() {
    return Array.from(this.state.openItems);
  },

  openItem(itemId) {
    this.open(itemId);
  },

  closeItem(itemId) {
    this.close(itemId);
  },

  toggleItem(itemId) {
    this.toggle(itemId);
  },

  updated() {
    // Re-initialize elements in case DOM changed
    this.initElements();
    // Process any changes to initial state
    this.processInitialState();
  },

  destroyed() {
    if (this.el && this.boundHandleClick) {
      this.el.removeEventListener("click", this.boundHandleClick);
      this.el.removeEventListener("keydown", this.boundHandleKeydown);
    }
    this.boundHandleClick = null;
    this.boundHandleKeydown = null;
  },
};

export default Collapsible;
