(ns sventechie.friendui-sql.storage
  (:require [sventechie.friendui-sql.db :as db]
            [de.sveri.friendui.globals :as f-glob])
  (:gen-class))


(defrecord FrienduiStorage [db-conn]
  f-glob/FrienduiStorage
  (account-activated? [this activation-id]
    (db/account-activated? db-conn activation-id))

  (activate-account [this activation-id]
    (db/activate-account db-conn activation-id))

  (create-user [this email password role activation-id]
    (db/create-new-user db-conn email password role activation-id))

  (get-all-users [this]
    (db/get-all-users db-conn))

  (get-user-for-activation-id [this id]
    (db/get-user-for-activation-id db-conn id))

  (update-user [this username data-map]
    (db/update-user db-conn username data-map))

  (username-exists? [this username]
    (db/username-exists? db-conn username))

  (get-loggedin-user-map [this]
    (db/get-loggedin-user-map db-conn))

  (get-old-pw-hash [this]
    (db/get-old-pw-hash db-conn))

  (change-password [this new-pw]
    (db/change-password db-conn new-pw)))
