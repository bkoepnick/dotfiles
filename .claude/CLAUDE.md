## Notebook Reading
Never use `python3 -c` to read or validate .ipynb files. Instead, use `cat` or `jq` to inspect them:
- `cat notebook.ipynb` to read raw content
- `jq '.cells[].source' notebook.ipynb` to extract cell sources
- `jq '.cells[] | select(.cell_type=="code") | .source' notebook.ipynb` for code cells only

## Notebook Verbosity
Writeups belong in the notebook header cell only. Every other markdown cell is a bare section
heading (`## 4. Breakdown ...`, `### Hits per cluster`) with no prose. Print output is terse —
labels and numbers, never full sentences (`print(f"on the plane {len(plane):,}   rankable {len(both):,}")`).
Explanations that matter go in code comments, where they sit next to the thing they explain.

## Plotting Style
Baseline for every figure:
- `sns.set_context("talk")`, `sns.set_palette("colorblind")`; white figure and axes faces.
- Grids off by default; turn them on per-axes as `grid(True, axis="y", alpha=0.3, linestyle="--")`
  with `set_axisbelow(True)`.
- `figure.dpi 110`.
- Keep titles simple: a short label of what is plotted (`"QC pass by plates"`, `"Interface ipTM by
  arm"`). No explanations, methodology, editorializing, or "A vs B — because …" clauses in the
  title. A dataset line is optional (the notebook header already carries the context); when used it
  is the dataset and nothing else — no n, no method notes.
  - Counts live where they attach to a mark: `n =` above the axes, `k/n` over each bar, and the
    printed output above the figure. Method notes (test used, CI type, which thin groups were
    dropped) go in the print output or a comment, never crammed into the title.
- Legends outside the axes: `fig.legend(..., loc="center left", bbox_to_anchor=(0.97, 0.5))`.
  Legend counts must be over what the figure actually draws, not the parent frame.
- Never write figures to disk (no `savefig`, no `output/figures/`); display them inline with
  `plt.show()` only. This holds for the agent too: do not extract a notebook's rendered PNGs to
  files in order to look at them. Read the figure out of the notebook JSON in memory if you must
  inspect it, and otherwise trust the code.

Encoding rules:
- One palette per categorical variable, defined once and reused everywhere (epitope keeps its hue
  in the scatter, the bar charts and the panel titles).
- Background/unselected/other is grey (`"0.78"`–`"0.87"`), drawn FIRST and at lower zorder; the
  highlighted set is drawn last. A dense grey layer plotted after the highlights buries them.
- Highlighted points get a size multiplier (~2.4x) over the backdrop, not a different marker.
- One marker size per role, shared across the scatter and its marginals; one bar width shared by
  an outline bar and the stacked fill drawn inside it, so they register exactly.
- Never distinguish tiers/subsets by marker shape when colour already does it.

Palettes for many categories (e.g. framework): saturate Pastel1 (`hsv`, S x 1.7). Gate low-contrast
slots on BOTH high luminance (Rec.709 > 0.90) and low saturation (< 0.15), and swap only those to a
reserved colour — luminance alone sweeps up perfectly good pastels.

Rates and counts:
- `PercentFormatter` decimals adaptive: `0 if max_rate >= 0.05 else 1`, or a sub-1% panel reads
  "0%" / "1%".
- Drop groups whose denominator is too small to show anything at the base rate (`MIN_POOL_N`), and
  name the dropped groups rather than silently omitting them — in the per-axes title of the panel
  they were dropped from, or the print output above the figure. Not the suptitle (see title rules).
- Annotate `k/n` above every rate bar.

Layout: at talk context labels collide. Rotate or shorten tick labels, put `n =` annotations ABOVE
the axes (`transform=get_xaxis_transform()`, `y=1.01, va="bottom"`), widen `wspace`, and scale the
figure width with the number of categories. Render the figure and LOOK at it before calling it done.

## Reusable Plot Types

### scatter-marginal
Two-arm measurement plane with marginal strips for designs missing one arm.
`gridspec(2, 2, width_ratios=[4, 1.3], height_ratios=[1.1, 5])`: main scatter bottom-left, top strip
= designs with only the x-arm, right strip = only the y-arm, corner = a centred count annotation
(never 40k points as a solid block). Log-log, `set_aspect("equal")`, y=x dashed reference.
- Split "has a coordinate" (value not null — censored pegs included) from "is rankable"
  (resolved classes only). The first decides what is plotted, the second what is selected.
