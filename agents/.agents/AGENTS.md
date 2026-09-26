# Global agent instructions

Applies to every project and every session, subagents included. Shared by Claude
Code (`~/.claude/CLAUDE.md`) and Codex (`~/.codex/AGENTS.md`); keep it
harness-neutral.

## Herdr workflow

These rules assume Herdr (`test "${HERDR_ENV:-}" = 1`). Skip them entirely when
that check fails. Load the `herdr` skill for command syntax before issuing
control commands — the installed binary is the authority, not these examples.

### Starting feature work → offer an isolated worktree

Before the first edit of any new feature, bugfix, or refactor that will produce
commits, **propose** a Herdr worktree and wait for a yes. Do not create one
unasked, and do not skip the offer because the change looks small.

On acceptance:

1. `herdr worktree create --workspace "$HERDR_WORKSPACE_ID" --branch <branch> --base <base> --label <short-name> --no-focus`
   Read the new workspace, tab, and root-pane ids from the JSON result.
2. Move this session into the new workspace's tab, then close the empty root
   pane Herdr created, so the tab holds only the session:
   `herdr pane move <my-pane> --tab <new-tab> --split right --target-pane <root-pane> --focus`
   then `herdr pane close <root-pane>`.
3. Work from the worktree path by absolute path.

Gotchas, learned the hard way:

- **`$HERDR_PANE_ID` goes stale after any move.** A moved pane gets a new
  workspace-qualified id; the env var still holds the old one. Resolve the real
  id from `herdr pane list --workspace <ws>` (match on the `agent` field), not
  from the env var.
- **The shell tool resets cwd between calls.** Address the worktree by absolute
  path every time, or `cd <worktree> && …` within a single command.
- **A fresh worktree has no generated or ignored artifacts** — generated project
  files, installed dependencies, build output. Run the project's generate or
  bootstrap step before building or testing there.
- `git add -A` refuses gitignored scratch dirs; add explicit paths instead.

### Finishing → move panes out BEFORE removing the worktree

Removing a worktree workspace closes its panes. If this session lives inside it,
that kills the session mid-command. Always:

1. Move every pane out to another workspace — including panes you did not create
   (move them, do not close them; they may hold the user's own shell).
2. Moving the last pane out auto-closes the workspace, so `herdr worktree remove
   --workspace <ws>` then fails. Finish with `git worktree remove <path>` and
   `git worktree prune`.
3. Delete the merged branch only after confirming it merged.

### Presenting a spec or plan for review → show it in the editor

When handing the user a written spec, design, or plan to validate, check the
layout first: `herdr pane layout --pane <my-pane>`. If the tab is **not** already
split, open the document beside you:

```
herdr pane split --current --direction right --cwd <dir-of-file> --no-focus
herdr pane run <new-pane-id> "\${EDITOR:-nvim} <path/to/spec.md>"
```

Keep focus in your own pane and tell the user to navigate over. If you edit the
file afterwards, say so — their buffer needs `:e` to reload. If the tab is
already split, do not split again; just give the path.

## Offering a diff review

The user reviews changes in a terminal diff viewer. Pick it by what is installed,
in this order, and do not ask which one: `hunk`, then `lazygit`, then plain
`git diff` as the last resort.

Offer a review at two points. Offer, wait for a yes, and do not open a viewer
unasked:

1. **Live review, after the spec is approved and before the first edit.** Ask
   whether they want to watch the diff build up as you work:
   `hunk diff --watch` reloads on every change. With lazygit, its working-tree
   view refreshes on its own, so it serves the same purpose.
2. **After the change is complete** — unless a live review from step 1 is already
   running, in which case say the work is done and let them look, rather than
   opening a second viewer.

Inside Herdr, put the viewer beside you rather than in your own pane, same rule
as a spec: check `herdr pane layout --pane <my-pane>` first, and if the tab is
not already split,

```
herdr pane split --current --direction right --cwd <repo-root> --no-focus
herdr pane run <new-pane-id> "hunk diff --watch"
```

Keep focus in your own pane and tell the user to navigate over. Outside Herdr,
just give them the command to run.

Gotchas, learned the hard way:

- **A working-tree viewer goes blank the moment you commit.**
  `hunk diff --watch` and lazygit's working-tree view both show *uncommitted*
  changes only, so committing during a review empties the pane the user is
  watching. Either hold the commit until they have looked, or repoint the pane at
  the commit — and say which you did, because a blank pane reads as "nothing
  happened".
- **These viewers are full-screen TUIs.** A second `herdr pane run` types into
  the running viewer instead of the shell. Send `q` with `herdr pane send-keys`
  first, then `pane read` to confirm the prompt is actually back — the viewer may
  have already exited on its own, in which case the `q` is now sitting on the
  command line and needs a `ctrl+c` before the next `pane run`.
- **Send those keys to the viewer's pane id, never to an agent name.** Your own
  session is a named agent too, so `herdr agent send-keys <name>` can resolve to
  you and type into your own prompt. Use `herdr pane send-keys <pane-id>`.
- **`pane read` only sees the rendered viewport.** A long changeset scrolls off;
  do not conclude from a read that files are missing from the diff. Confirm the
  file list with `git diff --stat` instead.
- **Pipe a patch rather than naming a revision.** `hunk diff <rev>` renders that
  one revision and not a range, and in a jj-colocated repo (a `.jj` directory
  next to `.git`) hunk resolves revsets through jj, so git spellings like
  `HEAD~2` fail outright. `git show <rev> | hunk patch` for one commit and
  `git diff <base> HEAD | hunk patch` for a range work in every repo. lazygit
  shows only git's view in a colocated repo and does not understand jj at all.
