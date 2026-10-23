
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :js) (:reload-fn 'app.main/reload!) (:target :browser)
      :feature-policy $ {}
      :modules $ [] |respo.calcit/ |respo-ui.calcit/ |phlox/ |pointed-prompt/ |bisection-key/ |touch-control/
      :type-slots $ {}
  :files $ {}
    'app.comp.container $ %{} 'FileEntry
      :defs $ {}
        'WindowHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait WindowHost (:innerHeight 'Number) (:innerWidth 'Number)
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
          :schema $ :: 'Trait
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
                    (:none) (Option :none)
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
                    * 0.5 $ .-innerHeight $ unsafe-coerce js/window WindowHost
                  :on-pointertap $ fn (e d!)
                    d! :add-slide-after $ schema/key-or-nil slide-key
                comp-button $ {} (:text |Command)
                  :position $ [] 220 $ - 60
                    * 0.5 $ .-innerHeight $ unsafe-coerce js/window WindowHost
                  :on-pointertap $ fn (e d!)
                    request-text! e
                      {} (:placeholder |Command)
                        :style $ {} $ :font-family ui/font-code
                      fn (code)
                        match
                          run-command
                            parse-cirru-list $ decode-map-as code 'String
                            :main-hint store-map
                            :secondary-hint store-map
                            , slide-key
                          (:none) &unit
                          (:some op) (d! op)
                        ; println |Store store $ :tab store
                        , &unit
                comp-button $ {} (:text |DEBUG)
                  :position $ [] 320 $ - 60
                    * 0.5 $ .-innerHeight $ unsafe-coerce js/window WindowHost
                  :on-pointertap $ fn (e d!) (js/console.warn |[DEBUG] store)
                comp-drag-point (>> states :main-hint)
                  {}
                    :position $ :main-hint store-map
                    :fill $ hslx 120 90 80
                    :radius 8
                    :hide-text? true
                    :on-change $ fn (pos d!) (d! :move-main-hint pos)
                comp-drag-point (>> states :secondary-hint)
                  {}
                    :position $ :secondary-hint store-map
                    :fill $ hslx 250 90 70
                    :radius 6
                    :hide-text? true
                    :on-change $ fn (pos d!) (d! :move-secondary-hint pos)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'phlox.schema/PhloxElement)
            :args $ [] 'app.schema/Store
            :features $ #{} :js-ffi
        'comp-slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn comp-slide (states pointed-key slide)
            let
                states-map states
                slide-map slide
                logs $ :logs slide-map
                cursor $ decode-map-as
                  .unwrap-or (get states-map :cursor) ([])
                  :: 'List 'Dynamic
                fallback-state $ {} (:pointer 0)
                  :spin-pos $ []
                    - 200 $ * 0.5 $ .-innerWidth (unsafe-coerce js/window WindowHost)
                    -
                      * 0.5 $ .-innerHeight $ unsafe-coerce js/window WindowHost
                      , 200
                state $ decode-map-as
                  decode-map-as
                    .unwrap-or (get states-map :data) fallback-state
                    :: 'Map 'Tag 'Dynamic
                  , schema/SlideState
                pointer $ :pointer state
              container ({})
                create-list :container ({})
                  -> logs $ map-indexed $ fn (idx log)
                    let
                        shape-op $ :op log
                      [] idx $ comp-button $ {}
                        :text $ str $ .unwrap-or (get shape-op :type) nil
                        :position $ []
                          - 20 $ * 0.5 $ .-innerWidth (unsafe-coerce js/window WindowHost)
                          - 120 $ * idx 40
                        :on-pointertap $ fn (e d!) (println |shape-op shape-op)
                create-list :container ({})
                  -> logs $ map-indexed $ fn (idx log)
                    [] idx $ render-shape $ :op log
                comp-spin-slider (>> states :spin)
                  {} (:value pointer)
                    :position $ :spin-pos state
                    :spin-pivot $ complex/add (:spin-pos state)
                      []
                        * 0.5 $ .-innerWidth $ unsafe-coerce js/window WindowHost
                        * 0.5 $ .-innerHeight $ unsafe-coerce js/window WindowHost
                    :unit 4
                    :min 0
                    :max 100
                    :fraction 2
                    :on-change $ fn (value d!)
                      d! cursor $ {} (:pointer value)
                        :spin-pos $ :spin-pos state
                    :on-move $ fn (pos d!) (; println "|move to:" pos)
                      d! cursor $ {}
                        :pointer $ :pointer state
                        :spin-pos pos
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'phlox.schema/PhloxElement)
            :args $ [] (:: 'Map 'Dynamic 'Dynamic) 'String 'app.schema/Slide
            :features $ #{} :js-ffi
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
                          &* 0.5 $ .-innerWidth $ unsafe-coerce js/window WindowHost
                        - 20 $ * 0.5 $ .-innerHeight (unsafe-coerce js/window WindowHost)
                      :fill $ if
                        match pointer
                          (:none) false
                          (:some selected) (= key selected)
                        hslx 60 80 30
                      :align-right? false
                      :on-pointertap $ fn (e d!) (; println |key key) (d! :switch-slide key)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'phlox.schema/PhloxElement)
            :args $ [] (:: 'Set 'String) (:: 'Option 'String)
            :features $ #{} :js-ffi
        'render-shape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-shape (shape-op)
            let
                shape-map shape-op
              match
                .unwrap-or (get shape-map :type) nil
                :rect $ rect $ {}
                  :position $ decode-map-as
                    .unwrap-or (get shape-map :position) ([] 0 0)
                    :: 'List 'Number
                  :size $ decode-map-as
                    .unwrap-or (get shape-map :sizes) ([] 0 0)
                    :: 'List 'Number
                  :line-style $ {} (:width 4)
                    :color $ hslx 0 80 50
                    :alpha 1
                  :fill $ hslx 200 80 80
                  :on $ {}
                :circle $ circle $ {}
                  :radius $ decode-map-as
                    .unwrap-or (get shape-map :radius) 0
                    , 'Number
                  :position $ decode-map-as
                    .unwrap-or (get shape-map :position) ([] 0 0)
                    :: 'List 'Number
                  :fill $ hslx 200 80 80
                  :on $ {}
                _ $ text $ {}
                  :text $ str "|Unknown: " shape-op
                  :style $ {} (:font-size 14) (:font-weight 500)
                    :fill $ hslx 0 100 50
                    :font-family ui/font-fancy
                  :align :center
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'phlox.schema/PhloxElement)
            :args $ [] $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
        'run-command $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn run-command (tree c1 c2 slide-key)
            if
              = 1 $ count tree
              let
                  statement $ decode-map-as
                    .unwrap $ first tree
                    :: 'List 'Dynamic
                  command $ .unwrap-or (first statement) nil
                match command
                  |del-slide $ Option :some $ :: :del-slide (schema/key-or-nil slide-key)
                  |add-slide $ if (.some? slide-key)
                    Option :some $ :: :add-slide-after $ schema/key-or-nil slide-key
                    do (js/console.warn "|nil slide-key") (Option :none)
                  |add-circle $ Option :some $ :: :add-shape
                    {}
                      :slide-key $ schema/key-or-nil slide-key
                      :op $ {} (:type :circle)
                        :position $ complex/divide-by (complex/add c1 c2) 2
                        :radius $ * 0.5 $ vec-length (complex/minus c2 c1)
                  |add-rect $ Option :some $ :: :add-shape
                    {}
                      :slide-key $ schema/key-or-nil slide-key
                      :op $ {} (:type :rect) (:position c1)
                        :sizes $ complex/minus c2 c1
                  _ $ do (println "|Unknown command:" command) (Option :none)
              do (js/console.warn "|unknown tree:" tree) (Option :none)
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'List 'Dynamic) (:: 'List 'Number) (:: 'List 'Number) (:: 'Option 'String)
            :features $ #{} :js-ffi
            :return $ :: 'Option 'Enum
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
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ .unwrap-or (get-env |mode) |release
          :examples $ []
          :schema $ :: 'Bool
        'site $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def site
            {} (:dev-ui |http://localhost:8100/main.css) (:release-ui |http://cdn.tiye.me/favored-fonts/main.css) (:cdn-url |http://cdn.tiye.me/phlox/) (:title |Phlox) (:icon |http://cdn.tiye.me/logo/quamolit.png) (:storage-key |phlox)
          :examples $ []
          :schema $ :: 'Map 'Tag 'String
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.config
    'app.main $ %{} 'FileEntry
      :defs $ {}
        '*store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defref *store schema/store
          :examples $ []
          :schema $ :: 'Ref 'app.schema/Store
        'FontFaceObserverHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait FontFaceObserverHost
            .load $ :: 'Fn $ {}
              :args $ []
              :return 'JsObject
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
          :schema $ :: 'Trait
        'PromiseHost $ %{} 'CodeEntry (:doc |)
          :code $ quote $ deftrait PromiseHost
            .then $ :: 'Fn $ {}
              :args $ [] $ :: 'Fn
                {} (:return 'Unit)
                  :args $ [] 'Dynamic
              :return 'Dynamic
          :examples $ []
          :ffi $ {} (:backend :js) (:kind :external-object) (:target :browser)
          :schema $ :: 'Trait
        'dispatch! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn dispatch! (op)
            when dev? $ match op
              (:states _ _) nil
              _ $ println |dispatch! op
            let
                op-id $ decode-map-as (nanoid) 'String
                op-time $ decode-map-as (js/Date.now) 'Number
              reset! *store $ updater @*store (schema/normalize-op op) op-id op-time
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Enum
            :features $ #{} :js-ffi
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (; js/console.log PIXI)
            if dev? $ load-console-formatter!
            let
                observer $ unsafe-coerce (new FontFaceObserver "|Josefin Sans") FontFaceObserverHost
                font-load $ unsafe-coerce (.!load observer) PromiseHost
              .!then font-load $ fn (event)
                render-app! $ {}
            add-watch! *store :change $ fn (store prev)
              render-app! $ {}
            render-control!
            start-control-loop! 8 on-control-event
            println "|App Started"
            , &unit
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
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
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! (arg)
            render! (comp-container @*store) dispatch! arg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] $ :: 'Map 'Tag 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.main
          :require (|pixi.js :as PIXI)
            phlox.core :refer $ render! clear-phlox-caches! on-control-event
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
            :op $ :: 'Map 'Tag 'Dynamic
            :snapshot $ :: 'List $ :: 'Map 'Tag 'Dynamic
          :examples $ []
          :schema $ :: 'StructDef
        'Op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defenum Op (:noop)
            :states (:: 'List 'Dynamic) 'Dynamic
            :move-main-hint $ :: 'List 'Number
            :move-secondary-hint $ :: 'List 'Number
            :add-slide-after $ :: 'Option 'String
            :del-slide $ :: 'Option 'String
            :switch-slide 'String
            :add-shape (:: 'Option 'String) (:: 'Map 'Tag 'Dynamic)
            :hydrate-storage 'Store
          :examples $ []
          :schema $ :: 'EnumDef
        'Slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Slide
            :logs $ :: 'List 'ActionLog
          :examples $ []
          :schema $ :: 'StructDef
        'SlideState $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct SlideState (:pointer 'Number)
            :spin-pos $ :: 'List 'Number
          :examples $ []
          :schema $ :: 'StructDef
        'Store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defstruct Store
            :states $ :: 'Map 'Dynamic 'Dynamic
            :slide-key $ :: 'Option 'String
            :slides $ :: 'Map 'String 'Slide
            :main-hint $ :: 'List 'Number
            :secondary-hint $ :: 'List 'Number
          :examples $ []
          :schema $ :: 'StructDef
        'decode-store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn decode-store (value)
            let
                data $ decode-map-as value $ :: 'Map 'Tag 'Dynamic
                normalized $ if
                  nil? $ .unwrap-or (get data :slide-key) nil
                  dissoc data :slide-key
                  , data
              decode-map-as normalized Store
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.schema/Store)
            :args $ [] 'Dynamic
        'key-or-nil $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn key-or-nil (key)
            match key
              (:none) nil
              (:some id) id
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] $ :: 'Option 'String
        'normalize-op $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn normalize-op (op)
            match op
              (:states cursor data)
                Op :states
                  decode-map-as cursor $ :: 'List 'Dynamic
                  , data
              (:move-main-hint pos)
                Op :move-main-hint $ decode-map-as pos $ :: 'List 'Number
              (:move-secondary-hint pos)
                Op :move-secondary-hint $ decode-map-as pos $ :: 'List 'Number
              (:add-slide-after key)
                Op :add-slide-after $ optional-key key
              (:del-slide key)
                Op :del-slide $ optional-key key
              (:switch-slide key)
                Op :switch-slide $ decode-map-as key 'String
              (:add-shape data)
                let
                    payload $ decode-map-as data $ :: 'Map 'Tag 'Dynamic
                  Op :add-shape
                    optional-key $ .unwrap $ get payload :slide-key
                    decode-map-as
                      .unwrap $ get payload :op
                      :: 'Map 'Tag 'Dynamic
              (:hydrate-storage data)
                Op :hydrate-storage $ decode-store data
              _ $ do (println |unknown-op op) (Op :noop)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.schema/Op)
            :args $ [] 'Enum
        'optional-key $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn optional-key (value)
            if (nil? value) (Option :none)
              Option :some $ decode-map-as value 'String
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ [] 'Dynamic
            :return $ :: 'Option 'String
        'slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def slide
            Slide :logs $ []
          :examples $ []
          :schema $ :: 'app.schema/Slide
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            Store :states
              {} $ :cursor $ []
              , :slide-key (Option :none) :slides ({}) :main-hint ([] 10 10) :secondary-hint $ [] 40 40
          :examples $ []
          :schema $ :: 'app.schema/Store
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
          :schema $ :: 'Fn $ {}
            :args $ [] (:: 'Map 'String 'app.schema/Slide) (:: 'Option 'String)
            :return $ :: 'Map 'String 'app.schema/Slide
        'updater $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-id op-time)
            match op
              (:noop) store
              (:states cursor data)
                assoc store :states $ decode-map-as
                  assoc-in (:states store) (conj cursor :data) data
                  :: 'Map 'Dynamic 'Dynamic
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
                assoc store :slide-key $ Option :some key
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
                            entry $ schema/ActionLog :op shape :snapshot $ conj tree shape
                          assoc store :slides $ assoc (:slides store) id $ assoc slide :logs (conj logs entry)
              (:hydrate-storage data) data
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'app.schema/Store)
            :args $ [] 'app.schema/Store 'app.schema/Op 'String 'Number
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require
            bisection-key.core :refer $ mid-id
            bisection-key.util :refer $ assoc-after assoc-append key-after
            app.schema :as schema
