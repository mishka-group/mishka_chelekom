// HeadlessCarousel — the parts CSS scroll-snap cannot do on its own.
//
// The scrolling itself is native: the viewport is a snap container and the slides are snap points,
// so dragging, trackpads, momentum and reduced-motion all behave the way the platform intends, and
// the carousel works with this file absent. What it adds is the state around that — which slide is
// current, prev/next, indicators, autoplay — none of which CSS can report.
//
// "Current" is *measured*, never assumed: after the viewport settles, whichever slide sits nearest
// the scroll position is the current one. A counter incremented on every button press would drift
// the moment anyone touched the scrollbar, dragged, or flicked two slides along.
//
// Measuring beats an IntersectionObserver here for two reasons: it needs no threshold to argue
// about when slides are wider or narrower than the viewport, and observer callbacks are suppressed
// in a hidden document, which is exactly where automated checks run.

const HeadlessCarousel = {
  mounted() {
    this.viewport = this.el.querySelector('[data-part="viewport"]');
    if (!this.viewport) return;

    this.slides = Array.from(this.el.querySelectorAll('[data-part="slide"]'));
    this.indicators = Array.from(this.el.querySelectorAll('[data-part="indicator"]'));
    this.loop = this.el.hasAttribute("data-loop");
    this.vertical = this.el.getAttribute("data-orientation") === "vertical";
    this.onChange = this.el.getAttribute("data-on-change");
    this.index = Number(this.el.getAttribute("data-index")) || 0;
    this.painted = false;

    this.bind();
    this.autoplay();
    this.reflect(this.index);
  },

  updated() {
    // Slides can be added or removed by the server; rebuild rather than hold stale nodes.
    this.destroyed();
    this.mounted();
  },

  destroyed() {
    clearTimeout(this.settle);
    clearInterval(this.timer);
    (this.unbind || []).forEach((off) => off());
    this.unbind = [];
  },

  bind() {
    this.unbind = [];

    const on = (node, event, handler) => {
      if (!node) return;
      node.addEventListener(event, handler);
      this.unbind.push(() => node.removeEventListener(event, handler));
    };

    on(this.el.querySelector('[data-part="previous"]'), "click", () => this.go(this.index - 1));
    on(this.el.querySelector('[data-part="next"]'), "click", () => this.go(this.index + 1));

    this.indicators.forEach((indicator, index) => on(indicator, "click", () => this.go(index)));

    // `scrollend` fires once the viewport has come to rest, including after a snap; the debounce
    // is the fallback for browsers that do not have it yet.
    if ("onscrollend" in window) {
      on(this.viewport, "scrollend", () => this.measure());
    } else {
      on(this.viewport, "scroll", () => {
        clearTimeout(this.settle);
        this.settle = setTimeout(() => this.measure(), 120);
      });
    }

    on(this.viewport, "keydown", (event) => {
      const back = this.vertical ? "ArrowUp" : "ArrowLeft";
      const forward = this.vertical ? "ArrowDown" : "ArrowRight";

      if (event.key === back) this.step(event, this.index - 1);
      else if (event.key === forward) this.step(event, this.index + 1);
      else if (event.key === "Home") this.step(event, 0);
      else if (event.key === "End") this.step(event, this.slides.length - 1);
    });

    // Autoplay that runs while you are reading it is hostile; pausing on hover and on focus is the
    // minimum, and both have to be undone again.
    ["mouseenter", "focusin"].forEach((event) => on(this.el, event, () => clearInterval(this.timer)));
    ["mouseleave", "focusout"].forEach((event) => on(this.el, event, () => this.autoplay()));
  },

  // Nearest wins: with `snap-center`, or slides narrower than the viewport, the leading edge is not
  // the one that matters.
  measure() {
    const position = this.vertical ? this.viewport.scrollTop : this.viewport.scrollLeft;
    const origin = this.vertical ? this.viewport.offsetTop : this.viewport.offsetLeft;

    let nearest = 0;
    let best = Infinity;

    this.slides.forEach((slide, index) => {
      const offset = (this.vertical ? slide.offsetTop : slide.offsetLeft) - origin;
      const distance = Math.abs(offset - position);
      if (distance < best) {
        best = distance;
        nearest = index;
      }
    });

    if (nearest !== this.index) this.reflect(nearest);
  },

  step(event, index) {
    event.preventDefault();
    this.go(index);
  },

  autoplay() {
    clearInterval(this.timer);

    const interval = Number(this.el.getAttribute("data-autoplay"));
    if (!interval) return;

    // Anyone who asked not to be moved should not be.
    if (this.reduceMotion()) return;

    this.timer = setInterval(() => this.go(this.index + 1, { wrap: true }), interval);
  },

  reduceMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  },

  go(index, { wrap = this.loop } = {}) {
    const last = this.slides.length - 1;
    let target = index;

    if (target < 0) target = wrap ? last : 0;
    if (target > last) target = wrap ? 0 : last;

    const slide = this.slides[target];
    if (!slide) return;

    // `scrollIntoView` would scroll the page as well when the carousel is partly offscreen; moving
    // the viewport's own scroll offset keeps the effect local.
    const offset = this.vertical
      ? slide.offsetTop - this.viewport.offsetTop
      : slide.offsetLeft - this.viewport.offsetLeft;

    // Smooth is the default, but someone who asked not to be animated should be moved instantly —
    // the same preference the autoplay honours.
    this.viewport.scrollTo({
      [this.vertical ? "top" : "left"]: offset,
      behavior: this.reduceMotion() ? "instant" : "smooth",
    });

    // We know where this is going, so say so now rather than waiting for the scroll to settle: an
    // indicator that lags a whole smooth-scroll behind the button that moved it looks broken.
    // `measure()` still runs afterwards and corrects anything the user did by hand.
    this.reflect(target);
  },

  reflect(index) {
    // Idempotent: `go()` reflects optimistically and the scroll then settles on the same slide, so
    // without this the change event would fire twice for one move.
    if (this.painted && index === this.index) return;

    this.painted = true;
    this.index = index;
    this.el.setAttribute("data-index", index);

    this.slides.forEach((slide, i) => {
      slide.toggleAttribute("data-current", i === index);
      // A slide scrolled out of view is still in the tab order; marking it lets a skin decide.
      slide.setAttribute("aria-hidden", i === index ? "false" : "true");
    });

    this.indicators.forEach((indicator, i) => {
      indicator.toggleAttribute("data-current", i === index);
      indicator.setAttribute("aria-current", i === index ? "true" : "false");
    });

    const previous = this.el.querySelector('[data-part="previous"]');
    const next = this.el.querySelector('[data-part="next"]');
    if (previous && !this.loop) previous.disabled = index === 0;
    if (next && !this.loop) next.disabled = index === this.slides.length - 1;

    if (this.onChange) this.pushEventTo(this.el, this.onChange, { index });
  },
};

export default HeadlessCarousel;
