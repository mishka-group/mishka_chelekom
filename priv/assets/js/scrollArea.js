/**
 * ScrollArea Hook for Phoenix LiveView
 *
 * This hook provides custom scroll area functionality for Phoenix LiveView components.
 * It updates only the thumb positions based on the viewport dimensions and scroll position.
 * The thumb sizes remain fixed. The scrollbar container is hidden only when the content size
 * exactly matches the viewport size.
 *
 * @module ScrollArea
 */

let ScrollArea = {
  mounted() {
    const { el } = this;
    this.viewport = el.querySelector(".scroll-viewport");
    this.thumbY = el.querySelector(".thumb-y");
    this.thumbX = el.querySelector(".thumb-x");
    this.scrollbarY = el.querySelector(".scrollbar-y");
    this.scrollbarX = el.querySelector(".scrollbar-x");

    // If viewport is not present, hide scrollbars and exit early
    if (!this.viewport) {
      if (this.scrollbarY) this.scrollbarY.style.display = "none";
      if (this.scrollbarX) this.scrollbarX.style.display = "none";
      return;
    }

    // Cache arrow functions for performance and cleanup
    this.updateThumbBound = () => this.updateThumb();
    this.handleResizeBound = () => this.updateThumb();

    if (this.viewport) {
      this.viewport.addEventListener("scroll", this.updateThumbBound);
    }
    window.addEventListener("resize", this.handleResizeBound);

    if (this.thumbY) {
      this.onThumbYPointerDownBound = (e) => this.onThumbYPointerDown(e);
      this.thumbY.addEventListener(
        "pointerdown",
        this.onThumbYPointerDownBound,
      );
    }
    if (this.thumbX) {
      this.onThumbXPointerDownBound = (e) => this.onThumbXPointerDown(e);
      this.thumbX.addEventListener(
        "pointerdown",
        this.onThumbXPointerDownBound,
      );
    }

    this.resizeObserver = new ResizeObserver(() => {
      this.updateThumb();
    });

    this.resizeObserver.observe(this.viewport);
  },

  updateAxis({ contentSize, clientSize, scrollPos, thumb, scrollbar, axis }) {
    if (contentSize <= clientSize) {
      if (scrollbar) scrollbar.style.display = "none";
      return;
    }
    if (scrollbar) scrollbar.style.display = "block";
    if (thumb) {
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

  updateThumb() {
    if (!this.viewport) return;
    const {
      scrollTop,
      scrollHeight,
      clientHeight,
      scrollLeft,
      scrollWidth,
      clientWidth,
    } = this.viewport;

    this.updateAxis({
      contentSize: scrollHeight,
      clientSize: clientHeight,
      scrollPos: scrollTop,
      thumb: this.thumbY,
      scrollbar: this.scrollbarY,
      axis: "vertical",
    });

    this.updateAxis({
      contentSize: scrollWidth,
      clientSize: clientWidth,
      scrollPos: scrollLeft,
      thumb: this.thumbX,
      scrollbar: this.scrollbarX,
      axis: "horizontal",
    });
  },

  onThumbYPointerDown(e) {
    e.preventDefault();
    // Set dragging state to true for vertical thumb
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
    const { scrollHeight, clientHeight } = this.viewport;
    const thumbHeight = (this.thumbY && this.thumbY.offsetHeight) || 20;
    const maxScroll = scrollHeight - clientHeight;
    const maxThumb = clientHeight - thumbHeight;
    const newScrollTop = Math.max(
      0,
      Math.min(this.startScrollTop + dy * (maxScroll / maxThumb), maxScroll),
    );
    this.viewport.scrollTop = newScrollTop;
  },

  onThumbYPointerUp() {
    // Reset dragging state for vertical thumb
    this.isDraggingY = false;
    if (this.scrollbarY) {
      this.scrollbarY.style.visibility = "";
    }
    document.removeEventListener("pointermove", this.boundThumbYPointerMove);
    document.removeEventListener("pointerup", this.boundThumbYPointerUp);
  },

  onThumbXPointerDown(e) {
    e.preventDefault();
    // Set dragging state to true for horizontal thumb
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
    const { scrollWidth, clientWidth } = this.viewport;
    const thumbWidth = (this.thumbX && this.thumbX.offsetWidth) || 20;
    const maxScroll = scrollWidth - clientWidth;
    const maxThumb = clientWidth - thumbWidth;
    const newScrollLeft = Math.max(
      0,
      Math.min(this.startScrollLeft + dx * (maxScroll / maxThumb), maxScroll),
    );
    this.viewport.scrollLeft = newScrollLeft;
  },

  onThumbXPointerUp() {
    // Reset dragging state for horizontal thumb
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
    this.thumbY?.removeEventListener(
      "pointerdown",
      this.onThumbYPointerDownBound,
    );
    this.thumbX?.removeEventListener(
      "pointerdown",
      this.onThumbXPointerDownBound,
    );
  },
};

export default ScrollArea;
