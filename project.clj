(defproject sventechie/friendui-sql "0.0.1-SNAPSHOT"
  :description "Implements friendui storage protocol for SQL DBMS: MySQL, PostgreSQL, etc."
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [de.sveri/clojure-commons "0.1.4"]
                 [org.clojure/java.jdbc "0.3.6"]
                 [korma "0.4.0"] ; db abstraction
                 [de.sveri/friendui "0.4.6"]]
  :profiles {:repl {:dependencies [[mysql/mysql-connector-java "5.1.34"]]}}
  :deploy-repositories [["clojars-self" {:url "https://clojars.org/repo"
                                         :sign-releases false}]])
