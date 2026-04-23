---
name: bee-ds-live-lookup
description: "Use when the task needs live Bee-DS lookup from Figma MCP: inspect Bee-DS Toolkit, inspect Bee-DS Icon Library, look up published Bee components, variants, tokens, icons, or verify the exact current Bee asset in Figma. Trigger for requests such as 'inspect Bee-DS in Figma', 'look up Bee tokens/icons', 'find the published Bee component/variant', 'check the exact Bee asset in the library', or 'load Bee-DS context from Figma MCP'. This skill is for live library discovery and exact asset verification, not for broader Bee design judgment."
---

# Bee-DS Live Lookup Skill

This skill extracts and documents the **Bee-DS Design System** from Figma files using the Figma MCP (Model Context Protocol) available in VS Code Copilot.

## Overview

The skill provides:
- **Component extraction** from Bee-DS Toolkit
- **Icon inventory** from Bee-DS Icon Library  
- **Design token documentation** (colors, effects, spacing)
- **Design system compliance checking**
- **Integration with Figma MCP** in VS Code

This skill should be treated as a **live Figma lookup workflow**, not a frozen catalog. Prefer extracting the current published result from Figma MCP at task time over relying on long embedded component or icon lists that can drift as Bee-DS evolves.

## Skill Boundary

Use this skill to answer questions such as:
- what Bee component family exists in the published library right now
- which variant names, icon names, or token names are actually available
- what the exact live component properties and rendered descendants look like

Do not use this skill as the main place for:
- Bee screen composition judgment
- spacing or layout taste decisions
- migration sequencing or cleanup execution

Those belong to:
- [bee-ds-design-guide](../bee-ds-design-guide/SKILL.md) for Bee design judgment
- [apply-bee-ds-toolkit](../apply-bee-ds-toolkit/SKILL.md) for Bee migration and rebuild execution

## Recommended Pairing

- Load this skill first when Bee families, variants, tokens, or icons are still unknown.
- Then load [bee-ds-design-guide](../bee-ds-design-guide/SKILL.md) if the design choice between Bee patterns is still ambiguous.
- Then load [apply-bee-ds-toolkit](../apply-bee-ds-toolkit/SKILL.md) when it is time to edit the Figma file.

## Figma Files

This skill works with:

- **Bee-DS Toolkit**: `oJgba28Kg7nFW0P1FLJfS5`
  - URL: https://www.figma.com/design/oJgba28Kg7nFW0P1FLJfS5/Bee-DS-Toolkit

- **Bee-DS Icon Library**: `sSLTAUrPkxqw72ecpGMxDE`
  - URL: https://www.figma.com/design/sSLTAUrPkxqw72ecpGMxDE/Bee-DS-Icon-Library

## When to Use

Use this skill when you need to:

1. **Convert legacy designs to Figma** (Sketch, PDF, screenshots)
   - Load design system → Get component specs → Convert design

2. **Generate components using Bee-DS**
   - Reference exact component names and tokens
   - Implement with correct variants and states
   - Apply semantic color tokens

3. **Verify design system compliance**
   - Check if designs use Bee-DS components
   - Verify tokens are applied correctly
   - Ensure icon names match library

4. **Learn component specifications**
   - Get detailed component info
   - Understand available variants
   - See usage guidelines and best practices

## How It Works

### Step 1: Use Figma MCP to Extract

The skill uses Figma MCP tools available in VS Code Copilot:

```
get_libraries() 
  → Find all Bee-DS libraries in file

search_design_system() 
  → Find components, tokens, icons by query

get_design_context() 
  → Get detailed specs for specific components
```

### Step 2: Document the Design System

Extracts and organizes:
- **Components**: Names, versions, variants, states
- **Tokens**: Color tokens with semantic naming
- **Icons**: Icon names and categories
- **Usage**: Guidelines and best practices

Do this dynamically from the live library whenever practical:
- use `get_libraries()` to confirm Bee-DS Toolkit and Bee-DS Icon Library are actually linked or accessible
- use `search_design_system()` to find the exact current family, variant, token, or icon needed for the task
- use `get_design_context()` or a temporary imported instance to inspect the real current properties, visible text nodes, and layout contract

Avoid treating any embedded list in this skill as complete or authoritative.

