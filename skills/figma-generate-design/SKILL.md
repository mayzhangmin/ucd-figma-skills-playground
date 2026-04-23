---
name: figma-generate-design
description: "Use this skill alongside figma-use when the task involves translating a screenshot, application page, view, or multi-section layout into Figma using a provided design library link. Primary triggers: 'convert this screenshot to Figma', 'rebuild this screen from an image', 'recreate this UI in Figma with our design system', 'use this Figma library to rebuild this screenshot'. Secondary triggers: 'write to Figma', 'create in Figma from code', 'push page to Figma', 'take this app/page and build it in Figma', 'create a screen', 'build a landing page in Figma', 'update the Figma screen to match code'. This is the preferred workflow skill whenever the user wants to build or update a full page, screen, or view in Figma from a screenshot first, using the provided Figma design library as the source of components and tokens. Discovers design system components, variables, and styles via search_design_system, imports them, and assembles screens incrementally section-by-section using design system tokens instead of hardcoded values while preserving the screenshot's visible wording."
disable-model-invocation: false
---

# Rebuild Screens from Screenshots with a Design System

Use this skill to create or update full-page screens in Figma by **reusing the published design system** — components, variables, and styles — rather than drawing primitives with hardcoded values. The primary source is a screenshot or image, though a running app, source code, or written description can also be used. The component and token source should be the Figma design library link the user provides. The key insight: the Figma file likely has a published design system with components, color/spacing variables, and text/effect styles that correspond to the product UI. Find and use those instead of tracing the screenshot with boxes and hex colors.

This skill is optimized for screenshot-to-design-library reconstruction. Start from the screenshot, infer the section structure and likely component families, then rebuild the screen with published components and tokens from the provided library. Code and live app inputs are supporting evidence, not the default path.

The output must preserve the screenshot's visible wording. If the screenshot says "Register", "Forgot password", or "Enterprise plan", the generated Figma design should use that same wording unless the user explicitly asks for content changes.

**MANDATORY**: You MUST also load your environment's `figma-use`-style helper before any `use_figma` call. That helper should contain the runtime rules that apply to every script you write, such as font loading and Figma API gotchas.

**Always pass `skillNames: "figma-generate-design"` when calling `use_figma` as part of this skill.** This is a logging parameter — it does not affect execution.

## Skill Boundaries

- Use this skill when the deliverable is a **Figma screen** (new or updated) composed of design system component instances, especially when the source of truth is a screenshot or image.
- If the user wants to generate **code from a Figma design**, switch to the environment's Figma-to-code implementation workflow.
- If the user wants to create **new reusable components or variants**, use the environment's lower-level `figma-use` workflow directly.
- If the user wants to write **Code Connect mappings**, switch to the environment's Code Connect workflow.

## Prerequisites

- Figma MCP server must be connected
- The user must provide a Figma design library link, file key, or target file that already exposes the design system components to use
- The target Figma file must have that published design system linked, or the workflow must import from the provided library
- User should provide either:
  - A Figma file URL / file key to work in
  - Or context about which file to target (the agent can discover pages)
- A screenshot, source code, running app, or description of the screen to build/update

Preferred inputs, in order:

1. A screenshot or image of the target screen
2. A Figma design library link or a Figma file that already uses the target design library
3. Source code or a live app only as supporting evidence for ambiguous structure or content

If the user does not provide a design library link or a file that clearly exposes the intended design system, stop and ask for it before building. Do not choose an arbitrary library.

## Secondary Workflow for Running Web Apps

When the source is a **running web app** rather than a standalone screenshot, the best results come from running both approaches in parallel:

1. **In parallel:**
   - Start building the screen using this skill's workflow (use_figma + design system components)
   - Run `generate_figma_design` to capture a pixel-perfect screenshot of the running web app
2. **Once both complete:** Update the use_figma output to match the pixel-perfect layout from the `generate_figma_design` capture. The capture provides the exact spacing, sizing, and visual treatment to aim for, while your use_figma output has proper component instances linked to the design system.
3. **Once confirmed looking good:** Delete the `generate_figma_design` output — it was only used as a visual reference.

This combines the best of both: `generate_figma_design` gives pixel-perfect layout accuracy, while use_figma gives proper design system component instances that stay linked and updatable.

