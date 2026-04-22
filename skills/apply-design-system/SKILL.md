---
name: apply-design-system
description: "Use when reconnecting an existing Figma screen, frame, or multi-section design to a published design system, including review-then-apply migrations, dependency-aware swaps, composition from primitives, and validation of real library-backed results."
---

# Connect A Design To A Design System

Use this skill for an existing Figma design that should reuse a published design system instead of detached layers, local wrappers, or one-off components.

This is the canonical workflow for multi-section design-system migration. Product-specific skills may add library-specific rules, but they should inherit the process defined here instead of restating it.

This skill supports two entry modes:
- `review-then-apply`: the user wants a broad pass and the exact offending sections are not yet identified
- `apply-known-scope`: the user already knows which sections or clusters should be brought onto the design system

Load these capabilities first:
- Figma MCP read access for tools such as `get_metadata`, `get_screenshot`, and `search_design_system`
- a `figma-use`-style helper before any `use_figma` call, when your environment requires one
- a screen-building companion workflow, when available, if you are reconnecting a full screen or page

Do not use this skill as the default follow-up to a single `audit-design-system` finding. For one targeted issue, use [fix-design-system-finding](../fix-design-system-finding/SKILL.md) so the write scope stays narrow.

## Use This Skill For

- reconnecting multiple sections on an existing screen to a published design system
- replacing local wrappers or detached layers with exact library swaps or composed library primitives
- migration work that needs dependency planning, blocker handling, and post-change validation
- design-system-specific overlay skills that need a shared migration workflow

## Core Rule

Do not treat a section as connected just because it contains a few design-system buttons or icons.

This skill is for multi-section reconciliation. If the task can be satisfied by fixing one specific reviewed node, the narrower finding-fix skill is the better choice.

Classify each section into exactly one bucket:
- `already-connected`: the section itself is a library instance or a composition the user explicitly accepts as already canonical
- `exact-swap`: a published library component or variant can replace the section directly
- `compose-from-primitives`: no single library component exists, but the section can be rebuilt from published library primitives
- `blocked`: the library does not expose the needed components, imports fail, or the section is intentionally bespoke

## Critical Precondition

Before any other step, attempt to import at least one key component from the target design system library, such as the main card, button, or nav component.

- If import succeeds, proceed with the workflow below.
- If import fails due to font, permissions, timeout, or any other error, stop immediately and classify all affected sections as `blocked`.
- Do not attempt visual-only workarounds or style-matching.
- Report the exact error message and blocker reason in the deliverable.

## Failure Prevention Rules

These rules are mandatory because reconnection often appears correct in properties while still failing on the canvas.

1. Treat every swap or replacement as an ID boundary.
   - After replacing a node, do not keep using old child IDs or assumptions about the previous subtree.
   - Re-discover the live node from a stable parent such as the target frame, section wrapper, or returned new instance ID.
2. Verify rendered output, not only component properties.
   - A property like `Title text` or `Label text` is not sufficient evidence on its own.
   - Inspect the visible descendant `TEXT` nodes and any relevant `FRAME` visibility state after each change.
3. Inspect the whole section footprint, not just the instance internals.
   - Duplicate labels or helper text may be separate sibling or top-level text nodes near the component, not descendants of the instance.
   - After each section update, inspect nearby and sibling nodes inside the target frame for redundant detached text.
4. Re-validate the new instance before deleting the old one whenever practical.
   - For exact swaps or family changes, create or import the replacement, inspect its real property keys and rendered descendants, then remove the old node.
5. Never infer variant behavior across families.
   - When moving from one component set to another, inspect the actual property keys, visible text nodes, and icon slots on the new instance before patching it.
6. Distinguish evidence levels in your reasoning.
   - `componentProperties` proves the override request.
   - descendant `TEXT` or `FRAME` visibility proves what is actually rendered.
   - section-level inspection proves there are no duplicate detached nodes left around the instance.
