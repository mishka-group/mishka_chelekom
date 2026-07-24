package com.example.mishka_mob

import org.json.JSONArray
import org.json.JSONObject

/**
 * Immutable data class representing one node in the Mob component tree.
 * Parsed from the JSON binary produced by Mob.Renderer on the BEAM.
 */
data class MobNode(
    val type: String,
    val props: Map<String, Any?>,
    val children: List<MobNode>
)

/** Recursively parse a JSONObject into a MobNode tree. */
fun JSONObject.toMobNode(): MobNode {
    val propsMap = mutableMapOf<String, Any?>()
    val propsObj = optJSONObject("props") ?: JSONObject()
    for (key in propsObj.keys()) {
        propsMap[key] = propsObj.get(key)
    }

    val childList = mutableListOf<MobNode>()
    val childArr  = optJSONArray("children") ?: JSONArray()
    for (i in 0 until childArr.length()) {
        childList.add(childArr.getJSONObject(i).toMobNode())
    }

    return MobNode(
        type     = getString("type"),
        props    = propsMap,
        children = childList
    )
}
