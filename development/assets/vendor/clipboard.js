/**
 * Enhanced Clipboard Component
 *
 * A reusable component that provides clipboard functionality with improved:
 * - Performance: Optimized event handling and DOM operations
 * - Security: Better sanitization and error handling
 * - Organization: Cleaner code structure with the original object pattern
 * - Accessibility: Enhanced ARIA support
 */
const Clipboard = {
  /**
   * Initialize the clipboard component
   */
  mounted() {
    // Prevent double initialization
    if (this._alreadyMounted) return;
    this._alreadyMounted = true;
    // Setup initial state
    this.initializeConfig();
    this.initializeElements();
    this.setupEventListeners();
  },

  /**
   * Initialize and cache DOM elements
   */
  initializeElements() {
    this.statusEl = this.el.querySelector(".clipboard-status");
    this.triggerWrapper = this.el.querySelector(".clipboard-trigger");
    this.triggerEl =
      this.triggerWrapper?.firstElementChild || this.triggerWrapper;

    if (!this.triggerEl) return;

    // Setup accessibility attributes
    if (!this.triggerEl.getAttribute("tabindex")) {
      this.triggerEl.setAttribute("tabindex", "0");
    }

    if (!this.triggerEl.getAttribute("role")) {
      this.triggerEl.setAttribute("role", "button");
    }

    if (!this.triggerEl.getAttribute("aria-label")) {
      this.triggerEl.setAttribute("aria-label", "Copy to clipboard");
    }

    // Save original content for restoring later
    this.labelEl = this.triggerEl.querySelector(".clipboard-label");
    if (this.labelEl) {
      this.originalLabel = this.labelEl.textContent;
    } else {
      const childNodes = Array.from(this.triggerEl.childNodes);
      this.originalTextNode = childNodes.find(
        (node) =>
          node.nodeType === Node.TEXT_NODE && node.textContent.trim() !== "",
      );

      if (this.originalTextNode) {
        this.originalText = this.originalTextNode.textContent;
      } else {
        this.originalLabelHTML = this.triggerEl.innerHTML;
      }
    }
  },

  /**
   * Clean up resources when component is removed
   */
  destroyed() {
    this.removeEventListeners();
    this.clearTimers();
  },

  /**
   * Parse configuration from data attributes
   */
  initializeConfig() {
    const { dataset } = this.el;

    // Parse timeout with validation
    const timeoutValue = parseInt(dataset.timeout, 10);
    this.timeout =
      !isNaN(timeoutValue) && timeoutValue > 0 ? timeoutValue : 2000;

    // Parse and sanitize configuration
    this.successClass = this.sanitizeClassName(
      dataset.successClass || "clipboard-success",
    );
    this.errorClass = this.sanitizeClassName(
      dataset.errorClass || "clipboard-error",
    );
    this.successText = this.sanitizeText(dataset.copySuccessText || "Copied!");
    this.errorText = this.sanitizeText(dataset.copyErrorText || "Copy failed");

    // Parse boolean values
    this.dynamicLabel = String(dataset.dynamicLabel).toLowerCase() === "true";
  },

  /**
   * Set up event listeners
   */
  setupEventListeners() {
    if (!this.triggerEl) return;

    // Store bound handlers for proper cleanup
    this.handleCopyClick = this.handleCopyClick.bind(this);
    this.handleCopyKeydown = this.handleCopyKeydown.bind(this);

    this.triggerEl.addEventListener("click", this.handleCopyClick);
    this.triggerEl.addEventListener("keydown", this.handleCopyKeydown);
  },

  /**
   * Remove event listeners
   */
  removeEventListeners() {
    if (!this.triggerEl) return;

    if (this.handleCopyClick) {
      this.triggerEl.removeEventListener("click", this.handleCopyClick);
    }

    if (this.handleCopyKeydown) {
      this.triggerEl.removeEventListener("keydown", this.handleCopyKeydown);
    }
  },

  /**
   * Clear any active timers
   */
  clearTimers() {
    if (this.statusReset) {
      clearTimeout(this.statusReset);
      this.statusReset = null;
    }
  },

  /**
   * Sanitize CSS class names for security
   * @param {string} classNames - Space-separated list of class names
   * @returns {string} - Sanitized class names
   */
  sanitizeClassName(classNames) {
    if (!classNames || typeof classNames !== "string") {
      return "clipboard-success";
    }

    return (
      classNames
        .split(" ")
        .filter((name) => /^[a-zA-Z0-9_\-]+$/.test(name))
        .join(" ") || "clipboard-success"
    );
  },

  /**
   * Sanitize text content
   * @param {string} text - Text to sanitize
   * @returns {string} - Sanitized text
   */
  sanitizeText(text) {
    if (!text || typeof text !== "string") {
      return "";
    }

    // Limit length and escape sensitive characters
    return text
      .slice(0, 100)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  },

  /**
   * Handle click events on the trigger element
   * @param {Event} event - The click event
   */
  handleCopyClick(event) {
    event.preventDefault();
    event.stopPropagation();
    this.handleCopy();
  },

  /**
   * Handle keyboard events for accessibility
   * @param {KeyboardEvent} event - The keyboard event
   */
  handleCopyKeydown(event) {
    // Handle Enter or Space key for accessibility
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      this.handleCopy();
    }
  },

  /**
   * Main copy operation handler
   * @returns {Promise<boolean>} - Success status
   */
  async handleCopy() {
    const text = this.getTextToCopy();
    if (!text) {
      this.showStatus(false);
      return false;
    }

    try {
      // Use modern Clipboard API with fallback
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text);
        this.showStatus(true);
        return true;
      } else {
        return this.fallbackCopyTextToClipboard(text);
      }
    } catch (error) {
      console.error("Clipboard operation failed:", error);
      this.showStatus(false);
      return false;
    }
  },

  /**
   * Legacy fallback for clipboard operations
   * @param {string} text - Text to copy
   * @returns {boolean} - Success status
   */
  fallbackCopyTextToClipboard(text) {
    const textArea = document.createElement("textarea");
    textArea.value = text;

    // Position off-screen but maintain accessibility
    Object.assign(textArea.style, {
      position: "absolute",
      left: "-9999px",
      top: "-9999px",
      opacity: "0",
    });

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    let succeeded = false;
    try {
      succeeded = document.execCommand("copy");
    } catch (error) {
      console.error("Fallback clipboard operation failed:", error);
    } finally {
      document.body.removeChild(textArea);
    }

    this.showStatus(succeeded);
    return succeeded;
  },

  /**
   * Get the text to be copied based on configuration
   * @returns {string|null} - Text to copy or null if not found
   */
  getTextToCopy() {
    const { dataset } = this.el;

    // Priority 1: Explicit text in data attribute
    if (dataset.clipboardText) {
      return dataset.clipboardText;
    }

    // Priority 2: Text from targeted element via selector
    if (dataset.targetSelector) {
      try {
        const el = document.querySelector(dataset.targetSelector);
        return el ? this.extractText(el) : null;
      } catch (error) {
        console.error("Error selecting target element:", error);
        return null;
      }
    }

    // Priority 3: Text from designated content element
    const contentEl = this.el.querySelector(".clipboard-content");
    return contentEl ? this.extractText(contentEl) : null;
  },

  /**
   * Extract text content from an element based on its type
   * @param {HTMLElement} el - Element to extract text from
   * @returns {string|null} - Extracted text or null
   */
  extractText(el) {
    if (!el) return null;

    // Handle form elements
    if (el.tagName === "INPUT" || el.tagName === "TEXTAREA") {
      return el.value;
    }

    // Handle code blocks with priority
    const code = el.querySelector("pre, code");
    if (code) {
      return code.textContent;
    }

    // Get clean text content without excessive whitespace
    return el.textContent.replace(/\s+/g, " ").trim();
  },

  /**
   * Update UI to show operation status
   * @param {boolean} success - Whether operation succeeded
   */
  showStatus(success) {
    const trigger = this.triggerEl;
    const status = this.statusEl;

    // Update trigger classes
    if (trigger) {
      this.updateTriggerClasses(trigger, success);

      trigger.setAttribute("aria-disabled", "true");
      trigger.setAttribute("tabindex", "-1");

      // Update label if configured
      if (this.dynamicLabel) {
        this.updateLabel(success);
      }
    }

    // Update status element
    if (status) {
      status.textContent = success ? this.successText : this.errorText;
      status.setAttribute("aria-hidden", "false");

      // Announce to screen readers
      this.announceToScreenReader(success ? this.successText : this.errorText);
    }

    // Schedule reset after timeout
    this.clearTimers();
    this.statusReset = setTimeout(() => this.resetStatus(), this.timeout);
  },

  /**
   * Update CSS classes on trigger element
   * @param {HTMLElement} trigger - Trigger element
   * @param {boolean} success - Success status
   */
  updateTriggerClasses(trigger, success) {
    // Remove all status classes
    const allClasses = [
      ...this.successClass.split(" "),
      ...this.errorClass.split(" "),
    ];

    allClasses.forEach((cls) => {
      if (cls) trigger.classList.remove(cls);
    });

    // Add appropriate status classes
    const newClasses = (success ? this.successClass : this.errorClass).split(
      " ",
    );
    newClasses.forEach((cls) => {
      if (cls) trigger.classList.add(cls);
    });
  },

  /**
   * Update label text based on operation status
   * @param {boolean} success - Success status
   */
  updateLabel(success) {
    const statusText = success ? this.successText : this.errorText;

    if (this.labelEl) {
      this.labelEl.textContent = statusText;
    } else if (this.originalTextNode) {
      this.originalTextNode.textContent = statusText;
    } else {
      this.triggerEl.innerHTML = statusText;
    }
  },

  /**
   * Announce status to screen readers
   * @param {string} message - Message to announce
   */
  announceToScreenReader(message) {
    let liveRegion = document.getElementById("clipboard-live-region");

    if (!liveRegion) {
      liveRegion = document.createElement("div");
      liveRegion.id = "clipboard-live-region";
      liveRegion.setAttribute("aria-live", "polite");
      liveRegion.setAttribute("aria-atomic", "true");
      liveRegion.className = "sr-only";

      Object.assign(liveRegion.style, {
        position: "absolute",
        width: "1px",
        height: "1px",
        padding: "0",
        margin: "-1px",
        overflow: "hidden",
        clip: "rect(0, 0, 0, 0)",
        whiteSpace: "nowrap",
        border: "0",
      });

      document.body.appendChild(liveRegion);
    }

    liveRegion.textContent = message;
  },

  /**
   * Reset UI state after timeout
   */
  resetStatus() {
    const trigger = this.triggerEl;
    const status = this.statusEl;

    // Reset status display
    if (status) {
      status.textContent = "";
      status.setAttribute("aria-hidden", "true");
    }

    // Remove all status classes
    if (trigger) {
      trigger.removeAttribute("aria-disabled");
      trigger.setAttribute("tabindex", "0");

      const allClasses = [
        ...this.successClass.split(" "),
        ...this.errorClass.split(" "),
      ];

      allClasses.forEach((cls) => {
        if (cls) trigger.classList.remove(cls);
      });
    }

    // Reset label to original
    if (this.dynamicLabel) {
      if (this.labelEl && this.originalLabel) {
        this.labelEl.textContent = this.originalLabel;
      } else if (this.originalTextNode && this.originalText) {
        this.originalTextNode.textContent = this.originalText;
      } else if (this.originalLabelHTML) {
        this.triggerEl.innerHTML = this.originalLabelHTML;
      }
    }

    // Clear screen reader announcement
    let liveRegion = document.getElementById("clipboard-live-region");
    if (liveRegion) {
      liveRegion.textContent = "";
    }
  },
};

export default Clipboard;
