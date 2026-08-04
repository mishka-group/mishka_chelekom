package com.example.mishka_mob

import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performScrollTo
import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

/**
 * End-to-end tests for the Nav Link page.
 *
 * Everything a nav link says about itself, it says in colour or in a glyph: the
 * current row is `:primary` on a raised background, an expanded group is a ▾
 * rather than a ▸. A device test reads neither. So the component fans `id` out
 * into tags that name the state — `<id>-active` / `-inactive` / `-disabled` on
 * the label, `<id>-open` / `-closed` on the chevron — and every assertion here
 * reads those rather than the page's text.
 *
 * Text would be worse than useless on this page: all eight examples render into
 * one scrolling column and each carries a code block, so "Docs" is on screen
 * from the moment it mounts whatever the rows are doing.
 *
 * Run with `mix e2e NavLinkTest`.
 */
@RunWith(AndroidJUnit4::class)
class NavLinkTest {

    @get:Rule
    val compose = createAndroidComposeRule<MainActivity>()

    private val home = "Native component library"

    // An example TITLE, not the entry description: the gallery index prints
    // every component's description under its row, so a description would read
    // as "already on the page" while we are still looking at the list.
    private val page = "A group the screen owns"

    private fun showing(text: String): Boolean =
        try {
            compose.onAllNodesWithText(text, substring = true).fetchSemanticsNodes().isNotEmpty()
        } catch (_: IllegalStateException) {
            false
        }

    // useUnmergedTree: the row is a clickable Box, and a clickable merges its
    // children's semantics — the label and chevron tags live under it.
    private fun tagged(tag: String): Boolean =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes().isNotEmpty()

    private fun tap(tag: String) {
        compose.onNodeWithTag(tag, useUnmergedTree = true).performScrollTo().performClick()
        compose.waitForIdle()
        Thread.sleep(400)
    }

    private fun bounds(tag: String) =
        compose.onAllNodesWithTag(tag, useUnmergedTree = true).fetchSemanticsNodes()
            .first().boundsInRoot

    @Before
    fun openNavLinkScreen() {
        compose.waitUntil(90_000) { showing(home) || showing(page) || showing("← Back") }

        var guard = 0
        while (!showing(page) && !showing(home) && guard++ < 3) {
            if (!showing("← Back")) break
            compose.onNodeWithText("← Back", substring = true).performScrollTo().performClick()
            compose.waitForIdle()
            Thread.sleep(800)
        }

        if (!showing(page)) {
            compose.onAllNodesWithText("Nav Link", substring = false)[0]
                .performScrollTo()
                .performClick()
            compose.waitUntil(60_000) { showing(page) }
        }

        // The BEAM outlives the Activity, so the page arrives holding whatever
        // the previous test left in its assigns. Put the two that latch back:
        // the sidebar's selection, and the mail group's open state.
        if (!tagged("nav-dash-active")) tap("nav-dash")
        if (tagged("nav-mail-open")) tap("nav-mail")
    }

    @Test
    fun tapping_a_leaf_moves_the_active_mark_to_it() {
        require(tagged("nav-dash-active")) { "the page did not start on the dashboard" }

        tap("nav-docs")

        compose.waitUntil(10_000) { tagged("nav-docs-active") }
        // Exactly one row is current — that is the whole point of `active`.
        require(tagged("nav-dash-inactive")) { "two rows were marked current at once" }
        require(tagged("nav-settings-inactive")) { "a third row was marked current" }
    }

    @Test
    fun one_handler_serves_every_link_because_the_href_rides_back() {
        tap("nav-settings")

        // Three rows, one `on_tap` tag: the row is identified only by the href
        // the tap carried, so a wrong href would mark the wrong row.
        compose.waitUntil(10_000) { tagged("nav-settings-active") }
        require(showing("Current: /settings")) { "the screen was told the wrong destination" }
    }

