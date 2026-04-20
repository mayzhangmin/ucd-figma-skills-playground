# Enhanced Apply-Design-System Skill

## Overview

This is the canonical workflow for reconnecting existing Figma designs to a published design system. It handles multi-section migrations with dependency-aware sequencing, composition from primitives, and rigorous validation of library-backed results.

**Version:** Enhanced  
**Last Updated:** 2026

---

## What's New in This Version

This enhanced version addresses four specific real-world migration failures that teams encountered in production:

### 1. **Wasted Planning Effort**
**Problem:** Teams spent 2+ hours mapping components and planning migrations, only to hit an import failure (unpublished library, broken keys). All planning was wasted.

**Solution:** Added **CRITICAL PRECONDITION** at the top. Test component import in 30 seconds before planning anything. If it fails → stop immediately.

**Impact:** Catches blockers before wasted effort.

---

### 2. **Invisible Duplicate Text Labels**
**Problem:** After swapping a component, the new instance had the correct label inside it. But an old TEXT node was floating next to it (a sibling, not a child). The screen showed two labels. This passed validation because nobody inspected siblings.

**Solution:** Added **Rule #3** and detached text detection code. Inspects the whole section footprint, including sibling nodes.

**Example:** A form input with an internal label "Email" plus an old detached "Email type" label floating nearby. Now you'll catch both.

**Impact:** Prevents silent regressions.

---

### 3. **Family Swap Property Mismatches**
**Problem:** You swapped a Tertiary button to Secondary. The component looked right in properties. But Secondary has different property keys, icons, and defaults. You patched using old property names. The button rendered wrong.

**Solution:** Added **Rule #5**: Never infer variant behavior across families. After every swap, inspect the new instance's actual property keys and descendants before deleting the old one.

**Impact:** Prevents silent property mismatches.

---

### 4. **Multi-Section Sequencing Errors**
**Problem:** You swapped Section A successfully. Section B sat in the same parent. A's size changed. B shifted or overlapped. You didn't plan the swap order. Should have swapped B first (leaf before parent) or both together.

**Solution:** Added **Step 5: Map Dependencies And Sequencing**. Identify coupled sections, plan bottom-up order, document before editing. Also added new pitfall category: Multi-Section Sequencing Errors.

**Impact:** Prevents sibling layout breaks.

---

## Key Additions and Improvements

### New Sections

| Section | Purpose |
|---------|---------|
| **CRITICAL PRECONDITION** | Test import before planning (moved to top for visibility) |
| **Step 5: Map Dependencies And Sequencing** | Plan swap order before making any edits |
| **Step 11: Document Composition Dependencies** | Record which primitives were used, layout structure, reusability potential |
| **Pitfall: Multi-Section Sequencing Errors** | Teaches the common mistake of wrong swap order |

### Enhanced Sections

| Section | Enhancement |
|---------|-------------|
| **Step 4: Inventory The Existing Screen** | Added detached text detection code; captures parent layout state |
| **Step 6: Build A Component Map** | Added explicit variant matching guidance (semantic cues, visual cues, patterns) |
| **Step 8: Update One Section At A Time** | Added temp frame composition pattern; explicit x/y/width/height preservation |
| **Step 9: Handle Import Failures** | Added structured blocker report format with remediation path |
| **Step 10: Validate What Actually Changed** | Added explicit visual validation checklist with evidence levels |

### New Failure Prevention Rules

Six mandatory rules for catching subtle failures:

1. **Treat every swap as an ID boundary** — re-discover nodes from stable parents
2. **Verify rendered output, not properties** — inspect TEXT nodes and FRAME visibility
3. **Inspect whole section footprint** — find sibling and detached nodes
4. **Re-validate before deleting** — compare new instance against original first
5. **Never infer variants across families** — inspect new instance's actual property keys
6. **Distinguish evidence levels** — properties prove intent, descendant nodes prove reality, section inspection proves cleanup

---

## When to Use This Skill

✅ **Use this skill for:**
- Reconnecting multiple sections on an existing screen to a published design system
- Replacing local wrappers or detached layers with exact library swaps or composed primitives
- Migration work that needs dependency planning, blocker handling, and post-change validation
- Building product-specific overlay skills that inherit this process

❌ **Don't use this skill for:**
- Single-section fixes (use `fix-design-system-finding` instead)
- Quick component swaps without dependency risk (use `fix-design-system-finding`)

---

## How to Use: The Workflow

### Before You Start

1. **Run the precondition test** (30 seconds)
   - Try to import one key component from the target library
   - If it fails → stop, classify everything as `blocked`, report the error
   - If it passes → continue

2. **Capture current state**
   - Get metadata, screenshot, backup

3. **Inventory sections and dependencies**
   - Map which sections are coupled (share a parent, reuse overrides, nest inside wrappers)
   - Identify sibling text nodes that might be detached

### During Migration

4. **Plan before editing**
   - Map dependencies (Step 5)
   - Build component map from library (Step 6)
   - Decide strategy for each section (exact-swap, compose, or blocked) (Step 7)
   - **Document your plan in the response before starting edits**

5. **Update one section at a time**
   - Follow dependency order (bottom-up for compositions, paired for siblings)
   - Import and validate each component
   - Visually compare before swapping in place
   - Screenshot immediately after each change
   - Do NOT batch multiple sections

### After Each Section

6. **Validate what changed**
   - Check the visual validation checklist:
     - Instance is library-backed (mainComponent is remote)
     - Placeholder text is gone
     - Descendant TEXT nodes match original
     - Spacing matches original
     - No hidden TEXT or FRAME nodes remain
     - Parent layout didn't regress
     - Variant was actually applied
   - Compare side-by-side with original screenshot

