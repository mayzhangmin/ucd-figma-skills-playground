---
name: apply-bee-ds-toolkit
description: "Use when actively migrating or rebuilding an existing Figma screen, frame, or section onto Bee-DS Toolkit after the relevant Bee families are known or being verified. Trigger for requests such as 'apply Bee-DS', 'move this screen to Bee-DS', 'connect this frame to Bee-DS', 'replace local Figma sections with Bee components', or 'rebuild this screen with Bee-DS components'. This skill is for execution and migration work, not for broad Bee design judgment or general live library lookup."
---

# Apply Bee-DS Toolkit To An Existing Design

Use this skill when the user wants an existing Figma screen, frame, or section migrated onto Bee-DS Toolkit instead of detached layers, local wrappers, or ad-hoc components.

This is a Bee-DS-specific specialization of [apply-design-system](../apply-design-system/SKILL.md).

Follow the full migration workflow in [apply-design-system](../apply-design-system/SKILL.md) for scope selection, import gating, backup, section inventory, dependency planning, swap versus composition strategy, blocker handling, and validation. This skill adds only Bee-specific rules, defaults, and pitfalls.

## Use This Skill For

- requests such as `apply Bee-DS`, `apply Bee-DS Toolkit`, `move this screen to Bee-DS`, or `connect this frame to Bee-DS`
- repeated migration passes across product screens that should use the Bee-DS library family
- Bee-DS button, dropdown, input, or icon replacement work where the generic skill needs Bee-specific family guidance

## Load First

- [apply-design-system](../apply-design-system/SKILL.md)
- [bee-ds-live-lookup](../bee-ds-live-lookup/SKILL.md) when the exact Bee family, variant, token, or icon still needs live lookup from Figma
- [bee-ds-design-guide](../bee-ds-design-guide/SKILL.md) when the task needs Bee screen-structure, spacing, or pattern judgment before writing
- `figma-use` before any `use_figma` write call
- normal Figma MCP inspection tools such as `get_metadata`, `get_screenshot`, and `search_design_system`

## Skill Boundary

This skill sits after lookup and design judgment.

Use:
- [bee-ds-live-lookup](../bee-ds-live-lookup/SKILL.md) to discover the exact live Bee asset, family, variant, token, or icon in Figma
- [bee-ds-design-guide](../bee-ds-design-guide/SKILL.md) to decide which Bee pattern, spacing rule, or screen structure should be preferred
- this skill to actually migrate, swap, compose, reconnect, and clean up the Figma section using Bee-DS

Do not use this skill as the primary place to maintain general Bee screen-design rules or long-lived Bee library inventories.

## Recommended Bee Skill Order

When a task spans discovery, design judgment, and implementation, use the Bee skills in this order:

1. `bee-ds-live-lookup`
	- confirm what Bee publishes right now
	- find the exact family, variant, token, or icon
2. `bee-ds-design-guide`
	- decide which Bee pattern fits the screen or section best
	- decide spacing, composition, and canonical screen structure
3. `apply-bee-ds-toolkit`
	- perform the migration or rebuild
	- validate rendered Bee instances and remove detached legacy artifacts

If the family is already known and the design judgment is straightforward, this skill can be loaded directly with [apply-design-system](../apply-design-system/SKILL.md).

## Bee-DS Target Libraries

Prefer these libraries in this order:
1. `Bee-DS Toolkit`
2. `Bee-DS Icon Library`
3. older `Bee-DS` results only when Toolkit does not expose the needed family and the user accepts the fallback

Do not mix similarly named search results casually. Verify the library name before importing.

## Reference Libraries

Use these canonical Figma files for direct library inspection when search results are noisy, variant choice is ambiguous, or you need to verify the published Bee-DS source manually.

- `Bee-DS Toolkit`: https://www.figma.com/design/oJgba28Kg7nFW0P1FLJfS5/Bee-DS-Toolkit
- `Bee-DS Icon Library`: https://www.figma.com/design/sSLTAUrPkxqw72ecpGMxDE/Bee-DS-Icon-Library

Treat these links as inspection references, not the primary source of truth.
Library name, import success, and exact component or component-set keys still take precedence when making migration decisions.

## Bee-DS Overrides To The Base Workflow

Apply these Bee-specific rules while following the base skill.

### Import Choice

For the precondition import test, prefer a Bee-DS Toolkit component family that is definitely needed for the target work, such as:
- the main button family expected on the screen
- the field family for the section being migrated
- a common structural primitive if many sections are being migrated

If the Bee-DS import fails, stop immediately, classify the affected work as `blocked`, and report the exact import error.

### Family Selection Rules

Choose the Bee-DS family first, then the variant.

Buttons:
- use `Secondary button` when the target has a visible border or medium emphasis
- use `Tertiary button` for lower-emphasis actions with lighter chrome
- use `Primary button` only for the dominant call-to-action
- do not assume you can convert one Bee family into another by setting a variant property alone

Inputs and dropdowns:
- prefer Bee-DS field titles inside the component over detached nearby text labels when the component already supports a title or header
- verify whether the visible title comes from the component header or from stray text outside the instance
- if the Bee instance already renders the intended title, remove or hide any detached duplicate text beside it

Icons:
- prefer Bee icons from `Bee-DS Icon Library`
- when an instance swap property expects an icon node reference, verify whether it needs an imported node ID instead of a component key
- do not assume icon slots are interchangeable across Bee-DS component families

### Validation Additions