    @Test
    fun a_group_opens_and_shuts_from_a_prop_the_screen_owns() {
        require(tagged("nav-mail-closed")) { "the group did not start closed" }
        require(!tagged("nav-inbox")) { "a closed group rendered its children" }

        tap("nav-mail")

        compose.waitUntil(10_000) { tagged("nav-mail-open") }
        require(tagged("nav-inbox") && tagged("nav-drafts")) {
            "the group opened but revealed no links"
        }

        tap("nav-mail")

        // And back: `opened` is a prop, so the same tap closes it again — the
        // web's <details> would have needed the server to re-render it shut.
        compose.waitUntil(10_000) { tagged("nav-mail-closed") }
        require(!tagged("nav-inbox")) { "the group shut but kept its children" }
    }

    @Test
    fun the_nested_links_sit_in_from_their_parent() {
        tap("nav-mail")
        compose.waitUntil(10_000) { tagged("nav-inbox") }

        // Scroll to the CHILD, not the parent: performScrollTo moves the
        // minimum distance, so bringing the parent flush with the bottom edge
        // leaves the rows underneath it off screen — and an off-screen node
        // reports (0, 0, 0, 0) whatever its layout says.
        compose.onNodeWithTag("nav-inbox", useUnmergedTree = true).performScrollTo()
        compose.waitForIdle()

        val parent = bounds("nav-mail")
        val child = bounds("nav-inbox")
        require(parent.width > 0f && child.width > 0f) {
            "a row was measured off screen: parent=$parent child=$child"
        }

        // `indent` is 24 on this example. Geometry is the only thing that says a
        // nested link belongs to the group above it.
        require(child.left > parent.left + 8f) {
            "the nested links are not indented: parent=$parent child=$child"
        }
        require(child.top > parent.top) { "the nested links are not below their parent" }
    }

    @Test
    fun a_nested_link_reports_on_its_own_and_leaves_the_group_open() {
        tap("nav-mail")
        compose.waitUntil(10_000) { tagged("nav-inbox") }

        tap("nav-inbox")

        compose.waitUntil(10_000) { tagged("nav-inbox-active") }
        require(tagged("nav-drafts-inactive")) { "its sibling was marked too" }
        // Choosing a destination is not the same as collapsing the section.
        require(tagged("nav-mail-open")) { "picking a nested link closed the group" }
    }

    @Test
    fun default_opened_is_open_at_mount_and_stays_where_it_is() {
        require(tagged("nav-team-open")) { "default_opened did not open the group" }
        require(tagged("nav-alice") && tagged("nav-bob")) { "the open group rendered no links" }

        tap("nav-team")
        Thread.sleep(400)

        // Uncontrolled means fixed here: with no `opened` and no `on_toggle`
        // there is nowhere for the answer to live, so the row wires no handler
        // at all. The web's <details> would have shut on this tap.
        require(tagged("nav-team-open")) { "an uncontrolled group toggled itself" }
    }

    @Test
    fun a_disabled_row_reports_nothing_while_its_sibling_still_does() {
        val before = tagged("nav-reports-active")

        tap("nav-archive")
        Thread.sleep(400)

        require(tagged("nav-reports-active") == before) { "a disabled row fired its handler" }
        require(tagged("nav-archive-disabled")) { "the disabled row is not marked as one" }

        tap("nav-reports")

        // The disabled row is inert, not the example — its neighbour still works.
        compose.waitUntil(10_000) { tagged("nav-reports-active") != before }
    }

    @Test
    fun every_glyph_is_attributable_to_the_row_it_belongs_to() {
        // A ▤ or a ↗ is the same character wherever it appears, so the icon and
        // trailing slots carry tags of their own. The badge is a NODE in the
        // trailing slot, and it is tagged exactly as a glyph string would be.
        for (tag in listOf("nav-dash-icon", "nav-docs-trailing", "nav-reports-trailing")) {
            require(tagged(tag)) { "$tag is not addressable" }
        }
    }

    @Test
    fun the_page_renders_every_example() {
        for (heading in listOf(
            "Leaves",
            "A group the screen owns",
            "default_opened",
            "Disabled, and a node",
            "Props",
        )) {
            compose.onAllNodesWithText(heading, substring = true)[0]
                .performScrollTo()
                .assertIsDisplayed()
        }
    }
}
