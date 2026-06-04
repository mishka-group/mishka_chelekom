// Otp — headless one-time-code (OTP) field engine.
//
// A row of single-character `[data-part="input"]` boxes. Typing advances to the next box,
// Backspace clears and moves back, ArrowLeft/Right navigate, and pasting a code distributes
// its characters across the boxes. The combined value is mirrored into a hidden
// `[data-part="value"]` input for form submission, and a `chelekom:complete` event is
// dispatched when every box is filled.

const Otp = {
  mounted() {
    this.boxes = Array.from(this.el.querySelectorAll('[data-part="input"]'));
    this.hidden = this.el.querySelector('[data-part="value"]');

    this.boxes.forEach((box, i) => {
      box.setAttribute("inputmode", "numeric");
      box.setAttribute("maxlength", "1");
      box.setAttribute("aria-label", `Digit ${i + 1}`);

      box.addEventListener("input", (e) => this.onInput(e, i));
      box.addEventListener("keydown", (e) => this.onKey(e, i));
      box.addEventListener("paste", (e) => this.onPaste(e, i));
      box.addEventListener("focus", () => box.select());
    });
  },

  onInput(e, i) {
    const v = e.target.value.replace(/\D?/g, "").slice(-1);
    e.target.value = v;
    if (v && i < this.boxes.length - 1) this.boxes[i + 1].focus();
    this.sync();
  },

  onKey(e, i) {
    if (e.key === "Backspace" && !this.boxes[i].value && i > 0) {
      this.boxes[i - 1].focus();
    } else if (e.key === "ArrowLeft" && i > 0) {
      e.preventDefault();
      this.boxes[i - 1].focus();
    } else if (e.key === "ArrowRight" && i < this.boxes.length - 1) {
      e.preventDefault();
      this.boxes[i + 1].focus();
    }
  },

  onPaste(e, i) {
    e.preventDefault();
    const chars = (e.clipboardData.getData("text") || "").replace(/\D/g, "").split("");
    chars.forEach((c, k) => {
      if (this.boxes[i + k]) this.boxes[i + k].value = c;
    });
    const next = Math.min(this.boxes.length - 1, i + chars.length);
    this.boxes[next].focus();
    this.sync();
  },

  sync() {
    const code = this.boxes.map((b) => b.value).join("");
    if (this.hidden) this.hidden.value = code;
    if (code.length === this.boxes.length) {
      this.el.dispatchEvent(new CustomEvent("chelekom:complete", { bubbles: true, detail: { code } }));
    }
  },
};

export default Otp;