7. Treat font-gated dry runs as a strategy issue, not automatically as a library blocker.
  - Cloning, duplicating, or appending an existing legacy node with text may require access to that legacy node's current fonts.
  - That does not by itself prove the target design-system component cannot be imported or used.
  - When a direct library validation path exists, prefer importing a fresh library instance, inspecting its real property schema, or replacing the live node in a backed-up scope instead of duplicating the old node first.
  - Only use clone-and-swap dry runs when you specifically need override-carryover evidence and the legacy fonts are available.
8. Treat stale canvas text as a repaint problem until proven otherwise.
  - If visible descendant `TEXT` nodes contain the intended copy but the canvas or screenshot still shows placeholders, do not assume the override failed.
  - Prefer editing the live visible descendant `TEXT` nodes directly over relying only on exposed text properties when the component family is known to repaint inconsistently.
  - Before concluding that manual interaction is required, switch to the target frame's actual page, focus the updated instances or text nodes there, and re-check the rendered output.
  - Distinguish a render invalidation issue from a real data-write failure: live descendant text proves the write; screenshot or canvas mismatch proves repaint is still pending.

## Required Workflow

### 1. Determine Scope First

Before gathering replacement candidates, decide whether the screen needs an initial audit.

If scope is not already identified:
1. Run [audit-design-system](../audit-design-system/SKILL.md) or perform an equivalent internal audit pass.
2. Collapse the review output into section-sized work packages instead of treating every micro-finding as a separate rewrite task.
3. If the review produces only one narrow finding, switch to [fix-design-system-finding](../fix-design-system-finding/SKILL.md) instead of continuing here.

If scope is already identified, continue directly.

Do not skip component discovery just because a review already exists. Review identifies drift; this skill still has to choose the actual replacement primitives and variants.

### 2. Capture The Current State

Before writing:
1. Get the target frame metadata with `get_metadata`.
2. Get a screenshot with `get_screenshot`.
3. If you need `get_design_context` and Figma asks the Code Connect question, ask the user exactly as instructed by the tool before proceeding.

For this skill, prefer `get_metadata` plus `use_figma` for structure discovery. `get_design_context` is optional unless it unlocks missing context.

### 3. Back Up The Target Screen

Before destructive edits, duplicate the frame or page and place the backup to the right.

Name it clearly, for example:
- `Backup - Start`
- `Backup - Mobile dashboard`

Do this in its own `use_figma` call and return the created node ID.

### 4. Inventory The Existing Screen

Inspect the target frame before searching the library.

Use `use_figma` to gather:
- top-level section instances and groups
- each section's `mainComponent`
- whether that component is local, remote, or missing
- nested published components already used inside each local wrapper
- exposed text and variant properties when present
- detached or sibling text nodes near candidate sections that might survive a later swap
- parent layout state: auto-layout yes or no, direction, and gap

Prefer exact keys over names. Names are only hints.

Also identify dependencies. Flag sections that:
- share a common parent group or component
- reuse override text or property values, such as a title used in both a section and its subtitle
- are nested inside a local wrapper that wraps multiple children

Useful read-only inventory pattern:

```js
(async () => {
  try {
    await figma.setCurrentPageAsync(figma.root.children.find(p => p.id === "PAGE_ID"));
    const frame = await figma.getNodeByIdAsync("FRAME_ID");

    const sections = frame.findAll(n => n.type === "INSTANCE" || n.type === "GROUP").map(inst => {
      const mainComponent = inst.mainComponent;
      const componentSet = mainComponent?.parent?.type === "COMPONENT_SET" ? mainComponent.parent : null;
      const parent = inst.parent;
      return {
        instanceId: inst.id,
        instanceName: inst.name,
        componentName: mainComponent?.name ?? null,
        componentKey: mainComponent?.key ?? null,
        componentSetName: componentSet?.name ?? null,
        componentSetKey: componentSet?.key ?? null,
        parentType: parent?.type,
        parentAutoLayout: parent?.layoutMode !== "NONE",
        parentGap: parent?.itemSpacing ?? null,
      };
    });

    const detachedText = frame.findAll(n => n.type === "TEXT").map(textNode => ({
      textId: textNode.id,
      content: textNode.characters,
      nearbyIds: frame.findAll(n =>
        (n.type === "INSTANCE" || n.type === "GROUP") &&
        Math.abs(n.x - textNode.x) < 200 && Math.abs(n.y - textNode.y) < 200
      ).map(n => n.id),
    }));

    figma.closePlugin(JSON.stringify({ createdNodeIds: [], mutatedNodeIds: [], sections, detachedText }));
  } catch (error) {
    figma.closePluginWithFailure(error.message);
  }
})()
```

