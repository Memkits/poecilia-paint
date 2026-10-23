
Phlox workflow in [calcit-js](http://github.com/calcit-lang)
----

### Usage

```bash
caps --ci --strict
yarn install --immutable
yarn dev
```

使用配对的正式 Calcit/procs 0.30.1、Node 24 和 Yarn 4.18.0，
仅维护 `calcit.cirru` / `deps.cirru`。升级后重启服务并刷新页面，不混用旧 runtime。
`yarn dev` 编译一次并启动 Vite。
For live Calcit edits, run `calcit calcit.cirru -w` in another terminal. `yarn build` and
`yarn release` remain one-shot compile/build commands.

CI checks canonical formatting, all definitions, application public namespaces,
the full strict workflow, the actual build and two focused drawing/state tests
(`node --test tests/paint.test.mjs` after compilation). The retired quantity-based
quality baseline is removed, not relaxed.

Store, Slide, ActionLog and widget state use real Structs; application operations
use a checked nominal Enum and Phlox 0.7.17's single-Enum dispatch. A missing
selection is Option<String>. Add still creates a tab without selecting it, and
commands still use the two draggable points. Drawing with no selected/existing
slide now leaves the store intact instead of replacing it with nil. No persistence
UI or history playback is introduced; the slider still does not filter drawings.
The existing hydration operation validates legacy Maps before constructing typed
data. Widget cursor storage and heterogeneous shape descriptions remain explicit
open boundaries; shape coordinates/radius are checked where rendered. Remaining
unsafe coercions describe actual Window/font/promise host interfaces only.

模块固定正式 tag：Phlox 0.7.17、Respo 0.16.124、UI 0.8.0、
Touch Control 0.0.32、Bisection Key 0.0.35、Pointed Prompt 0.0.20。
旧 Option 调用改为公开方法，字面量命令/形状分支使用 `match`；原默认分支、
几何计算、Add 不自动选择和无选择绘图保持状态的行为不变。
热更新继续通过 `hud!` 显示成功或错误，不改为抛异常。
页签组件的返回合同明确为 `PhloxElement`，不再用 Dynamic 隐藏其已知输出；
输入集合、选中值与排序保持不变。
未选中页签使用普通按钮背景，保持可见的点击区域；Add 后仍需自行选择页签。

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
