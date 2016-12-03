(ns zensols.nlserv.service
  (:require [clojure.data.json :as json]
            [clojure.tools.logging :as log])
  (:require [liberator.core :refer [defresource]])
  (:require [zensols.nlparse.parse :as p]))

(def ^:private utterance-param "utterance")
(def ^:private pretty-param "pretty")

(defn- is-malformed? [params]
  (not (contains? params utterance-param)))

(defn parse [utterance & {:keys [pretty?]}]
  (->> (p/parse utterance)
       ((if pretty?
          (fn [panon]
            (with-out-str (json/pprint panon)))
          json/write-str))))

(defn- handle-parse-utterance [params]
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
