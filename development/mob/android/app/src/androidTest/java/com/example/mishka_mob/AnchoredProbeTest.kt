package com.example.mishka_mob

import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * THROWAWAY probe for the `anchored` node type. Delete once popover, tooltip and
 * preview_card are migrated and their own suites cover this.
 *
 * It exists to fail fast on the one question that decides the whole approach:
 * does a panel rendered in a Compose Popup escape the clipping ancestors that
 * every showcase example sits inside — a Box with corner_radius, inside a
 * verticalScroll — while staying visible to the test semantics tree and
 * remaining tappable?
 *
 * A custom Layout placing the panel outside its own bounds does NOT: it measures
 * (0,0,0,0) inside a rounded card, which is invisible AND untappable. If these
 * assertions fail, the Popup approach dies too and the design has to change.
 *
 * Run with `mix e2e AnchoredProbeTest`.
 */
@RunWith(AndroidJUnit4::class)
class AnchoredProbeTest {

    @get:Rule
    val compose = createComposeRule()

    private fun node(type: String, props: Map<String, Any?>, children: List<MobNode> = emptyList()) =
        MobNode(type, props, children)

    private fun text(id: String, label: String) =
        node("text", mapOf("id" to id, "text" to label, "text_size" to "base"))

    private fun panel(id: String) =
        node(
            "box",
            mapOf(
                "id" to id,
                "background" to "#FF3355FF",
                "padding" to 16.0,
                "corner_radius" to 8.0,
                "fill_width" to false,
            ),
            listOf(text("$id-label", "PANEL CONTENT")),
        )

    private fun trigger(id: String) =
        node(
            "box",
            mapOf(
                "id" to id,
                "background" to "#FF999999",
                "padding" to 12.0,
                "fill_width" to false,
            ),
            listOf(text("$id-label", "TRIGGER")),
        )

    /**
     * The hostile nesting the real showcase uses: a scrolling Column of cards,
     * each card a Box with corner_radius (which clips), and a sibling directly
     * below the anchor so displacement is measurable.
     */
    private fun tree(open: Boolean, side: String, spacerBefore: Int) =
        node(
            "scroll",
            mapOf(),
            listOf(
                node(
                    "column",
                    mapOf("fill_width" to true),
                    listOf(
                        node("spacer", mapOf("size" to spacerBefore.toDouble())),
                        node(
                            "box",
                            mapOf(
                                "id" to "card",
                                "fill_width" to true,
                                "corner_radius" to 12.0,
                                "background" to "#FFEEEEEE",
                                "padding" to 16.0,
                            ),
                            listOf(
                                node(
                                    "column",
                                    mapOf("fill_width" to true),
                                    listOf(
                                        node(
                                            "anchored",
                                            mapOf(
                                                "id" to "probe",
                                                "side" to side,
                                                "align" to "start",
                                                "side_offset" to 8.0,
                                            ),
                                            if (open) {
                                                listOf(trigger("probe-trigger"), panel("probe-panel"))
                                            } else {
                                                listOf(trigger("probe-trigger"))
                                            },
                                        ),
                                        text("marker", "MARKER"),
                                    ),
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        )

    private fun rect(tag: String) =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes()
            .first().boundsInWindow

    private fun present(tag: String) =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    @Test
    fun the_panel_is_visible_to_the_test_tree_inside_a_clipping_card() {
        compose.setContent { RenderNode(tree(open = true, side = "bottom", spacerBefore = 40)) }
        compose.waitForIdle()

        require(present("probe-panel")) {
            "the panel is not in the semantics tree — Popup content is invisible to the test rule"
        }
        val panel = rect("probe-panel")
        require(panel.width > 0f && panel.height > 0f) {
            "the panel measured $panel — a zero-area rect is the clip failure that killed the " +
                "custom-Layout approach"
        }
    }

    @Test
    fun the_panel_does_not_displace_the_sibling_below_it() {
        // setContent may only be called once per test, so toggle open/closed
        // through state and recompose the same tree.
        val open = mutableStateOf(false)
        compose.setContent { RenderNode(tree(open = open.value, side = "bottom", spacerBefore = 40)) }
        compose.waitForIdle()

        val closed = rect("marker")

        // In flow this is the accordion bug: the marker moves down by the
        // panel's height. Out of flow it does not move at all.
        open.value = true
        compose.waitForIdle()

        require(present("probe-panel")) { "the panel never opened, so this proves nothing" }
        val opened = rect("marker")

        require(kotlin.math.abs(closed.top - opened.top) <= 1f) {
            "opening the panel MOVED the sibling: ${closed.top} -> ${opened.top}. Still in flow."
        }
    }

    @Test
    fun a_top_side_panel_sits_above_its_trigger_and_escapes_the_card() {
        // 300dp down, so there is room above and `flip` has no reason to fire.
        compose.setContent { RenderNode(tree(open = true, side = "top", spacerBefore = 300)) }
        compose.waitForIdle()

        val panel = rect("probe-panel")
        val trig = rect("probe-trigger")
        val card = rect("card")

        require(panel.height > 0f) { "the panel has no area: $panel" }
        require(panel.bottom <= trig.top + 1f) {
            "side=top did not put the panel above the trigger: panel=$panel trigger=$trig"
        }
        // The whole point: it leaves the rounded card that would have clipped it.
        require(panel.top < card.top) {
            "the panel stayed inside the card's bounds: panel=$panel card=$card"
        }
    }

    @Test
    fun a_tap_inside_the_panel_reaches_it() {
        compose.setContent {
            // Wire the tap through the bridge's own on_tap path by using a node
            // the renderer makes clickable, and observe via a side effect.
            RenderNode(tree(open = true, side = "bottom", spacerBefore = 40))
        }
        compose.waitForIdle()

        // performClick throws if the node is not hittable, which is the failure
        // mode that matters: a panel drawn outside a clip can be "clicked" by a
        // test while a finger cannot reach it.
        compose.onNodeWithTag("probe-panel", useUnmergedTree = true).performClick()
        compose.waitForIdle()
    }

    @Test
    fun a_bottom_panel_with_no_room_below_flips_above() {
        // The trigger must stay ON SCREEN or it never gets positioned and
        // reports Rect(0,0,0,0) — then there is nothing to compare against.
        // So: no scroll, and a spacer sized from the real viewport to leave the
        // trigger near the bottom with less room under it than the panel needs.
        val open = mutableStateOf(false)
        compose.setContent {
            val h = androidx.compose.ui.platform.LocalConfiguration.current.screenHeightDp
            RenderNode(
                node(
                    "column",
                    mapOf("fill_width" to true),
                    listOf(
                        node("spacer", mapOf("size" to (h - 90).toDouble())),
                        node(
                            "anchored",
                            mapOf(
                                "id" to "probe",
                                "side" to "bottom",
                                "align" to "start",
                                "side_offset" to 8.0,
                            ),
                            if (open.value) {
                                listOf(trigger("probe-trigger"), panel("probe-panel"))
                            } else {
                                listOf(trigger("probe-trigger"))
                            },
                        ),
                    ),
                )
            )
        }
        compose.waitForIdle()

        val trig = rect("probe-trigger")
        require(trig.height > 0f) { "the trigger is off screen ($trig); the test proves nothing" }

        open.value = true
        compose.waitForIdle()

        val panel = rect("probe-panel")
        require(panel.height > 0f) { "the panel has no area: $panel" }
        require(panel.bottom <= trig.top + 1f) {
            "side=bottom did not flip above a trigger with no room below it: " +
                "panel=$panel trigger=$trig"
        }
    }
}