During the base skill's validation steps, add these Bee-specific checks:
- after any Bee family change, inspect the new instance's actual `componentProperties`, visible descendant `TEXT` nodes, and visible descendant `FRAME` nodes
- for Bee inputs and dropdowns, verify both the title text and the visibility of the enclosing header container
- confirm detached labels are removed only after the Bee instance itself renders the intended copy
- confirm icon swaps actually took effect and did not silently stay on the default icon

## Bee-DS Working Assumptions

- Bee-DS migrations should end in real library-backed instances, not visual approximations
- published Bee-DS component families may have different property keys even when they look similar
- Bee-DS inputs and dropdowns often carry their own internal title or label structure, so detached text outside the instance is a common migration artifact
- Bee-DS button family changes are not just style changes; `Secondary button` and `Tertiary button` are different replacement targets

## Bee-DS Section Strategy Guide

Use the base skill's section buckets, but apply them with Bee-specific meaning.

### `exact-swap`

Use `exact-swap` when Bee-DS already publishes a component that matches the section's role and structure closely enough to replace it directly.

Quick test:
- the existing section and the Bee component do the same job
- the Bee component already has the right internal structure, not just the right styling
- the section can be replaced by one Bee instance or one compatible family swap without rebuilding the layout from smaller pieces

Typical Bee examples:
- a custom benefit row replaced by Bee `List`
- a local or detached nav section replaced by Bee `Top navigation` or `App native top navigation`
- a medium-emphasis outlined action replaced by a true Bee `Secondary button`
- a badge-bearing icon cluster replaced by Bee `Icon with badge`

Default preference:
- prefer `exact-swap` over composition when a published Bee component already exists for the section
- if a Bee-converted reference frame already exists in the same file, reuse that exact family and variant before searching broadly again

### `compose-from-primitives`

Use `compose-from-primitives` when no single Bee component exists for the full section, but Bee provides the smaller pieces needed to rebuild it cleanly.

Quick test:
- no one Bee component matches the whole section
- Bee does provide the internal building blocks
- the section can be rebuilt from Bee instances without inventing custom visual styling to fake the system

Typical Bee examples:
- a summary block made of title, badge, metrics, and actions rebuilt from Bee text, badge, and button primitives
- a wrapper section that groups several already-Bee child components but is not itself a Bee component
- a custom content panel rebuilt from Bee list rows, icons, and buttons because Bee does not ship that exact domain container

Guardrails:
- do not call something `compose-from-primitives` if the work really depends on keeping bespoke local styling; that is usually `blocked` or intentionally custom
- if the wrapper is legacy but the important children are already Bee-backed, first decide whether the wrapper actually needs rewriting or can remain `already-connected` for the user's goal

### `already-connected`

Use `already-connected` when the section is already a Bee library instance, or when the section is a wrapper the user is comfortable keeping because the meaningful child content is already Bee-backed.

Typical Bee examples:
- a button area whose primary and secondary actions are already real Bee button instances
- a section that is already composed from Bee instances and only needs audit confirmation, not rebuilding

### `blocked`

Use `blocked` when Bee-DS does not expose the required composite or primitive set, or when import/runtime constraints prevent a reliable migration.

Typical Bee examples:
- a required family or icon cannot be imported
- a section depends on fonts or legacy-node operations that the runtime cannot access
- the screen pattern is product-specific and Bee does not provide a safe canonical replacement

### Practical Decision Order

For each section, decide in this order:
1. Is it already Bee-backed enough to count as `already-connected`?
2. If not, does Bee publish one component for this exact job? If yes, use `exact-swap`.
3. If not, can the section be rebuilt cleanly from Bee pieces? If yes, use `compose-from-primitives`.
4. If not, classify it as `blocked` and explain why.

When in doubt, prefer the lowest-risk valid choice in this order:
`already-connected` -> `exact-swap` -> `compose-from-primitives` -> `blocked`

## Bee-DS-Specific Pitfalls

### Detached Labels Beside Fields

Common symptom:
- the input or dropdown appears correct internally
- the screen still shows a duplicate `ID`, `ID type`, or helper label nearby

Required response:
- inspect the stable parent group or frame
- identify detached sibling text nodes
- remove or hide them only after the Bee-DS instance renders the intended copy itself

### Hidden Header Containers In Dropdowns Or Inputs

Common symptom:
- the property says the title text is correct
- the visible title is missing because the container frame is hidden

Required response:
- inspect both the text node and its enclosing header or title frame
- verify container visibility, not only the text value

### Cross-Family Button Swaps

Common symptom:
- a button should become `Secondary button`, but the migrated result still behaves like the old family or keeps the wrong label or icon defaults

Required response:
- import or create a true Bee-DS `Secondary button` instance
- inspect its actual property keys
- patch label, icon visibility, icon swap, and state on that exact instance
- only then remove the previous button

### Icon Swap Type Mismatch

Common symptom:
- a Bee-DS icon swap property rejects a component key or silently stays on the default icon

Required response:
- inspect the exact property type
- if needed, import the icon and use the imported icon node ID rather than the component key

## Bee-DS Writing Rules

- prefer Bee-DS Toolkit over older Bee-DS libraries unless the user explicitly wants the fallback
- prefer exact component or component-set keys over name-only matching
- do not report success until the Bee-DS instance, visible text, and surrounding footprint all agree
- if a Bee-specific rule conflicts with the base skill's generic assumption, follow the Bee-specific rule and call out the reason

## Deliverable Additions

Use the base skill's deliverable format. When helpful, label the results with Bee-specific terminology:
- `Bee-DS swapped`: sections replaced with Bee-DS Toolkit instances
- `Bee-DS composed`: sections rebuilt from Bee-DS primitives
- `Bee-DS cleanup`: detached text or wrappers removed around successfully migrated sections
- `Blocked`: anything Bee-DS could not support, with the exact reason