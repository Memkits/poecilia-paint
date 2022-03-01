
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!)
    :modules $ [] |memof/ |lilac/ |respo.calcit/ |respo-ui.calcit/ |phlox/ |pointed-prompt/ |bisection-key/
    :version |0.4.10
  :entries $ {}
  :files $ {}
    |app.comp.container $ {}
      :ns $ quote
        ns app.comp.container $ :require
          phlox.core :refer $ g hslx rect circle text container graphics create-list >>
          phlox.comp.button :refer $ comp-button
          phlox.comp.drag-point :refer $ comp-drag-point
          "\"shortid" :as shortid
          respo-ui.core :as ui
          memof.alias :refer $ memof-call
          phlox.comp.drag-point :refer $ comp-drag-point
          phlox.comp.button :refer $ comp-button
          phlox.input :refer $ request-text!
          phlox.comp.slider :refer $ comp-spin-slider
          phlox.complex :as complex
          phlox.math :refer $ vec-length
      :defs $ {}
        |comp-container $ quote
          defn comp-container (store)
            ; println "\"Store" store $ :tab store
            let
                cursor $ []
                states $ :states store
                slides $ :slides store
                slide-key $ :slide-key store
              container ({})
                let
                    slide $ get slides slide-key
                  if (nil? slide)
                    text $ {} (:text "\"No Slide")
                      :style $ {} (:font-size 60) (:font-weight 100)
                        :fill $ hslx 0 100 50
                        :font-family ui/font-fancy
                      :align :center
                    comp-slide (>> states slide-key) slide-key slide
                comp-slide-tabs (keys slides) slide-key
                comp-button $ {} (:text "\"Add")
                  :position $ [] 160
                    - 60 $ * 0.5 js/window.innerHeight
                  :on-pointertap $ fn (e d!) (d! :add-slide-after slide-key)
                comp-button $ {} (:text "\"Command")
                  :position $ [] 220
                    - 60 $ * 0.5 js/window.innerHeight
                  :on-pointertap $ fn (e d!)
                    request-text! e
                      {} (:placeholder "\"Command")
                        :style $ {} (:font-family ui/font-code)
                      fn (code)
                        run-command (parse-cirru code) (:main-hint store) (:secondary-hint store) slide-key d!
                        ; println "\"Store" store $ :tab store
                comp-button $ {} (:text "\"DEBUG")
                  :position $ [] 320
                    - 60 $ * 0.5 js/window.innerHeight
                  :on-pointertap $ fn (e d!) (js/console.warn "\"[DEBUG]" store)
                comp-drag-point (>> states :main-hint)
                  {}
                    :position $ :main-hint store
                    :fill $ hslx 120 90 80
                    :radius 8
                    :hide-text? true
                    :on-change $ fn (pos d!) (d! :move-main-hint pos)
                comp-drag-point (>> states :secondary-hint)
                  {}
                    :position $ :secondary-hint store
                    :fill $ hslx 250 90 70
                    :radius 6
                    :hide-text? true
                    :on-change $ fn (pos d!) (d! :move-secondary-hint pos)
        |comp-slide $ quote
          defn comp-slide (states pointed-key slide)
            let
                cursor $ :cursor states
                state $ either (:data states)
                  {} (:pointer 0)
                    :spin-pos $ []
                      - 200 $ * 0.5 js/window.innerWidth
                      - (* 0.5 js/window.innerHeight) 200
                pointer $ :pointer state
              container ({})
                create-list :container ({})
                  -> slide :logs $ map-indexed
                    fn (idx log)
                      let
                          shape-op $ :op log
                        [] idx $ comp-button
                          {}
                            :text $ str (:type shape-op)
                            :position $ []
                              - 20 $ * 0.5 js/window.innerWidth
                              - 120 $ * idx 40
                            :on-pointertap $ fn (e d!) (println "\"shape-op" shape-op)
                create-list :container ({})
                  -> slide :logs $ map-indexed
                    fn (idx log)
                      [] idx $ render-shape (:op log)
                comp-spin-slider (>> states :spin)
                  {} (:value pointer)
                    :position $ :spin-pos state
                    :spin-pivot $ complex/add (:spin-pos state)
                      [] (* 0.5 js/window.innerWidth) (* 0.5 js/window.innerHeight)
                    :unit 4
                    :min 0
                    :max 100
                    :fraction 2
                    :on-change $ fn (value d!)
                      d! cursor $ assoc state :pointer value
                    :on-move $ fn (pos d!) (; println "\"move to:" pos)
                      d! cursor $ assoc state :spin-pos pos
        |comp-slide-tabs $ quote
          defn comp-slide-tabs (slide-keys pointer)
            ; println "\"key" $ -> slide-keys .to-list
              .sort $ fn (a b) (&compare a b)
            create-list :container ({})
              -> slide-keys .to-list
                .sort $ fn (a b) (&compare a b)
                .map-indexed $ fn (idx key)
                  [] key $ comp-button
                    {} (:text key)
                      :position $ []
                        -
                          + 100 $ * idx 44
                          &* 0.5 js/window.innerWidth
                        - 20 $ * 0.5 js/window.innerHeight
                      :fill $ if (= key pointer) (hslx 60 80 30)
                      :align-right? false
                      :on-pointertap $ fn (e d!) (; println "\"key" key) (d! :switch-slide key)
        |run-command $ quote
          defn run-command (tree c1 c2 slide-key d!)
            if
              = 1 $ count tree
              let[] (command p1 p2 p3) (first tree)
                case-default command (println "\"Unknown command:" command)
                  "\"del-slide" $ d! :del-slide slide-key
                  "\"add-slide" $ if (some? slide-key) (d! :add-slide-after slide-key) (js/console.warn "\"nil slide-key")
                  "\"add-circle" $ d! :add-shape
                    {} (:slide-key slide-key)
                      :op $ {} (:type :circle)
                        :position $ complex/divide-by (complex/add c1 c2) 2
                        :radius $ * 0.5
                          vec-length $ complex/minus c2 c1
                  "\"add-rect" $ d! :add-shape
                    {} (:slide-key slide-key)
                      :op $ {} (:type :rect) (:position c1)
                        :sizes $ complex/minus c2 c1
              js/console.warn "\"unknown tree:" tree
        |render-shape $ quote
          defn render-shape (shape-op)
            case-default (:type shape-op)
              text $ {}
                :text $ str "\"Unknown: " shape-op
                :style $ {} (:font-size 14) (:font-weight 500)
                  :fill $ hslx 0 100 50
                  :font-family ui/font-fancy
                :align :center
              :rect $ rect
                {}
                  :position $ :position shape-op
                  :size $ :sizes shape-op
                  :line-style $ {} (:width 4)
                    :color $ hslx 0 80 50
                    :alpha 1
                  :fill $ hslx 200 80 80
                  :on $ {}
              :circle $ circle
                {}
                  :radius $ :radius shape-op
                  :position $ :position shape-op
                  :fill $ hslx 200 80 80
                  :on $ {}
    |app.schema $ {}
      :ns $ quote (ns app.schema)
      :defs $ {}
        |store $ quote
          def store $ {}
            :states $ {}
              :cursor $ []
            :slide-key nil
            :slides $ do slide ({})
            :main-hint $ [] 10 10
            :secondary-hint $ [] 40 40
        |slide $ quote
          def slide $ {}
            :logs $ do action-log ([])
        |action-log $ quote
          def action-log $ {} (:op nil) (:snapshot nil)
    |app.updater $ {}
      :ns $ quote
        ns app.updater $ :require
          [] phlox.cursor :refer $ [] update-states
          bisection-key.core :refer $ bisect mid-id
          bisection-key.util :refer $ assoc-after assoc-append key-after
          app.schema :as schema
      :defs $ {}
        |updater $ quote
          defn updater (store op op-data op-id op-time)
            case-default op
              do (println "\"unknown op" op op-data) store
              :states $ update-states store op-data
              :move-main-hint $ assoc store :main-hint op-data
              :move-secondary-hint $ assoc store :secondary-hint op-data
              :add-slide-after $ update store :slides
                fn (slides) (add-slide-after slides op-data)
              :del-slide $ dissoc-in store ([] :slides op-data)
              :switch-slide $ assoc store :slide-key op-data
              :add-shape $ let
                  slide-key $ :slide-key op-data
                  shape-op $ :op op-data
                if (some? slide-key)
                  update-in store ([] :slides slide-key :logs)
                    fn (logs)
                      let
                          tree $ if (empty? logs) ([])
                            :snapshot $ last logs
                        conj logs $ {} (:op shape-op)
                          :snapshot $ conj tree shape-op
              :hydrate-storage op-data
        |add-slide-after $ quote
          defn add-slide-after (slides base-key)
            if (nil? base-key)
              if (empty? slides)
                {} $ mid-id schema/slide
                assoc-append slides schema/slide
              if (empty? slides)
                let
                    next-key $ key-after slides base-key
                  assoc slides next-key schema/slide
                assoc-after slides base-key schema/slide
    |app.main $ {}
      :ns $ quote
        ns app.main $ :require ("\"pixi.js" :as PIXI)
          phlox.core :refer $ render! clear-phlox-caches!
          app.comp.container :refer $ comp-container
          app.schema :as schema
          app.config :refer $ dev?
          "\"shortid" :as shortid
          app.updater :refer $ updater
          "\"fontfaceobserver-es" :as FontFaceObserver
          "\"./calcit.build-errors" :default build-errors
          "\"bottom-tip" :default hud!
      :defs $ {}
        |render-app! $ quote
          defn render-app! (? arg)
            render! (comp-container @*store) dispatch! $ or arg ({})
        |main! $ quote
          defn main! () (; js/console.log PIXI)
            if dev? $ load-console-formatter!
            -> (new FontFaceObserver/default "\"Josefin Sans") (.!load)
              .!then $ fn (event) (render-app!)
            add-watch *store :change $ fn (store prev) (render-app!)
            println "\"App Started"
        |*store $ quote (defatom *store schema/store)
        |dispatch! $ quote
          defn dispatch! (op op-data)
            when
              and dev? $ not= op :states
              println "\"dispatch!" op op-data
            let
                op-id $ shortid/generate
                op-time $ js/Date.now
              reset! *store $ updater @*store op op-data op-id op-time
        |reload! $ quote
          defn reload! () $ if (nil? build-errors)
            do (println "\"Code updated.") (clear-phlox-caches!) (remove-watch *store :change)
              add-watch *store :change $ fn (store prev) (render-app!)
              render-app!
              hud! "\"ok~" "\"Ok"
            hud! "\"error" build-errors
    |app.config $ {}
      :ns $ quote (ns app.config)
      :defs $ {}
        |dev? $ quote
          def dev? $ = "\"dev" (get-env "\"mode")
        |site $ quote
          def site $ {} (:dev-ui "\"http://localhost:8100/main.css") (:release-ui "\"http://cdn.tiye.me/favored-fonts/main.css") (:cdn-url "\"http://cdn.tiye.me/phlox/") (:title "\"Phlox") (:icon "\"http://cdn.tiye.me/logo/quamolit.png") (:storage-key "\"phlox")