### 5. Map Dependencies And Sequencing

**Do not skip dependency planning—it prevents multi-section sequencing errors.**

Before making any swaps, understand the dependency graph.

1. Identify coupled sections. If Section A is a wrapper containing Section B, or if both share a parent, mark them as coupled.
2. Plan swap order. Swap leaf sections before parents. Swap parents that do not depend on shared overrides first.
3. Mark shared state. If two sections inherit the same text override or property from a parent, plan to swap both in a single operation or re-validate the parent afterward.

Example sequences:
- Bottom-up, safest for compositions: swap primitive buttons, then card, then card container
- Paired swap: if a section and its subtitle are siblings sharing a parent, swap both together and screenshot the parent afterward
- Isolated swaps: if sections do not share a parent or overrides, swap independently and validate each

Document the planned sequence in your response before starting edits. This prevents surprises and lets the user review the plan.

### 6. Build A Component Map From The Design System

Prefer authoritative sources in this order:
1. Existing screens in the same library or workfile that already use the system
2. Known library pages inspected directly with `use_figma`
3. `search_design_system` as a fallback only

When using `search_design_system`, remember:
- results may include unrelated team or community libraries
- broad queries are useful for discovery, but do not trust them without verifying the actual file or page
- once the right library is known, prefer direct inspection of that file over repeated search calls

For each candidate, capture:
- component or component-set key
- exact variant name
- whether the section is a one-to-one swap or a composition
- text property keys or nested instance properties needed for overrides

Do not default blindly to the library's primary or default variant.

Before choosing a variant, inspect the original node for:
- semantic cues: name, copy, and usage context
- visual cues: fills, strokes, effects, corner radius, and typography treatment
- variant-like traits: existing visual patterns in the screen, such as primary vs secondary button treatment

Then compare those cues against the available component-set variants and choose the closest match. If the family is correct but the variant match is ambiguous, call that out explicitly instead of silently using the default.

### 7. Decide Section Strategy

Apply the blocker guard first:
- If any required component import fails, classify the section as `blocked` and stop. Do not proceed for that section.
- Do not attempt to make it look like the design system using only local styles or visual tweaks.

Use these heuristics:
- `exact-swap` if a library component matches the section's job and structure closely enough that `swapComponent()` or a direct replacement preserves intent
- `compose-from-primitives` if the section is really a container around library pieces such as avatar, badge, buttons, metrics, or nav items
- `blocked` if the design system lacks the composite, the library is not published, imports fail, or the section should remain bespoke

Common patterns:
- header summary blocks are often `compose-from-primitives`, not one component
- alerts and metrics often have strong `exact-swap` candidates
- appointment or patient cards often require composition unless the system explicitly ships those domain cards
- bottom nav bars are frequently custom containers built from nav-item primitives

For compositions, decide early whether to build beside the original and compare visually, or rebuild in place. Building beside is safer for complex layouts. Rebuilding in place is faster if the replacement is simple and the parent is auto-layout.

### 8. Update One Section At A Time

Never rewrite the entire screen in one script.

For each section in dependency order:
1. Read the current node IDs from the live frame. Do not reuse cached IDs.
2. Import or locate the library component and verify import succeeded.
3. Match the closest variant to the original section before swapping or rebuilding.
4. Detect parent layout state: is the parent auto-layout and what is the gap.
5. For exact swap, use `swapComponent()` if the node is already an instance of a compatible family.
6. For compositions, build the replacement beside the original, using the same parent and an offset, then visually compare before moving.
7. Return all mutated node IDs and screenshot immediately. Do not batch multiple sections into one script.
8. Validate with `get_screenshot` before moving to the next section.

