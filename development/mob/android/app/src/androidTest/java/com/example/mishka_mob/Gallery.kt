package com.example.mishka_mob

import androidx.compose.ui.test.hasScrollToNodeAction
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.junit4.ComposeTestRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.performScrollToNode

/**
 * Bring a gallery card into the tree before a test taps it.
 *
 * The home screen is one lazy list (`:list`, a LazyColumn, since the grid was
 * virtualized), so a card below the fold is not composed and
 * `performScrollTo()` has no node to scroll to. Scroll the list to the card
 * first. A no-op when the text is already composed, as a heading on a
 * component page is, or when no lazy list is showing.
 */
fun ComposeTestRule.revealCard(name: String) {
    if (onAllNodesWithText(name).fetchSemanticsNodes().isNotEmpty()) return

    val lists = onAllNodes(hasScrollToNodeAction())
    if (lists.fetchSemanticsNodes().isEmpty()) return

    lists[0].performScrollToNode(hasText(name))
    waitForIdle()
}