- Strips are slotted by the reason the value is missing, one slot per class, with n in the tick label.
- Jitter positions assigned ONCE on the full frame so a design sits at the same spot in every panel.
- The main axes is aspect-equal so its drawn box is narrower than its gridspec cell: after
  `fig.canvas.draw()`, pull the top strip onto it —
  `ax_top.set_position([p.x0, pt.y0, p.width, pt.height])`.
- `sharex` gotcha: clear a marginal's labels with `tick_params(labelbottom=False)`, never
  `set_xticks([])`, which strips the labels off the shared axis too.
- One function, a `highlight` set of ids switches it from "colour by class" to "picks in colour,
  everything else grey" — so the selection figure is provably the same plot.

### cluster-hits
Per-cluster hit composition. One subplot row per epitope/group, each with its own x-axis of the
clusters holding a hit of that group (clusters are rarely nested inside the group), shared y.
- Open black-outline bar = everything tested in that cluster (the denominator); stacked fill inside
  it = hits split by framework; same `BAR_W` for both.
- Label the hit total above each stack: tested runs 10-100x the hits, so the stack is a sliver.
- x labels are the composite key, sorted by its parts — see the id-scoping rule below.

### binned affinity/hitrate
Two rows x one column per group: KD box+jittered strip on a log axis over a hit-rate bar with a
Wilson score 95% CI and `k/n` annotated, sharing x down each column, y-ranges shared across columns.
- Bin edges FIXED across groups when the groups must be comparable; per-group edges only when each
  group spans its own range.
- The KD boxes hold every resolved estimate in the bin, NOT just the hits: if a hit is defined by a
  threshold on that same KD, boxing hits alone just redraws the cutoff.
- Jitter the strip over the box; a single vertical line of points reads as fliers.
- A dotted rule marks the hit threshold when there is one.

## Analysis Data Hygiene
- Composite ids: check whether an id restarts within each group before using it as a key
  (`cluster_id` restarted per arm, so the real key was `arm13_270`). Build the composite column
  once, sort by its parts numerically, and use it everywhere.
- A vendor "hit" call is not a threshold on the reported value — it can require a bounded CI. When
  both exist, report the overlap (both / call-only / threshold-only) rather than assuming they nest.
- Output CSVs keep every source column; curate a narrow sheet separately if a readable one is wanted.
- When a load/merge is expensive (many catalog/container reads), cache the merged frame to a CSV
  (S3 for shared work) keeping ALL columns, and split the notebook so the analysis section reads
  that cache — the analysis can then be re-run standalone without the load. Merge external
  per-sequence scores on the sequence, not an artifact id, when the fold may have been re-run.
- The in-memory working df keeps every column from the source/expanded frame — do NOT cherry-pick
  down to the columns a given plot or step needs. Add derived/normalized columns (e.g. `iptm`,
  `edit_distance`) alongside the originals and concatenate the full per-group frames; use a union
  concat so heterogeneous columns are kept, not dropped. We rarely know up front which score we'll
  want next, and re-loading to recover a column dropped earlier is wasteful. Narrow only at the
  point of a specific plot/export, never in the shared working frame.

## Notebook Authoring Workflow
Long analysis notebooks are generated by a `build_nb.py` script in the scratchpad that emits the
.ipynb. The user edits the .ipynb directly, so BEFORE every edit round: regenerate to a temp path,
extract code cells from both with `jq -r '.cells[]|select(.cell_type=="code")|.source|join("")'`,
`diff` them, and fold the user's edits back into the generator until the diff is empty. Never edit
the notebook and the generator independently.

**Do not execute notebooks.** Write the generator, emit the .ipynb, and stop — the user runs it.
Check the emitted cells parse (`ast.parse` over the code cells) instead of running them. Execution
is the user's call; it burns wall-clock, mutates the file under them, and can overwrite outputs
they were reading. Only run `jupyter nbconvert --to notebook --execute --inplace` when asked to.
- If asked to execute, check `jq '[.cells[].outputs[]?|select(.output_type=="error")]|length'` AND
  the file size afterwards — nbconvert can fail without the error reaching a piped tail, leaving an
  unexecuted file.
- Never do a bare global string replace on an identifier (`axes[1].` -> `ax_tm.`); scope it to the
  cell. Same for removing a line: take the leading whitespace with it or the next line gets swallowed.
- Kernel is python 3.11: f-strings cannot reuse the outer quote character inside the expression
  part, and cannot contain a backslash. Bind the value to a name on the line above instead.

## PyMOL
There are custom PyMOL hooks that load a CAD artifact straight from the API, so
`load <artifact_id>, <object_name>;` is correct and complete. Do NOT fetch the artifact's
`example_uri` from S3 or emit a local file path — the artifact id IS the loadable handle.
