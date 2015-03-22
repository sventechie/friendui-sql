(ns sventechie.friendui-sql.globals
  (:require [de.sveri.clojure.commons.files.edn :as commons]))

(def friendui-config-name "friendui-config.edn")
(def friendui-config (commons/from-edn friendui-config-name))

(def username-kw (:username-kw friendui-config))
(def pw-kw (:pw-kw friendui-config))
(def activated-kw (:activated-kw friendui-config))
(def role-kw (:role-kw friendui-config))
(def database (:database friendui-config))

(def activationid-kw :user/activationid)
