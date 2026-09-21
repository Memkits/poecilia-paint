
{}
  :about "|Machine-generated snapshot. Do not edit directly — changes will be overwritten. Use `calcit query` to inspect and `calcit edit`/`calcit tree` to modify. Run `calcit docs agents --contract` before mutations; use `--full` for first orientation or changed contract digest. Manual edits must follow format and schema conventions, then run `calcit edit format`."
  :package |app
  :entries $ {} $ :default
    {} (:description |) (:init-fn 'app.main/main!) (:mode :native) (:reload-fn 'app.main/reload!)
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
                store-map $ unsafe-coerce store 'Map
                cursor $ []
                states $ unsafe-coerce (&map:get store-map :states) 'Map
                slides $ unsafe-coerce (&map:get store-map :slides) 'Map
                slide-key $ &map:get store-map :slide-key
              container ({})
                match (get slides slide-key)
                  (:none)
                    text $ {} (:text "|No Slide")
                      :style $ {} (:font-size 60) (:font-weight 100)
                        :fill $ hslx 0 100 50
                        :font-family ui/font-fancy
                      :align :center
                  (:some slide)
                    comp-slide (>> states slide-key) slide-key slide
                comp-slide-tabs (keys slides) slide-key
                comp-button $ {} (:text |Add)
                  :position $ [] 160 $ - 60
                    * 0.5 $ unsafe-coerce
                      .-innerHeight $ unsafe-coerce js/window WindowHost
                      , 'Number
                  :on-pointertap $ fn (e d!) (d! :add-slide-after slide-key)
                comp-button $ {} (:text |Command)
                  :position $ [] 220 $ - 60
                    * 0.5 $ unsafe-coerce
                      .-innerHeight $ unsafe-coerce js/window WindowHost
                      , 'Number
                  :on-pointertap $ fn (e d!)
                    request-text! e
                      {} (:placeholder |Command)
                        :style $ {} $ :font-family ui/font-code
                      fn (code)
                        run-command (parse-cirru code)
                          unsafe-coerce
                            option:unwrap-or (get store-map :main-hint) ([] 10 10)
                            , 'List
                          unsafe-coerce
                            option:unwrap-or (get store-map :secondary-hint) ([] 40 40)
                            , 'List
                          , slide-key d!
                        ; println |Store store $ :tab store
                comp-button $ {} (:text |DEBUG)
                  :position $ [] 320 $ - 60
                    * 0.5 $ unsafe-coerce
                      .-innerHeight $ unsafe-coerce js/window WindowHost
                      , 'Number
                  :on-pointertap $ fn (e d!) (js/console.warn |[DEBUG] store)
                comp-drag-point (>> states :main-hint)
                  {}
                    :position $ unsafe-coerce
                      option:unwrap-or (get store-map :main-hint) ([] 10 10)
                      , 'List
                    :fill $ hslx 120 90 80
                    :radius 8
                    :hide-text? true
                    :on-change $ fn (pos d!) (d! :move-main-hint pos)
                comp-drag-point (>> states :secondary-hint)
                  {}
                    :position $ unsafe-coerce
                      option:unwrap-or (get store-map :secondary-hint) ([] 40 40)
                      , 'List
                    :fill $ hslx 250 90 70
                    :radius 6
                    :hide-text? true
                    :on-change $ fn (pos d!) (d! :move-secondary-hint pos)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'comp-slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn comp-slide (states pointed-key slide)
            let
                states-map $ unsafe-coerce states 'Map
                slide-map $ unsafe-coerce slide 'Map
                logs $ unsafe-coerce (&map:get slide-map :logs) 'List
                cursor $ &map:get states-map :cursor
                fallback-state $ {} (:pointer 0)
                  :spin-pos $ []
                    - 200 $ * 0.5 $ unsafe-coerce
                      .-innerWidth $ unsafe-coerce js/window WindowHost
                      , 'Number
                    -
                      * 0.5 $ unsafe-coerce
                        .-innerHeight $ unsafe-coerce js/window WindowHost
                        , 'Number
                      , 200
                state $ unsafe-coerce
                  option:unwrap-or (get states-map :data) fallback-state
                  , 'Map
                pointer $ &map:get state :pointer
              container ({})
                create-list :container ({})
                  -> logs $ map-indexed $ fn (idx log)
                    let
                        shape-op $ &map:get (unsafe-coerce log 'Map) :op
                      [] idx $ comp-button $ {}
                        :text $ str $ &map:get (unsafe-coerce shape-op 'Map) :type
                        :position $ []
                          - 20 $ * 0.5 $ unsafe-coerce
                            .-innerWidth $ unsafe-coerce js/window WindowHost
                            , 'Number
                          - 120 $ * idx 40
                        :on-pointertap $ fn (e d!) (println |shape-op shape-op)
                create-list :container ({})
                  -> logs $ map-indexed $ fn (idx log)
                    [] idx $ render-shape $ &map:get (unsafe-coerce log 'Map) :op
                comp-spin-slider (>> states :spin)
                  {} (:value pointer)
                    :position $ unsafe-coerce
                      option:unwrap-or (get state :spin-pos) ([] 0 0)
                      , 'List
                    :spin-pivot $ complex/add
                      unsafe-coerce
                        option:unwrap-or (get state :spin-pos) ([] 0 0)
                        , 'List
                      []
                        * 0.5 $ unsafe-coerce
                          .-innerWidth $ unsafe-coerce js/window WindowHost
                          , 'Number
                        * 0.5 $ unsafe-coerce
                          .-innerHeight $ unsafe-coerce js/window WindowHost
                          , 'Number
                    :unit 4
                    :min 0
                    :max 100
                    :fraction 2
                    :on-change $ fn (value d!)
                      d! cursor $ assoc state :pointer value
                    :on-move $ fn (pos d!) (; println "|move to:" pos)
                      d! cursor $ assoc state :spin-pos pos
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'comp-slide-tabs $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn comp-slide-tabs (slide-keys pointer)
            ; println |key $ -> slide-keys .to-list $ .sort
              fn (a b) (&compare a b)
            let
                slide-key-set $ unsafe-coerce slide-keys 'Set
              create-list :container ({})
                -> (&set:to-list slide-key-set)
                  sort $ fn (a b) (&compare a b)
                  map-indexed $ fn (idx key)
                    [] key $ comp-button $ {} (:text key)
                      :position $ []
                        -
                          + 100 $ * idx 44
                          &* 0.5 $ unsafe-coerce
                            .-innerWidth $ unsafe-coerce js/window WindowHost
                            , 'Number
                        - 20 $ * 0.5 $ unsafe-coerce
                          .-innerHeight $ unsafe-coerce js/window WindowHost
                          , 'Number
                      :fill $ if (= key pointer) (hslx 60 80 30)
                      :align-right? false
                      :on-pointertap $ fn (e d!) (; println |key key) (d! :switch-slide key)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] (:: 'Set 'String) 'Dynamic
            :features $ #{} :js-ffi
        'render-shape $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-shape (shape-op)
            let
                shape-map $ unsafe-coerce shape-op 'Map
              case-default (&map:get shape-map :type)
                text $ {}
                  :text $ str "|Unknown: " shape-op
                  :style $ {} (:font-size 14) (:font-weight 500)
                    :fill $ hslx 0 100 50
                    :font-family ui/font-fancy
                  :align :center
                :rect $ rect $ {}
                  :position $ unsafe-coerce
                    option:unwrap-or (get shape-map :position) ([] 0 0)
                    , 'List
                  :size $ unsafe-coerce
                    option:unwrap-or (get shape-map :sizes) ([] 0 0)
                    , 'List
                  :line-style $ {} (:width 4)
                    :color $ hslx 0 80 50
                    :alpha 1
                  :fill $ hslx 200 80 80
                  :on $ {}
                :circle $ circle $ {}
                  :radius $ option:unwrap-or (get shape-map :radius) 0
                  :position $ unsafe-coerce
                    option:unwrap-or (get shape-map :position) ([] 0 0)
                    , 'List
                  :fill $ hslx 200 80 80
                  :on $ {}
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic
            :features $ #{} :js-ffi
        'run-command $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn run-command (tree c1 c2 slide-key d!)
            if
              = 1 $ count tree
              let[] (command p1 p2 p3)
                unsafe-coerce
                  option:unwrap-or (first tree) ([])
                  , 'List
                case-default command (println "|Unknown command:" command)
                  |del-slide $ d! :del-slide slide-key
                  |add-slide $ if (some? slide-key) (d! :add-slide-after slide-key) (js/console.warn "|nil slide-key")
                  |add-circle $ d! :add-shape $ {} (:slide-key slide-key)
                    :op $ {} (:type :circle)
                      :position $ complex/divide-by (complex/add c1 c2) 2
                      :radius $ * 0.5 $ vec-length (complex/minus c2 c1)
                  |add-rect $ d! :add-shape $ {} (:slide-key slide-key)
                    :op $ {} (:type :rect) (:position c1)
                      :sizes $ complex/minus c2 c1
              js/console.warn "|unknown tree:" tree
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic 'Dynamic 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.comp.container
          :require
            phlox.core :refer $ g hslx rect circle text container graphics create-list >>
            phlox.comp.button :refer $ comp-button
            phlox.comp.drag-point :refer $ comp-drag-point
            |shortid :as shortid
            respo-ui.core :as ui
            phlox.input :refer $ request-text!
            phlox.comp.slider :refer $ comp-spin-slider
            phlox.complex :as complex
            phlox.math :refer $ vec-length
    'app.config $ %{} 'FileEntry
      :defs $ {}
        'dev? $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def dev?
            = |dev $ option:unwrap-or (get-env |mode) |release
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
          :code $ quote $ defatom *store schema/store
          :examples $ []
          :schema $ :: 'Ref $ :: 'Map 'Tag 'Dynamic
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
          :code $ quote $ defn dispatch! (op op-data)
            when
              and dev? $ not= op :states
              println |dispatch! op op-data
            let
                op-id $ nanoid
                op-time $ js/Date.now
              reset! *store $ assert-type (updater @*store op op-data op-id op-time) (:: 'Map 'Tag 'Dynamic)
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Dynamic 'Dynamic
            :features $ #{} :js-ffi
        'main! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn main! () (; js/console.log PIXI)
            if dev? $ load-console-formatter!
            let
                observer $ unsafe-coerce (new FontFaceObserver "|Josefin Sans") FontFaceObserverHost
                font-load $ unsafe-coerce (.!load observer) PromiseHost
              .!then font-load $ fn (event)
                render-app! $ {}
            add-watch *store :change $ fn (store prev)
              render-app! $ {}
            render-control!
            start-control-loop! 8 on-control-event
            println "|App Started"
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'reload! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn reload! ()
            if (nil? build-errors)
              do (println "|Code updated.") (clear-phlox-caches!) (remove-watch *store :change)
                add-watch *store :change $ fn (store prev)
                  render-app! $ {}
                render-app! $ {}
                replace-control-loop! 8 on-control-event
                hud! |ok~ |Ok
              hud! |error build-errors
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ []
            :features $ #{} :js-ffi
        'render-app! $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn render-app! (arg)
            render! (comp-container @*store) dispatch! arg
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Unit)
            :args $ [] 'Dynamic
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
        'action-log $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def action-log
            {} (:op nil) (:snapshot nil)
          :examples $ []
          :schema $ :: 'Map 'Tag 'Dynamic
        'slide $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def slide
            {} $ :logs $ do action-log ([])
          :examples $ []
          :schema $ :: 'Map 'Tag 'Dynamic
        'store $ %{} 'CodeEntry (:doc |)
          :code $ quote $ def store
            {}
              :states $ {} $ :cursor ([])
              :slide-key nil
              :slides $ do slide $ {}
              :main-hint $ [] 10 10
              :secondary-hint $ [] 40 40
          :examples $ []
          :schema $ :: 'Map 'Tag 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.schema
    'app.updater $ %{} 'FileEntry
      :defs $ {}
        'add-slide-after $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn add-slide-after (slides base-key)
            if (nil? base-key)
              if (empty? slides)
                {} $ mid-id schema/slide
                assoc-append slides schema/slide
              if (empty? slides)
                let
                    next-key $ key-after slides base-key
                  assoc slides next-key schema/slide
                assoc-after slides base-key schema/slide
          :examples $ []
          :schema $ :: 'Fn $ {}
            :args $ []
              :: 'Map 'String $ :: 'Map 'Tag 'Dynamic
              , 'Dynamic
            :return $ :: 'Map 'String $ :: 'Map 'Tag 'Dynamic
        'updater $ %{} 'CodeEntry (:doc |)
          :code $ quote $ defn updater (store op op-data op-id op-time)
            case-default op
              do (println "|unknown op" op op-data) store
              :states $ let[] (cursor data) op-data $ update-states store cursor data
              :move-main-hint $ assoc store :main-hint op-data
              :move-secondary-hint $ assoc store :secondary-hint op-data
              :add-slide-after $ assoc store :slides $ add-slide-after
                assert-type
                  option:unwrap-or (get store :slides) ({})
                  :: 'Map 'String $ :: 'Map 'Tag 'Dynamic
                , op-data
              :del-slide $ dissoc-in store $ [] :slides op-data
              :switch-slide $ assoc store :slide-key op-data
              :add-shape $ let
                  op-map $ assert-type op-data $ :: 'Map 'Tag 'Dynamic
                  slide-key $ &map:get op-map :slide-key
                  shape-op $ &map:get op-map :op
                if (some? slide-key)
                  let
                      slide-key $ assert-type slide-key 'String
                    let
                        logs $ assert-type
                          option:unwrap-or
                            get-in store $ [] :slides slide-key :logs
                            []
                          :: 'List $ :: 'Map 'Tag 'Dynamic
                        tree $ if (empty? logs) ([])
                          assert-type
                            &map:get
                              assert-type
                                option:unwrap $ last logs
                                :: 'Map 'Tag 'Dynamic
                              , :snapshot
                            :: 'List 'Dynamic
                      assoc-in store ([] :slides slide-key :logs)
                        conj logs $ {} (:op shape-op)
                          :snapshot $ conj tree shape-op
              :hydrate-storage op-data
          :examples $ []
          :schema $ :: 'Fn $ {} (:return 'Dynamic)
            :args $ [] 'Dynamic 'Dynamic 'Dynamic 'Dynamic 'Dynamic
      :ns $ %{} 'NsEntry (:doc |)
        :code $ quote $ ns app.updater
          :require
            [] phlox.cursor :refer $ [] update-states
            bisection-key.core :refer $ bisect mid-id
            bisection-key.util :refer $ assoc-after assoc-append key-after
            app.schema :as schema
