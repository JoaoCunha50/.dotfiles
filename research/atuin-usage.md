# Modern Atuin usage and fit for this dotfiles design

## Executive conclusion

Atuin still has a clear, non-dotfiles value proposition in the 18.25 era: **context-rich local shell-history search**. Cross-device encrypted history sync is the second well-evidenced use. Public workflow material repeatedly demonstrates `Ctrl-R` search, directory/workspace/host filtering, and history moving between machines; it does not show comparable adoption of KV, scripts, output capture, or stats. This is a reading of the available first-party material and named users' workflows, not usage telemetry.

For the stated setup—one Linux desktop, one Mac, a possible future Linux laptop, local-first operation, occasional manual sync, and machine-specific JSON configuration—the best fit is:

1. **Keep machine configuration out of Atuin.** Atuin removed its dotfiles feature in 18.23 because it was incomplete and could be unsafe, and explicitly recommends a purpose-built tool such as chezmoi ([18.23.0 release, 2026-09-22](https://github.com/atuinsh/atuin/releases/tag/v18.23.0)). KV remains in 18.25, but using a globally synced string store as a machine-configuration database would be custom glue rather than a documented modern workflow.
2. **Use Atuin locally for history search if context-aware recall is useful.** Current docs explicitly support staying local and skipping sync ([18.25 overview](https://docs.atuin.sh/18.25/)). Disable both sync and the update check if “local-first” means no unsolicited Atuin network access; the current config docs say `update_check = false` plus no sync causes no network requests of its own ([18.25 config](https://docs.atuin.sh/18.25/configuration/config/)).
3. **Enable Threads locally only if agent-session search/resume solves a real problem.** Threads is opt-in, requires the daemon, and captures conversations, tool inputs/outputs, and diffs; that is substantially more sensitive than command history ([18.25 Threads docs](https://docs.atuin.sh/18.25/ai/threads/)).
4. **Add encrypted manual sync later, rather than making it part of the dotfiles architecture now.** Set `auto_sync = false` and run `atuin sync` when desired; both are current documented behavior ([18.25 config](https://docs.atuin.sh/18.25/configuration/config/#auto_sync), [sync reference](https://docs.atuin.sh/18.25/reference/sync/)). Sync becomes materially useful once the Mac and Linux machines both host terminal work, or when the laptop arrives.

In short: **Atuin is a history/agent-work-log tool, not the configuration transport for this design. Start local; add sync only after cross-machine history is demonstrably useful.**

## Scope and confidence

“Dominant” below means dominant in current official positioning plus concrete, attributable public workflows. Atuin does not publish a current feature-by-feature usage breakdown. The official August 2026 sync article reports record-count distributions for Atuin Hub users, which demonstrates substantial sync data but not how often each UI or subcommand is used ([packfiles post, 2026-08-25](https://blog.atuin.sh/making-atuin-sync-32x-faster-with-packfiles/)). Community sources are therefore treated only as anecdotes about their authors.

The version boundary matters: **18.23.0 was released on 2026-09-22 and removed dotfiles support**. Any earlier article or video that mentions `atuin dotfiles`, synced aliases, or synced environment variables is stale on that point, even when its history-search advice remains useful.

## What people actually use

| Capability | Evidence of real-world use | Assessment in 18.25 |
|---|---|---|
| **History search** | Multiple independent users show replacing shell `Ctrl-R`/fzf with Atuin, especially directory/workspace, host, exit-code, and time filters: DevOps Toolbox’s demo ([2024-07-12](https://www.youtube.com/watch?v=Em0TdAftXAA)), Caleb Hearth’s daily workflow ([2024-11-12](https://calebhearth.com/search-sync-shell-atuin)), Bruno Perrotta’s fzf-like setup ([2025-11-30; updated 2026-02-16](https://perrotta.dev/2025/11/atuin/)), and Karandeep Singh’s Atuin 18.19 trial ([2026-08-11](https://karandeepsingh.ca/posts/atuin-shell-history-search/)). | **Primary use and clearest value.** The current homepage still leads with local SQLite history plus command, directory, duration, result, machine, and session context ([18.25 overview](https://docs.atuin.sh/18.25/)). |
| **Cross-device history sync/backup** | Fuzz describes the concrete trigger—needing commands from another computer—and deploys a self-hosted server for six servers and three clients ([2026-04-22](https://fuzznotes.com/posts/shell-history-with-atuin/)). DevOps Toolbox demonstrates moving history to another host; Perrotta describes personal/work computer continuity; Ellie Huxtable’s EMF talk explains search, sync, and encryption ([2024-06-01](https://media.ccc.de/v/emf2024-160-keeping-shell-history-in-sync-with-turtles-and-magic)). | **Second primary use.** Optional, supports hosted or self-hosted servers, automatic or manual sync, and is documented as end-to-end encrypted ([18.25 sync reference](https://docs.atuin.sh/18.25/reference/sync/)). It is not required for local search. |
| **Stats** | Hearth uses stats to spot possible aliases and publishes weekly stats; Perrotta calls it “cool” and uses it to inspect tool habits. | **Secondary/reflective use, not a reason to architect around Atuin.** Official docs themselves call stats “currently a little basic” ([18.25 stats reference](https://docs.atuin.sh/18.25/reference/stats/)). |
| **Scripts** | The first-party launch shows turning recent commands into named, tagged, parameterized scripts with a configurable shebang and encrypted sync ([official post, 2025-04-09](https://blog.atuin.sh/atuin-scripts-shareable-syncable-shell-snippets/)). The reviewed concrete user workflows did not feature it. | **Available but not evidenced as dominant.** Useful for personal snippets; source-controlled scripts remain easier to review, diff, test, and provision as part of dotfiles. The launch post predates 18.23 but Scripts itself was not removed. |
| **KV** | The first-party v16 launch presented KV as a beta store for small text, environment fragments, or small scripts up to 100 KiB, synced across machines, and warned against production secrets ([official post, 2023-08-02](https://blog.atuin.sh/release-v16/)). Atuin 18.25 source still contains `set`, `get`, `delete`, `list`, namespaces, stdin values, encryption, and the record store ([v18.25.0 KV CLI source](https://github.com/atuinsh/atuin/blob/v18.25.0/crates/atuin/src/command/client/kv.rs)). There is no current 18.25 user guide presenting KV as a dotfiles or machine-config solution, and none of the reviewed named workflows uses it that way. | **Low-profile primitive, not a mainstream configuration workflow.** It can hold JSON as text, but provides no documented schema, host overlay, template, merge, provenance, or deployment model. Using namespaces or host-named keys to invent those semantics is possible but custom. |
| **Daemon** | First-party v18.13 material demonstrates faster in-memory fuzzy search and background sync ([2026-03-18](https://blog.atuin.sh/atuin-v18-13/)); current docs also assign it database writes, maintenance, captured output, and thread capture ([18.25 daemon reference](https://docs.atuin.sh/18.25/reference/daemon/)). | **Infrastructure, not usually the end goal.** It is useful for `daemon-fuzzy` search and required by Threads/output capture, but adds a managed background process. |
| **Command-output capture** | Current docs show inspector playback, full-text `atuin output search`, and MCP access. It is off by default and requires both the PTY proxy and daemon ([18.25 output-capture guide](https://docs.atuin.sh/18.25/guide/output-capture/)). No reviewed independent workflow made it central. | **New/specialized.** Captured output remains local and is explicitly **not synced** in 18.25. It has a default 1 MiB per-command cap, a disk budget, exclusions, and best-effort secret redaction. Enable only for a concrete output-recall need. |
| **AI Threads** | The creator describes her own multi-machine workflow: searching old agent work, resuming/forking sessions across machines and agents, and using MCP to retrieve past investigations ([official author anecdote and demo, 2026-10-27](https://blog.atuin.sh/threads-agent-sessions/)). Threads first shipped in 18.24 ([18.24.0 release, 2026-10-15](https://github.com/atuinsh/atuin/releases/tag/v18.24.0)). | **Promising but too new to call dominant.** Current 18.25 docs support local capture, search, import, resume, forks, cross-agent continuation, and encrypted sync for a growing agent list ([Threads docs](https://docs.atuin.sh/18.25/ai/threads/)). It is opt-in and its privacy/storage surface is much larger than history. |

### Overall pattern

The public workflows are remarkably consistent:

1. import existing history;
2. bind Atuin to `Ctrl-R` while often leaving the up arrow alone;
3. retrieve commands with fuzzy search and current-directory/workspace/host filters;
4. optionally sync between computers;
5. sometimes inspect stats.

That pattern appears in the DevOps Toolbox, Hearth, Perrotta, Singh, and Fuzz examples above. Scripts, KV, output capture, and Threads are real product capabilities, but only Threads currently has a detailed first-party workflow story. This justifies calling search and sync dominant while avoiding a claim about population-wide market share.

## Useful workflow material and freshness

| Material | Published | Concrete workflow shown | Relative to 18.23 dotfiles removal |
|---|---:|---|---|
| [Atuin Threads: All your agent sessions on every machine](https://blog.atuin.sh/threads-agent-sessions/) (official post + 13-second demo) | 2026-10-27 | Capture, search, sync, resume, and fork coding-agent sessions; creator anecdotes include moving an investigation to a faster Mac and feeding results back. | **After removal; current for 18.24+ Threads.** Agent support has expanded further in 18.25 docs. |
| [Stop Pressing the Up Arrow: Searchable Shell History with Atuin](https://karandeepsingh.ca/posts/atuin-shell-history-search/) (Karandeep Singh) | 2026-08-11 | A real Atuin 18.19 trial: import, workspace/directory filtering, noninteractive search, sync-key handling, and a sensible “try local before sync” sequence. | **Before removal.** Its `atuin dotfiles` mention is now wrong; its tested history workflow remains relevant. |
| [Shell history backup, sync, and search with Atuin](https://fuzznotes.com/posts/shell-history-with-atuin/) (Fuzz) | 2026-04-22 | Self-hosted Atuin 18.15 for six servers and three clients, provisioned with Podman/Ansible; disables up-arrow binding. | **Before removal.** Useful as the author’s sync anecdote, not as current 18.25 deployment instructions. |
| [Atuin](https://perrotta.dev/2025/11/atuin/) (Bruno Perrotta) | 2025-11-30; updated 2026-02-16 | Migrates from fzf `Ctrl-R`, disables the up-arrow binding, imports history, uses workspace search and stats, considers hosted/self-hosted sync. | **Before removal.** The linked dotfiles feature no longer exists. |
| [Atuin Has Forever Changed The Way I Use Command History](https://www.youtube.com/watch?v=Em0TdAftXAA) (DevOps Toolbox) | 2024-07-12 | Eight-minute UI demo: fuzzy search, metadata/inspector, filtering, pruning, stats, hosted sync, and history on a second host. | **Before removal.** Its closing aliases/env/dotfiles segment is stale; the history UI concepts remain representative. |
| [Search and Sync Your Shell History With Atuin](https://calebhearth.com/search-sync-shell-atuin) (Caleb Hearth) | 2024-11-12 | The author’s long-running search, stats, regex filters, and sync configuration; stats suggest aliases. | **Before removal.** Its “dotfiles syncing” experiment is obsolete. |
| [Keeping shell history in sync with turtles and magic](https://media.ccc.de/v/emf2024-160-keeping-shell-history-in-sync-with-turtles-and-magic) (Ellie Huxtable, EMF talk) | 2024-06-01 | 21-minute creator talk on the problem, sync, encryption, and project lessons. | **Before removal.** Useful for architecture and intent, not current CLI breadth. |
| [Atuin v18.13 – better search, a PTY proxy, and AI for your shell](https://blog.atuin.sh/atuin-v18-13/) (official post + embedded demos) | 2026-03-18 | Daemon-fuzzy search and PTY overlay demos; also demos the former inline Atuin AI agent. | **Before removal and partly stale:** 18.25 removed the Atuin AI agent ([18.25.0 release, 2026-11-20](https://github.com/atuinsh/atuin/releases/tag/v18.25.0)). Do not confuse that removed feature with current Threads. |

## KV and dotfiles: direct answer

### Is KV commonly presented for machine configuration?

No, not in the evidence reviewed.

The original official description is deliberately generic: small snippets of text, environment data, or small scripts that become available on every machine after sync. It also says Atuin might use the primitive for future synced config and host aliases ([v16 post](https://blog.atuin.sh/release-v16/)). That is not the same as a supported machine-configuration model. Current 18.25 docs do not give KV a guide, while the 18.25 source confirms the low-level CLI still exists ([KV source](https://github.com/atuinsh/atuin/blob/v18.25.0/crates/atuin/src/command/client/kv.rs)).

A machine-specific JSON design would have to decide, outside Atuin:

- how a host is identified and renamed;
- whether defaults inherit into host values;
- how Linux and macOS values differ;
- how conflicts and deletions are resolved;
- how JSON is validated or migrated;
- how changes are reviewed and rolled back;
- how a new machine is bootstrapped before Atuin login/sync.

KV can store the bytes, but it does not document those semantics. A host-namespaced KV convention is therefore an unusual custom application. It also works against KV’s basic cross-machine presentation: the same synced key/value set is delivered everywhere, while this requirement intentionally differs by machine.

### What does Atuin recommend after removal?

The 18.23 release note is unambiguous: dotfiles support was “never as complete or as useful as we had hoped,” “could be used unsafely,” and **tools like [chezmoi](https://www.chezmoi.io/) are much more suitable** ([release note](https://github.com/atuinsh/atuin/releases/tag/v18.23.0)). That recommendation should supersede old docs and videos showing `atuin dotfiles`, aliases, or environment-variable sync.

This does not require choosing chezmoi specifically. A Git-backed dotfiles repository with explicit per-host JSON overlays can also satisfy reviewability and machine specificity. The important conclusion is that Atuin should not own that data.

## Recommendation for the stated workflow

### Capability-by-capability value

- **Clear value now:** local history import and context-aware fuzzy search. Directory/workspace filters are useful even on one machine and do not require an account.
- **Clear value once two machines are actively used:** encrypted history sync, especially for recalling a command run on the other OS. Manual sync matches the stated preference: disable automatic sync and invoke `atuin sync` intentionally.
- **Conditional value:** local Threads, if coding-agent sessions are frequent enough that search/resume matters. Threads may be more valuable than shell sync for agent-heavy work, but capture should be a deliberate privacy decision.
- **Nice-to-have only:** stats. It may expose repeated commands worth promoting to an alias/script, but it does not justify the dependency.
- **Probably redundant:** Atuin Scripts, if useful scripts already live in the dotfiles repository. Git-backed scripts have clearer ownership and review history.
- **Not recommended by default:** output capture. It adds PTY proxy/daemon complexity, local disk use, and more sensitive retained data; it does not sync in 18.25.
- **No clear value for this design:** KV as the machine-specific JSON transport. Keep JSON in the configuration system.

### Three options

| Option | Benefits | Costs and risks | Fit |
|---|---|---|---|
| **1. No Atuin** | Fewest moving parts; no daemon, account, encryption key, database, or additional retained command/agent data. Native shell history plus fzf may be sufficient. | History remains per machine and usually lacks structured cwd, exit-code, duration, host, and session context. No Atuin thread index/resume. Cross-machine recall requires another mechanism. | Reasonable if commands are short/recreated easily, native/fzf search already feels sufficient, or minimizing retained activity data dominates. |
| **2. Atuin only for local history/Threads** | Best local search model; works offline; no sync account or key custody. With no sync and `update_check = false`, current docs say Atuin makes no network requests itself. Local Threads can search/resume agent work. | Each machine is a silo. Installing the Mac/laptop does not bring prior history or threads. Threads require the daemon and retain conversation/tool/diff content; output capture and Threads increase local privacy exposure. Database/daemon lifecycle is another component to maintain. | **Recommended starting point**, with local history enabled and Threads opt-in only. It tests whether Atuin earns its place before introducing sync. |
| **3. Atuin with encrypted history/Thread sync** | Makes history and Threads available across Linux/macOS; manual `atuin sync` is supported; hosted and self-hosted servers are documented. Official docs state records are end-to-end encrypted, so the server operator cannot read their content. | Requires an account/server and careful encryption-key backup for new-machine login. Encryption does not protect data on an unlocked endpoint. Synced Threads can include prompts, tool inputs/outputs, file names, and diffs; filtering/redaction reduces but does not eliminate sensitivity. Manual sync means other machines may be stale until invoked. Self-hosting adds server operations without removing endpoint/key risks. | Best **later**, when cross-machine command or agent-session continuity has proven useful. Use manual sync; do not sync configuration through KV. |

### Suggested adoption sequence

1. Install 18.25 and import local history on the main Linux desktop.
2. Keep sync unconfigured; set `update_check = false` if strict no-background-network behavior is desired.
3. Use workspace/directory search for a few weeks. Leave output capture off. Enable the daemon only if `daemon-fuzzy` performance or Threads is wanted.
4. If using coding agents, review the [Threads capture contents and filters](https://docs.atuin.sh/18.25/ai/threads/#whats-captured) before enabling local capture; consider `capture_tools = false` when conversations are useful but tool bodies/diffs are not.
5. Put machine-specific JSON in the dotfiles/configuration layer with explicit host/OS overlays, not KV.
6. When the Mac or future laptop produces real “that command/session is on the other machine” friction, configure sync, securely retain the encryption key, set `auto_sync = false`, and sync intentionally.

This sequence preserves the strongest Atuin benefit, keeps the design local-first, and leaves encrypted cross-device history/Threads as a reversible later addition rather than a foundation for machine configuration.

## Evidence table

| Source | Date/version | Type | Evidence used |
|---|---:|---|---|
| [Atuin 18.25 overview](https://docs.atuin.sh/18.25/) | 18.25 current | Official docs | SQLite history/context; optional encrypted sync; explicitly supports staying local. |
| [Sync reference](https://docs.atuin.sh/18.25/reference/sync/) and [config](https://docs.atuin.sh/18.25/configuration/config/) | 18.25 current | Official docs | Hosted/self-hosted E2EE claim, manual `atuin sync`, key handling, `auto_sync`, sync frequency, no-network configuration. |
| [Daemon reference](https://docs.atuin.sh/18.25/reference/daemon/) | 18.25 current | Official docs | Daemon responsibilities and enablement. |
| [Output-capture guide](https://docs.atuin.sh/18.25/guide/output-capture/) | 18.25 current | Official docs | Off by default, PTY/daemon requirements, local-only/no-sync behavior, retention and redaction limits. |
| [Threads guide](https://docs.atuin.sh/18.25/ai/threads/) | 18.25 current | Official docs | Opt-in capture, daemon requirement, local index, encrypted sync, capture contents, filters, search/resume/fork behavior. |
| [18.23.0 release](https://github.com/atuinsh/atuin/releases/tag/v18.23.0) | 2026-09-22 | Official release | Dotfiles removal and chezmoi recommendation. |
| [18.24.0 release](https://github.com/atuinsh/atuin/releases/tag/v18.24.0) | 2026-10-15 | Official release | Threads/session capture and cross-machine resume introduced. |
| [18.25.0 release](https://github.com/atuinsh/atuin/releases/tag/v18.25.0) | 2026-11-20 | Official release | Current baseline; former Atuin AI agent removed while Threads remains. |
| [Atuin Threads](https://blog.atuin.sh/threads-agent-sessions/) | 2026-10-27 | Official author workflow/demo | Creator’s own multi-agent, multi-machine workflow; product behavior checked against current docs. |
| [Making sync faster with packfiles](https://blog.atuin.sh/making-atuin-sync-32x-faster-with-packfiles/) | 2026-08-25 | Official engineering post | Evidence of hosted sync record volumes and 18.20 sync architecture; not treated as feature-usage telemetry. |
| [Atuin Scripts](https://blog.atuin.sh/atuin-scripts-shareable-syncable-shell-snippets/) | 2025-04-09 | Official feature demo | Script creation, parameters, shebangs, and sync. Predates dotfiles removal. |
| [Atuin v16](https://blog.atuin.sh/release-v16/) and [v18.25 KV source](https://github.com/atuinsh/atuin/blob/v18.25.0/crates/atuin/src/command/client/kv.rs) | 2023-08-02 / 18.25 | Official post/source | KV’s original beta positioning and its current low-level commands; no modern machine-config recommendation. |
| [DevOps Toolbox video](https://www.youtube.com/watch?v=Em0TdAftXAA) | 2024-07-12 | Community anecdote/demo | Search UI, filters, metadata, stats, and second-host sync. Dotfiles ending is stale. |
| [Caleb Hearth](https://calebhearth.com/search-sync-shell-atuin) | 2024-11-12 | Community anecdote | Search as daily workflow, stats for alias ideas, optional sync; dotfiles experiment is stale. |
| [Bruno Perrotta](https://perrotta.dev/2025/11/atuin/) | 2025-11-30; updated 2026-02-16 | Community anecdote | fzf-to-Atuin migration, up-arrow choice, workspace search, stats, optional sync. Dotfiles section is stale. |
| [Fuzz Notes](https://fuzznotes.com/posts/shell-history-with-atuin/) | 2026-04-22 | Community anecdote | Nine-host self-hosted history sync; specific deployment is pre-18.23/18.25. |
| [Karandeep Singh](https://karandeepsingh.ca/posts/atuin-shell-history-search/) | 2026-08-11 (tested 18.19) | Community anecdote | Local-first trial, context filters, import, and delayed sync recommendation. `atuin dotfiles` mention is stale. |
| [EMF talk](https://media.ccc.de/v/emf2024-160-keeping-shell-history-in-sync-with-turtles-and-magic) | 2024-06-01 | First-party talk/video | Creator’s explanation of search/sync/encryption and project history; predates 18.23. |
