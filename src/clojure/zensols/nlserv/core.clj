(ns zensols.nlserv.core
  (:require [zensols.actioncli.parse :as cli]
            [zensols.actioncli.log4j2 :as lu])
  (:require [serv.version])
  (:gen-class :main true))

(def program-name "nlparse")

(def ^:private version-info-command
  {:description "Get the version of the application."
   :options [["-g" "--gitref"]]
   :app (fn [{refp :gitref} & args]
          (println serv.version/version)
          (if refp (println serv.version/gitref)))})

(defn- create-command-context []
  {:command-defs '((:repl zensols.actioncli repl repl-command)
                   (:parse zensols.nlserv handler parse-command)
                   (:service zensols.nlserv handler start-server-command)
                   (:describe zensols.nlserv handler describe-component-command))
   :single-commands {:version version-info-command}})

(defn -main [& args]
  (lu/configure "nlp-serv-log4j2.xml")
  (cli/set-program-name program-name)
  (let [command-context (create-command-context)]
    (apply cli/process-arguments command-context args)))