**This workflow is secondary.** It only applies to web apps where `generate_figma_design` can capture the running page. For screenshot-led work, non-web apps (iOS, Android, etc.), or existing-screen updates, use the standard workflow below.

If the only source is a screenshot or image, skip `generate_figma_design`. Use the screenshot as the visual reference and rebuild the screen section-by-section from design system components, variables, and styles.

## Required Workflow

**Follow these steps in order. Do not skip steps.**

### Step 0: Confirm the Design Library Source

Before analyzing the screen, confirm which Figma design library should supply the components, variables, and styles.

1. If the user provided a Figma design library link, use that as the source of truth.
2. If the user provided a target workfile that already uses the library, inspect that file and confirm the relevant library is actually available.
3. Search and import from that provided library before considering any other library.
4. Do not substitute another team or community library just because search results are broader or easier to use.

The screenshot defines what to recreate. The provided Figma design library defines what you must recreate it with.

### Step 1: Understand the Screen

Before touching Figma, understand what you're building:

1. Inspect the screenshot first and identify the page structure, major sections, repeated patterns, visible copy, and obvious component families.
2. Identify the major sections of the screen (e.g., Header, Hero, Content Panels, Pricing Grid, FAQ Accordion, Footer).
3. For each section, list the UI components involved (buttons, inputs, cards, navigation pills, accordions, etc.).
4. Only if the screenshot leaves important ambiguities, use source code, an existing app, or neighboring screens as supporting evidence.

When the source is a screenshot, treat the screenshot as a layout and styling reference, not as something to trace literally. Your job is to recreate the same design intent with library-backed components and tokens.

For screenshot-driven work, extract at least these details before searching the design system:

- viewport type: desktop, tablet, or mobile
- section order and rough heights
- repeated UI patterns that likely map to one shared component
- visible text that must be preserved exactly
- ambiguous areas where the library choice is uncertain and needs explicit verification

Create a copy inventory from the screenshot before building. Capture all visible wording that appears in the outcome, including:

- headings and subheadings
- button labels
- input placeholders and helper text
- tab labels and navigation items
- card titles, metrics, badges, and status labels
- footnotes, disclaimers, and captions

Treat this wording as part of the acceptance criteria. The working content in the generated Figma outcome should match the screenshot unless the user explicitly approves a content change or the screenshot text is unreadable.

Decide early whether each visible area is most likely:

- an exact library component instance
- a section composed from several library primitives
- a bespoke layout container that should stay manual but use library tokens and nested components

### Step 2: Discover Design System — Components, Variables, and Styles

You need three things from the design system: **components** (buttons, cards, etc.), **variables** (colors, spacing, radii), and **styles** (text styles, effect styles like shadows). Don't hardcode hex colors or pixel values when design system tokens exist.

#### 2a: Discover components

**Preferred: inspect existing screens first.** If the target file or provided library already contains screens using the same design system, skip broad discovery and inspect those existing instances directly. A single `use_figma` call that walks an existing frame's instances gives you an exact, authoritative component map:

```js
const frame = figma.currentPage.findOne(n => n.name === "Existing Screen");
const uniqueSets = new Map();
frame.findAll(n => n.type === "INSTANCE").forEach(inst => {
  const mc = inst.mainComponent;
  const cs = mc?.parent?.type === "COMPONENT_SET" ? mc.parent : null;
  const key = cs ? cs.key : mc?.key;
  const name = cs ? cs.name : mc?.name;
  if (key && !uniqueSets.has(key)) {
    uniqueSets.set(key, { name, key, isSet: !!cs, sampleVariant: mc.name });
  }
});
return [...uniqueSets.values()];
```

Only fall back to `search_design_system` when the file has no existing screens to reference. When using it, constrain discovery to the provided library when possible, then search broadly within that library — try multiple terms and synonyms (e.g., "button", "input", "nav", "card", "accordion", "header", "footer", "tag", "avatar", "toggle", "icon", etc.). Use `includeComponents: true` to focus on components.

**Include component properties** in your map — you need to know which TEXT properties each component exposes for text overrides. Create a temporary instance, read its `componentProperties` (and those of nested instances), then remove the temp instance.

Example component map with property info:

