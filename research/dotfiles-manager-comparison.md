# Dotfiles manager comparison

## Recommendation

**Keep this repository as a normal Git repository with one small Bash bootstrap and checked-in, schema-versioned JSON profiles for now.** That is a recognized dotfiles shape, not an anti-pattern: GitHub Codespaces formally supports cloning a dotfiles repository and running a root `install`, `bootstrap`, or `setup` script, falling back to symlinking dotfiles when no script exists ([GitHub Codespaces dotfiles documentation](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles)). GNU Stow's manual also explicitly identifies version-controlled home-directory configuration as a use case ([GNU Stow 2.4.1 manual](https://www.gnu.org/software/stow/manual/stow.html#Introduction)), and Dotbot deliberately models `git clone … && ./install` while leaving version control to Git ([Dotbot README](https://github.com/anishathalye/dotbot/blob/master/README.md#rationale)).

The recognized part is **Git + an installer/bootstrap + links**. A JSON profile overlay is a reasonable local convention, but not a standard dotfiles protocol. Its value here is that machine data—platform, package set, sessionizer roots, and the selected Ghostty variant—stays declarative and reviewable. Keep the JSON vocabulary deliberately small rather than building a general configuration language.

Do **not** add a manager merely to avoid roughly one page of link/backup code. Of the evaluated tools, **Dotbot is the closest replacement** if that code becomes troublesome: it natively handles explicit links and timestamped backups while preserving this repository's current layout. **chezmoi becomes the better tool only when machine variation grows enough to justify its source-state naming, templates, local machine config, and persistent state.** Stow and yadm are sound tools, but neither fits this exact repository as closely.

## What custom Git + Bash buys, and what it costs

### Strengths

- The repository remains ordinary: files have application-oriented names, Git works normally, and there is no manager-specific source-state encoding.
- One explicit entry point can perform the genuinely repo-specific work in the required order: choose a profile interactively, install packages, back up collisions, create links, and emit shared sessionizer data.
- Linux/macOS differences are visible as normal files and profile values. Ghostty can have complete platform files instead of conditional fragments.
- Symlinks keep edits in the checked-out repository, which matches the current editing model.
- With no secrets, there is no need to adopt a manager for encryption or password-manager integration.
- Idempotence can be simple and inspectable: package-manager “already installed” operations, a correct-link no-op, and backup only when a destination is neither absent nor already the intended link.

### Maintenance owned by this repository

- Define, validate, and migrate the JSON schema; reject unsupported `schema_version` values rather than guessing.
- Define composition semantics. Avoid a generic deep merge: concatenate only documented arrays, allow a platform scalar to override a common scalar, and reject duplicate link destinations.
- Bootstrap the parser (`jq`) and package manager, including Homebrew on a fresh Mac if it is part of the design. Bash on macOS also means avoiding features unavailable in its system Bash unless a newer Bash is installed first.
- Correctly handle quoting, spaces, relative/absolute paths, broken links, failed partial runs, `sudo`, package-manager differences, dry runs, and non-interactive invocation.
- Specify collision backup location, timestamping, restoration, and cleanup. A good installer must never repeatedly back up the link it created itself.
- Own drift reporting and removal of obsolete links; Git does not know what was installed into `$HOME`.
- Keep package installation idempotent and decide whether package removal is intentionally out of scope.
- Test the first-install and repeat-install paths on both platforms whenever bootstrap behavior changes.

These costs are real, but the current requirement already contains custom policy—interactive profile selection, package sets, shared sessionizer roots, and platform-complete Ghostty files—that no compared tool removes entirely.

## Status snapshot and comparison