Dry-run guidance:
- If you only need to inspect the target library family, import a fresh library instance and inspect that instance directly.
- If the current screen uses fonts unavailable to the plugin runtime, avoid clone-based dry runs of legacy text-bearing nodes unless they are strictly necessary.
- If a direct replacement path is available and the screen has already been backed up, prefer section-by-section live replacement plus immediate screenshot validation over duplicating the old section just to test the swap.
- Treat font errors from touching the old node as a signal to change validation strategy, not as automatic evidence that the migration is blocked.

Repaint guidance:
- If descendant `TEXT` nodes are correct but the section still renders placeholder copy, first classify the problem as repaint-pending rather than failed migration.
- Prefer updating the visible descendant `TEXT` nodes directly when exposed text properties do not repaint reliably.
- Run the refresh recipe on the section's actual page before deciding that the repaint is blocked.

Refresh recipe:
1. Write the intended copy onto the live visible descendant `TEXT` nodes.
2. Resolve the section's containing page and call `await figma.setCurrentPageAsync(page)`.
3. Select each updated instance on that page, one at a time.
4. Call `figma.viewport.scrollAndZoomIntoView([node])` for the selected node.
5. If the canvas is still stale, toggle `node.visible = false` and then `node.visible = true`.
6. Re-run the close-up screenshot for that section before deciding whether the repaint worked.

Example repaint pass:

```js
await figma.setCurrentPageAsync(targetPage);

for (const node of updatedNodes) {
  figma.currentPage.selection = [node];
  figma.viewport.scrollAndZoomIntoView([node]);
  node.visible = false;
  node.visible = true;
}
```

When the parent is not auto-layout, treat replacement as a layout-risk operation:
- preserve `x` and `y` explicitly
- preserve width and height explicitly when the replacement should occupy the same footprint
- do not assume the new instance will inherit the old node's position or size
- warn the user that absolute-positioned or grouped parents can cause drift after swaps or rebuilds
- suggest converting the parent to auto-layout only when the user wants structural cleanup, not as the default move

For compositions:
- import all primitives first and verify they import successfully
- build the composition in a temporary frame beside the original section
- visually compare the temporary against the original for spacing, alignment, and text rendering
- once validated, move the composition into place and delete the original
- validate that the parent layout did not shift

### 9. Handle Import Failures Explicitly

If `importComponentSetByKeyAsync()` or `importComponentByKeyAsync()` fails or times out:

1. Stop immediately.
2. Do not continue making unrelated edits and pretend the section is connected.
3. Check whether the exact component key already exists elsewhere in the target file.
4. If the library file is accessible, verify the exact component key there.
5. Try importing the exact component key instead of the component-set key.
6. If imports still fail after these checks, mark the section `blocked` and report the blocker clearly.

Treat these as real blockers:
- published key exists in the library but import times out
- `search_design_system` finds the family, but the target file cannot import it
- only nested primitives can be imported, not the intended composite
- the key is a component-set key, not a component key, and component-set imports are not supported in your Figma version

Do not misclassify these as import blockers:
- a font-loading failure caused by cloning or appending the existing legacy node during a dry run
- an unavailable legacy font encountered while trying to duplicate the pre-migration section for comparison
- any font issue that occurs before the target design-system component import itself is attempted

Blocker report format:
- Component: name
- Blocker Type: import failure, timeout, missing, permission, or unpublished
- Error: exact error message or observed behavior
- Attempted fixes: what was tried
- Resolution: what is needed to unblock, such as library update, file sharing, or key correction
- Status: cannot proceed

You must not attempt to fake connection by applying only visual styling.

### 10. Validate What Actually Changed

After each section, perform a targeted validation.

Visual validation checklist:
- instance is really linked to a library component by checking `mainComponent`
- all placeholder text is gone
- descendant `TEXT` nodes match the original labels and content
- spacing matches the original
- no hidden `TEXT` or `FRAME` nodes remain in the section footprint
- parent layout did not regress
- the chosen variant was actually applied

Screenshot validation:
1. Take a close-up screenshot of just the changed section.
2. Compare side-by-side with the original screenshot from Step 2.
3. Look for spacing drift, text clipping, icon alignment, color shifts, and effect loss.
4. If any regression appears, stop and fix it before proceeding.

