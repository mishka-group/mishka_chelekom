/**
 * ScrollArea Hook for Phoenix LiveView
 *
 * This hook provides custom scroll area functionality for Phoenix LiveView components.
 * It updates only the thumb positions based on the viewport dimensions and scroll position.
 * The thumb sizes remain fixed. When the content overflows the scroll-area-wrapper,
 * the corresponding scrollbar is shown; if not, it remains hidden.
 *
 * @module ScrollArea
 */

let ScrollArea = {
  mounted() {
    const { el } = this;
    // el is the scroll-area-wrapper
    this.viewport = el.querySelector(".scroll-viewport");
    this.thumbY = el.querySelector(".thumb-y");
    this.thumbX = el.querySelector(".thumb-x");
    this.scrollbarY = el.querySelector(".scrollbar-y");
    this.scrollbarX = el.querySelector(".scrollbar-x");

    if (!this.viewport) {
      // If viewport is missing, hide scrollbars and exit
      if (this.scrollbarY) this.scrollbarY.style.display = "none";
      if (this.scrollbarX) this.scrollbarX.style.display = "none";
      return;
    }

    // Functions to update thumb positions on scroll/resize
    this.updateThumbBound = () => this.updateThumb();
    this.handleResizeBound = () => this.updateThumb();

    this.viewport.addEventListener("scroll", this.updateThumbBound);
    window.addEventListener("resize", this.handleResizeBound);

    // Pointer down for vertical thumb
    if (this.thumbY) {
      this.onThumbYPointerDownBound = (e) => this.onThumbYPointerDown(e);
      this.thumbY.addEventListener("pointerdown", this.onThumbYPointerDownBound);
    }
    // Pointer down for horizontal thumb
    if (this.thumbX) {
      this.onThumbXPointerDownBound = (e) => this.onThumbXPointerDown(e);
      this.thumbX.addEventListener("pointerdown", this.onThumbXPointerDownBound);
    }

    // Use ResizeObserver to recalc thumbs if content changes
    this.resizeObserver = new ResizeObserver(() => {
      this.updateThumb();
    });
    this.resizeObserver.observe(this.viewport);

    // Initial update
    this.updateThumb();
  },

  /**
   * Update scrollbar and thumb for a given axis.
   * If the content size is less than or equal to the scroll-area-wrapper size, hide the scrollbar.
   */
  updateAxis({ contentSize, clientSize, scrollPos, thumb, scrollbar, axis }) {
    if (contentSize <= clientSize) {
      if (scrollbar) {
        scrollbar.style.display = "none";
      }
      if (thumb) {
        thumb.style.transform =
          axis === "vertical" ? "translateY(0px)" : "translateX(0px)";
        thumb.style.opacity = "0";
      }
      return;
    }

    // When overflow exists, show scrollbar and update thumb position.
    if (scrollbar) {
      scrollbar.style.display = "block";
    }
    if (thumb) {
      thumb.style.opacity = "1"; // ensure visible
      const thumbSize =
        axis === "vertical"
          ? thumb.offsetHeight || 20
          : thumb.offsetWidth || 20;
      const maxScroll = contentSize - clientSize;
      const maxThumb = clientSize - thumbSize;
      const pos = (scrollPos / maxScroll) * maxThumb;
      thumb.style.transform =
        axis === "vertical" ? `translateY(${pos}px)` : `translateX(${pos}px)`;
    }
  },

  /**
   * Update thumb positions by comparing the inner content size
   * (from .scroll-content) against the scroll-area-wrapper dimensions.
   */
  updateThumb() {
    if (!this.viewport) return;
    // Query the scroll-content inside the viewport.
    const scrollContent = this.viewport.querySelector(".scroll-content");

    // For vertical axis:
    // contentHeight is taken from the scroll-content element, if available.
    const contentHeight = scrollContent
      ? scrollContent.scrollHeight
      : this.viewport.scrollHeight;
    // Use the height of the scroll-area-wrapper (this.el)
    const wrapperHeight = this.el.clientHeight;
    const scrollTop = this.viewport.scrollTop;
    this.updateAxis({
      contentSize: contentHeight,
      clientSize: wrapperHeight,
      scrollPos: scrollTop,
      thumb: this.thumbY,
      scrollbar: this.scrollbarY,
      axis: "vertical",
    });

    // For horizontal axis:
    const contentWidth = scrollContent
      ? scrollContent.scrollWidth
      : this.viewport.scrollWidth;
    const wrapperWidth = this.el.clientWidth;
    const scrollLeft = this.viewport.scrollLeft;
    this.updateAxis({
      contentSize: contentWidth,
      clientSize: wrapperWidth,
      scrollPos: scrollLeft,
      thumb: this.thumbX,
      scrollbar: this.scrollbarX,
      axis: "horizontal",
    });
  },

  // Drag logic for vertical thumb
  onThumbYPointerDown(e) {
    e.preventDefault();
    this.isDraggingY = true;
    if (this.scrollbarY) {
      this.scrollbarY.style.visibility = "visible";
    }
    this.startY = e.clientY;
    this.startScrollTop = this.viewport.scrollTop;
    this.boundThumbYPointerMove = (e) => this.onThumbYPointerMove(e);
    this.boundThumbYPointerUp = () => this.onThumbYPointerUp();
    document.addEventListener("pointermove", this.boundThumbYPointerMove);
    document.addEventListener("pointerup", this.boundThumbYPointerUp);
  },

  onThumbYPointerMove(e) {
    e.preventDefault();
    const dy = e.clientY - this.startY;
    const { scrollHeight } = this.viewport;
    // Use the wrapper height for calculations
    const wrapperHeight = this.el.clientHeight;
    const thumbHeight = (this.thumbY && this.thumbY.offsetHeight) || 20;
    const maxScroll = (scrollHeight > wrapperHeight) ? scrollHeight - wrapperHeight : 0;
    const maxThumb = wrapperHeight - thumbHeight;
    const newScrollTop = Math.max(
      0,
      Math.min(this.startScrollTop + dy * (maxScroll / maxThumb), maxScroll)
    );
    this.viewport.scrollTop = newScrollTop;
  },

  onThumbYPointerUp() {
    this.isDraggingY = false;
    if (this.scrollbarY) {
      this.scrollbarY.style.visibility = "";
    }
    document.removeEventListener("pointermove", this.boundThumbYPointerMove);
    document.removeEventListener("pointerup", this.boundThumbYPointerUp);
  },

  // Drag logic for horizontal thumb
  onThumbXPointerDown(e) {
    e.preventDefault();
    this.isDraggingX = true;
    if (this.scrollbarX) {
      this.scrollbarX.style.visibility = "visible";
    }
    this.startX = e.clientX;
    this.startScrollLeft = this.viewport.scrollLeft;
    this.boundThumbXPointerMove = (e) => this.onThumbXPointerMove(e);
    this.boundThumbXPointerUp = () => this.onThumbXPointerUp();
    document.addEventListener("pointermove", this.boundThumbXPointerMove);
    document.addEventListener("pointerup", this.boundThumbXPointerUp);
  },

  onThumbXPointerMove(e) {
    e.preventDefault();
    const dx = e.clientX - this.startX;
    const { scrollWidth } = this.viewport;
    const wrapperWidth = this.el.clientWidth;
    const thumbWidth = (this.thumbX && this.thumbX.offsetWidth) || 20;
    const maxScroll = (scrollWidth > wrapperWidth) ? scrollWidth - wrapperWidth : 0;
    const maxThumb = wrapperWidth - thumbWidth;
    const newScrollLeft = Math.max(
      0,
      Math.min(this.startScrollLeft + dx * (maxScroll / maxThumb), maxScroll)
    );
    this.viewport.scrollLeft = newScrollLeft;
  },

  onThumbXPointerUp() {
    this.isDraggingX = false;
    if (this.scrollbarX) {
      this.scrollbarX.style.visibility = "";
    }
    document.removeEventListener("pointermove", this.boundThumbXPointerMove);
    document.removeEventListener("pointerup", this.boundThumbXPointerUp);
  },

  destroyed() {
    this.viewport?.removeEventListener("scroll", this.updateThumbBound);
    window.removeEventListener("resize", this.handleResizeBound);
    this.thumbY?.removeEventListener("pointerdown", this.onThumbYPointerDownBound);
    this.thumbX?.removeEventListener("pointerdown", this.onThumbXPointerDownBound);
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
  },
};

export default ScrollArea;