```
Component Map:
- Button → key: "abc123", type: COMPONENT_SET
  Properties: { "Label#2:0": TEXT, "Has Icon#4:64": BOOLEAN }
- PricingCard → key: "ghi789", type: COMPONENT_SET
  Properties: { "Device": VARIANT, "Variant": VARIANT }
  Nested "Text Heading" has: { "Text#2104:5": TEXT }
  Nested "Button" has: { "Label#2:0": TEXT }
```

#### 2b: Discover variables (colors, spacing, radii)

**Inspect existing screens first** (same as components). Or use `search_design_system` with `includeVariables: true`.

> **WARNING: Two different variable discovery methods — do not confuse them.**
>
> - `use_figma` with `figma.variables.getLocalVariableCollectionsAsync()` — returns **only local variables defined in the current file**. If this returns empty, it does **not** mean no variables exist. Remote/published library variables are invisible to this API.
> - `search_design_system` with `includeVariables: true` — searches across **all linked libraries**, including remote and published ones. This is the correct tool for discovering design system variables.
>
> **Never conclude "no variables exist" based solely on `getLocalVariableCollectionsAsync()` returning empty.** Always also run `search_design_system` with `includeVariables: true` to check for library variables before deciding to create your own.

**Query strategy:** `search_design_system` matches against **variable names** (e.g., "Gray/gray-9", "core/gray/100", "space/400"), not categories. Run multiple short, simple queries in parallel rather than one compound query:

- **Primitive colors:** "gray", "red", "blue", "green", "white", "brand"
- **Semantic colors:** "background", "foreground", "border", "surface", "text"
- **Spacing/sizing:** "space", "radius", "gap", "padding"

If initial searches return empty, try shorter fragments or different naming conventions — libraries vary widely ("grey" vs "gray", "spacing" vs "space", "color/bg" vs "background").

Inspect an existing screen's bound variables for the most authoritative results:

```js
const frame = figma.currentPage.findOne(n => n.name === "Existing Screen");
const varMap = new Map();
for (const node of frame.findAll(() => true)) {
  const bv = node.boundVariables;
  if (!bv) continue;
  for (const [prop, binding] of Object.entries(bv)) {
    const bindings = Array.isArray(binding) ? binding : [binding];
    for (const b of bindings) {
      if (b?.id && !varMap.has(b.id)) {
        const v = await figma.variables.getVariableByIdAsync(b.id);
        if (v) varMap.set(b.id, { name: v.name, id: v.id, key: v.key, type: v.resolvedType, remote: v.remote });
      }
    }
  }
}
return [...varMap.values()];
```

For library variables (remote = true), import them by key with `figma.variables.importVariableByKeyAsync(key)`. For local variables, use `figma.variables.getVariableByIdAsync(id)` directly.

If your environment includes `figma-use` reference docs, load the variable binding patterns reference before writing scripts that bind variables.

#### 2c: Discover styles (text styles, effect styles)

Search for styles using `search_design_system` with `includeStyles: true` and terms like "heading", "body", "shadow", "elevation". Or inspect what an existing screen uses:

```js
const frame = figma.currentPage.findOne(n => n.name === "Existing Screen");
const styles = { text: new Map(), effect: new Map() };
frame.findAll(() => true).forEach(node => {
  if ('textStyleId' in node && node.textStyleId) {
    const s = figma.getStyleById(node.textStyleId);
    if (s) styles.text.set(s.id, { name: s.name, id: s.id, key: s.key });
  }
  if ('effectStyleId' in node && node.effectStyleId) {
    const s = figma.getStyleById(node.effectStyleId);
    if (s) styles.effect.set(s.id, { name: s.name, id: s.id, key: s.key });
  }
});
return {
  textStyles: [...styles.text.values()],
  effectStyles: [...styles.effect.values()]
};
```

Import library styles with `figma.importStyleByKeyAsync(key)`, then apply with `node.textStyleId = style.id` or `node.effectStyleId = style.id`.

If your environment includes `figma-use` reference docs, load the text-style and effect-style references before writing scripts that import or apply styles.

### Step 3: Create the Page Wrapper Frame First

**Do NOT build sections as top-level page children and reparent them later** — moving nodes across `use_figma` calls with `appendChild()` silently fails and produces orphaned frames. Instead, create the wrapper first, then build each section directly inside it.

