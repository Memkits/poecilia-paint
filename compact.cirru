
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
      :defs $ {}
        |comp-container $ quote
          defn comp-container (store)
            ; println "\"Store" store $ :tab store
            let
                cursor $ []
                states $ :states store
                slides $ :slides store
                pointer $ :slide-pointer store
              container ({})
                let
                    slide $ get slides pointer
                  if (nil? slide)
                    text $ {} (:text "\"No Slide")
                      :style $ {} (:font-size 60) (:font-weight 100)
                        :fill $ hslx 0 100 50
                        :font-family ui/font-fancy
                      :align :center
                    comp-slide (>> states pointer) pointer slide
                comp-slide-tabs (keys slides) pointer
                comp-button $ {} (:text "\"Add")
                  :position $ [] 100
                    - 20 $ * 0.5 js/window.innerHeight
                  :on-pointertap $ fn (e d!) (d! :add-slide-after pointer)
                comp-button $ {} (:text "\"Command")
                  :position $ [] 160
                    - 20 $ * 0.5 js/window.innerHeight
                  :on-pointertap $ fn (e d!) (d! :add-slide-after pointer)
                    request-text! e
                      {} (:placeholder "\"Command")
                        :style $ {} (:font-family ui/font-code)
                      fn (code)
                        println $ parse-cirru code
                        println "\"Store" store $ :tab store
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
                text $ {}
                  :text $ str "\"Something " slide
                  :style $ {} (:font-size 20)
                    :fill $ hslx 0 100 50
                    :font-family ui/font-fancy
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
                          + 300 $ * idx 32
                          &* 0.5 js/window.innerWidth
                        - 20 $ * 0.5 js/window.innerHeight
                      :fill $ if (= key pointer) (hslx 60 80 30)
                      :align-right? false
                      :on-pointertap $ fn (e d!) (; println "\"key" key) (d! :switch-slide key)
    |app.schema $ {}
      :ns $ quote (ns app.schema)
      :defs $ {}
        |store $ quote
          def store $ {}
            :states $ {}
              :cursor $ []
            :slide-pointer nil
            :slides $ do slide ({})
            :main-hint $ [] 10 10
            :secondary-hint $ [] 40 40
        |slide $ quote
          def slide $ {}
            :action-stamps $ do action-stamp ([])
            :tree $ {}
        |action-stamp $ quote
          def action-stamp $ {} (:op nil) (:snapshot nil)
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
              :switch-slide $ assoc store :slide-pointer op-data
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
