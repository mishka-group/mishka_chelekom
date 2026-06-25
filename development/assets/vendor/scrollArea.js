/**
 * ScrollArea Hook for Phoenix LiveView — custom scrollbar engine (Base UI parity).
 *
 * Hides the native scrollbar and drives a custom `[data-part="thumb"]` inside a
 * `[data-part="scrollbar"]`: the thumb is sized PROPORTIONALLY to the content (exposed as the
 * `--scroll-area-thumb-height/width` CSS vars), positioned by transform as the viewport scrolls, and
 * draggable. A scrollbar is hidden when its axis doesn't overflow.
 *
 * Mirrors Base UI's state on the root + viewport + scrollbar(s) + content:
 *   data-scrolling                       — set briefly while scrolling
 *   data-hovering   (scrollbar)          — while the pointer is over the root
 *   data-has-overflow-x / -y             — when that axis overflows
 *   data-overflow-{x,y}-{start,end}      — when scrolled away from that edge
 * and exposes the distance from each edge as `--scroll-area-overflow-{x,y}-{start,end}` (px) so a
 * consumer can fade the edges (the Base UI "scroll fade" demo).
 *
 * Element lookup prefers `data-part` (headless); it falls back to the styled component's class names
 * (`.scroll-viewport`, `.thumb-y/x`, `.scrollbar-y/x`) so the existing styled scroll area keeps working.
 */