Create the page wrapper in its own `use_figma` call. Position it away from existing content and return its ID:

```js
// Find clear space
let maxX = 0;
for (const child of figma.currentPage.children) {
  maxX = Math.max(maxX, child.x + child.width);
}

const wrapper = figma.createFrame();
wrapper.name = "Homepage";
wrapper.layoutMode = "VERTICAL";
wrapper.primaryAxisAlignItems = "CENTER";
wrapper.counterAxisAlignItems = "CENTER";
wrapper.resize(1440, 100);
wrapper.layoutSizingHorizontal = "FIXED";
wrapper.layoutSizingVertical = "HUG";
wrapper.x = maxX + 200;
wrapper.y = 0;

return { success: true, wrapperId: wrapper.id };
```

### Step 4: Build Each Section Inside the Wrapper

**This is the most important step.** Build one section at a time, each in its own `use_figma` call. At the start of each script, fetch the wrapper by ID and append new content directly to it.

```js
const createdNodeIds = [];
const wrapper = await figma.getNodeByIdAsync("WRAPPER_ID_FROM_STEP_3");

// Import design system components by key
const buttonSet = await figma.importComponentSetByKeyAsync("BUTTON_SET_KEY");
const primaryButton = buttonSet.children.find(c =>
  c.type === "COMPONENT" && c.name.includes("variant=primary")
) || buttonSet.defaultVariant;

// Import design system variables for colors and spacing
const bgColorVar = await figma.variables.importVariableByKeyAsync("BG_COLOR_VAR_KEY");
const spacingVar = await figma.variables.importVariableByKeyAsync("SPACING_VAR_KEY");

// Build section frame with variable bindings (not hardcoded values)
const section = figma.createFrame();
section.name = "Header";
section.layoutMode = "HORIZONTAL";
section.setBoundVariable("paddingLeft", spacingVar);
section.setBoundVariable("paddingRight", spacingVar);
const bgPaint = figma.variables.setBoundVariableForPaint(
  { type: 'SOLID', color: { r: 0, g: 0, b: 0 } }, 'color', bgColorVar
);
section.fills = [bgPaint];

// Import and apply text/effect styles
const shadowStyle = await figma.importStyleByKeyAsync("SHADOW_STYLE_KEY");
section.effectStyleId = shadowStyle.id;

// Create component instances inside the section
const btnInstance = primaryButton.createInstance();
section.appendChild(btnInstance);
createdNodeIds.push(btnInstance.id);

// Append section to wrapper
wrapper.appendChild(section);
section.layoutSizingHorizontal = "FILL"; // AFTER appending

createdNodeIds.push(section.id);
return { success: true, createdNodeIds };
```

After each section, validate with `get_screenshot` before moving on. Look closely for cropped/clipped text (line heights cutting off content) and overlapping elements — these are the most common issues and easy to miss at a glance.

#### Override instance text with setProperties()

Component instances ship with placeholder text ("Title", "Heading", "Button"). Use the component property keys you discovered in Step 2 to override them with `setProperties()` — this is more reliable than direct `node.characters` manipulation. If your environment includes a component-patterns reference, load its section on overriding text in component instances before writing the script.

For nested instances that expose their own TEXT properties, call `setProperties()` on the nested instance:

```js
const nestedHeading = cardInstance.findOne(n => n.type === "INSTANCE" && n.name === "Text Heading");
if (nestedHeading) {
  nestedHeading.setProperties({ "Text#2104:5": "Actual heading from source code" });
}
```

Only fall back to direct `node.characters` for text that is NOT managed by any component property.

When applying overrides, use the screenshot wording exactly. Do not leave placeholder text in place, do not paraphrase, and do not normalize the copy to match a default component demo unless the screenshot text is unreadable.

#### Handle repaint-pending text explicitly

Use the same term as [apply-design-system](../apply-design-system/SKILL.md): `Section Repaint Pass`.

Do not assume a text override failed just because the canvas or screenshot still shows placeholder copy.

Evidence levels:
- `setProperties()` proves the override request was sent
- visible descendant `TEXT` nodes prove the intended copy exists in the live instance
- canvas or screenshot mismatch after that usually means repaint is still pending

If exposed TEXT properties were updated but the rendered result still shows stale placeholder text:

