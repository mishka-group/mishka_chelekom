// Avatar — image loading-status engine (Base UI parity).
//
// Tracks the `[data-part="image"]`'s loading status — `idle | loading | loaded | error` — on the root
// as `data-status`, and shows the right child: the image is revealed ONLY once it has loaded, and the
// `[data-part="fallback"]` (initials) shows whenever the image isn't loaded. A `data-delay` (ms) on
// the fallback makes it wait that long before appearing, so a fast-loading image never flashes the
// fallback. `data-on-loading-status-change` pushes `{status}` to LiveView on every change.
//
// The image is toggled via the `hidden` attribute; the fallback via inline `display` (so it still
// hides even when the consumer styles it `display:flex`).

const Avatar = {
  mounted() {
    const el = this.el;
    this.image = el.querySelector('[data-part="image"]');
    this.fallback = el.querySelector('[data-part="fallback"]');
    this.onChange = el.getAttribute("data-on-loading-status-change");

    const d = this.fallback && this.fallback.getAttribute("data-delay");
    this.delay = d ? parseInt(d, 10) : undefined;
    this.delayPassed = !this.delay;

    const src = this.image && this.image.getAttribute("src");
    if (!src) {
      this.set("idle");
    } else if (this.image.complete) {
      // already settled (e.g. cached) — naturalWidth is 0 on a broken image
      this.set(this.image.naturalWidth > 0 ? "loaded" : "error");
    } else {
      this.set("loading");
      this._onLoad = () => this.set(this.image.naturalWidth > 0 ? "loaded" : "error");
      this._onError = () => this.set("error");
      this.image.addEventListener("load", this._onLoad);
      this.image.addEventListener("error", this._onError);
    }

    if (!this.delayPassed && this.status !== "loaded") {
      this._timer = setTimeout(() => {
        this.delayPassed = true;
        this.apply();
      }, this.delay);
    }
    this.apply();
  },

  destroyed() {
    if (this._timer) clearTimeout(this._timer);
    if (this.image && this._onLoad) {
      this.image.removeEventListener("load", this._onLoad);
      this.image.removeEventListener("error", this._onError);
    }
  },

  set(status) {
    if (this.status === status) return;
    this.status = status;
    this.el.setAttribute("data-status", status);
    if (this.onChange) this.pushEventTo(this.el, this.onChange, { status });
    this.apply();
  },

  apply() {
    const loaded = this.status === "loaded";
    if (this.image) this.image.hidden = !loaded;
    // fallback shows when the image isn't loaded AND the (optional) delay has elapsed
    if (this.fallback) {
      this.fallback.style.display = !loaded && this.delayPassed ? "" : "none";
    }
  },
};

export default Avatar;
