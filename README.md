# Poecilia Paint

基于Phlox的绘图原型，支持页签及由两个控制点生成矩形/圆形的命令。

## 使用者需要注意

本地开发使用正式 Calcit 和 `@calcit/procs` **0.40.0**。升级后请重装依赖、构建并刷新。新增页签仍需手动选择，绘图命令、几何、日志和刷新后的 No Slide 保持原行为。

绘图命令派发具名 `Op`。渲染使用 `Shape` union 区分矩形、圆形和历史图形数据。旧日志、快照和带附加字段的图形 Map 沿用原存储格式。滑钮通过 `SlideState` 更新值和位置，Phlox 控件的旧状态事件在渲染入口按 `CoordKey` 解码，业务操作直接使用具名 `Op`。

正式依赖图使用 Phlox 0.9.3、Respo 0.19.5、UI 0.15.2、Touch Control 0.0.39、Bisection Key 0.0.46、Pointed Prompt 0.0.27 和 JS FFI 0.2.13。页面 `hud!` 提示和原前端部署路径保持。

## 开发与验证

```sh
caps --ci --strict
yarn install --immutable
caps verify --toolchain
calcit calcit.cirru --check-only --all-defs
calcit calcit.cirru fix --workflow strict --verify
yarn build
node --test tests/paint.test.mjs
```

全量 260 个定义、应用 29 个定义、完整 strict、原两项 Node 回归与构建通过。Chrome 隔离预览验证新增并选择页签、矩形与圆形命令、滑钮旋转和移动、刷新返回 No Slide。字体验收使用本地替身。

yarn dev编译一次后启动Vite，实时编辑另开终端运行calcit calcit.cirru -w。仅维护calcit.cirru/deps.cirru，Snapshot通过官方CLI修改，不恢复compact.cirru/package.cirru，不提交js-out/dist。

## 前端部署

VITE_BASE_URL控制资源前缀，生产仍Memkits/poecilia-paint/，PR沿用独立编号/run/attempt前缀。COS仅dist/，正式v1.2.0 action自带HTML引用及公开资源验证，不复制verify脚本。原队列、上传权限、服务器dist目的地、校验后的rsync和SSH host设置保持。不合并、不生产部署、不改后端、不发布应用Git/npm。

模板：https://github.com/Phlox-GL/phlox-workflow 。

## License

MIT
