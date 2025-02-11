/**
 * @fileoverview
 * The `ScrollArea` Phoenix LiveView hook provides custom scrolling behavior
 * for an element and its content. It syncs scroll positions across sessions,
 * displays/hides scrollbars based on overflow, and handles both touch and
 * mouse-based interactions for a smoother, more intuitive user experience.
 *
 * Extended to demonstrate `destroyed()` lifecycle, which removes all event
 * listeners that were attached in `mounted()`.
 */

const ScrollArea = {
  mounted() {
    const { el } = this;
    // Main elements
    this.viewport = el.querySelector(".scroll-viewport");
    this.content = el.querySelector(".scroll-content");
    this.thumbY = el.querySelector(".thumb-y");
    this.thumbX = el.querySelector(".thumb-x");
    this.trackY = el.querySelector(".scrollbar-y");
    this.trackX = el.querySelector(".scrollbar-x");

    // Early exit if essential elements are missing
    if (!this.viewport || !this.content) return;

    // Restore scroll positions
    this.viewport.scrollTop = parseInt(
      sessionStorage.getItem("scrollTop") || 0,
      10,
    );
    this.viewport.scrollLeft = parseInt(
      sessionStorage.getItem("scrollLeft") || 0,
      10,
    );

    // ========================
    // BIND LISTENER REFERENCES
    // ========================
    this.boundOnScroll = this.onScroll.bind(this);
    this.boundKeydown = this.handleKeyboardScroll.bind(this);
    this.boundKeyup = this.stopKeyboardScroll.bind(this);
    this.boundTouchstart = this.onTouchstart.bind(this);
    this.boundTouchmove = this.onTouchmove.bind(this);

    // Attach event listeners
    this.viewport.addEventListener("scroll", this.boundOnScroll);
    this.viewport.addEventListener("keydown", this.boundKeydown);
    this.viewport.addEventListener("keyup", this.boundKeyup);
    this.viewport.addEventListener("touchstart", this.boundTouchstart, {
      passive: false,
    });
    this.viewport.addEventListener("touchmove", this.boundTouchmove, {
      passive: false,
    });

    // Enable dragging on scrollbar thumbs
    this.initThumbDrag("Y");
    this.initThumbDrag("X");

    // Defer initial measurement so the DOM is rendered
    requestAnimationFrame(() => {
      requestAnimationFrame(() => this.updateThumbPosition());
    });
  },

  // Phoenix LiveView calls this whenever the DOM node is patched
  updated() {
    requestAnimationFrame(() => this.updateThumbPosition());
  },

  // Called when the DOM node is removed or replaced — perfect for cleanup!
  destroyed() {
    // Remove main viewport listeners
    if (this.viewport) {
      this.viewport.removeEventListener("scroll", this.boundOnScroll);
      this.viewport.removeEventListener("keydown", this.boundKeydown);
      this.viewport.removeEventListener("keyup", this.boundKeyup);
      this.viewport.removeEventListener("touchstart", this.boundTouchstart);
      this.viewport.removeEventListener("touchmove", this.boundTouchmove);
    }

    // Remove any global mousemove/mouseup listeners for the thumbs
    if (this._thumbMouseMove) {
      document.removeEventListener("mousemove", this._thumbMouseMove);
      document.removeEventListener("mouseup", this._thumbMouseUp);
    }
    if (this._thumbMouseMoveX) {
      document.removeEventListener("mousemove", this._thumbMouseMoveX);
      document.removeEventListener("mouseup", this._thumbMouseUpX);
    }

    // If we have an ongoing scroll interval, clear it
    if (this.scrollInterval) {
      clearInterval(this.scrollInterval);
      this.scrollInterval = null;
    }
  },

  // ==============
  // HELPER METHODS
  // ==============
  onScroll() {
    this.updateThumbPosition();
    this.saveScrollPosition();
  },

  updateThumbPosition() {
    if (!this.viewport || !this.content) return;

    const {
      scrollTop,
      scrollLeft,
      clientHeight: vh,
      clientWidth: vw,
    } = this.viewport;

    const { scrollHeight: sh, scrollWidth: sw } = this.content;

    // Check overflow
    const hasOverflowY = sh > vh;
    const hasOverflowX = sw > vw;

    // ====== VERTICAL SCROLLBAR ======
    if (this.trackY && this.thumbY) {
      if (hasOverflowY) {
        this.trackY.style.display = "";
        this.thumbY.style.display = "";

        const thumbH = this.thumbY.clientHeight;
        const maxY = vh - thumbH;
        const y = (scrollTop / (sh - vh)) * maxY;
        this.thumbY.style.transform = `translateY(${y}px)`;
      } else {
        this.trackY.style.display = "none";
        this.thumbY.style.display = "none";
      }
    }

    // ====== HORIZONTAL SCROLLBAR ======
    if (this.trackX && this.thumbX) {
      if (hasOverflowX) {
        this.trackX.style.display = "";
        this.thumbX.style.display = "";

        const thumbW = this.thumbX.clientWidth;
        const maxX = vw - thumbW;
        const x = (scrollLeft / (sw - vw)) * maxX;
        this.thumbX.style.transform = `translateX(${x}px)`;
      } else {
        this.trackX.style.display = "none";
        this.thumbX.style.display = "none";
      }
    }
  },

  saveScrollPosition() {
    const { scrollTop, scrollLeft } = this.viewport;
    sessionStorage.setItem("scrollTop", scrollTop);
    sessionStorage.setItem("scrollLeft", scrollLeft);
  },

  handleKeyboardScroll(e) {
    // If we're already scrolling, skip
    if (this.scrollInterval) return;

    let step = 10;
    const acceleration = 5;
    const maxSpeed = 100;

    this.scrollInterval = setInterval(() => {
      const { clientHeight, scrollBy } = this.viewport;
      switch (e.key) {
        case "ArrowUp":
          scrollBy({ top: -step });
          break;
        case "ArrowDown":
          scrollBy({ top: step });
          break;
        case "ArrowLeft":
          scrollBy({ left: -step });
          break;
        case "ArrowRight":
          scrollBy({ left: step });
          break;
        case "PageUp":
          scrollBy({ top: -clientHeight });
          break;
        case "PageDown":
          scrollBy({ top: clientHeight });
          break;
        default:
          break;
      }
      this.updateThumbPosition();
      if (step < maxSpeed) step += acceleration;
    }, 50);
  },

  stopKeyboardScroll() {
    clearInterval(this.scrollInterval);
    this.scrollInterval = null;
  },

  initThumbDrag(axis) {
    const thumb = axis === "Y" ? this.thumbY : this.thumbX;
    if (!thumb) return;

    thumb.addEventListener("mousedown", (e) => {
      e.preventDefault();

      const isVertical = axis === "Y";
      const startCoord = isVertical ? e.clientY : e.clientX;
      const startScroll = isVertical
        ? this.viewport.scrollTop
        : this.viewport.scrollLeft;

      // We'll store these so we can remove them in `destroyed()`
      const onMouseMove = (evt) => {
        const delta = (isVertical ? evt.clientY : evt.clientX) - startCoord;
        const ratio =
          delta /
          (isVertical ? this.viewport.clientHeight : this.viewport.clientWidth);
        const contentSize = isVertical
          ? this.content.scrollHeight
          : this.content.scrollWidth;

        if (isVertical) {
          this.viewport.scrollTop = startScroll + ratio * contentSize;
        } else {
          this.viewport.scrollLeft = startScroll + ratio * contentSize;
        }
        this.updateThumbPosition();
      };

      const onMouseUp = () => {
        document.removeEventListener("mousemove", onMouseMove);
        document.removeEventListener("mouseup", onMouseUp);
      };

      // For cleanup in destroyed()
      if (isVertical) {
        this._thumbMouseMove = onMouseMove;
        this._thumbMouseUp = onMouseUp;
      } else {
        this._thumbMouseMoveX = onMouseMove;
        this._thumbMouseUpX = onMouseUp;
      }

      document.addEventListener("mousemove", onMouseMove);
      document.addEventListener("mouseup", onMouseUp);
    });
  },

  onTouchstart(e) {
    const touch = e.touches[0];
    this.startY = touch.clientY;
    this.startX = touch.clientX;
    this.startScrollTop = this.viewport.scrollTop;
    this.startScrollLeft = this.viewport.scrollLeft;
  },

  onTouchmove(e) {
    const touch = e.touches[0];
    const deltaY = touch.clientY - this.startY;
    const deltaX = touch.clientX - this.startX;

    this.viewport.scrollTop = this.startScrollTop - deltaY;
    this.viewport.scrollLeft = this.startScrollLeft - deltaX;
    this.updateThumbPosition();
    e.preventDefault();
  },
};

export default ScrollArea;
