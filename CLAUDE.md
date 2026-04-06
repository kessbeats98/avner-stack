# CLAUDE.md — avner-stack package

This repo IS the avner-stack governance framework, not a target project.
For the project CLAUDE.md template, see `templates/project/CLAUDE.md.tmpl`.

## Dev Notes
- `init/avner-init` scaffolds target projects from `templates/project/`
- `setup` installs skills globally via symlinks
- `agents/` contains the 3 core agents + 5 Council agents
- `skills/` contains skills installed globally for all AVNER projects
- `vendor/` contains read-only reference submodules (avner, gstack, gsd, ecc)
