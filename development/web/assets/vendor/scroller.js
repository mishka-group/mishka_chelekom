// Scroller — horizontal scroll container with prev/next controls (Mantine Scroller parity).
//
// The `[data-part="prev"]`/`[data-part="next"]` buttons scroll the `[data-part="viewport"]` by ~80%
// of its width (or `data-scroll-by` px), smoothly. On scroll/resize the buttons get `data-disabled`
// (+ the native `disabled`) at the two ends so you can dim them. Uses a ResizeObserver so it stays
// correct when the container or its content changes size.

const Scroller = {
  mounted() {
    const root = this.el;
    this.viewport = root.querySelector('[data-part="viewport"]');
    this.prev = root.querySelector('[data-part="prev"]');
    this.next = root.querySelector('[data-part="next"]');
    if (!this.viewport) return;

    const amount = () =>
      Number(root.getAttribute("data-scroll-by")) || this.viewport.clientWidth * 0.8;

    this._prevClick = () => this.viewport.scrollBy({ left: -amount(), behavior: "smooth" });
    this._nextClick = () => this.viewport.scrollBy({ left: amount(), behavior: "smooth" });

    this._update = () => {
      const { scrollLeft, scrollWidth, clientWidth } = this.viewport;
      const atStart = scrollLeft <= 1;
      const atEnd = scrollLeft + clientWidth >= scrollWidth - 1;
      if (this.prev) {
        this.prev.toggleAttribute("data-disabled", atStart);
        this.prev.disabled = atStart;
      }
      if (this.next) {
        this.next.toggleAttribute("data-disabled", atEnd);
        this.next.disabled = atEnd;
      }
    };

    if (this.prev) this.prev.addEventListener("click", this._prevClick);
    if (this.next) this.next.addEventListener("click", this._nextClick);
    this.viewport.addEventListener("scroll", this._update, { passive: true });
    this._ro = new ResizeObserver(this._update);
    this._ro.observe(this.viewport);
    this._update();
  },

  destroyed() {
    if (this.prev) this.prev.removeEventListener("click", this._prevClick);
    if (this.next) this.next.removeEventListener("click", this._nextClick);
    if (this.viewport) this.viewport.removeEventListener("scroll", this._update);
    if (this._ro) this._ro.disconnect();
  },
};

export default Scroller;
