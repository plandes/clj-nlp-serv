(ns zensols.nlserv.handler
  (:require [clojure.tools.logging :as log])
  (:require [compojure.route :as route]
            [compojure.handler :as handler]
            [compojure.core :refer (defroutes GET POST ANY)]
            [ring.adapter.jetty :as jetty]
            [ring.middleware.params :refer [wrap-params]])
  (:require [zensols.actioncli.log4j2 :as lu]
            [zensols.actioncli.dynamic :refer (defa-)])
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

(defn- handle-exception
  "Handle exceptions thrown from CLI commands."
  [e]
  (if (instance? java.io.FileNotFoundException e)
    (binding [*out* *err*]
      (println (format "io error: %s" (.getMessage e))))
    (binding [*out* *err*]
      (println (format "error: %s"
                       (if ex-data
                         (.getMessage e)
                         (.toString e))))))
  (if *dump-jvm-on-error*
    (System/exit 1)
    (throw e)))

(def parse-command
  "CLI command to parse an utterance and return as a JSON string"
  {:description "parse an English utterance"
   :options
   [(lu/log-level-set-option)
    ["-u" "--utterance" "The utterance to parse"
     :required "TEXT"
     :validate [#(> (count %) 0) "No utterance given"]]
    ["-p" "--pretty" "Pretty print the JSON string"]]
   :app (fn [{:keys [utterance pretty] :as opts} & args]
          (try 
            (if (nil? utterance)
              (throw (ex-info "missing -u option"
                              {:option "-u"})))
            (println (service/parse utterance :pretty? pretty))
            (catch Exception e
              (handle-exception e))))})

(def start-server-command
  {:description "start the agent parse website and service" 
   :options [["-p" "--port PORT" "the port bind for web site/service"
              :default 8080
              :parse-fn #(Integer/parseInt %)
              :validate [#(< 0 % 0x10000) "Must be a number between 0 and 65536"]]]
   :app (fn [{:keys [port]} & args]
          (run-server port))})

;(run-server)
