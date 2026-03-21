# Codex Skills

This repository is a home for reusable Codex skills.

Each skill is a self-contained folder that can be copied into a Codex skills directory and shared with other teams. The first skill in this repository is `figma-design-review`, a Figma review skill that inspects screens for design-system integration drift and returns review findings in the schema Codex desktop can render as review cards.

## Repository Layout

```text
.
├── README.md
└── skills/
    └── figma-design-review/
        ├── SKILL.md
        └── agents/
            └── openai.yaml
```

## Adding More Skills

Add each new skill under `skills/<skill-name>/`.

Recommended structure:

```text
skills/
  <skill-name>/
    SKILL.md
    agents/
      openai.yaml
    scripts/        # optional
    references/     # optional
    assets/         # optional
```

Guidelines:

- Keep each skill self-contained.
- Put trigger rules and workflow in `SKILL.md`.
- Keep UI metadata in `agents/openai.yaml`.
- Add optional `scripts/`, `references/`, and `assets/` only when the skill needs them.

## Installing A Skill

Copy the desired skill folder into your Codex skills directory:

```bash
cp -R skills/figma-design-review ~/.codex/skills/
```

If `CODEX_HOME` is set in your environment, copy it into `$CODEX_HOME/skills/` instead.

## Current Skills

- `figma-design-review`: Review Figma boards, screens, or components for design-system integration drift.