If the screenshot still shows stale placeholder text but the live descendant `TEXT` nodes are correct:
1. Re-run validation on the section's actual page, not whichever page the plugin last had open.
2. Run the refresh recipe and re-check the screenshot.
3. Report the result as `repaint-pending` rather than `blocked` when the write is correct but the canvas still has not refreshed.

After all sections are complete:
- take a full-frame screenshot and compare with the original backup
- confirm no unintended changes to sections marked `already-connected`
- confirm all sections are either library-backed or explicitly marked `blocked`

### 11. Document Composition Dependencies

If you composed a section from multiple primitives, document:
- which primitives were used, including names and keys
- the layout structure, such as auto-layout vertical with an 8px gap
- any overrides that were necessary, such as text properties or hidden slots
- whether the composition could be extracted into a reusable local component for later publication

## Known Pitfalls From Real Migrations

### Duplicate Detached Labels Beside Inputs Or Dropdowns

Symptom:
- the component appears to have the correct internal title or label
- the canvas still shows an extra `ID`, `ID type`, helper label, or similar copy nearby

Root cause:
- the duplicate text is not inside the library instance at all
- it is a separate sibling or top-level text node left behind from the pre-system layout

Required response:
- inspect the section footprint from the stable parent frame or group
- list sibling and nearby text nodes, not only instance descendants
- remove or hide the detached duplicate only after confirming the library instance renders the intended copy itself

### Family Swap With Mismatched Defaults

Symptom:
- a button was swapped from one family to another, such as `Tertiary button` to `Secondary button`
- the new instance exists, but the label, icon, or visible defaults are wrong even though the family is correct

Root cause:
- property keys, default text, icon slots, and visible descendants differ across component families
- patch logic reused assumptions from the old family instead of inspecting the new instance

Required response:
- import or create the replacement instance first
- inspect that exact new instance's `componentProperties`, visible text nodes, and nested icon instances
- patch the new instance using its own property keys, not the old family's keys
- verify the rendered text and icon state in a screenshot before removing the old instance when practical

### Composition Layout Drift When Parent Is Grouped

Symptom:
- a composed section was rebuilt and looks correct in isolation
- when placed in a grouped, non-auto-layout parent, it shifts or overlaps siblings

Root cause:
- the composed section's `x` and `y` were not preserved when moving it into place
- grouped parents rely on absolute positioning, so each sibling needs explicit coordinates

Required response:
- capture the original section's `x`, `y`, `width`, and `height`
- explicitly set those properties when moving the composition into place
- re-inspect the parent and all siblings to ensure no overlaps or drift
- if parent shifting is unavoidable, offer auto-layout conversion only as a suggestion

### Multi-Section Sequencing Errors

Symptom:
- Section A was swapped successfully
- Section B, which sits inside Section A's parent, now has broken spacing or overlaps
- the issue was not visible until Section A's size changed

Root cause:
- dependency order was wrong
- or the parent's auto-layout rules were not re-checked after the first swap

Required response:
- plan dependency order before starting any swaps
- for coupled sections, swap in bottom-up order
- after swapping in a grouped parent, re-validate all siblings
- if the parent is auto-layout, re-check gap and alignment settings after swaps

## Writing Rules

- work incrementally and preserve a backup
- plan dependency order before making any swaps
- prefer direct library inspection over noisy search results
- prefer exact component keys over names
- match the variant to the original visual treatment, not just the correct component family
- preserve position and size explicitly when replacing content inside non-auto-layout parents
- for compositions, build beside the original and visually compare before swapping in
- use imperative evidence in the report: node names, keys, component families, dependency order, and whether the final node is local or library-backed
- do not claim full reconnection when the result is still a local shell around a few shared children
- if a section must remain bespoke, say so and explain why
- always call out ambiguous variant matches instead of silently choosing the default

## Deliverable Format

When closing the task, report in this order:

1. Precondition result: `Import test passed` or `Blocked at precondition: [reason]`
2. Dependency order: `Swaps planned in this order: [list]`
3. Results by category:
   - `Swapped`: sections replaced directly with library instances, including names and keys
   - `Composed`: sections rebuilt from library primitives, including composition structure
   - `Already connected`: sections that were already valid
   - `Blocked`: sections that could not be connected, with concrete reason and remediation path