### Step 3: Provide Context for Your Work

Supplies information you need to:
- Generate code using exact component names
- Apply correct design tokens
- Reference correct icons
- Maintain design system compliance

## Component Discovery Strategy

Do not maintain or rely on a long static component inventory here.

Instead, discover the needed Bee family at runtime:
- search by job first, not by guess: `search`, `top navigation`, `inline message`, `base tile`, `radio`, `dropdown`, `button`
- then inspect the exact imported component or component set for:
  - published name
  - current variant names
  - exposed text properties
  - visible descendant text
  - footprint and sizing behavior

Useful Bee families to check first for screen rebuild work:
- navigation and status bar families for top chrome
- field families such as search, dropdown, and selection inputs
- message families such as inline message for informational banners
- tile or list-item families for account and menu rows

Treat these as starting points for discovery, not a promise that a specific published version or exact naming will remain unchanged.

## Design Tokens

### Color Tokens (Semantic)

**Container Backgrounds**:
- Interactive: `default`, `hover`, `pressed`, `disabled`
- Selected: `default`, `hover`, `pressed`, `disabled`
- Static: For non-interactive containers

**Container Borders**:
- Static: `semantic/color/border/container/static`
- Interactive: `default`, `hover`
- Selected: `default`, `hover`, `disabled`

### Effect Tokens

**Shadows**:
- `semantic/shadow/container/floating` - For floating elements (snackbars, sticky buttons)

### Token Usage Pattern

```
semantic/[type]/[element]/[variant]/[state]

Examples:
- semantic/color/background/container/interactive/default
- semantic/color/border/container/selected/hover
- semantic/shadow/container/floating
```

## Icon Discovery Strategy

Do not embed a long icon inventory unless you are prepared to keep it updated.

For implementation work, prefer:
- searching Bee-DS Icon Library by the semantic job of the icon, such as `search`, `chevron-left`, `information`, `more-horizontal`
- verifying the exact published icon name before import
- checking whether the consuming Bee component expects an icon component key, imported node ID, or direct nested instance swap

If search results are noisy, inspect the Bee-DS Icon Library file directly through Figma MCP instead of guessing from memory.

## Workflow Example

### Convert Legacy Design to Figma

```
Step 1: Get component specs
  "What components should I use for a selection list?"
  → Skill provides: Selection card specs, Radio button specs

Step 2: Understand tokens
  "What color tokens apply to the card?"
  → Skill provides: Background tokens, border tokens, states

Step 3: Reference icons
  "What icons are available for this design?"
  → Skill provides: Icon names from library

Step 4: Generate code
  "Create a React component for this design using Bee-DS"
  → Use exact component names from step 1
  → Apply tokens from step 2
  → Reference icons from step 3
  → Result: Design-system-compliant code
```

## Usage with Copilot in VS Code

### Query Component Info
```
User: "What variants does the Primary button have?"

Skill extracts from Figma MCP:
- Component name: Primary button
- Versions: v1.1.0
- Category: action
- Variants: default, hover, active, disabled
- Usage: Main call-to-action
```

### Get Design Tokens
```
User: "What tokens should I use for a selection card background?"

Skill provides:
- semantic/color/background/container/selected/default
- semantic/color/background/container/selected/hover
- semantic/color/background/container/selected/pressed
- semantic/color/background/container/selected/disabled
```

### Find Icons
```
User: "What icons are available for navigation?"

Skill lists:
- Menu
- Menu-More-Horizontal
- Menu-More-Horizontal-Active
- Global-View-Management
```

### Verify Compliance
```
User: "Does my design follow Bee-DS?"

Skill checks:
✓ Uses components from library
✓ Applies semantic tokens
✓ References correct icons
✓ Implements all states
```

## Integration Pattern

Use this skill with other Figma MCP tools:

```
bee-ds-live-lookup (Load system)
    ↓ Provides component specs, tokens, icons
    ↓
get_design_context() (Get design details)
    ↓ Returns code and screenshots
    ↓
Generate code (Using specs from skill)
    ↓ Design-system-compliant implementation
```

## Best Practices

### 1. Use Exact Component Names
✅ "Use the `Primary button` component (v1.1.0)"
❌ "Use a primary button"

