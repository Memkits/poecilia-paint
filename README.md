
Phlox workflow in [calcit-js](http://github.com/calcit-lang)
----

### Usage

```bash
caps --ci
yarn install --immutable
yarn dev
```

Use Calcit/procs 0.27.0, Node 24 and Yarn 4.18.0 with canonical
`calcit.cirru` / `deps.cirru` only. Development compiles once, then watches Calcit
`js -w` alongside Vite; either process exiting stops the other. `yarn build` and
`yarn release` remain one-shot compile/build commands.

CI keeps canonical formatting, strict entry and all application public checks,
the original quality baseline and actual build. Repeated migration/type-debt
reports are removed; no extra verifier script or test suite is added. Open-state
and upstream type debt are not claimed eliminated. Drawing code, data and fonts
are unchanged.

Vite base and COS action v1.1.1 share the frontend prefix: production remains
`Memkits/poecilia-paint/`, while previews use `pr/<number>/<run-id>/<attempt>/`.
Runs are grouped per PR and separately for production without cancellation.
Upload/public verification uses the action itself. The existing upload permission
policy, server `dist/*` destination, verified rsync and SSH host setup are unchanged.
PR uploads are not production or physical drawing/browser acceptance.

### Workflow

Workflow https://github.com/Phlox-GL/phlox-workflow

### License

MIT