1. Re-discover the live instance from the target frame. Do not rely on stale node IDs from before a swap or replacement.
2. Inspect the visible descendant `TEXT` nodes on the live instance.
3. If those descendant nodes already contain the intended copy, classify the issue as repaint-pending rather than failed override.
4. Prefer writing directly to the visible descendant `TEXT` nodes when the component family is known to repaint inconsistently.
5. Run the `Section Repaint Pass` on the actual page that contains the updated section. **Clicking each TEXT node is the mandatory repaint trigger — do not skip it.** This is a known Figma MCP limitation: text written via the plugin API does not always invalidate the canvas render cache until the layer is explicitly selected (simulating a click).

Section Repaint Pass steps:
  - `await figma.setCurrentPageAsync(page)`
  - For each updated instance, select the instance and call `figma.viewport.scrollAndZoomIntoView([node])`
  - Then **for every visible descendant `TEXT` node inside that instance**, do all of the following in sequence:
    1. `figma.currentPage.selection = [textNode]`
    2. `figma.viewport.scrollAndZoomIntoView([textNode])`
    3. `figma.currentPage.selection = [parentInstance]`
    4. `figma.currentPage.selection = [textNode]`  ← second selection simulates the click that triggers the render invalidation
  - After clicking all text layers, re-select the parent instance and call `scrollAndZoomIntoView` on it

Example Section Repaint Pass:
```js
await figma.setCurrentPageAsync(targetPage);

for (const instance of updatedInstances) {
  figma.currentPage.selection = [instance];
  figma.viewport.scrollAndZoomIntoView([instance]);

  const textNodes = instance.findAll(n => n.type === 'TEXT' && n.visible);
  for (const t of textNodes) {
    figma.currentPage.selection = [t];
    figma.viewport.scrollAndZoomIntoView([t]);
    figma.currentPage.selection = [instance];
    figma.currentPage.selection = [t]; // second selection = click trigger
    figma.viewport.scrollAndZoomIntoView([t]);
  }

  figma.currentPage.selection = [instance];
  figma.viewport.scrollAndZoomIntoView([instance]);
}
```

6. Re-run a close-up screenshot for that section before deciding whether more invasive fallback work is necessary.

**Always run the Section Repaint Pass immediately after any text write.** Do not defer it to a later step and do not skip it even when `setProperties()` appears to have succeeded. The click sequence is the only reliable way to flush the Figma MCP render cache.

Do not switch to manual replacement too early. If the live visible text is already correct, first treat it as a repaint problem and exhaust the `Section Repaint Pass`.

#### Read defaults carefully

When translating code components to Figma instances, check the component's default prop values in the source code, not just what's explicitly passed. For example, `<Button size="small">Register</Button>` with no variant prop — check the component definition to find `variant = "primary"` as the default. Selecting the wrong variant (e.g., Neutral instead of Primary) produces a visually incorrect result that's easy to miss.

When translating from a screenshot, you often do not have those defaults directly. Infer them from the closest existing library usage in the file, from other screens using the same design system, or from source code if available. Do not silently guess when the variant choice is ambiguous.

#### What to build manually vs. import from design system

| Build manually | Import from design system |
|----------------|--------------------------|
| Page wrapper frame | **Components**: buttons, cards, inputs, nav, etc. |
| Section container frames | **Variables**: colors (fills, strokes), spacing (padding, gap), radii |
| Layout grids (rows, columns) | **Text styles**: heading, body, caption, etc. |
| | **Effect styles**: shadows, blurs, etc. |

**Never hardcode hex colors or pixel spacing** when a design system variable exists. Use `setBoundVariable` for spacing/radii and `setBoundVariableForPaint` for colors. Apply text styles with `node.textStyleId` and effect styles with `node.effectStyleId`.

### Step 5: Validate the Full Screen

After composing all sections, call `get_screenshot` on the full page frame and compare against the source. Fix any issues with targeted `use_figma` calls — don't rebuild the entire screen.

**Screenshot individual sections, not just the full page.** A full-page screenshot at reduced resolution hides text truncation, wrong colors, and placeholder text that hasn't been overridden. Take a screenshot of each section by node ID to catch:
- **Cropped/clipped text** — line heights or frame sizing cutting off descenders, ascenders, or entire lines
- **Overlapping content** — elements stacking on top of each other due to incorrect sizing or missing auto-layout
- Placeholder text still showing ("Title", "Heading", "Button")
- Truncated content from layout sizing bugs
- Wrong component variants (e.g., Neutral vs Primary button)

