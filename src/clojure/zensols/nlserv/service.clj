(ns zensols.nlserv.service
  (:require [clojure.data.json :as json]
            [clojure.tools.logging :as log])
  (:require [liberator.core :refer [defresource]])
  (:require [zensols.actioncli.dynamic :as dyn])
  (:require [zensols.nlparse.config :as conf :refer (with-context)]
            [zensols.nlparse.parse :as p]))

(def ^:private utterance-param "utterance")

(def ^:private pretty-param "pretty")

(defonce ^:private parse-context-inst (atom (conf/create-context)))

(defn set-parse-context [parse-context]
  (log/debugf "setting parse context: <%s>" (pr-str parse-context))
  (reset! parse-context-inst parse-context))

(defn- parse-context []
  @parse-context-inst)

(defn reset []
  (set-parse-context (conf/create-context)))

(dyn/register-purge-fn reset)

(defn- is-malformed?
  "Make sure the [[utterance-param]] key is given in the request parameters."
  [params]
  (not (contains? params utterance-param)))

(defn parse
  "Parse an human language utterance and return the JSON string."
  [utterance & {:keys [pretty?]}]
  (log/debugf "parsing (pretty?=%s) <%s>" pretty? utterance)
  (with-context (parse-context)
    (->> (p/parse utterance)
         ((if pretty?
            (fn [panon]
              (with-out-str (json/pprint panon)))
            json/write-str)))))

(defn- handle-parse-utterance
  "Service the parse utterance endpoint."
  [params]
  (let [pretty? (get params pretty-param)]
    (log/infof "servicing request with parameter: <%s>" params)
    (-> (get params utterance-param)
        (parse :pretty? pretty?))))

(defresource parse-utterance [params]
  :available-media-types ["text/json"]
  :allowed-methods [:post :get]
  :malformed? (fn [context]
                (let [params (get-in context [:request :params])]
                  (or (empty? params)
                      (is-malformed? params))))
  :handle-ok (fn [ctx]
               (handle-parse-utterance params))
  :handle-created (fn [ctx]
                    (handle-parse-utterance params))
  :post! (fn [ctx]
           (handle-parse-utterance params))
  :handle-not-found "Not found")
