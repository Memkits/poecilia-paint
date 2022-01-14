
{} (:package |app)
  :configs $ {} (:init-fn |app.main/main!) (:reload-fn |app.main/reload!)
    :modules $ [] |memof/ |lilac/ |respo.calcit/ |respo-ui.calcit/ |phlox/ |pointed-prompt/
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
                comp-slide (>> states pointer) (get slides pointer)
                comp-button $ {} (:text "\"Add")
                  :position $ [] 100
                    - 20 $ * 0.5 js/window.innerHeight
                  :on-pointertap $ fn (e d!) (println "\"Add slide")
                comp-button $ {} (:text "\"Command")
                  :position $ [] 160
                    - 20 $ * 0.5 js/window.innerHeight
                  :on-pointertap $ fn (e d!) (println "\"Add slide")
                    request-text! e
                      {} (:placeholder "\"Command")
                        :style $ {} (:font-family ui/font-code)
                      fn (code)
                        println $ parse-cirru code
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
          defn comp-slide (states slide)
            if (nil? slide)
              text $ {} (:text "\"no slide")
                :style $ {} (:font-size 20)
                  :fill $ hslx 0 100 50
                  :font-family ui/font-fancy
              text $ {} (:text "\"something")
                :style $ {} (:font-size 20)
                  :fill $ hslx 0 100 50
                  :font-family ui/font-fancy
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
            :actions $ []
            :tree $ {}
    |app.updater $ {}
      :ns $ quote
        ns app.updater $ :require
          [] phlox.cursor :refer $ [] update-states
      :defs $ {}
        |updater $ quote
          defn updater (store op op-data op-id op-time)
            case-default op
              do (println "\"unknown op" op op-data) store
              :states $ update-states store op-data
              :move-main-hint $ assoc store :main-hint op-data
              :move-secondary-hint $ assoc store :secondary-hint op-data
              :hydrate-storage op-data
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
