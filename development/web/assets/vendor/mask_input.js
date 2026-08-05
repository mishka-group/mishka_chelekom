// MaskInput — format-as-you-type input masking (Mantine MaskInput parity).
//
// `data-mask` is a pattern where `9` = digit, `a` = letter, `*` = alphanumeric, and every other
// character is a literal that is inserted automatically (e.g. `(999) 999-9999`, `99/99/9999`). On
// each input the value is re-masked; literals never block typing, and a separator is auto-inserted
// as soon as the group before it completes. The masked value is what submits with the form. The
// masking runs in the element's own `input` listener, so LiveView's delegated phx-change handler
// always reads the already-masked value.

function applyMask(value, mask) {
  const fillable = (value || "").replace(/[^a-zA-Z0-9]/g, "");
  if (!fillable) return "";

  const chars = value.split("");
  let out = "";
  let vi = 0;

  const nextMatch = (test) => {
    while (vi < chars.length) {
      const c = chars[vi++];
      if (test(c)) return c;
    }
    return null;
  };

  for (const m of mask) {
    if (m === "9" || m === "a" || m === "*") {
      const test =
        m === "9"
          ? (c) => /\d/.test(c)
          : m === "a"
            ? (c) => /[a-zA-Z]/.test(c)
            : (c) => /[a-zA-Z0-9]/.test(c);
      const ch = nextMatch(test);
      if (ch === null) break;
      out += ch;
    } else {
      out += m;
    }
  }

  return out;
}

const MaskInput = {
  mounted() {
    this.mask = this.el.getAttribute("data-mask") || "";
    this._onInput = () => {
      const masked = applyMask(this.el.value, this.mask);
      if (this.el.value !== masked) {
        this.el.value = masked;
        const pos = masked.length;
        try {
          this.el.setSelectionRange(pos, pos);
        } catch (_e) {}
      }
    };
    this.el.addEventListener("input", this._onInput);
    if (this.el.value) this._onInput();
  },

  updated() {
    this.mask = this.el.getAttribute("data-mask") || this.mask;
    if (this.el.value) this.el.value = applyMask(this.el.value, this.mask);
  },

  destroyed() {
    this.el.removeEventListener("input", this._onInput);
  },
};

export default MaskInput;
