// Indeterminate — reflect `data-indeterminate` onto a checkbox's DOM property.
//
// HTML has no `indeterminate` attribute: the mixed state of a checkbox exists only as a property,
// so a server-rendered "some of these are selected" cannot be expressed in markup alone. This is
// the whole hook — anything with a tri-state select-all can use it without pulling in an engine
// that also wants to own the clicking.

const Indeterminate = {
  mounted() {
    this.sync();
  },

  updated() {
    // Re-rendering the input resets the property, so it has to be reapplied on every patch.
    this.sync();
  },

  sync() {
    this.el.indeterminate = this.el.hasAttribute("data-indeterminate");
  },
};

export default Indeterminate;
