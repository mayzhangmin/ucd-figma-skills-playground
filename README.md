# Figma Design System Skills

This repository packages reusable Figma design-system workflows as portable skills.

The canonical source lives in [`skills/`](skills/). The repo also exposes the same skills through project-local Claude Code entries in [`.claude/skills/`](.claude/skills/), so the same checkout can be used in both Codex and Claude Code.

## Included Skills

- `apply-design-system`
  Review an existing design and connect it to design system components.
- `audit-design-system`
  Audit a Figma screen or component for design-system integration drift, including missing shared components, local overrides, and unbound tokens.
- `fix-design-system-finding`
  Fix a specific design-system integration finding in a Figma screen or component, including missing shared components, local overrides, and unbound tokens.

## Repository Layout

```text
.
├── README.md
├── skills/
│   ├── apply-design-system/
│   ├── audit-design-system/
│   └── fix-design-system-finding/
└── .claude/
    └── skills/
        ├── apply-design-system -> ../../skills/apply-design-system
        ├── audit-design-system -> ../../skills/audit-design-system
        └── fix-design-system-finding -> ../../skills/fix-design-system-finding
```

Each skill folder contains:

- `SKILL.md`: shared instructions that work across tools using the open Agent Skills format
- `agents/openai.yaml`: Codex/OpenAI UI metadata; safe for other tools to ignore

## Prerequisites

These skills assume the host environment already has Figma access set up. In practice that means:

- Figma MCP read tools such as `get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`, and `search_design_system`
- Figma write access via `use_figma`
- a helper skill or built-in workflow that teaches safe `use_figma` usage, if your environment requires one

This repository does not vendor the full Figma helper stack. It contains the design-system workflows themselves.

## Use In Codex

Copy the skills you want into your Codex skills directory:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R skills/* "${CODEX_HOME:-$HOME/.codex}/skills/"
```

After that, the skills are available as:

- `$apply-design-system`
- `$audit-design-system`
- `$fix-design-system-finding`

Codex uses the `agents/openai.yaml` files for display names, descriptions, and default prompts.

## Use In Claude Code

Claude Code already discovers project-local skills from [`.claude/skills/`](.claude/skills/), so opening this repository in Claude Code is enough to make the three skills available as slash commands:

- `/apply-design-system`
- `/audit-design-system`
- `/fix-design-system-finding`

If you want them available across all projects instead, copy the same folders into `~/.claude/skills/`.

Claude Code reads `SKILL.md` and ignores the Codex-specific `agents/openai.yaml` metadata.

## Editing And Publishing

Edit the canonical files under [`skills/`](skills/). The Claude Code entries are symlinks to those same directories, so there is only one source of truth per skill.

When adding a new skill, use the same pattern:

1. Create `skills/<skill-name>/SKILL.md`
2. Add `skills/<skill-name>/agents/openai.yaml` if Codex UI metadata is needed
3. Add a matching symlink under `.claude/skills/`
4. Document the skill here
