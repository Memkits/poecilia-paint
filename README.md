# Poecilia Paint

基于Phlox的绘图原型，支持页签及由两个控制点生成矩形/圆形的命令。

## 使用者需要注意

配对正式 **Calcit / @calcit/procs 0.32.1**、Caps0.1.1、Node24 和 Yarn4.18.0，直接模块为已发布正式Phlox0.8.0、Respo0.17.1、UI0.9.0、Touch Control0.0.35、Bisection Key0.0.40、Pointed Prompt0.0.24、JS FFI0.2.9。传递STD0.2.47已正式发布，UI的Router0.9.0-alpha.4仍为原固定传递依赖。重新安装完整图、生成JS、重启并刷新，不混用旧runtime/main/hash。

Store/Slide/ActionLog、业务Op、绘图几何及快照、Add不自动选择、无选择时绘图保留Store的行为保持。仍无持久化UI，刷新回到No Slide初始状态；不新增历史播放，slider仍不筛选已有图形。legacy Map hydration和混合页签/widget游标保持原检查，不伪造封闭状态类型。真实JS `hud!`成功/编译错误提示保留，不改为raise。

## 本次迁移与风险

- 官方formatter迁移18处旧类型形式。27个既有完整官方视图仅comp-container、comp-slide、comp-slide-tabs三处代码变化，所有既有schema/tests/meta保持，没有新增定义。
- 6处tag/payload或cursor/state可变参数派发改为显式单个Enum，保留原Phlox兼容桥构造的相同wire形状。7个相关回调标明单Enum→Unit派发，以及真实Number/List<Number>数值或opaque Dynamic宿主事件输入；不把事件伪装成JsObject，不强转未验证的业务数据。
- 原normalize-op/updater、命令解析、Window字段读取、字体加载及几何代码保持，2处字体/Promise宿主unsafe不新增也不冒称清零。Phlox本身仍保留内部旧桥，此处应用6个旧调用清零不等于整个生态已退役。
- 依赖/runtime/lock配对，删除旧procs预批准，npm包龄60分钟无单包例外，保留原Pixi packageExtensions。原CI、全部类型门禁、两项测试文件/断言、权限、正式Action tags、COSverify及rsync/SSH验证路径不改。不增加checker/concurrently、预算或编译器fix/proof规则。

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

候选通过267个全定义、原五namespace公开检查、完整strict diagnostics=[]、原2项JS几何/快照/Map恢复/混合游标回归及编译构建，原测试及断言保持。没有附带native测试，不把空集合计为通过。

新回环页面实际验证Add不自动选择、页签选择、Command add-rect、拖第二控制点再add-circle、两项日志、第一控制点拖动、slider位置移动以及刷新回到无持久化初始状态，浏览器warn/error=[]。slider数值旋转、窗口缩放、字体加载失败和HUD注错未完成验收；线性拖动未改变slider数值，不把它记作该项通过，不宣称完整交互或历史回放。未读真实文件/存档或操作剪贴板。

yarn dev编译一次后启动Vite，实时编辑另开终端运行calcit calcit.cirru -w。仅维护calcit.cirru/deps.cirru，Snapshot通过官方CLI修改，不恢复compact.cirru/package.cirru，不提交js-out/dist。

## 前端部署

VITE_BASE_URL控制资源前缀，生产仍Memkits/poecilia-paint/，PR沿用独立编号/run/attempt前缀。COS仅dist/，正式v1.2.0 action自带HTML引用及公开资源验证，不复制verify脚本。原队列、上传权限、服务器dist目的地、校验后的rsync和SSH host设置保持。不合并、不生产部署、不改后端、不发布应用Git/npm。

模板：https://github.com/Phlox-GL/phlox-workflow 。

## License

MIT