If a section screenshot still shows placeholder copy after overrides:
1. Inspect the live visible descendant `TEXT` nodes before assuming the write failed.
2. If descendant text is correct, treat the mismatch as repaint-pending.
3. Run the `Section Repaint Pass` on the section's actual page — **this means clicking each visible TEXT node individually, not just toggling visibility.** Re-take the section screenshot after.
4. Only escalate to a manual wrapper or fallback composition after the full click-based repaint pass fails to change the rendered output.

### Step 6: Updating an Existing Screen

When updating rather than creating from scratch:

1. Use `get_metadata` to inspect the existing screen structure.
2. Identify which sections need updating and which can stay.
3. For each section that needs changes:
   - Locate the existing nodes by ID or name
   - Swap component instances if the design system component changed
   - Update text content, variant properties, or layout as needed
   - Remove deprecated sections
   - Add new sections
4. Validate with `get_screenshot` after each modification.

```js
// Example: Swap a button variant in an existing screen
const existingButton = await figma.getNodeByIdAsync("EXISTING_BUTTON_INSTANCE_ID");
if (existingButton && existingButton.type === "INSTANCE") {
  // Import the updated component
  const buttonSet = await figma.importComponentSetByKeyAsync("BUTTON_SET_KEY");
  const newVariant = buttonSet.children.find(c =>
    c.name.includes("variant=primary") && c.name.includes("size=lg")
  ) || buttonSet.defaultVariant;
  existingButton.swapComponent(newVariant);
}
return { success: true, mutatedNodeIds: [existingButton.id] };
```

## Reference Docs

If your environment includes `figma-use` reference docs, load these as needed:

- `component-patterns.md` — importing by key, finding variants, setProperties, text overrides, working with instances
- `variable-patterns.md` — creating/binding variables, importing library variables, scopes, aliasing, discovering existing variables
- `text-style-patterns.md` — creating/applying text styles, importing library text styles, type ramps
- `effect-style-patterns.md` — creating/applying effect styles (shadows), importing library effect styles
- `gotchas.md` — layout pitfalls (HUG/FILL interactions, counterAxisAlignItems, sizing order), paint/color issues, page context resets

## Error Recovery

Follow your environment's `figma-use`-style error recovery process:

1. **STOP** on error — do not retry immediately.
2. **Read the error message carefully** to understand what went wrong.
3. If the error is unclear, call `get_metadata` or `get_screenshot` to inspect the current file state.
4. **Fix the script** based on the error message.
5. **Retry** the corrected script — this is safe because failed scripts are atomic (nothing is created if a script errors).

Because this skill works incrementally (one section per call), errors are naturally scoped to a single section. Previous sections from successful calls remain intact.

## Best Practices

- **Always search before building.** The design system likely has the component, variable, or style you need. Manual construction and hardcoded values should be the exception, not the rule.
- **Treat the provided design library as mandatory.** The screenshot is the visual source; the provided Figma library is the component and token source.
- **Search broadly.** Try synonyms and partial terms. A "NavigationPill" might be found under "pill", "nav", "tab", or "chip". For variables, search "color", "spacing", "radius", etc.
- **Prefer design system tokens over hardcoded values.** Use variable bindings for colors, spacing, and radii. Use text styles for typography. Use effect styles for shadows. This keeps the screen linked to the design system.
- **Prefer component instances over manual builds.** Instances stay linked to the source component and update automatically when the design system evolves.
- **Do not trace screenshots with detached rectangles and text unless the library truly has no matching primitive.** A close library-backed reconstruction is better than a pixel-perfect but disconnected mock.
- **Preserve the screenshot's wording.** The visible working content in the generated design should match the screenshot unless the user explicitly asks for copy changes.
- **Work section by section.** Never build more than one major section per `use_figma` call.
- **Return node IDs from every call.** You'll need them to compose sections and for error recovery.
- **Validate visually after each section.** Use `get_screenshot` to catch issues early.
- **Match existing conventions.** If the file already has screens, match their naming, sizing, and layout patterns.