### 2. Reference Exact Token Names
✅ "`semantic/color/background/container/interactive/hover`"
❌ "Use the hover color"

### 3. Include All States
✅ "Implement states: default, hover, pressed, disabled, selected"
❌ "Make it interactive"

### 4. Use Icons from Library
✅ "Use the `Menu` icon from Bee-DS Icon Library"
❌ "Add a menu icon"

### 5. Reference the Skill
✅ "According to Bee-DS specs from the skill..."
❌ "I think the button should..."

### 6. Prefer Live Discovery Over Static Lists
✅ "Use Figma MCP to confirm the current Bee component family and variant before implementing"
❌ "Assume the component list in the skill is complete and current"

## Key Information

### Naming Convention
- Components: `[Type] [name]` (e.g., "Primary button")
- Tokens: `semantic/[type]/[element]/[variant]/[state]`
- Icons: `[Category]-[Name]` (e.g., "Menu-More-Horizontal")

### Versions
All components have versions (e.g., v1.1.0):
- Major: Major changes
- Minor: New features/variants
- Patch: Fixes and refinements

### Categories
Components are tagged with categories:
- `#action` - Action components (buttons)
- `#container/layout` - Container components (cards)
- `#selection/input` - Input components (radio, checkbox)
- `#navigation` - Navigation components (pagination, links)
- `#notification` - Notification components (alerts, messages)

## Common Queries

**"What Bee family should I use for this section?"**
→ Searches the live library, then inspects the exact current family and variant candidates

**"How do I implement [component]?"**
→ Shows the current variant, states, tokens, and usage guidance from live Figma inspection

**"What icon should I use here?"**
→ Searches Bee-DS Icon Library by semantic intent and verifies the exact published icon name

**"Is my design compliant?"**
→ Checks components, tokens, icons, and whether the rendered result matches the intended Bee family

**"What's the difference between [variant1] and [variant2]?"**
→ Explains the difference only after inspecting the current published variants

## Requirements

- **VS Code** with Copilot extension
- **Figma MCP** enabled in VS Code Copilot
- **Read access** to both Bee-DS Figma files
- **Internet connection** to access Figma API

## Troubleshooting

### "Can't access Bee-DS files"
→ Verify you have read access to both Figma files
→ Check Figma MCP is enabled in Copilot

### "Component not found"
→ Use exact component name from skill
→ Check version number matches
→ Verify spelling (e.g., "Primary button" not "primary button")

### "Token doesn't work"
→ Use full semantic token name
→ Check format: `semantic/[type]/[element]/[variant]/[state]`
→ Verify token exists in design system

## Related Skills

- **figma-implement-design** - Convert Figma designs to code
- **apply-design-system** - Update designs to use design system
- **audit-design-system** - Check design system compliance

## Resources

- Bee-DS Toolkit: https://www.figma.com/design/oJgba28Kg7nFW0P1FLJfS5/Bee-DS-Toolkit
- Bee-DS Icon Library: https://www.figma.com/design/sSLTAUrPkxqw72ecpGMxDE/Bee-DS-Icon-Library
- Figma MCP Documentation: https://www.figma.com/developers/api

## Quick Reference

### Component Lookup Pattern
```
1. Confirm Bee-DS libraries are available
2. Search by semantic job of the section or control
3. Import the exact family or variant candidate
4. Inspect live properties and visible descendants
5. Implement only after the rendered output and layout contract are clear
```

### Token Types
```
Colors:
  - semantic/color/background/container/[interactive|selected|static]/[state]
  - semantic/color/border/container/[static|interactive|selected]/[state]

Effects:
  - semantic/shadow/container/floating
```

### All Icon Categories
```
Navigation & Menu
Status & Information
Actions & Interactions
Categories & Content
```

## Summary

This skill provides **complete Bee-DS design system documentation** accessible through Figma MCP in VS Code Copilot. Use it to:

1. **Get exact component specifications**
2. **Learn correct design tokens**
3. **Reference icon names**
4. **Verify design system compliance**
5. **Generate design-system-compliant code**

Always consult this skill first when working with Bee-DS in Figma MCP.

---

**Skill Version**: 1.0.0  
**Last Updated**: April 22, 2026  
**Status**: Production Ready ✅  
**For**: VS Code Copilot with Figma MCP
