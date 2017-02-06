(ns zensols.nlserv.core
  (:require [zensols.actioncli.parse :as cli]
            [zensols.actioncli.log4j2 :as lu])
  (:require [zensols.nlserv.version :as ver])
  (:gen-class :main true))

(def program-name "nlparse")

(defn- version-info-action []
  (println (format "%s (%s)" ver/version ver/gitref)))

(defn- create-action-context []
  (cli/multi-action-context
   '((:repl zensols.actioncli.repl repl-command)
     (:parse zensols.nlserv.handler parse-command)
     (:service zensols.nlserv.handler start-server-command)
     (:describe zensols.nlserv.handler describe-component-command))
   :version-option (cli/version-option version-info-action)))

(defn -main [& args]
  (lu/configure "nlp-serv-log4j2.xml")
  (cli/set-program-name program-name)
  (-> (create-action-context)
      (cli/process-arguments args)))
