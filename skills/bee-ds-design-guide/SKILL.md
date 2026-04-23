---
name: bee-ds-design-guide
description: "Use when making Bee-DS design decisions at the screen, section, or component level after the relevant Bee families are known or being compared. Trigger for requests such as 'design this in Bee-DS style', 'how should this Bee screen be structured', 'apply Bee spacing/layout rules', 'match Bee design language', 'choose between Bee variants', 'which Bee pattern fits this screen', or 'check whether this follows Bee-DS guidelines'. This skill is for design judgment, screen composition, spacing, states, and canonical Bee patterns rather than live Figma asset lookup."
---

# Bee-DS Design System - Complete Design Guide

**Comprehensive Design Guidelines & Specifications**  
**Version**: 1.0.0  
**Last Updated**: April 22, 2026

---

## Table of Contents

1. [Design Principles](#design-principles)
2. [Color System](#color-system)
3. [Typography & Text](#typography--text)
4. [Spacing & Layout](#spacing--layout)
5. [Screen Composition](#screen-composition)
6. [Components](#components)
7. [States & Interactions](#states--interactions)
8. [Accessibility](#accessibility)
9. [Best Practices](#best-practices)

## Skill Boundary

Use this skill when the relevant Bee families are known or being compared and the real question is:
- which Bee pattern fits this screen best
- how the screen should be structured in Bee style
- what spacing, section rhythm, and wrapper choices make the result feel canonical

Do not use this skill as the main source for:
- exact live asset lookup from Figma libraries
- published variant discovery
- migration execution or cleanup scripting

Those belong to:
- [bee-ds-live-lookup](../bee-ds-live-lookup/SKILL.md) for live Figma lookup
- [apply-bee-ds-toolkit](../apply-bee-ds-toolkit/SKILL.md) for migration and rebuild execution

## Recommended Pairing

- If the Bee family or variant is not known yet, load [bee-ds-live-lookup](../bee-ds-live-lookup/SKILL.md) first.
- If the task already knows the Bee family but needs design judgment, load this skill directly.
- Once the pattern choice is clear, load [apply-bee-ds-toolkit](../apply-bee-ds-toolkit/SKILL.md) to implement it in Figma.

---

## Design Principles

### 1. Semantic Design Language
Bee-DS uses **semantic naming** for all design decisions:
- Colors have meaning (primary, secondary, actionable, etc.)
- Components have clear purposes (action, container, input, navigation)
- Tokens describe their use, not their appearance

**Principle**: Never name by appearance (e.g., "red-color"), always by semantic meaning (e.g., "semantic/color/text/actionable/disabled")

### 2. State-Based Design
All interactive elements have clear states:
- **Default**: Initial/resting state
- **Hover**: User hovers over element
- **Pressed**: User actively presses/clicks
- **Disabled**: Element is non-interactive
- **Selected**: Item is selected/active

**Principle**: Design for all states. Every interactive element must have visual feedback for each state.

### 3. Accessibility First
- All colors have sufficient contrast
- Components support keyboard navigation
- States are communicated visually AND semantically
- Icons have proper labels
- Text has appropriate sizing and line height

**Principle**: Design is only complete when it works for everyone.

### 4. Consistency Over Flexibility
- Use existing components, don't create variations
- Apply tokens consistently across designs
- Maintain predictable interactions
- Follow established patterns

**Principle**: Consistency builds trust and usability.

### 5. Progressive Disclosure
- Show only what's needed
- Group related information
- Use clear hierarchy
- Progressively reveal detail

**Principle**: Reduce cognitive load through clear organization.

---

## Color System

### Semantic Color Structure

**Format**: `semantic/color/[target]/[role]/[state]`

**Targets**:
- `background` - Fill colors for containers, surfaces
- `border` - Stroke colors for outlines, dividers
- `text` - Text and typography colors
- `fill` - Fill colors for interactive elements
- `icon` - Colors for icon elements

**Roles**:
- `primary` - Most important, highest emphasis
- `secondary` - Less important, medium emphasis
- `actionable` - Interactive, clickable elements
- `container` - Container and card backgrounds

**States**:
- `default` - Resting state
- `hover` - On hover
- `pressed` - On active/pressed
- `disabled` - Disabled/non-interactive
- `selected` - Selected/active state

### Color Token Categories

#### Container Colors

**Interactive Containers** (clickable cards, buttons):
```
semantic/color/background/container/interactive/default
  → Standard interactive container background
  → Use for: Card that users can click/interact with
  
semantic/color/background/container/interactive/hover
  → Hover state background
  → Use for: When user hovers over interactive card
  
semantic/color/background/container/interactive/pressed
  → Active/pressed state background
  → Use for: When user actively clicks/presses
  
semantic/color/background/container/interactive/disabled
  → Disabled state background
  → Use for: When container is disabled/non-interactive
```

**Selected Containers** (selected cards, checked items):
```
semantic/color/background/container/selected/default
  → Selected state background
  → Use for: Item that user has selected
  
semantic/color/background/container/selected/hover
  → Selected + hovering
  → Use for: Selected item with hover state
```

#### Text Colors

**By Importance**:
```
semantic/color/text/primary/*
  → Primary text, highest emphasis
  → Use for: Main content, headings, labels
  
semantic/color/text/secondary/*
  → Secondary text, lower emphasis
  → Use for: Helper text, descriptions, sub-text
  
semantic/color/text/actionable/*
  → Interactive text, clickable
  → Use for: Links, interactive text, CTAs
```

**States**:
```
All text has states: default, hover, pressed, disabled
Apply appropriate state based on element state
```

#### Fill Colors

**For Interactive Elements**:
```
semantic/color/fill/primary/*
  → Primary fill color for buttons, inputs
  
semantic/color/fill/selected/*
  → Fill for selected elements (checkboxes, radio)
  
All have states: default, hover, pressed, disabled
```

#### Icon Colors

**By Importance**:
```
semantic/color/icon/primary/*
  → Important icons
  
semantic/color/icon/secondary/*
  → Less important icons
  
semantic/color/icon/actionable/*
  → Interactive/clickable icons
```

### Color Usage Rules

✅ **DO**:
- Always use semantic tokens
- Reference the full token name
- Apply tokens based on state
- Ensure sufficient contrast (WCAG AA minimum)
- Use colors consistently across product

❌ **DON'T**:
- Hardcode hex values
- Create custom colors
- Skip disabled states
- Use colors without semantic meaning
- Mix token types (e.g., primary text + secondary background)

---

## Typography & Text

### Text Hierarchy

**Principle**: Clear visual hierarchy guides users through content

#### Text Roles

1. **Headings/Display**
   - Largest, most prominent
   - Use for: Page titles, section headers
   - Font: Bold weight, increased size
   
2. **Body/Content**
   - Regular reading text
   - Use for: Descriptions, paragraphs, main content
   - Font: Regular weight, standard size
   
3. **Labels**
   - Field labels, component labels
   - Use for: Input labels, button text
   - Font: Medium weight, slightly reduced size
   
4. **Captions/Helper**
   - Supporting text, explanations
   - Use for: Hints, error messages, support text
   - Font: Regular weight, small size

### Text States

All text follows semantic color tokens with states:

```
Default State
→ semantic/color/text/[role]/default
→ Used for normal, resting text

Hover State
→ semantic/color/text/[role]/hover
→ Text changes color on parent hover

Disabled State
→ semantic/color/text/[role]/disabled
→ Reduced prominence when disabled
```

### Typography Best Practices

✅ **DO**:
- Maintain clear hierarchy
- Use semantic color tokens for all text
- Ensure sufficient contrast
- Use consistent sizes within role
- Apply states based on element state

❌ **DON'T**:
- Mix multiple sizes randomly
- Use hardcoded text colors
- Skip contrast requirements
- Ignore state changes
- Use non-standard fonts

---

## Spacing & Layout

### Spacing Scale

Bee-DS uses a consistent, scalable spacing system:

```
xs: 4px   → Tight spacing, icon gaps
sm: 8px   → Small gaps, button padding
md: 16px  → Standard padding, default spacing
lg: 24px  → Large padding, section spacing
xl: 32px  → Extra large, major breaks
```

### When to Use Each

**xs (4px)**:
- Icon-to-icon spacing
- Tight, compact layouts
- Minimal gaps

**sm (8px)**:
- Button padding
- Small component gaps
- Narrow spacing

**md (16px)**:
- Card padding
- Standard spacing
- Default component padding
- Between elements

**lg (24px)**:
- Section padding
- Large component margins
- Clear separation
- Container padding

**xl (32px)**:
- Page padding
- Major section breaks
- Large separations
- Container margins

### Layout Patterns

#### Card Layout
```
Card Container
├─ Padding: lg (24px) inside card
├─ Gap between elements: md (16px)
├─ Margin below card: lg (24px) from next
└─ Border width: 1px
```

#### Button Layout
```
Button
├─ Padding horizontal: md (16px)
├─ Padding vertical: sm (8px)
├─ Icon gap: xs (4px)
├─ Group gap: sm (8px)
└─ Stack gap: md (16px)
```

#### Section Layout
```
Section
├─ Top padding: xl (32px)
├─ Bottom padding: xl (32px)
├─ Element gap: lg (24px)
├─ Heading padding: md (16px) below
└─ Content padding: lg (24px)
```

### Responsive Spacing

When scaling for screens:
- **Large screens**: Use larger spacing (lg, xl)
- **Standard screens**: Use standard spacing (md)
- **Small screens**: Use compact spacing (sm, xs)
- **Never skip spacing**: Always maintain visual breathing room

---

## Screen Composition

### Core Rule

When building a Bee-DS-style screen, prefer **canonical Bee screen scaffolding and section wrappers** before composing ad-hoc local shells around Bee parts.

Using Bee icons and tiles alone is not enough if the screen-level rhythm, wrappers, and content blocks do not follow Bee conventions.

### Composition Priorities

Build in this order:

1. **Screen chrome first**
  - Prefer published status bar, top navigation, search/header wrappers, and other top-level Bee containers before placing local text or icons.
2. **Section containers next**
  - Prefer section header wrappers, message wrappers, and content blocks with canonical Bee spacing and insets.
3. **Row and field families after that**
  - Use tiles, inline messages, radios, dropdowns, and other content primitives only after the section scaffold is established.
4. **Detached local shapes last and only when necessary**
  - Use manual rectangles, text, or spacers only for gaps that Bee-DS does not publish directly.

### Screen-Level Heuristics

#### 1. Match the Screen Rhythm Before Micro Details

Get these right early:
- overall frame height and breathing room
- section header heights
- left and right content insets
- vertical spacing between sections
- message block height and row height

If the frame feels compressed, the result will not read as Bee-DS even when the components themselves are correct.

#### 2. Prefer Canonical Wrappers Over Tight Manual Assemblies

Prefer:
- a Bee search wrapper over placing a search field directly on the canvas
- an inline message family over icon-plus-text hand assembly
- section blocks with consistent header and content areas over manual separators and text rows

Avoid rebuilding the whole screen as manually stacked Bee atoms unless the library truly lacks the intermediate wrapper.

#### 3. Respect Content Insets Consistently

Bee screens usually feel correct because the inset system is consistent across:
- section headers
- row text blocks
- message content
- footer and informational copy

If one section uses a tighter local inset than the others, the screen quickly stops feeling canonical.

#### 4. Give Multi-Line Content Its Own Vertical Contract

Rows with:
- multi-line titles
- helper text
- inline messages
- long disclaimers

should usually use taller wrappers instead of being forced into the default height of a shorter single-line row family.

#### 5. Validate the Whole Screen, Not Only the Component

A Bee row can be valid in isolation but still be wrong in a Bee screen if:
- headers are too shallow
- message blocks are too short
- section spacing is too tight
- top chrome is approximated instead of canonical

### Composition Failure Patterns

Common screen-level mistakes:
- using the right Bee components inside the wrong section scaffolding
- compressing a screen vertically because the visible screenshot looked simple
- composing inline messages manually when Bee already has a message family
- matching content but missing the Bee rhythm of wrappers, spacing, and insets

### Practical Rule For Screenshot Rebuilds

When recreating a screenshot in Bee-DS style:
- use the screenshot for copy, order, and intent
- use Bee-DS for structure, wrappers, and spacing contracts
- if the screenshot and Bee wrapper differ slightly, prefer the canonical Bee wrapper unless the task explicitly requires pixel matching

---

## Components

### Component States

Every component must support these states:

#### 1. Default State
- Resting, uninteracted state
- Standard colors and styles
- Clear and inviting

#### 2. Hover State
- Visual feedback on hover
- Color change or emphasis
- Indicates interactivity

#### 3. Pressed/Active State
- Feedback on interaction
- Clear visual change
- Communicates action

#### 4. Disabled State
- Non-interactive appearance
- Reduced contrast
- Communicates unavailability

#### 5. Selected State
- For multi-select components
- Clear selection indicator
- Semantic color tokens applied

### Component Categories

#### Action Components (Buttons)

**Primary Button**:
- Use for: Main action, primary CTA
- Tokens: `semantic/color/fill/primary/*`
- States: default, hover, pressed, disabled
- Accessibility: Sufficient contrast, clear label

**Secondary Button**:
- Use for: Alternative action
- Tokens: Outlined style with primary tokens
- States: All states required
- Accessibility: Clear, distinct from primary

**Tertiary Button**:
- Use for: Less important action
- Tokens: Text-based, minimal styling
- States: All states required
- Accessibility: Subtle but discoverable

#### Container Components (Cards)

**Card Container**:
- Use for: Generic content container
- Tokens: 
  - Background: `semantic/color/background/container/interactive/default`
  - Border: `semantic/color/border/container/interactive/default`
- States: Interactive card states
- Padding: lg (24px)

**Selection Card**:
- Use for: User selection scenarios
- Tokens:
  - Default: `semantic/color/background/container/interactive/default`
  - Selected: `semantic/color/background/container/selected/default`
- States: All selection states
- Interactions: Clear selection feedback

**Message Card**:
- Use for: Notifications, alerts
- Tokens: Semantic colors for message type
- States: Normal, dismissed
- Accessibility: Proper semantics, icon + text

#### Input Components

**Radio Button**:
- Use for: Single selection from options
- Tokens: `semantic/color/fill/selected/*`
- States: Unselected, selected, disabled
- Accessibility: Proper labels, keyboard support

**Text Input**:
- Use for: Text entry
- Tokens: Border and text colors
- States: Default, focus, filled, disabled, error
- Accessibility: Associated labels, clear focus

#### Navigation Components

**Pagination**:
- Use for: Multi-page navigation
- Tokens: Button-style tokens
- States: Default, current, disabled
- Accessibility: Aria labels, keyboard nav

**Category Links**:
- Use for: Section navigation
- Tokens: Text tokens with underline
- States: Default, hover, active, visited
- Accessibility: Clear distinction, keyboard nav

### Component Specifications

#### Size Specifications
Components should support:
- **Small**: Compact, 24px height
- **Medium**: Standard, 32px height (default)
- **Large**: Spacious, 40px height

#### Font Specifications
- **Button text**: medium weight, 14px
- **Label**: medium weight, 14px
- **Caption**: regular weight, 12px
- **Body**: regular weight, 14px

---

## States & Interactions

### State Machine

Every interactive component follows this state flow:

```
Default
├─→ Hover (on mouse/touch hover)
│   ├─→ Pressed (on click/tap)
│   │   └─→ Default (on release)
│   └─→ Default (on leave)
├─→ Focus (on keyboard focus)
│   ├─→ Pressed (on enter/space)
│   │   └─→ Focus (on release)
│   └─→ Blur (on escape/tab)
└─→ Disabled (never interactive)
```

### Visual Feedback

**Every state must be visually distinct**:

- Default: Standard colors
- Hover: Slightly different color/shadow
- Pressed: More pronounced change
- Disabled: Reduced contrast, muted
- Selected: Semantic highlighting

### Transition Timing

- Hover→Pressed: Instant
- Pressed→Default: 100-200ms
- Color changes: 100ms fade
- Opacity changes: 200ms fade
- Never: abrupt, jarring changes

---

## Accessibility

### WCAG Compliance

Bee-DS components meet WCAG 2.1 AA standards:

#### Color Contrast
- Text vs background: 4.5:1 minimum
- UI components: 3:1 minimum
- Never rely on color alone for meaning

#### Keyboard Navigation
- All interactive elements keyboard accessible
- Logical tab order
- Clear focus indicators
- Visible focus state

#### Semantic HTML
- Use proper semantic elements
- Provide `aria-label` when needed
- Form inputs have associated labels
- Lists use proper list structure

#### Screen Readers
- Descriptive link text
- Image alt text when needed
- Form field descriptions
- Status messages announced

### Component Accessibility Checklist

For every component, ensure:
- ✅ Sufficient color contrast
- ✅ Keyboard accessible
- ✅ Clear focus indicator
- ✅ Proper semantic HTML
- ✅ Aria attributes where needed
- ✅ Descriptive labels/text
- ✅ State communicated visually + semantically
- ✅ Touch target size ≥ 44x44px

---

## Best Practices

### Design System Compliance

✅ **DO**:
1. Use components from the library
2. Reference exact component names
3. Apply semantic color tokens
4. Implement all states
5. Test with real content
6. Verify accessibility
7. Document custom patterns
8. Get design review before coding

❌ **DON'T**:
1. Create custom component variations
2. Mix components incorrectly
3. Hardcode colors or spacing
4. Skip disabled states
5. Ignore accessibility
6. Use placeholder content in final design
7. Override component behaviors
8. Break established patterns

### Workflow Best Practice

#### Step 1: Plan Component Needs
- What interaction needed?
- What states required?
- What's the user flow?

#### Step 2: Select Component
- Find matching component in Bee-DS
- Review specifications
- Check variants available

#### Step 3: Apply Tokens
- Use semantic color tokens
- Apply spacing consistently
- Use component sizing guidelines

#### Step 4: Implement States
- Default state
- Hover/focus state
- Active/pressed state
- Disabled state
- Selected state (if applicable)

#### Step 5: Verify Accessibility
- Color contrast check
- Keyboard navigation test
- Screen reader test
- Touch target size check

#### Step 6: Document & Review
- Document any custom patterns
- Get design system review
- Ensure handoff clarity

### Design Decision Tree

**Need a user action?**
→ Use Button component
  - Primary action? → Primary button
  - Alternative? → Secondary button
  - Low importance? → Tertiary button

**Need to display content?**
→ Use Card component
  - With image? → Image card
  - Selectable? → Selection card
  - Notification? → Message card
  - Custom? → Placeholder card

**Need user input?**
→ Use Input component
  - Single select? → Radio button
  - Text entry? → Text input
  - Multiple options? → Selection group

**Need navigation?**
→ Use Navigation component
  - Between pages? → Pagination
  - Between sections? → Category links

---

## Common Patterns

### Button Groups
- Group related buttons
- Use sm (8px) spacing between
- Similar visual weight
- Clear primary action

### Card Layouts
- Consistent padding (lg = 24px)
- md (16px) spacing between elements
- Clear information hierarchy
- Visible border for separation

### Form Layouts
- Labels above inputs (vertical)
- md (16px) spacing between fields
- lg (24px) spacing between sections
- Clear error states and messages

### Lists
- md (16px) padding per item
- sm (8px) gap between items
- Consistent icon positioning
- Clear interactive states

---

## Token Quick Reference

### Most Common Tokens

**Text Colors**:
- `semantic/color/text/primary/default` - Main text
- `semantic/color/text/primary/disabled` - Disabled text
- `semantic/color/text/secondary/default` - Supporting text

**Fill Colors**:
- `semantic/color/fill/primary/default` - Primary fill
- `semantic/color/fill/selected/default` - Selected fill
- `semantic/color/fill/primary/disabled` - Disabled fill

**Background Colors**:
- `semantic/color/background/container/interactive/default` - Card background
- `semantic/color/background/container/interactive/hover` - Card hover
- `semantic/color/background/container/selected/default` - Selected background

**Border Colors**:
- `semantic/color/border/container/interactive/default` - Card border
- `semantic/color/border/container/interactive/hover` - Card border hover
- `semantic/color/border/container/static` - Non-interactive border

---

## Implementation Checklist

Before shipping a design:

- [ ] All components from Bee-DS library
- [ ] All colors use semantic tokens
- [ ] All spacing uses scale (xs, sm, md, lg, xl)
- [ ] All interactive elements have states
- [ ] Disabled state implemented
- [ ] Hover state implemented
- [ ] Focus state implemented
- [ ] Color contrast ≥ 4.5:1 for text
- [ ] Touch targets ≥ 44x44px
- [ ] Keyboard navigation supported
- [ ] Screen reader compatible
- [ ] Responsive at mobile/tablet/desktop
- [ ] Documentation complete
- [ ] Design review passed
- [ ] Ready for handoff

---

## Summary

**Bee-DS is a semantic, accessible, state-based design system built on:**

1. **Semantic naming** - Tokens describe meaning, not appearance
2. **Consistent states** - Every element has defined states
3. **Accessibility first** - WCAG AA compliance built in
4. **Scalable spacing** - Consistent, reusable spacing scale
5. **Component library** - Pre-built, tested components
6. **Token-based colors** - Semantic color tokens for consistency

**Follow these principles and you'll maintain Bee-DS consistency across your entire product.**

---

**Use this guide when:**
- Making design decisions
- Selecting components
- Applying colors and spacing
- Implementing states
- Ensuring accessibility
- Following best practices

**Reference the skill to:**
- Get component specifications
- Find correct token names
- Learn state requirements
- Verify accessibility
- Check spacing guidelines

---

**Version**: 1.0.0  
**Last Updated**: April 22, 2026  
**Status**: Production Ready ✅