4. Visual validation: `All sections tested against original screenshot. No regressions detected.` or `Regressions found: [list]`
5. Remaining work: if any sections were marked `blocked`, list what is needed to unblock them

If a product-specific skill exists, it should add only system-specific rules such as library precedence, family selection, or validation checks. It should not duplicate the migration process defined here unless the product system materially changes it.
- but when placed in a grouped (non-auto-layout) parent, it shifts left/right or overlaps siblings

**Root cause:**
- the composed section's x/y was not preserved when moving it into place
- grouped parents rely on absolute positioning — each sibling needs explicit coordinates

**Required response:**
- after building the composition, capture the original section's `x`, `y`, `width`, `height`
- when moving the composition into place, explicitly set these properties
- re-inspect the parent and all siblings to ensure no overlaps or drift
- if parent shifting is unavoidable, offer to convert the parent to auto-layout (only as a suggestion, not default)

### Multi-Section Sequencing Errors

**Symptom:**
- Section A was swapped successfully
- Section B, which sits inside Section A's parent, now has broken spacing or overlaps
- The issue wasn't visible until Section A's size changed

**Root cause:**
- dependency order was wrong (should have swapped Section B first or both together)
- or the parent's auto-layout rules were not re-checked after the first swap

**Required response:**
- plan dependency order before starting any swaps (Step 5)
- for coupled sections, swap in bottom-up order (children before parents)
- after swapping in a grouped parent, re-validate all siblings
- if parent layout is auto-layout, re-check the gap and alignment settings after swaps

## Writing Rules

- Work incrementally and preserve a backup.
- Plan dependency order before making any swaps (Step 5).
- Prefer direct library inspection over noisy search results.
- Prefer exact component keys over names.
- Match the variant to the original visual treatment, not just the correct component family.
- Preserve position and size explicitly when replacing content inside non-auto-layout parents.
- For compositions, build beside the original and visually compare before swapping in.
- Use imperative evidence in the report: node names, keys, component families, dependency order, and whether the final node is local or library-backed.
- Do not claim full reconnection when the result is still a local shell around a few shared children.
- If a section must remain bespoke, say so and explain why.
- Always call out ambiguous variant matches instead of silently choosing the default.

## Deliverable Format

When closing the task, report in this order:

1. **Precondition result:** "Import test passed" or "Blocked at precondition: [reason]"
2. **Dependency order:** "Swaps planned in this order: [list]"
3. **Results by category:**
   - `Swapped`: sections replaced directly with library instances (list names and keys)
   - `Composed`: sections rebuilt from library primitives (list composition structure)
   - `Already connected`: sections that were already valid
   - `Blocked`: sections that could not be connected, with the concrete reason and remediation path

4. **Visual validation:** "All sections tested against original screenshot. No regressions detected." or "Regressions found: [list]"
5. **Remaining work:** If any sections were marked `blocked`, list what's needed to unblock them.

Example closure:

```
Precondition: ✓ Import test passed (Button, Card, Badge all imported successfully)

Dependency order:
  1. Badge (primitive, no dependencies)
  2. Metric card (uses Badge)
  3. Header block (uses Metric card)

Results:
  Swapped (2): Header title (typography/heading), Status indicator (state/status)
  Composed (2): Metric card (from badge + metric + typography), Header block (from metric card + heading)
  Already connected (1): Sidebar nav (already using nav-item library component)
  Blocked (1): Custom chart widget (no published chart component exists)

Visual validation: ✓ All sections match original. No spacing or text regressions.

Remaining work: To unblock the chart widget, the design system needs a published 
"Chart card" component or primitives (axis, gridlines, legend). Request added to design 
system backlog.
```

If everything is blocked, say that plainly and include the exact failure mode:

```
Precondition: ✗ Import test failed

Error: Cannot import any components from the target library.
Reason: Library file is not published (status: "Draft").
Remediation: Publish the library file in Figma Team settings, or grant Editor 
access to [user email]. Once published, re-run the precondition test.

All sections marked blocked pending library publication.
```