// Tests for the pure fitting math behind the OverflowList engine.
// Run with: node --test  (from priv/assets/js/)
//
// Every case is a real scenario from the showcase demo: 10 pill-shaped tags
// (widths measured in the browser at ~16px/em) in a gap-8px row.

import { test } from "node:test";
import assert from "node:assert/strict";
import { fit } from "./overflow_list.js";

const GAP = 8;
const COUNTER = 45.5;

// ~ the demo's ten tags: Design Phoenix Elixir LiveView Tailwind Headless
// Accessibility Components Mishka Chelekom
const TAGS = [61.2, 68.4, 52.9, 74.1, 70.3, 76.8, 101.5, 96.7, 60.9, 78.2];

const rowWidth = (widths, gap) =>
  widths.reduce((sum, w, i) => sum + w + (i ? gap : 0), 0);

test("everything fits: no counter reserved, all visible", () => {
  const avail = rowWidth(TAGS, GAP) + 1;
  assert.equal(
    fit({ widths: TAGS, counterW: COUNTER, gap: GAP, avail, min: 1 }),
    TAGS.length,
  );
});

test("one pixel short of all fitting: reserves the counter, drops enough items", () => {
  const avail = rowWidth(TAGS, GAP) - 1;
  const visible = fit({ widths: TAGS, counterW: COUNTER, gap: GAP, avail, min: 1 });
  assert.ok(visible < TAGS.length);
  const used = rowWidth(TAGS.slice(0, visible), GAP);
  assert.ok(used + GAP + COUNTER <= avail, "visible items + counter must fit");
});

test("the regression: items flush to the edge must yield to the counter", () => {
  // avail exactly holds the first 4 tags — the old engine kept all 4 and pushed
  // the counter past the clip; the correct answer is 3 + counter.
  const avail = rowWidth(TAGS.slice(0, 4), GAP);
  const visible = fit({ widths: TAGS, counterW: COUNTER, gap: GAP, avail, min: 1 });
  assert.equal(visible, 3);
});

test("visible set + counter always fits, at every width", () => {
  const total = Math.ceil(rowWidth(TAGS, GAP)) + 60;
  for (let avail = 0; avail <= total; avail++) {
    const visible = fit({ widths: TAGS, counterW: COUNTER, gap: GAP, avail, min: 1 });
    if (visible === TAGS.length) {
      assert.ok(rowWidth(TAGS, GAP) <= avail, `all visible but row overflows at ${avail}`);
    } else if (visible > 1) {
      const used = rowWidth(TAGS.slice(0, visible), GAP);
      assert.ok(
        used + GAP + COUNTER <= avail,
        `overflow past the clip at avail=${avail}: ${visible} visible`,
      );
    }
  }
});

test("shrinking is monotone: narrower never shows more items", () => {
  const total = Math.ceil(rowWidth(TAGS, GAP)) + 60;
  let prev = Infinity;
  for (let avail = total; avail >= 0; avail--) {
    const visible = fit({ widths: TAGS, counterW: COUNTER, gap: GAP, avail, min: 1 });
    assert.ok(visible <= prev, `visible grew from ${prev} to ${visible} at ${avail}`);
    prev = visible;
  }
});

test("min_visible wins over fitting", () => {
  assert.equal(fit({ widths: TAGS, counterW: COUNTER, gap: GAP, avail: 10, min: 1 }), 1);
  assert.equal(fit({ widths: TAGS, counterW: COUNTER, gap: GAP, avail: 10, min: 3 }), 3);
});

test("min_visible is capped at the item count", () => {
  const two = TAGS.slice(0, 2);
  assert.equal(fit({ widths: two, counterW: COUNTER, gap: GAP, avail: 10, min: 5 }), 2);
});

test("fractional widths do not accumulate into an overshoot", () => {
  // Ten items of 50.6px each: integer rounding (offsetWidth-style) would under-count
  // the row by 6px and admit an extra item.
  const widths = Array(10).fill(50.6);
  const avail = rowWidth(widths.slice(0, 4), GAP) + GAP + COUNTER + 0.4;
  const visible = fit({ widths, counterW: COUNTER, gap: GAP, avail, min: 1 });
  assert.equal(visible, 4);
  assert.ok(rowWidth(widths.slice(0, 4), GAP) + GAP + COUNTER <= avail);
});

test("zero counter width degrades gracefully", () => {
  const avail = rowWidth(TAGS.slice(0, 4), GAP);
  const visible = fit({ widths: TAGS, counterW: 0, gap: GAP, avail, min: 1 });
  assert.equal(visible, 4);
});

test("empty list", () => {
  assert.equal(fit({ widths: [], counterW: COUNTER, gap: GAP, avail: 100, min: 1 }), 0);
});
