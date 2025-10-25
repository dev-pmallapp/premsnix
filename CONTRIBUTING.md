# Contributing to premsnix

Thank you for your interest in contributing to premsnix! This document provides
guidelines for contributing to this Nix-based dotfiles configuration.

## Code Style and Conventions

### Nix Code Style

1. **Library Usage**:
   - Avoid using `with lib;` - instead use `inherit (lib) ...` or inline `lib.`
     prefixes
   - Prefer inlining `lib.` usages to `inherit (lib)` when 1 or 2 usages of the
     library function
   - Keep `let in` blocks scoped as close to usage as possible

2. **Imports**: Group related imports together within the inputs or let binding

3. **Naming**:
   - Use camelCase for variables
   - Use kebab-case for files/directories

4. **Options**: Define namespace-scoped options (premsnix.*)
   - Reduce option repetition by using a shared top level option
   - Use top level option values throughout configuration when possible

5. **Conditionals**: Prefer `lib.mkIf`, `lib.optionals`, `lib.optionalString`
   instead of `if then else` expressions
   - Only use `if then else` when it makes the expression too complicated using
     other means

6. **Organization**: Group related items within each module

7. **Theming**: Handle theme toggling with conditional paths and mkIf
   expressions
   - Prefer specific theme module customizations over stylix
   - Prefer all theme modules over the defaults of each module

8. **Reduce Repetition**: Utilize Nix functions and abstractions to minimize
   duplicated code

### Module Organization

- **Host specific customization**: Place in host named configuration modules
- **Platform specific customization**: Place in nixos/darwin modules
- **Home application specific customization**: Place in home modules
- **User specific customization**: Place in user home configuration
- **Prefer handling customization in home configuration**, wherever possible

## Commit Message Convention

This repository follows a **component-based** commit message format:

```
component: description
```

### Examples:

- `claude-code: enhance commit-changes with pattern recognition`
- `firefox: userchrome trimmed down`
- `hyprland: add walker to test`
- `flake.lock: update`
- `docs: add specialized agents and commands section`

### Guidelines:

- Use lowercase for the description
- Keep the subject line under 50 characters when possible
- Use imperative mood ("add", "fix", "update", not "added", "fixed", "updated")
- No trailing period in the subject line
- Component should match the primary area affected (module name, config area,
  etc.)

## Development Workflow

### Before Making Changes

1. (Optional) Sync & update flake inputs: `nix flake update` (only when needed)
2. Skim recent changes: `git fetch --all --prune && git rebase origin/main` (or
   merge)
3. Pick a target system to validate (e.g. `${host}` you care about)
4. Ensure secrets you’ll touch are present (sops-nix) before editing modules

### Before Committing (Manual Checklist)

Pre-commit hooks that auto-format were intentionally disabled to speed
iteration. You MUST run the following manually before every commit:

1. Format everything:
   - `nix fmt`
2. Run flake checks (includes treefmt + statix + other format validators in
   read-only mode):
   - `nix flake check`
3. (If touching a host) Build at least one affected system:
   - `nix build .#nixosConfigurations.${host}.config.system.build.toplevel`
   - For Darwin: `nix build .#darwinConfigurations.${host}.system`
4. (If touching home modules) Dry-eval a home configuration:
   - `nix build .#homeConfigurations."${user}@${host}".activationPackage`
5. Stage & review diff:
   - `git add -p`
   - `git diff --cached`
6. Commit with a scoped message (see below)

Shortcuts:

```
# Basic (format + flake check)
nix fmt && nix flake check

# Full (with one host build)
nix fmt && nix flake check && nix build .#nixosConfigurations.${host}.config.system.build.toplevel

# Flake app wrapper (auto finds repo root)
nix run .#dev-check -- --host ${host}

# Auto-fix (deadnix --edit + statix fix + reformat)
nix run .#dev-check -- --host ${host} --fix
```

Optional git alias:

```
git config alias.dev-check '!./scripts/dev-check.sh'
```

### Optional Pre-Push Hook

To enforce a minimal gate (formatting unchanged + flake check) before pushes:

```
ln -sf ../../scripts/pre-push-check.sh .git/hooks/pre-push
# or set a hooks path:
git config core.hooksPath .githooks
mkdir -p .githooks
cp scripts/pre-push-check.sh .githooks/pre-push && chmod +x .githooks/pre-push
```

Skip the hook for an emergency push:

```
SKIP_PRE_PUSH=1 git push
```

### Branch Protection & CI Guarantees

Recommended protected branch rules:

1. Require latest successful runs of:
   - Formatting Check (fmt.yml)
   - Lint & Flake Check (lint.yml)
2. (Optional) Require Nightly Host Builds on release branches.
3. Disallow force pushes to main; use PRs to ensure checks run.
4. Mark formatting drift failures as required (ensures contributors run
   `nix fmt`).

CI artifacts for debugging:

- `formatting-diff.patch`: Unified diff of required formatting changes.
- `flake-show-<system>.json`: Flake output graph per system from eval job.

To reproduce CI locally:

```
# Format & drift check
nix build .#checks.$(nix eval --raw --expr 'builtins.currentSystem').treefmt
nix fmt

# Linters
nix develop -c statix check .
nix develop -c deadnix .

# Example system build
nix build .#nixosConfigurations.premsnix.config.system.build.toplevel
```

If any formatter would have changed files, re-run `nix fmt` until `git diff` is
clean.

### Making Changes

1. Follow the code style guidelines above
2. Test your changes on your system or a representative subset
3. Keep commits focused and minimal (avoid mixing refactors with feature
   changes)
4. Use secrets management with sops-nix for any sensitive data
5. Avoid committing generated artifacts or decrypted secrets

### Submitting Changes

1. Create atomic commits - one logical change per commit
2. Follow the commit message convention
3. Ensure manual checklist (format + flake check + build) is clean
4. Include only necessary changes (no accidental reformat churn outside touched
   scope)
5. Test that at least one representative system and/or home config builds
   successfully
6. Push and let CI re-run the formatting / lint checks in read-only mode

## Available Tools

### Claude Code Commands

The repository includes specialized Claude Code commands:

#### Nix Commands

- `nix-refactor [path] [--style-only] [--fix-let-blocks] [--fix-lib-usage]`
- `nix-check [path] [--build] [--eval] [--format]`
- `module-scaffold [name] [--nixos] [--home] [--darwin]`

#### Git Commands

- `commit-changes [--all] [--amend]`: Analyze and commit changes following repo
  conventions
- `add-and-format [files]`: Stage files and run formatters
- `commit-msg [type] [message]`: Generate conventional commit messages

#### Quality Assurance

- `quick-check [path]`: Fast validation of code quality and formatting
- `deep-check [path] [--security] [--performance]`: Comprehensive code analysis
- `style-audit [path] [--fix]`: Style and convention compliance check

### Specialized Agents

When using Claude Code, specialized agents are available:

- **Dotfiles Expert**: premsnix configuration specialist
- **Nix Expert/Module Expert/Refactor**: Nix language specialists
- **System Config Expert**: NixOS system configuration specialist
- **Security Auditor**: Security analysis specialist

## Getting Help

- Check the [CLAUDE.md](./CLAUDE.md) file for detailed development guidelines
- Use the specialized Claude Code agents for complex tasks
- Ensure you understand the module structure before making changes

## Security

- Never commit secrets or keys to the repository
- Use sops-nix for secrets management
- Follow security best practices in configurations
- Use the Security Auditor agent for security-related changes

Thank you for contributing to premsnix!
