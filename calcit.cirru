
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |phlox/ |pointed-prompt/ |bisection-key/ |touch-control/ |js-ffi/
      :type-slots $ {}
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        'comp-container $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn comp-container (store)
            ; println |Store store $ :tab store
            let
                store-map store
                cursor $ []
                states $ :states store-map
                slides $ :slides store-map
                slide-key $ :slide-key store-map
              container ({})
                match
                  match slide-key
                    (:none) None
                    (:some id) (get slides id)
                  (:none)
                    text $ {} (:text "|No Slide")
                      :style $ {} (:font-size 60) (:font-weight 100)
                        :fill $ hslx 0 100 50
                        :font-family ui/font-fancy
                      :align :center
                  (:some slide)
                    comp-slide
                      >> states $ .unwrap slide-key
                      .unwrap slide-key
                      , slide
                comp-slide-tabs (keys slides) slide-key
                comp-button $ {} (:text |Add)
                  :position $ [] 160 $ - 60
                    * 0.5 $ .-inner-height $ window-host
                  :on-pointertap $ fn (e d!)
                    hint-fn $ Fn phlox.core/DomEventHost
                      Fn app.schema/Op $ -> Unit
                      -> Unit
                    d! $ schema/Op :add-slide-after slide-key
                comp-button $ {} (:text |Command)
                  :position $ [] 220 $ - 60
                    * 0.5 $ .-inner-height $ window-host
                  :on-pointertap $ fn (e d!)
                    hint-fn $ Fn phlox.core/DomEventHost
                      Fn app.schema/Op $ -> Unit
                      -> Unit
                    request-text! e
                      {} (:placeholder |Command)
                        :style $ {} $ :font-family ui/font-code
                      fn (code)
                        match
                          .parse-cirru-list $ decode-map-as code String
                          (:err message)
                            do (js/console.warn "|Invalid command syntax:" message) &unit
                          (:ok tree)
                            match
                              run-command tree (:main-hint store-map) (:secondary-hint store-map) slide-key
                              (:none) &unit
                              (:some op) (d! op)
                    , &unit
                comp-button $ {} (:text |DEBUG)
                  :position $ [] 320 $ - 60
                    * 0.5 $ .-inner-height $ window-host
                  :on-pointertap $ fn (e d!) (js/console.warn |[DEBUG] store)
                comp-drag-point (>> states :main-hint)
                  {}
                    :position $ :main-hint store-map
                    :fill $ hslx 120 90 80
                    :radius 8
                    :hide-text? true
                    :on-change $ fn (pos d!)
                      hint-fn $ Fn (List Number)
                        Fn app.schema/Op $ -> Unit
                        -> Unit
                      d! $ schema/Op :move-main-hint pos
                comp-drag-point (>> states :secondary-hint)
                  {}
                    :position $ :secondary-hint store-map
                    :fill $ hslx 250 90 70
                    :radius 6
                    :hide-text? true
                    :on-change $ fn (pos d!)
                      hint-fn $ Fn (List Number)
                        Fn app.schema/Op $ -> Unit
                        -> Unit
                      d! $ schema/Op :move-secondary-hint pos
          :examples $ []
          :schema $ quote $ Fn schema/Store (-> phlox.schema/PhloxElement) (:features :js-ffi)
        'comp-slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn comp-slide (states pointed-key slide)
            let
                states-map states
                slide-map slide
                logs $ :logs slide-map
                cursor $ decode-map-as
                  .unwrap-or (get states-map :cursor) ([])
                  List respo.schema/CoordKey
                fallback-state $ {} (:pointer 0)
                  :spin-pos $ []
                    - 200 $ * 0.5 $ .-inner-width (window-host)
                    -
                      * 0.5 $ .-inner-height $ window-host
                      , 200
                state $ decode-map-as
                  decode-map-as
                    .unwrap-or (get states-map :data) fallback-state
                    Map Tag Dynamic
                  , schema/SlideState
                pointer $ :pointer state
              container ({})
                create-list :container ({})
                  -> logs $ map-indexed $ fn (idx log)
                    let
                        shape-op $ :op log
                      [] idx $ comp-button $ {}
                        :text $ match (get shape-op :type)
                          (:some kind) (str kind)
                          (:none) |
                        :position $ []
                          - 20 $ * 0.5 $ .-inner-width (window-host)
                          - 120 $ * idx 40
                        :on-pointertap $ fn (e d!) (println |shape-op shape-op)
                create-list :container ({})
                  -> logs $ map-indexed $ fn (idx log)
                    [] idx $ render-shape $ schema/decode-shape (:op log)
                comp-spin-slider (>> states :spin)
                  {} (:value pointer)
                    :position $ :spin-pos state
                    :spin-pivot $ complex/add (:spin-pos state)
                      []
                        * 0.5 $ .-inner-width $ window-host
                        * 0.5 $ .-inner-height $ window-host
                    :unit 4
                    :min 0
                    :max 100
                    :fraction 2
                    :on-change $ fn (value d!)
                      hint-fn $ Fn Number
                        Fn app.schema/Op $ -> Unit
                        -> Unit
                      d! $ schema/Op :slide-state cursor $ assoc state :pointer value
                    :on-move $ fn (pos d!)
                      hint-fn $ Fn (List Number)
                        Fn app.schema/Op $ -> Unit
                        -> Unit
                      ; println "|move to:" pos
                      d! $ schema/Op :slide-state cursor $ assoc state :spin-pos pos
          :examples $ []
          :schema $ quote $ Fn (Map Dynamic Dynamic) String schema/Slide (-> phlox.schema/PhloxElement) (:features :js-ffi)
        'comp-slide-tabs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn comp-slide-tabs (slide-keys pointer)
            ; println |key $ -> slide-keys .to-list $ .sort
              fn (a b) (.compare a b)
            let
                slide-key-set slide-keys
              create-list :container ({})
                -> (.to-list slide-key-set)
                  sort $ fn (a b) (.compare a b)
                  map-indexed $ fn (idx key)
                    [] key $ comp-button $ {} (:text key)
                      :position $ []
                        -
                          + 100 $ * idx 44
                          &* 0.5 $ .-inner-width $ window-host
                        - 20 $ * 0.5 $ .-inner-height (window-host)
                      :fill $ if
                        match pointer
                          (:none) false
                          (:some selected) (= key selected)
                        hslx 60 80 30
                        hslx 0 0 20
                      :align-right? false
                      :on-pointertap $ fn (e d!)
                        hint-fn $ Fn phlox.core/DomEventHost
                          Fn app.schema/Op $ -> Unit
                          -> Unit
                        ; println |key key
                        d! $ schema/Op :switch-slide key
          :examples $ []
          :schema $ quote $ Fn (Set String) (Option String) (-> phlox.schema/PhloxElement) (:features :js-ffi)
        'render-shape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-shape (shape)
            match shape
              (app.schema/RectShape data)
                rect $ {}
                  :position $ :position data
                  :size $ :sizes data
                  :line-style $ {} (:width 4)
                    :color $ hslx 0 80 50
                    :alpha 1
                  :fill $ hslx 200 80 80
                  :on $ {}
              (app.schema/CircleShape data)
                circle $ {}
                  :radius $ :radius data
                  :position $ :position data
                  :fill $ hslx 200 80 80
                  :on $ {}
              (app.schema/LegacyShape data)
                text $ {}
                  :text $ str "|Unknown: " $ :wire data
                  :style $ {} (:font-size 14) (:font-weight 500)
                    :fill $ hslx 0 100 50
                    :font-family ui/font-fancy
                  :align :center
          :examples $ []
          :schema $ quote $ Fn schema/Shape (-> phlox.schema/PhloxElement)
        'run-command $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn run-command (tree c1 c2 slide-key)
            if
              = 1 $ .len tree
              match
                .unwrap $ first tree
                (List statement)
                  match
                    .unwrap-or (first statement) |
                    (String command)
                      match command
                        |del-slide $ Some $ schema/Op :del-slide slide-key
                        |add-slide $ if (.some? slide-key)
                          Some $ schema/Op :add-slide-after slide-key
                          do (js/console.warn "|nil slide-key") None
                        |add-circle $ Some $ schema/Op :add-shape slide-key
                          schema/CircleShape :position
                            complex/divide-by (complex/add c1 c2) 2
                            , :radius $ * 0.5 $ vec-length (complex/minus c2 c1)
                        |add-rect $ Some $ schema/Op :add-shape slide-key
                          schema/RectShape :position c1 :sizes $ complex/minus c2 c1
                        _ $ do (println "|Unknown command:" command) None
                    _ $ do (js/console.warn "|Expected a command name") None
                _ $ do (js/console.warn "|Expected a command row") None
              do (js/console.warn "|unknown tree:" tree) None
          :examples $ []
          :schema $ quote $ Fn (List CirruNode) (List Number) (List Number) (Option String)
            -> $ Option schema/Op
            :features :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require
            phlox.core :refer $ g hslx rect circle text container graphics create-list >>
            phlox.comp.button :refer $ comp-button
            phlox.comp.drag-point :refer $ comp-drag-point
            respo-ui.core :as ui
            phlox.input :refer $ request-text!
            phlox.comp.slider :refer $ comp-spin-slider
            phlox.complex :as complex
            phlox.math :refer $ vec-length
            app.schema :as schema
            js-ffi.browser :refer $ window-host
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ .unwrap-or (get-env |mode) |release
          :examples $ []
          :schema $ quote Bool
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} (:dev-ui |http://localhost:8100/main.css) (:release-ui |http://cdn.tiye.me/favored-fonts/main.css) (:cdn-url |http://cdn.tiye.me/phlox/) (:title |Phlox) (:icon |http://cdn.tiye.me/logo/quamolit.png) (:storage-key |phlox)
          :examples $ []
          :schema $ quote $ Map Tag String
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *store schema/store
          :examples $ []
          :schema $ quote $ Ref schema/Store
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when
              and dev? $ match op
                (:states _ _) false
                (:slide-state _ _) false
                _ true
              println |dispatch! op
            let
                op-id $ decode-map-as (nanoid) 'String
                op-time $ decode-map-as (js/Date.now) 'Number
              reset! *store $ updater @*store op op-id op-time
            , &unit
          :examples $ []
          :schema $ quote $ Fn schema/Op (-> Unit) (:features :js-ffi)
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (; js/console.log PIXI)
            if dev? $ load-console-formatter!
            ffi-then
              ffi-load-font $ new FontFaceObserver "|Josefin Sans"
              fn (_event)
                render-app! $ {}
            add-watch! *store :change $ fn (store prev)
              render-app! $ {}
            render-control!
            start-control-loop! 8 on-control-event
            println "|App Started"
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (nil? build-errors)
              do (println "|Code updated.") (clear-phlox-caches!) (remove-watch! *store :change)
                add-watch! *store :change $ fn (store prev)
                  render-app! $ {}
                render-app! $ {}
                replace-control-loop! 8 on-control-event
                hud! |ok~ |Ok
              hud! |error build-errors
            , &unit
          :examples $ []
          :schema $ quote $ Fn (-> Unit) (:features :js-ffi)
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! (arg)
            render! (comp-container @*store)
              fn (op)
                if (enum? op)
                  dispatch! $ schema/normalize-op op
                  raise |expected-poecilia-event
              , arg
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (-> Unit) (:features :js-ffi)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require (|pixi.js :as PIXI)
            phlox.core :refer $ render! clear-phlox-caches! on-control-event ffi-load-font ffi-then
            app.comp.container :refer $ comp-container
            app.schema :as schema
            app.config :refer $ dev?
            |nanoid :refer $ nanoid
            app.updater :refer $ updater
            |fontfaceobserver-es :default FontFaceObserver
            |./calcit.build-errors :default build-errors
            |bottom-tip :default hud!
            touch-control.core :refer $ render-control! start-control-loop! replace-control-loop!
    'app.schema $ %{} 'FileEntry
      :defs $ {}
        'ActionLog $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct ActionLog
            :op $ Map Tag Dynamic
            :snapshot $ List $ Map Tag Dynamic
          :examples $ []
          :schema $ quote StructDef
        'CircleShape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct CircleShape (:radius Number)
            :position $ List Number
          :examples $ []
          :schema $ quote StructDef
        'LegacyShape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct LegacyShape
            :wire $ Map Tag Dynamic
          :examples $ []
          :schema $ quote StructDef
        'Op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum Op (:noop)
            :states (List respo.schema/CoordKey) Dynamic
            :move-main-hint $ List Number
            :move-secondary-hint $ List Number
            :add-slide-after $ Option String
            :del-slide $ Option String
            :switch-slide String
            :add-shape (Option String) Shape
            :slide-state (List respo.schema/CoordKey) SlideState
            :hydrate-storage Store
          :examples $ []
          :schema $ quote EnumDef
        'RectShape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct RectShape
            :position $ List Number
            :sizes $ List Number
          :examples $ []
          :schema $ quote StructDef
        'Shape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defunion Shape RectShape CircleShape LegacyShape
          :examples $ []
          :schema $ quote UnionDef
        'Slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Slide
            :logs $ List ActionLog
          :examples $ []
          :schema $ quote StructDef
        'SlideState $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct SlideState (:pointer Number)
            :spin-pos $ List Number
          :examples $ []
          :schema $ quote StructDef
        'Store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Store
            :states $ Map Dynamic Dynamic
            :slide-key $ Option String
            :slides $ Map String Slide
            :main-hint $ List Number
            :secondary-hint $ List Number
          :examples $ []
          :schema $ quote StructDef
        'decode-shape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-shape (wire)
            match
              .unwrap-or (get wire :type) :unknown
              :rect $ RectShape :position
                decode-map-as
                  .unwrap-or (get wire :position) ([] 0 0)
                  List Number
                , :sizes $ decode-map-as
                  .unwrap-or (get wire :sizes) ([] 0 0)
                  List Number
              :circle $ CircleShape :position
                decode-map-as
                  .unwrap-or (get wire :position) ([] 0 0)
                  List Number
                , :radius $ decode-map-as
                  .unwrap-or (get wire :radius) 0
                  , Number
              _ $ LegacyShape :wire wire
          :examples $ []
          :schema $ quote $ Fn (Map Tag Dynamic) (-> Shape)
        'decode-store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-store (value)
            let
                data $ decode-map-as value $ Map Tag Dynamic
                normalized $ match (get data :slide-key)
                  (:none) data
                  (:some key)
                    if (nil? key) (dissoc data :slide-key) data
              decode-map-as normalized Store
          :examples $ []
          :schema $ quote $ Fn Dynamic (-> Store)
        'encode-shape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn encode-shape (shape)
            match shape
              (RectShape rect)
                {} (:type :rect)
                  :position $ :position rect
                  :sizes $ :sizes rect
              (CircleShape circle)
                {} (:type :circle)
                  :position $ :position circle
                  :radius $ :radius circle
              (LegacyShape legacy) (:wire legacy)
          :examples $ []
          :schema $ quote $ Fn Shape
            -> $ Map Tag Dynamic
        'normalize-op $ %{} 'CodeEntry
          :doc "|Accept application Op values and adapt legacy widget state events."
          :code $ quote $ defn normalize-op (op)
            if
              = (enum-definition op) (Some Op)
              decode-map-as op 'app.schema/Op
              match op
                (:states cursor data)
                  Op :states
                    decode-map-as cursor $ List respo.schema/CoordKey
                    , data
                _ $ do (println |unknown-op op) (Op :noop)
          :examples $ []
          :schema $ quote $ Fn AnyEnum (-> Op) (:open :decode)
        'slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def slide
            Slide :logs $ []
          :examples $ []
          :schema $ quote Slide
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            Store :states
              {} $ :cursor $ []
              , :slide-key None :slides ({}) :main-hint ([] 10 10) :secondary-hint $ [] 40 40
          :examples $ []
          :schema $ quote Store
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.updater $ %{} 'FileEntry
      :defs $ {}
        'add-slide-after $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-slide-after (slides base-key)
            match base-key
              (:none)
                if (empty? slides)
                  {} $ mid-id schema/slide
                  assoc-append slides schema/slide
              (:some key)
                if (empty? slides)
                  assoc slides (key-after slides key) schema/slide
                  assoc-after slides key schema/slide
          :examples $ []
          :schema $ quote $ Fn (Map String schema/Slide) (Option String)
            -> $ Map String schema/Slide
        'updater $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:noop) store
              (:states cursor data)
                assoc store :states $ decode-map-as
                  assoc-in (:states store) (conj cursor :data) data
                  Map Dynamic Dynamic
              (:slide-state cursor state)
                assoc store :states $ decode-map-as
                  assoc-in (:states store) (conj cursor :data) (&struct:to-map state)
                  Map Dynamic Dynamic
              (:move-main-hint pos) (assoc store :main-hint pos)
              (:move-secondary-hint pos) (assoc store :secondary-hint pos)
              (:add-slide-after key)
                assoc store :slides $ add-slide-after (:slides store) key
              (:del-slide key)
                match key
                  (:none) store
                  (:some id)
                    assoc store :slides $ dissoc (:slides store) id
              (:switch-slide key)
                assoc store :slide-key $ Some key
              (:add-shape key shape)
                match key
                  (:none) store
                  (:some id)
                    match
                      get (:slides store) id
                      (:none) store
                      (:some slide)
                        let
                            logs $ :logs slide
                            tree $ match (last logs)
                              (:none) ([])
                              (:some log) (:snapshot log)
                            wire $ schema/encode-shape shape
                            entry $ schema/ActionLog :op wire :snapshot $ conj tree wire
                          assoc store :slides $ assoc (:slides store) id $ assoc slide :logs (conj logs entry)
              (:hydrate-storage data) data
          :examples $ []
          :schema $ quote $ Fn schema/Store schema/Op String Number (-> schema/Store)
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require
            bisection-key.core :refer $ mid-id
            bisection-key.util :refer $ assoc-after assoc-append key-after
            app.schema :as schema
