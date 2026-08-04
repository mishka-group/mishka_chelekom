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
    fun dragging_the_handle_changes_how_many_fit() {
        compose.onNodeWithTag("rail-handle", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        val before = shownCount("rail")
        val track = boundsOf("rail-handle")

        // The track spans the whole width RANGE and sits below the rail, so its
        // x maps straight onto a width — touch near the right end for the widest
        // rail. This is what the web gets from a ResizeObserver; here the screen
        // owns the width, so it can ask fit/3 what that width holds.
        compose.onRoot().performTouchInput {
            down(androidx.compose.ui.geometry.Offset(track.left + 20f, track.center.y))
            repeat(5) { moveBy(androidx.compose.ui.geometry.Offset(track.width / 6f, 0f)) }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(700)

        val after = shownCount("rail")
        require(after > before) {
            "widening the rail did not reveal more items: $before -> $after"
        }

        // And back: narrowing hides them again, so the count really follows the
        // width rather than only ever growing.
        compose.onRoot().performTouchInput {
            down(androidx.compose.ui.geometry.Offset(track.right - 20f, track.center.y))
            repeat(5) { moveBy(androidx.compose.ui.geometry.Offset(-track.width / 6f, 0f)) }
            up()
        }
        compose.waitForIdle()
        Thread.sleep(700)

        require(shownCount("rail") < after) {
            "narrowing the rail did not hide items: $after -> ${shownCount("rail")}"
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
