// Countdown — tick down to an instant (no daisyUI equivalent; theirs is a display, not a timer).
//
// The server renders the correct remaining time and hands over an absolute `data-deadline`, so the
// first paint is right before this runs and right again after a reconnect. Working from an instant
// rather than a duration is what keeps a slow render or a backgrounded tab from drifting the clock.
//
// Each `[data-part="digit"]` gets its unit's value written to `--value` — the custom property
// daisyUI's rolling digits animate — and to its text, so an unskinned countdown still reads.

const SIZES = { days: 86400, hours: 3600, minutes: 60, seconds: 1 };

const Countdown = {
  mounted() {
    this.start();
  },

  updated() {
    // A re-render can move the deadline (a new target, a reset), so re-read rather than assume.
    this.start();
  },

  destroyed() {
    this.stop();
  },

  stop() {
    clearTimeout(this.align);
    clearInterval(this.timer);
  },

  start() {
    this.stop();
    this.deadline = Number(this.el.getAttribute("data-deadline"));
    this.units = (this.el.getAttribute("data-units") || "").split(" ").filter(Boolean);
    this.onComplete = this.el.getAttribute("data-on-complete");
    this.completed = this.el.hasAttribute("data-complete");

    if (!Number.isFinite(this.deadline) || !this.deadline) return;

    this.tick();

    // Align to the boundary so the display changes when a watching clock would, rather than
    // whenever this happened to mount.
    const offset = ((this.deadline - Date.now()) % 1000 + 1000) % 1000;
    this.align = setTimeout(() => {
      this.tick();
      this.timer = setInterval(() => this.tick(), 1000);
    }, offset);
  },

  tick() {
    const remaining = Math.max(0, Math.round((this.deadline - Date.now()) / 1000));
    this.paint(remaining);

    if (remaining > 0) return;

    this.stop();
    this.el.setAttribute("data-complete", "");

    // Once, not once per tick.
    if (this.onComplete && !this.completed) {
      this.completed = true;
      this.pushEventTo(this.el, this.onComplete, {});
    }
  },

  paint(remaining) {
    let left = remaining;

    this.units.forEach((unit) => {
      const size = SIZES[unit];
      if (!size) return;

      const value = Math.floor(left / size);
      left -= value * size;

      const digit = this.el.querySelector(`[data-part="digit"][data-unit="${unit}"]`);
      if (!digit) return;

      digit.style.setProperty("--value", value);
      if (digit.textContent !== String(value)) digit.textContent = value;
      digit.setAttribute("aria-label", `${value} ${unit}`);
    });
  },
};

export default Countdown;
