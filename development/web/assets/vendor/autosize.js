// Autosize — grow a <textarea> with its content (Mantine Textarea autosize parity).
//
// Height is measured, not guessed: the element is collapsed to `auto` for one frame so
// `scrollHeight` reports the content height rather than the height we last set, then clamped
// between `data-min-rows` and `data-max-rows`. Rows are converted through the *computed*
// line-height, so a skin that changes font-size or padding stays correct without telling us.
//
// Once `max-rows` is reached the textarea starts scrolling instead of growing, which is the whole
// point of a maximum — `overflow-y` is toggled to match so the scrollbar only appears then.

const rows = (el, attr) => {
  const value = Number(el.getAttribute(attr));
  return Number.isFinite(value) && value > 0 ? value : null;
};

const Autosize = {
  mounted() {
    this.resize = () => this.fit();
    this.el.addEventListener("input", this.resize);
    // Fonts land after mount and change line-height under us; re-measure when they do.
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(this.resize);
    this.fit();
  },

  updated() {
    // A server render can replace the value wholesale (a reset, a validation round trip), so the
    // height we computed for the old content no longer describes this one.
    this.fit();
  },

  destroyed() {
    this.el.removeEventListener("input", this.resize);
  },

  fit() {
    const el = this.el;
    const style = window.getComputedStyle(el);
    const lineHeight = parseFloat(style.lineHeight) || parseFloat(style.fontSize) * 1.2;

    // Padding and borders are outside the text box but inside scrollHeight/offsetHeight, so a row
    // count has to be converted with them included or min-rows renders one row short.
    const vertical =
      parseFloat(style.paddingTop) +
      parseFloat(style.paddingBottom) +
      (style.boxSizing === "border-box"
        ? parseFloat(style.borderTopWidth) + parseFloat(style.borderBottomWidth)
        : 0);

    const min = rows(el, "data-min-rows");
    const max = rows(el, "data-max-rows");

    el.style.height = "auto";
    let height = el.scrollHeight;

    if (min) height = Math.max(height, min * lineHeight + vertical);

    if (max) {
      const ceiling = max * lineHeight + vertical;
      el.style.overflowY = height > ceiling ? "auto" : "hidden";
      height = Math.min(height, ceiling);
    } else {
      el.style.overflowY = "hidden";
    }

    el.style.height = `${Math.ceil(height)}px`;
  },
};

export default Autosize;
