// Splitter — two-panel resizable layout (Mantine Splitter parity).
//
// Drag the `[data-part="resizer"]` (or use the keyboard) to change the split. The position is written
// to the `--chelekom-splitter-pos` CSS variable on the root (a percentage), which your CSS uses to
// size the first panel. The resizer is a `role="separator"` with `aria-valuenow`; Arrow keys move it
// (Shift = ×10), Home/End jump to min/max. `data-dragging` is set on the root while dragging.

const Splitter = {
  mounted() {
    const root = this.el;
    const resizer = root.querySelector('[data-part="resizer"]');
    if (!resizer) return;

    const horizontal = root.getAttribute("data-orientation") !== "vertical";
    const min = Number(root.getAttribute("data-min")) || 0;
    const max = Number(root.getAttribute("data-max") || 100);
    const disabled = () => root.hasAttribute("data-disabled");

    const clamp = (n) => Math.min(max, Math.max(min, n));

    const setPos = (pct) => {
      pct = clamp(pct);
      root.style.setProperty("--chelekom-splitter-pos", pct + "%");
      resizer.setAttribute("aria-valuenow", String(Math.round(pct)));
      const on = root.getAttribute("data-on-change");
      if (on) this.pushEventTo(root, on, { value: Math.round(pct) });
    };

    const fromPointer = (e) => {
      const r = root.getBoundingClientRect();
      const pct = horizontal
        ? ((e.clientX - r.left) / r.width) * 100
        : ((e.clientY - r.top) / r.height) * 100;
      setPos(pct);
    };

    const onMove = (e) => {
      fromPointer(e);
      e.preventDefault();
    };
    const onUp = () => {
      root.removeAttribute("data-dragging");
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerup", onUp);
    };

    this._down = (e) => {
      if (disabled()) return;
      root.setAttribute("data-dragging", "");
      window.addEventListener("pointermove", onMove);
      window.addEventListener("pointerup", onUp);
      e.preventDefault();
    };

    this._key = (e) => {
      if (disabled()) return;
      const now = Number(resizer.getAttribute("aria-valuenow")) || 50;
      const step = e.shiftKey ? 10 : 1;
      const dec = horizontal ? ["ArrowLeft", "ArrowUp"] : ["ArrowUp", "ArrowLeft"];
      const inc = horizontal ? ["ArrowRight", "ArrowDown"] : ["ArrowDown", "ArrowRight"];
      if (dec.includes(e.key)) {
        setPos(now - step);
        e.preventDefault();
      } else if (inc.includes(e.key)) {
        setPos(now + step);
        e.preventDefault();
      } else if (e.key === "Home") {
        setPos(min);
        e.preventDefault();
      } else if (e.key === "End") {
        setPos(max);
        e.preventDefault();
      }
    };

    resizer.addEventListener("pointerdown", this._down);
    resizer.addEventListener("keydown", this._key);
    this._resizer = resizer;
  },

  destroyed() {
    if (this._resizer) {
      this._resizer.removeEventListener("pointerdown", this._down);
      this._resizer.removeEventListener("keydown", this._key);
    }
  },
};

export default Splitter;