### At the End

7. **Document and report**
   - Precondition result: passed or blocked
   - Dependency order: which sections were swapped in what order
   - Results by category: Swapped, Composed, Already Connected, Blocked
   - Visual validation: all tested, regressions noted
   - Remaining work: what needs unblocking

---

## Common Patterns and Examples

### Pattern: Bottom-Up Composition
Swap primitive buttons → swap card (uses buttons) → swap header (uses card).
Test after each layer.

### Pattern: Paired Sibling Swap
If Section A (title) and Section B (subtitle) are siblings sharing a parent, swap both together and screenshot the parent afterward. Don't swap A, then B.

### Pattern: Isolated Swaps
If sections don't share a parent or overrides, swap independently and validate each separately.

---

## Known Pitfalls and How to Avoid Them

### 1. Duplicate Detached Labels Beside Inputs
**Symptom:** Component looks correct internally, but extra label floats nearby.  
**Cause:** Old TEXT node is a sibling, not inside the instance.  
**Prevention:** Rule #3 + detached text detection. Inspect the whole section footprint.

### 2. Family Swap With Mismatched Defaults
**Symptom:** Button swapped from Tertiary to Secondary, but label/icon is wrong.  
**Cause:** Property keys differ across families. You patched old keys, not new ones.  
**Prevention:** Rule #5. Inspect new instance's properties and descendants before deleting the old one.

### 3. Composition Layout Drift When Parent Is Grouped
**Symptom:** Composed section looks right in isolation, shifts when moved into grouped parent.  
**Cause:** x/y weren't preserved. Grouped parents use absolute positioning.  
**Prevention:** Capture original x, y, width, height. Explicitly set them when moving into place.

### 4. Multi-Section Sequencing Errors
**Symptom:** Section A swapped fine. Section B in same parent now has broken spacing.  
**Cause:** Swap order was wrong. Should have done B first or both together.  
**Prevention:** Step 5. Map dependencies first, swap bottom-up (children before parents).

---

## Deliverable Format

When closing the task, report in this exact order:

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

---

## For Product Teams: Building Overlay Skills

This skill is **the canonical workflow**. Product-specific overlay skills should:

✅ **Inherit the entire process** (don't restate it)  
✅ **Add only system-specific rules** (library precedence, family selection, validation checks)  
✅ **Reference this skill** for the migration process  
✅ **Extend, don't duplicate**

Example: A Figma Material Design System skill would add rules for "always use Material Button variants in this order" but inherit the entire workflow, failure prevention, and dependency planning from this canonical skill.

---

## Failure Prevention Rules: Quick Reference

| Rule | Prevents | When |
|------|----------|------|
| **#1: ID boundary** | Reusing old node IDs after swap | After each replacement |
| **#2: Verify rendered output** | Trusting properties when nodes are hidden | After each change |
| **#3: Inspect footprint** | Missing sibling duplicate text | After section update |
| **#4: Re-validate before delete** | Swapping without comparing | Before removing old node |
| **#5: Never infer variants** | Property mismatches across families | When changing component sets |
| **#6: Distinguish evidence** | Confusing properties with reality | During validation |

---

## Troubleshooting

### "I planned everything but now I'm blocked at import"
You skipped the CRITICAL PRECONDITION. Go back and test import of one key component. If it fails, report the blocker and stop. Don't waste more time.

### "The component looks right but something's off"
You're probably trusting properties instead of rendered output. Rule #2: inspect actual TEXT and FRAME visibility. Take a screenshot and compare descendant nodes.

### "I swapped one section and another broke"
You didn't do Step 5. You swapped in the wrong order or didn't catch a dependency. Re-examine the sections' parent, overrides, and nesting. Plan the full order before continuing.

### "I found duplicate text nodes"
This is Rule #3 in action. Good catch. Delete the detached one only after confirming the library instance has the correct text internally.

---

## What Changed From Original

| Aspect | Original | Enhanced |
|--------|----------|----------|
| Precondition | Mentioned in text | **CRITICAL PRECONDITION** at top |
| Dependency planning | None | **Step 5** with examples |
| Detached text handling | Implicit | **Rule #3** + code example |
| Family swap safety | Vague | **Rule #5** explicit inspection |
| Validation | "Compare screenshots" | **Step 10** checklist with evidence levels |
| Composition guidance | Brief mention | **Step 8** expanded, temp frame pattern |
| Pitfalls | 3 categories | **4 categories** (added sequencing) |
| Known blockers | Vague | **Structured format** with remediation |

---

## Quick Start (TL;DR)

1. **Test import** (30 sec) — if fails, stop
2. **Map dependencies** (5 min) — plan order before editing
3. **Swap one section at a time** — validate after each
4. **Catch silent failures:**
   - Rule #3: detached text
   - Rule #5: property mismatches
   - Rule #5: sibling layout breaks
5. **Report results** — include dependency order

---

## Support and Feedback

This skill is based on real migration failures. If you encounter a new failure mode:

1. Document the symptoms, root cause, and prevention
2. Add it to the Known Pitfalls section
3. Update the relevant failure prevention rule or step
4. Share with product teams so overlay skills can learn

---

## Files and References

- **Full skill:** `apply-design-system.md` (canonical workflow)
- **Related skills:**
  - `fix-design-system-finding.md` (single-section fixes)
  - `audit-design-system.md` (discovery)
- **Product overlays:** Inherit this skill, add system-specific rules only

---

**This is a production-ready skill.** It consolidates learnings from actual Figma design-system migrations. Use it to migrate with confidence, catch silent failures before they ship, and save hours of wasted planning effort.
