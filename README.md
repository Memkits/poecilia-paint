
Phlox workflow in [calcit-js](http://github.com/calcit-lang)
----

### Usage

```bash
caps --ci --strict
yarn install --immutable
yarn dev
```

Use the paired Calcit/procs 0.30.1-alpha.4 (currently a compiler prerelease), Node 24 and Yarn 4.18.0 with canonical
`calcit.cirru` / `deps.cirru` only. `yarn dev` compiles initially and starts Vite.
For live Calcit edits, run `calcit calcit.cirru -w` in another terminal. `yarn build` and
`yarn release` remain one-shot compile/build commands.

CI checks canonical formatting, all definitions, application public namespaces,
the full strict workflow, the actual build and two focused drawing/state tests
(`node --test tests/paint.test.mjs` after compilation). The retired quantity-based
quality baseline is removed, not relaxed.

Store, Slide, ActionLog and widget state use real Structs; application operations
use a checked nominal Enum and Phlox 0.7.15's single-Enum dispatch. A missing
selection is Option<String>. Add still creates a tab without selecting it, and
commands still use the two draggable points. Drawing with no selected/existing
slide now leaves the store intact instead of replacing it with nil. No persistence
UI or history playback is introduced; the slider still does not filter drawings.
The existing hydration operation validates legacy Maps before constructing typed
data. Widget cursor storage and heterogeneous shape descriptions remain explicit
open boundaries; shape coordinates/radius are checked where rendered. Remaining
unsafe coercions describe actual Window/font/promise host interfaces only.

All Calcit modules use formal tags (Phlox 0.7.15, Respo 0.16.122, UI 0.7.41,
Touch Control 0.0.31, Bisection Key 0.0.32 and Pointed Prompt 0.0.19).

Vite base and released COS action v1.2.0 share the frontend prefix: production remains
`Memkits/poecilia-paint/`, while previews use `pr/<number>/<run-id>/<attempt>/`.
Runs are grouped per PR and separately for production without cancellation.
HTML reference/public verification uses the action itself. The existing upload permission
policy, server `dist/*` destination, verified rsync and SSH host setup are unchanged.
PR uploads are not production or physical drawing/browser acceptance.

### Workflow

Workflow https://github.com/Phlox-GL/phlox-workflow

### License

MIT