let ScrollArea = {
  mounted() {
    const { el } = this;
    this.viewport = q(el, '[data-part="viewport"]', ".scroll-viewport");
    this.content = this.viewport && this.viewport.querySelector('[data-part="content"]');
    this.scrollbarY = q(el, '[data-part="scrollbar"][data-orientation="vertical"]', ".scrollbar-y");
    this.scrollbarX = q(el, '[data-part="scrollbar"][data-orientation="horizontal"]', ".scrollbar-x");
    this.thumbY = (this.scrollbarY && this.scrollbarY.querySelector('[data-part="thumb"]')) || el.querySelector(".thumb-y");
    this.thumbX = (this.scrollbarX && this.scrollbarX.querySelector('[data-part="thumb"]')) || el.querySelector(".thumb-x");

    if (!this.viewport) {
      if (this.scrollbarY) this.scrollbarY.style.display = "none";
      if (this.scrollbarX) this.scrollbarX.style.display = "none";
      return;
    }

    this.boundUpdate = () => this.updateThumb();
    this.boundScroll = () => {
      this.markScrolling();
      this.updateThumb();
    };
    this.viewport.addEventListener("scroll", this.boundScroll, { passive: true });
    window.addEventListener("resize", this.boundUpdate);

    // hover state for auto-hiding scrollbars
    this.boundEnter = () => this.setHovering(true);
    this.boundLeave = () => this.setHovering(false);
    el.addEventListener("pointerenter", this.boundEnter);
    el.addEventListener("pointerleave", this.boundLeave);

    if (this.thumbY) {
      this.onThumbYPointerDownBound = (e) => this.onThumbYPointerDown(e);
      this.thumbY.addEventListener("pointerdown", this.onThumbYPointerDownBound);
    }
    if (this.thumbX) {
      this.onThumbXPointerDownBound = (e) => this.onThumbXPointerDown(e);
      this.thumbX.addEventListener("pointerdown", this.onThumbXPointerDownBound);
    }

    this.resizeObserver = new ResizeObserver(() => this.updateThumb());
    this.resizeObserver.observe(this.viewport);
    if (this.content) this.resizeObserver.observe(this.content);

    this.updateThumb();
  },

  updateAxis({ contentSize, clientSize, scrollPos, thumb, scrollbar, axis }) {
    const has = contentSize > clientSize + 1;
    if (!has) {
      if (scrollbar) scrollbar.style.display = "none";
      return;
    }
    if (scrollbar) scrollbar.style.display = "";
    if (thumb && scrollbar) {
      // PROPORTIONAL thumb size (Base UI): track * (viewport / content), min 20px. Exposed as a CSS
      // var so the consumer's thumb opts in with `height/width: var(--scroll-area-thumb-*)`.
      const trackSize = axis === "vertical" ? scrollbar.clientHeight : scrollbar.clientWidth;
      const thumbSize = Math.max(20, (clientSize / contentSize) * trackSize);
      this.el.style.setProperty(
        axis === "vertical" ? "--scroll-area-thumb-height" : "--scroll-area-thumb-width",
        `${thumbSize}px`,
      );
      const actual = (axis === "vertical" ? thumb.offsetHeight : thumb.offsetWidth) || thumbSize;
      const maxScroll = contentSize - clientSize;
      const maxThumb = trackSize - actual;
      const pos = maxScroll > 0 ? (scrollPos / maxScroll) * maxThumb : 0;
      thumb.style.transform = axis === "vertical" ? `translateY(${pos}px)` : `translateX(${pos}px)`;
    }
  },

  updateThumb() {
    if (!this.viewport) return;
    const v = this.viewport;

    const hasY = v.scrollHeight > v.clientHeight + 1;
    const hasX = v.scrollWidth > v.clientWidth + 1;

    this.updateAxis({ contentSize: v.scrollHeight, clientSize: v.clientHeight, scrollPos: v.scrollTop, thumb: this.thumbY, scrollbar: this.scrollbarY, axis: "vertical" });
    this.updateAxis({ contentSize: v.scrollWidth, clientSize: v.clientWidth, scrollPos: v.scrollLeft, thumb: this.thumbX, scrollbar: this.scrollbarX, axis: "horizontal" });

    // overflow presence
    this.flag("data-has-overflow-y", hasY, [this.el, this.viewport, this.scrollbarY, this.scrollbarX, this.content]);
    this.flag("data-has-overflow-x", hasX, [this.el, this.viewport, this.scrollbarX, this.scrollbarY, this.content]);

    // per-edge overflow distance (for the scroll-fade mask) + data flags
    const yStart = v.scrollTop;
    const yEnd = v.scrollHeight - v.clientHeight - v.scrollTop;
    const xStart = v.scrollLeft;
    const xEnd = v.scrollWidth - v.clientWidth - v.scrollLeft;
    const set = (name, px) => this.el.style.setProperty(name, `${Math.max(0, Math.round(px))}px`);
    set("--scroll-area-overflow-y-start", hasY ? yStart : 0);
    set("--scroll-area-overflow-y-end", hasY ? yEnd : 0);
    set("--scroll-area-overflow-x-start", hasX ? xStart : 0);
    set("--scroll-area-overflow-x-end", hasX ? xEnd : 0);
    this.flag("data-overflow-y-start", hasY && yStart > 0, [this.el, this.viewport, this.content]);
    this.flag("data-overflow-y-end", hasY && yEnd > 1, [this.el, this.viewport, this.content]);
    this.flag("data-overflow-x-start", hasX && xStart > 0, [this.el, this.viewport, this.content]);
    this.flag("data-overflow-x-end", hasX && xEnd > 1, [this.el, this.viewport, this.content]);
  },

  flag(attr, on, nodes) {
    nodes.forEach((n) => n && n.toggleAttribute(attr, on));
  },

  setHovering(on) {
    [this.scrollbarY, this.scrollbarX].forEach((s) => s && s.toggleAttribute("data-hovering", on));
  },

  markScrolling() {
    this.flag("data-scrolling", true, [this.el, this.viewport, this.scrollbarY, this.scrollbarX, this.content]);
    clearTimeout(this._scrollTimer);
    this._scrollTimer = setTimeout(
      () => this.flag("data-scrolling", false, [this.el, this.viewport, this.scrollbarY, this.scrollbarX, this.content]),
      500,
    );
  },

  // ---- thumb dragging (unchanged logic; thumb size read from offset*) --------

  onThumbYPointerDown(e) {
    e.preventDefault();
    this.isDraggingY = true;
    this.startY = e.clientY;
    this.startScrollTop = this.viewport.scrollTop;
    this.boundThumbYPointerMove = (ev) => this.onThumbYPointerMove(ev);
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
    this.viewport.scrollTop = Math.max(0, Math.min(this.startScrollTop + dy * (maxScroll / maxThumb), maxScroll));
  },

  onThumbYPointerUp() {
    this.isDraggingY = false;
    document.removeEventListener("pointermove", this.boundThumbYPointerMove);
    document.removeEventListener("pointerup", this.boundThumbYPointerUp);
  },

  onThumbXPointerDown(e) {
    e.preventDefault();
    this.isDraggingX = true;
    this.startX = e.clientX;
    this.startScrollLeft = this.viewport.scrollLeft;
    this.boundThumbXPointerMove = (ev) => this.onThumbXPointerMove(ev);
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
    this.viewport.scrollLeft = Math.max(0, Math.min(this.startScrollLeft + dx * (maxScroll / maxThumb), maxScroll));
  },

  onThumbXPointerUp() {
    this.isDraggingX = false;
    document.removeEventListener("pointermove", this.boundThumbXPointerMove);
    document.removeEventListener("pointerup", this.boundThumbXPointerUp);
  },

  destroyed() {
    this.viewport?.removeEventListener("scroll", this.boundScroll);
    window.removeEventListener("resize", this.boundUpdate);
    this.el.removeEventListener("pointerenter", this.boundEnter);
    this.el.removeEventListener("pointerleave", this.boundLeave);
    this.thumbY?.removeEventListener("pointerdown", this.onThumbYPointerDownBound);
    this.thumbX?.removeEventListener("pointerdown", this.onThumbXPointerDownBound);
    this.resizeObserver?.disconnect();
    clearTimeout(this._scrollTimer);
  },
};

function q(el, primary, fallback) {
  return el.querySelector(primary) || el.querySelector(fallback);
}

export default ScrollArea;