Status checked 2026-11-26 from first-party projects: GNU Stow's current published manual is **2.4.1** (2024-09-08) ([GNU project page](https://www.gnu.org/software/stow/)); chezmoi's latest release is **2.74.2** (2026-11-22) ([release](https://github.com/twpayne/chezmoi/releases/tag/v2.74.2)); yadm's latest tag is **3.5.0** (2025-03-03), and its unarchived repository has later development activity ([tag commit](https://github.com/yadm-dev/yadm/commit/7eabaee84c8bd9521e56966e5c88e7a435fdd9c7), [repository](https://github.com/yadm-dev/yadm)); and Dotbot's latest release is **1.24.0** (2025-11-29), with subsequent activity in its unarchived repository ([release](https://github.com/anishathalye/dotbot/releases/tag/v1.24.0), [repository](https://github.com/anishathalye/dotbot)).

“Native” below means behavior supplied by the tool itself. “Custom” means this repository still owns a script, convention, or external package-manager call.

| Option | Common + Linux/macOS selection | Symlinks and existing files | Packages, first setup, idempotence | Fit for the exact requirement |
|---|---|---|---|---|
| **Git + Bash + JSON** | **Custom:** explicit common/platform profile composition and complete Ghostty variants. JSON is versioned in Git and carries `schema_version`. | **Custom:** `link_file` creates links and moves a collision to a state-directory backup first. | **Custom:** native package-manager commands, interactive Bash prompt, and all idempotence/error handling. | **Best now.** Every custom part expresses repo-specific policy; no second DSL or layout migration. Keep the interface narrow. |
| **GNU Stow 2.4.1** | **Native:** separate package trees can be stowed together. **Custom:** OS detection and choosing common + platform packages; no profile data or templating. | **Native:** symlink farms, simulation, restow, and conflict detection. It normally refuses a pre-existing plain file; `--adopt` moves that file *into the Stow package*, which is useful for review but is not a preserved backup ([invocation manual](https://www.gnu.org/software/stow/manual/html_node/Invoking-Stow.html)). **Custom:** timestamped backups. | **Custom:** package installation and interactive setup. Stow stores no extra state and repeated stowing/restowing is predictable, but bootstrap idempotence remains ours ([manual](https://www.gnu.org/software/stow/manual/stow.html#Introduction)). | Good if the repo's primary abstraction is package-shaped directory trees. Here it adds a tree-layout migration while leaving profiles, packages, backups, and prompting custom. |
| **chezmoi 2.74.2** | **Native:** a common source directory plus machine-local config, Go templates, `.chezmoi.os`, JSON/JSONC/TOML/YAML data, lexical data merging, and templated ignore rules ([setup](https://www.chezmoi.io/user-guide/setup/), [templating](https://www.chezmoi.io/user-guide/templating/), [data files](https://www.chezmoi.io/reference/special-files/chezmoidata-format/), [ignore rules](https://www.chezmoi.io/reference/special-files/chezmoiignore/)). This can replace most JSON overlay logic. | **Native:** files, directories, and explicit `symlink_` source-state entries; apply/diff/merge and overwrite prompting for managed files ([source-state attributes](https://www.chezmoi.io/reference/source-state-attributes/), [apply](https://www.chezmoi.io/reference/commands/apply/)). It does **not** document Dotbot-style automatic timestamped collision backups; preserving an existing target requires reviewing/adding/merging or custom backup policy ([usage FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/usage/)). Default management is generated/copied target files, not repository-to-home symlinks. | **Native orchestration:** `run_`, content-hashed `run_onchange_`, and `run_once_` state; init-time prompts and one-command init/apply ([scripts](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/), [setup](https://www.chezmoi.io/user-guide/setup/#create-a-config-file-on-a-new-machine-automatically)). **Custom:** actual apt/pacman/brew commands; the docs explicitly implement package installation as scripts and still advise scripts be idempotent. | Most complete cross-machine model, but currently more mechanism than needed. Best future migration target for numerous hosts, generated per-host content, or increasingly complex conditions. |
| **yadm 3.5.0** | **Native:** OS/distro/arch/host/user/class “alternate” files and a built-in template processor; the selected alternate is linked automatically ([alternates](https://yadm.io/docs/alternates), [templates](https://yadm.io/docs/templates)). | **Native:** normal files are tracked directly in a bare-style Git repository whose work tree is `$HOME`; alternate variants get generated symlinks. On clone, conflicting local files are left unmodified for manual resolution—not backed up automatically ([manual](https://github.com/yadm-dev/yadm/blob/3.5.0/yadm.md#commands)). This does not naturally satisfy “all configs are symlinks into a normal checkout.” | **Native orchestration:** clone offers to run `$HOME/.config/yadm/bootstrap`. **Custom:** the executable bootstrap and all package commands; yadm explicitly recommends making it idempotent ([bootstrap](https://yadm.io/docs/bootstrap)). | Strong for people who want Git directly over `$HOME`. Poor match for preserving this normal checkout and explicit repo-to-home symlink model. |
| **Dotbot 1.24.0** | **Native:** per-link shell `if` conditions, and configuration may be YAML or JSON. **Custom/conventional:** select multiple machine/platform config files in the install wrapper; the project's wiki documents profiles as wrapper-script composition rather than a core data model ([README configuration](https://github.com/anishathalye/dotbot/blob/v1.24.0/README.md#configuration), [multiple configurations](https://github.com/anishathalye/dotbot/wiki/Tips-and-Tricks#how-can-i-have-different-groups-of-tasks-for-different-hosts-with-different-configurations)). | **Native:** explicit symlinks, parent creation, relinking, and `backup: true`, which renames a collision with `.dotbot-backup.{timestamp}` ([README link directive](https://github.com/anishathalye/dotbot/blob/v1.24.0/README.md#link)). This is the closest match to the requested collision behavior. | **Native orchestration:** ordered `shell` directives can accept stdin, and configs should be idempotent. **Custom:** package-manager commands and profile prompt; package directives are third-party plugins, not Dotbot core ([README](https://github.com/anishathalye/dotbot/blob/master/README.md#configuration)). | **Best manager alternative.** Low migration and useful link/backup behavior, but it still needs a wrapper and package/session-root logic, so its net benefit is small at the current scale. |

## Requirement-by-requirement implications

- **Linux/macOS and common + platform config:** all four tools can be made to work. chezmoi and yadm understand machine conditions natively; Stow and Dotbot need a selector script/config convention. Plain Bash already needs such a selector and makes it explicit.
- **Symlinks:** Stow and Dotbot are naturally link-oriented. chezmoi supports links but normally materializes generated files. yadm normally tracks files in `$HOME`; only alternates are symlinked.
- **Existing-file backup:** Dotbot alone has the exact native timestamped-backup primitive. Stow refuses or adopts, yadm preserves a conflict for manual resolution, and chezmoi provides diff/merge/overwrite workflows rather than a documented automatic backup archive.
- **Package installation:** none of the four is a cross-platform package manager. chezmoi supplies stateful script scheduling, yadm supplies a bootstrap command, and Dotbot supplies shell directives; Stow supplies neither. The apt/pacman/brew/Homebrew policy remains custom in every case.
- **Fish/Bash shared sessionizer roots:** this is application data, not dotfile-manager behavior. Store roots once in the selected profile and have both shells call the same sessionizer executable, which reads a generated newline-delimited data file. Do not generate two shell-specific lists.
- **Ghostty platform files:** keep complete `linux` and `macos` files and link exactly one to the platform's documented location. Ghostty reads `${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config.ghostty` on Linux and additionally uses `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty` on macOS, where that file has higher precedence ([Ghostty configuration file locations](https://ghostty.org/docs/config#file-location)). Every option can select one; chezmoi/yadm can template a single file, but complete files are easier to inspect when platform settings differ substantially.
- **No secrets:** removes the main reason to pay the complexity cost of chezmoi's encryption/password-manager features or yadm encryption.
- **Interactive first setup:** chezmoi has native init-time prompt functions; yadm asks whether to run bootstrap. Stow and Dotbot require custom prompting. A Bash `select`/read prompt is sufficient here, with `--profile` for unattended use.
- **Idempotence:** no tool makes arbitrary package/install scripts idempotent. Chezmoi can suppress unchanged/once scripts by content hash, but its own docs still require scripts to be idempotent. Dotbot says the same; yadm explicitly places the responsibility on bootstrap. Link reconciliation itself is naturally repeatable in all four.

## Migration from this repository

The current checkout is already organized by application (`fish/`, `ghostty/`, `nvim/`, `tmux/`, `rex/`, `caelestia-shell/`), with executable scripts under `bin/.local/scripts/` and `starship.toml` at the root. There is no bootstrap or machine-profile layer yet.

Two content changes are required regardless of manager:

1. `ghostty/config.ghostty` mixes Linux-specific `/usr/bin/fish`, GTK options, and an absolute `/home/joaocunha50/...` shader path. It must become explicit Linux/macOS variants and use portable/profile-derived paths.
2. Both sessionizers currently hard-code `~/dev` and `~/uni`. They should consume one machine-local roots file generated from the selected profile.

| Option | Migration cost from the current tree |
|---|---|
| **Git + Bash + JSON** | **Low to moderate.** Keep application directories and add profiles/bootstrap. Split Ghostty and change the sessionizers; add explicit source→destination mappings. |
| **Dotbot** | **Low to moderate.** Keep the tree, add pinned Dotbot (submodule, packaged binary, or prerequisite), config, and a platform/profile wrapper. The same Ghostty/sessionizer changes remain. |
| **Stow** | **Moderate.** Reorganize files into installation images such as `common/.config/fish/config.fish`, `linux/.config/ghostty/config.ghostty`, and `common/.local/scripts/...`; add a bootstrap for selection, backups, packages, and prompts. |
| **chezmoi** | **High one-time cost.** Import/rename paths into source-state names such as `dot_config/...`, decide which entries are copied versus `symlink_`, translate profiles to data/config templates, and adopt `chezmoi edit/apply` workflow. |
| **yadm** | **High and conceptually disruptive.** Rewrite the repository tree to paths relative to `$HOME` (for example `.config/fish/config.fish`) and move from a visible normal checkout to yadm's repository with `$HOME` as work tree. Its normal-file model also changes the requested symlink behavior. |

## Proposed boring layout and interface

```text
bootstrap                       # only public setup entry point
profiles/
  common.json                   # schema_version, common packages, session roots/defaults
  linux.json                    # platform, package manager, Linux packages, Ghostty source
  macos.json                    # platform, package manager, macOS packages, Ghostty source
config/
  common/
    fish/config.fish
    nvim/...
    rex/init.lua
    starship/starship.toml
    tmux/tmux.conf
    scripts/rex-sessionizer
    scripts/tmux-sessionizer
  linux/
    ghostty/config.ghostty
    ghostty/tabs.css
    caelestia-shell/...
  macos/
    ghostty/config.ghostty
  shared/
    ghostty/shaders/...
```

Repository paths need not mirror `$HOME`; the bootstrap owns one short, explicit mapping table. Avoid link discovery by filename because it makes accidental files installable.

### Profile contract

Each JSON document has `"schema_version": 1`. `common.json` contains shared package names and default `session_roots`; a platform profile contains only `platform`, `package_manager`, platform packages, optional root overrides, and the Ghostty source and destination paths. The bootstrap implements only these operations:

1. detect `linux` or `darwin`; if interactive, show the inferred profile and ask once; `--profile linux|macos` is mandatory in non-interactive use;
2. ensure the one JSON parser prerequisite, then validate both documents and their schema version;
3. compose documented fields only—no recursive/general-purpose merge;
4. install missing packages using the selected native package manager;
5. write `${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/session-roots`, one expanded absolute directory per line, atomically;
6. link common paths plus exactly one platform Ghostty path;
7. when a destination collision is not already the intended link, move it once to `${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/backups/<timestamp>/<home-relative-path>` before linking;
8. on repeated runs, leave installed packages, generated data, and correct links unchanged.

Suggested interface:

```text
./bootstrap                         # interactive first setup
./bootstrap --profile linux         # repeatable/unattended
./bootstrap --profile macos --dry-run
```

Keep update separate and unsurprising: `git pull`, inspect, then rerun `./bootstrap --profile …`. Do not make the script pull or commit automatically.

## Threshold for changing tools

Stay with the proposed design while there are roughly **two platforms, a handful of machines, complete platform files, no secrets, and fewer than about 30 explicit link targets**. Reconsider when one of these observable conditions appears:

- link collision, drift, removal, or dry-run code becomes a substantial subsystem: adopt **Dotbot**, retaining the profile/package wrapper;
- three or more independent host roles require many conditional fragments, generated values, per-host local data, or repeated reconciliation; or secrets/password-manager data enter scope: migrate to **chezmoi** and let its config/data/templates/scripts replace the JSON overlay and most bootstrap state;
- the desired model changes to “Git directly tracks files in `$HOME`”: choose **yadm**;
- the repo is deliberately reorganized into package-shaped directory images and only symlink farming is wanted: choose **GNU Stow**.

For the repository as it exists, none of those thresholds has been crossed. Plain Git + a constrained bootstrap is the smallest design that completely meets the requirement; Dotbot is the first escalation, and chezmoi is the eventual complexity threshold—not a prerequisite now.
