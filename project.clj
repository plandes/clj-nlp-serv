(defproject com.zensols.nlp/serv "0.1.0-SNAPSHOT"
  :description "A RESTful service that service NLP parsing requests."
  :url "https://github.com/plandes/RESTful NLP parse service"
  :license {:name "Apache License version 2.0"
            :url "https://www.apache.org/licenses/LICENSE-2.0"
            :distribution :repo}
  :plugins [[lein-codox "0.10.1"]
            [org.clojars.cvillecsteele/lein-git-version "1.2.7"]]
  :codox {:metadata {:doc/format :markdown}
          :project {:name "RESTful NLP parse service"}
          :output-path "target/doc/codox"
          :source-uri "https://github.com/plandes/clj-nlp-serv/blob/v{version}/{filepath}#L{line}"}
  :git-version {:root-ns "zensols.nlserv"
                :path "src/clojure/zensols/nlserv"
                :version-cmd "git describe --match v*.* --abbrev=4 --dirty=-dirty"}
  :source-paths ["src/clojure"]
  :java-source-paths ["src/java"]
  :javac-options ["-Xlint:unchecked"]
  :jar-exclusions [#".gitignore"]
  :exclusions [org.slf4j/slf4j-log4j12
               log4j/log4j
               ch.qos.logback/logback-classic]
  :dependencies [[org.clojure/clojure "1.8.0"]

                 ;; logging
                 [org.apache.logging.log4j/log4j-core "2.7"]
                 [org.apache.logging.log4j/log4j-slf4j-impl "2.7"]
                 [org.apache.logging.log4j/log4j-1.2-api "2.7"]
                 [org.apache.logging.log4j/log4j-jcl "2.7"]

                 ;; web services
                 [ring/ring-core "1.5.0"]
                 [ring/ring-jetty-adapter "1.5.0"]
                 [org.eclipse.jetty/jetty-server "9.2.10.v20150310"]
                 [compojure "1.5.1"]
                 [liberator "0.14.1"]

                 ;; json
                 [org.clojure/data.json "0.2.6"]

                 ;; command line
                 [com.zensols.nlp/parse "0.0.15"]]
  :pom-plugins [[org.codehaus.mojo/appassembler-maven-plugin "1.6"
                 {:configuration ([:programs
                                   [:program
                                    ([:mainClass "zensols.nlserv.core"]
                                     [:id "nlparse"])]]
                                  [:environmentSetupFileName "setupenv"])}]]
  :profiles {:uberjar {:aot [zensols.nlserv.core]}
             :appassem {:aot :all}
             :dev
             {:jvm-opts
              ["-Dlog4j.configurationFile=test-resources/log4j2.xml" "-Xms4g" "-Xmx12g" "-XX:+UseConcMarkSweepGC"]
              :dependencies [[com.zensols/clj-append "1.0.5"]]}}
  :main zensols.nlserv.core)
