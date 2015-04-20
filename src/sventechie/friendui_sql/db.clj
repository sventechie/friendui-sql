(ns sventechie.friendui-sql.db
  (:require [sventechie.friendui-sql.globals :as glob]
            [sventechie.friendui-sql.queries :refer :all]
            [de.sveri.friendui.service.user :as friend-service]))

(defn role->string
  "Convert role keyword to string"
  [role]
  (clojure.string/replace (str role) #":" ""))

(defn string->role
  "Convert role string to role keyword"
  [raw-string]
  (if-let [role-string raw-string]
    (keyword
      (clojure.string/replace role-string #":" ""))
    :user/bogus-role))

(defn- format-user-map
  "Format user data according to Friend-UI spec"
  [result-map]
  (if-let [user-map result-map]
    (hash-map glob/activated-kw (:verified user-map)
              glob/role-kw (string->role (:role user-map))
              glob/username-kw (:email_address user-map)
              glob/pw-kw (:password user-map))
    {}))

(defn get-usermap-by-username
  [db-conn email-address & [pw]]
  (when-let [result (get-account-by-email-query {:email_address email-address
                                                 :db-conn db-conn})]
    (let [user-map (format-user-map (first result))]
      (if pw user-map (dissoc user-map glob/pw-kw)))))

(defn get-loggedin-user-map [db-conn]
  (get-usermap-by-username db-conn (friend-service/get-logged-in-username)))

(defn get-loggedin-user-role [db-conn]
  (glob/role-kw (get-loggedin-user-map db-conn)))

(defn login-user [db-conn email-address]
  (when-let [user-map (get-usermap-by-username db-conn email-address true)]
    (when (friend-service/is-user-activated? user-map)
      {:username email-address
       :roles #{(glob/role-kw user-map)}
       :password (glob/pw-kw user-map)})))


(defn account-activated?
  "Check if account has been activated"
  [db-conn activation-id]
  (:verified
   (first (check-account-active-query {:activation_id activation-id
                                       :db-conn db-conn}))))

(defn activate-account
  "Activate the account"
  [db-conn activation-id]
  (activate-account-query! {:activation_id activation-id
                            :db-conn db-conn}))

(defn create-new-user
  "Create a new account with email, pw, role and activation ID"
  [db-conn email-address password role activation-id]
  (create-account-query<! {:email_address email-address
                           :password password
                           :activation_id activation-id
                           :account_type (role->string role)
                           :db-conn db-conn}))

(defn get-all-users
  "Lists all accounts"
  [db-conn]
  (map format-user-map
    (list-all-accounts-query)))

(defn get-user-for-activation-id
  "Lookup user by activation ID"
  [db-conn activation-id]
  (let [account-map (first (get-account-by-activation-query {:activation_id activation-id
                                                             :db-conn db-conn}))]
    {:username (:email_address account-map)
     :roles #{(string->role (:role account-map))}}))

(defn update-user
  "Update user role and activation status"
  [db-conn email data-map]
  (update-account-query!
   {:email_addres email
    :activated (:user/activated data-map)
    :account_type (role->string (:user/role data-map))
    :db-conn db-conn}))

(defn username-exists?
  "Checks if account exists"
  [db-conn email-address]
  (some?
    (first
      (get-account-by-email-query {:email_address email-address
                                   :db-conn db-conn}))))

(defn get-old-pw-hash
  "Get current password hash"
  ([db-conn] (get-old-pw-hash db-conn (friend-service/get-logged-in-username)))
  ([db-conn email]
  (:password
   (first
    (get-password-query {:email_address email
                         :db-conn db-conn})))))

(defn change-password
  "Change password"
  ([db-conn new-password] (change-password db-conn (friend-service/get-logged-in-username) new-password))
  ([db-conn email-address new-password]
  (set-password-query! {:email_address email-address
                        :password new-password
                        :db-conn db-conn})))

(defn set-account-type
  "Set account type to :user/admin, :user/free, etc."
  [db-conn email-address account-type]
  (set-account-type-query! {:email_address email-address
                            :account_type account-type
                            :db-conn db-conn}))
