(ns zensols.nlserv.handler
  (:require [clojure.tools.logging :as log]
            [clojure.string :as s]
            [clojure.java.io :as io])
  (:require [compojure.route :as route]
            [compojure.handler :as handler]
            [compojure.core :refer (defroutes GET POST ANY)]
            [ring.adapter.jetty :as jetty]
            [ring.middleware.params :refer [wrap-params]])
  (:require [zensols.actioncli.log4j2 :as lu]
            [zensols.actioncli.parse :refer (with-exception)]
            [zensols.actioncli.dynamic :refer (defa-)]
            [zensols.nlparse.config :as conf])
  (:require [zensols.nlserv.service :as service]
            [serv.version :as ver]))

(defa- server-inst)

(def ^:dynamic *dump-jvm-on-error* true)

(defroutes main-routes
  (GET "/ver/:type" [type]
       (if (= "git" type)
         ver/gitref
         ver/version))
  (ANY "/parse"
       {params :params}
       (service/parse-utterance params)))

(def ^:private app
  (-> main-routes
      (wrap-params)))

(defn- run-server
  ([]
   (run-server 8080))
  ([port]
   (log/infof "starting server of port: %d" port)
   (swap! server-inst
          #(or %
               (let [options {:port port :join? false}]
                 (jetty/run-jetty (var app) options))))))

(def ^:private components-option
  ["-c" "--components" (format "A comma separated list of pipeline components")
   ;:default (conf/components-as-string)
   :required "TEXT"])

(def describe-component-command
  "CLI command to print component documentation."
  {:description "component documentation"
   :options []
   :app (fn [opts & args]
          (println (conf/print-component-documentation)))})

(def parse-command
  "CLI command to parse an utterance and return as a JSON string"
  {:description "parse an English utterance"
   :options
   [(lu/log-level-set-option)
    components-option
    ["-u" "--utterance" "The utterance to parse"
     :required "TEXT"
     :validate [#(> (count %) 0) "No utterance given"]]
    ["-p" "--pretty" "Pretty print the JSON string"]]
   :app (fn [{:keys [utterance components pretty] :as opts} & args]
          (with-exception
            (if (nil? utterance)
              (throw (ex-info "missing -u option" {:option "-u"})))
            (when components
              (->> (conf/create-context components)
                   service/set-parse-context))
            (println (service/parse utterance :pretty? pretty))))})

(def start-server-command
  {:description "start the agent parse website and service"
   :options
   [(lu/log-level-set-option)
    components-option
    ["-p" "--port PORT" "the port bind for web site/service"
     :default 8080
     :parse-fn #(Integer/parseInt %)
     :validate [#(< 0 % 0x10000) "Must be a number between 0 and 65536"]]]
   :app (fn [{:keys [components port]} & args]
          (when components
            (->> (conf/create-context components)
                 service/set-parse-context))
          (run-server port))})

;(run-server)
