package com.example.mishka_mob

import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onRoot
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Overflow List page.
 *
 * Two things are worth asserting on a device and nowhere else.
 *
 * The counter must HUG. A Box given neither a width nor `fill_width` fills its
 * parent, which turned the "+N" pill into a bar stretching across the rest of
 * the row — a pure layout fact that no unit test can see, because the tree is
 * identical either way. [the_counter_hugs_its_label] measures it.
 *
 * And the item count must follow `visible`. Items are caller-supplied nodes, so
 * the component stamps `<id>-item-<n>` on each SHOWN one — counting those tags
 * counts what survived the split.
 *
 * Run with `mix e2e OverflowListTest`.
 */
@RunWith(AndroidJUnit4::class)
class OverflowListTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"
    private val page = "Items on one row, with the rest collapsed"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun boundsOf(tag: String): Rect =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true)
            .fetchSemanticsNodes()
            .map { it.boundsInRoot }
            .firstOrNull { it.width > 0f && it.height > 0f }
            ?: error("no laid-out node tagged \"$tag\"")

    /** How many items the list actually rendered, counted by their own tags. */
    private fun shownCount(list: String): Int = generateSequence(1) { it + 1 }
        .takeWhile { tagged("$list-item-$it") }
        .count()

    private fun show(list: String) {
        compose.onAllNodesWithTag("$list-item-1", useUnmergedTree = true)[0].performScrollTo()
        compose.waitForIdle()
    }

    @Before
    fun openOverflowListScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Overflow List", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }
    }

    @Test
    fun the_counter_hugs_its_label() {
        show("langs")

        val counter = boundsOf("langs-counter")
        val item = boundsOf("langs-item-1")
        val row = boundsOf("langs")

        // "+4" is shorter than "Design", so the pill must be narrower than a
        // real item — and nowhere near the full row. Without fill_width={false}
        // it filled its parent and stretched across everything left over, which
        // is what this measures and what a unit test cannot see.
        require(counter.width < item.width) {
            "the +N counter is wider than an item: counter=$counter item=$item"
        }
        require(counter.width < row.width / 2f) {
            "the +N counter stretched across the row: counter=$counter row=$row"
        }
    }

    @Test
    fun the_counter_is_not_squeezed_into_a_column_of_characters() {
        show("langs")

        val counter = boundsOf("langs-counter")
        val item = boundsOf("langs-item-1")

        // The bug this guards, exactly as reported: with every child of the Row
        // unweighted, Compose measured them in order and the counter — last —
        // got the scraps, so "+4" wrapped CHARACTER BY CHARACTER into a stack of
        // "+" over "4". Two independent symptoms, so two assertions.
        //
        // 1. It is no taller than an item. A two-line counter is roughly double.
        require(counter.height < item.height * 1.5f) {
            "the counter is stacking its characters vertically: " +
                "counter=$counter item=$item"
        }

        // 2. It is wide enough to actually read. A starved counter collapsed to
        // roughly one character.
        require(counter.width > 40f) {
            "the counter was squeezed to $counter — there is no room for the count"
        }

        // And it sits INSIDE the row it belongs to, rather than being pushed out
        // past the edge.
        val row = boundsOf("langs")
        require(counter.right <= row.right + 2f) {
            "the counter overflowed its row: counter=$counter row=$row"
        }
    }

    @Test
    fun dragging_the_boxs_right_edge_changes_how_many_fit() {
        compose.onNodeWithTag("rail-handle", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        val before = shownCount("rail")
        val surface = boundsOf("rail-handle")
        val box = boundsOf("rail")

        // Grab the box's RIGHT EDGE — the drag only engages there. The canvas
        // spans the whole width range and covers the badges, so that a tap on a
        // badge cannot snap the width to the finger.
        compose.onRoot().performTouchInput {
            down(androidx.compose.ui.geometry.Offset(box.right, surface.center.y))
            repeat(5) { moveBy(androidx.compose.ui.geometry.Offset(40f, 0f)) }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(700)

        val after = shownCount("rail")
        require(after > before) {
            "pulling the edge right did not reveal more badges: $before -> $after"
        }

        // And back: narrowing hides them again, so the count follows the width
        // rather than only ever growing.
        val wider = boundsOf("rail")
        compose.onRoot().performTouchInput {
            down(androidx.compose.ui.geometry.Offset(wider.right, surface.center.y))
            repeat(5) { moveBy(androidx.compose.ui.geometry.Offset(-40f, 0f)) }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(700)

        require(shownCount("rail") < after) {
            "pulling the edge back did not hide badges: $after -> ${shownCount("rail")}"
        }
    }

    @Test
    fun a_touch_away_from_the_edge_does_not_resize() {
        compose.onNodeWithTag("rail-handle", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        val before = shownCount("rail")
        val surface = boundsOf("rail-handle")
        val box = boundsOf("rail")

        // The drag surface has to cover the badges to be a stable ruler, so the
        // handler refuses any gesture that does not start on the edge —
        // otherwise tapping a badge would snap the box to your finger.
        compose.onRoot().performTouchInput {
            down(androidx.compose.ui.geometry.Offset(box.left + 20f, surface.center.y))
            repeat(5) { moveBy(androidx.compose.ui.geometry.Offset(40f, 0f)) }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(600)

        require(shownCount("rail") == before) {
            "a drag starting on a badge resized the box: $before -> ${shownCount("rail")}"
        }
    }

    @Test
    fun it_shows_exactly_what_visible_asks_for() {
        show("langs")

        // visible={3} over seven tags.
        require(shownCount("langs") == 3) { "expected 3 items, found ${shownCount("langs")}" }
        require(tagged("langs-counter")) { "four items are hidden but no counter was drawn" }
    }

    @Test
    fun tapping_the_counter_reveals_one_more() {
        show("more")
        val before = shownCount("more")

        compose.onNodeWithTag("more-counter", useUnmergedTree = true)
            .performScrollTo()
            .performClick()
        compose.waitForIdle()
        Thread.sleep(500)

        compose.waitUntil(10_000) { shownCount("more") > before }
    }

    @Test
    fun min_visible_is_a_floor() {
        show("floor-one")

        // Both ask for visible={0}. The first floors at the default 1, the
        // second at min_visible={2} — so the floor is doing the work, not the
        // requested count, which is zero in both cases.
        require(shownCount("floor-one") == 1) {
            "visible={0} showed ${shownCount("floor-one")}, expected the default floor of 1"
        }
        require(shownCount("floor-two") == 2) {
            "min_visible={2} showed ${shownCount("floor-two")}"
        }
    }

    @Test
    fun the_counter_can_say_something_other_than_plus_n() {
        show("worded")

        require(tagged("worded-counter")) { "the worded example drew no counter" }
        // visible={2} of seven leaves five hidden, and counter_text turns that
        // count into prose rather than "+5".
        require(showing("5 more")) { "counter_text did not replace the +N label" }
    }

    @Test
    fun the_page_renders_every_example_and_the_props_table() {
        for (heading in listOf(
            "Three fit, four do not",
            "Tap the counter",
            "min_visible is a floor",
            "Resizable",
            "A counter that says something else",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
