(ns sventechie.friendui-sql.queries
  (:require [korma.core :refer :all]
            [korma.db :refer [with-db]]))

(declare users user-details roles linked-oauth-accounts permissions)

(defentity users
  (pk :id)
  (table :azn_account)
  (belongs-to roles {:fk :role_id}))

(defentity user-details
  (pk :account_id)
  (table :azn_account_details)
  (belongs-to users {:fk :account_id}))

(defentity roles
  (pk :id)
  (table :azn_acl_role))

(defentity linked-oauth-accounts
  (pk :id)
  (table :azn_login_providers)
  (belongs-to users {:fk :account_id}))

(defentity permissions
  (pk :id)
  (table :azn_acl_permission))

;; SELECT verified
;; FROM azn_account
;; WHERE azn_account.verify_uuid = :activation_id
(defn check-account-active-query
  "Check if account is activated"
  [{:keys [db-conn activation_id]}]
  (with-db db-conn
    (select users
      (fields :verified)
      (where {:verify_uuid activation_id}))))

;; UPDATE azn_account
;; SET verified = true
;; WHERE azn_account.verify_uuid = :activation_id
(defn activate-account-query!
  "Make account active"
  [{:keys [db-conn activation_id]}]
  (with-db db-conn
    (update users
      (set-fields {:verified true})
      (where {:verify_uuid activation_id}))))

;; SELECT *
;; FROM azn_account
(defn list-accounts-query
  "List all users"
  [{:keys [db-conn]}]
  (with-db db-conn
   (sql-only
    (select users))))

;; SELECT verified, email_address, azn_acl_role.name AS role
;; FROM azn_account
;; JOIN azn_acl_role ON (azn_acl_role.id = azn_account.role_id)
(defn list-all-accounts-query
  "List all user-maps: email/activated/role"
  [{:keys [db-conn]}]
  (with-db db-conn
    (select users
      (with roles)
      (fields :verified :email_address [:azn_acl_role.name :role]))))

;; SELECT azn_account.*, azn_acl_role.name AS role
;; FROM azn_account
;; WHERE azn_account.email_address = :email_address
;; JOIN azn_acl_role ON (azn_acl_role.id = azn_account.role_id)
(defn get-account-by-email-query
  "Find user by email_address"
  [{:keys [db-conn email_address]}]
  (with-db db-conn
    (select users
      (with roles)
      (fields :verified :email_address :password [:azn_acl_role.name :role])
      (where {:email_address email_address}))))

;; SELECT azn_account.email_address, azn_acl_role.name AS role
;; FROM azn_account
;; JOIN azn_acl_role ON (azn_acl_role.id = azn_account.role_id)
;; WHERE azn_account.verify_uuid = :activation_id
(defn get-account-by-activation-query
  "Find user by activation_id"
  [{:keys [db-conn activation_id]}]
  (with-db db-conn
    (select users
      (with roles)
      (fields :verified :email_address [:azn_acl_role.name :role])
      (where {:verify_uuid activation_id}))))

;; INSERT INTO azn_account ( email_address, password, created_on, verified, verify_uuid, role_id )
;; VALUES ( :email_address, :password, NOW(), false, :activation_id,
;;         ( SELECT id FROM azn_acl_role WHERE name = :account_type ))
(defn create-account-query<!
  "Creates a user account and returns account_id or row"
  [{:keys [db-conn email_address password activation_id account_type]}]
  (with-db db-conn
    (insert users
      (values {:email_address email_address :password password :created_on (sqlfn now)
               :verified false :verify_uuid activation_id
               :role_id (subselect roles
                          (fields :id)
                          (where {:name account_type}))}))))

;;UPDATE azn_account
;;SET role_id = (SELECT id FROM azn_acl_role WHERE name = :account_type),
;;    verified = :activated
;;WHERE azn_account.email_address = :email_address
(defn update-account-query!
  "Updates user account by email, returns rows affected"
  [{:keys [db-conn email_address activated account_type]}]
  (with-db db-conn
    (update users
      (set-fields {:verified activated
                   :role_id (subselect roles
                              (fields :id)
                              (where {:name account_type}))})
      (where {:email_address email_address}))))

;;UPDATE azn_account
;;SET role_id = (SELECT id FROM azn_acl_role WHERE name = :account_type)
;;WHERE azn_account.email_address = :email_address
(defn set-account-type-query!
  "Sets user group/type"
  [{:keys [db-conn email_address account_type]}]
  (with-db db-conn
    (update users
      (set-fields {:role_id (subselect roles
                              (fields :id)
                              (where {:name account_type}))})
      (where {:email_address email_address}))))

;;SELECT password
;;FROM azn_account
;;WHERE azn_account.email_address = :email_address
(defn get-password-query
  "Find password by email_address"
  [{:keys [db-conn email_address]}]
  (with-db db-conn
    (select users
      (fields :password)
      (where {:email_address email_address}))))

;;UPDATE azn_account
;;SET password = :password
;;WHERE azn_account.email_address = :email_address
(defn set-password-query!
  "Change password"
  [{:keys [db-conn email_address password]}]
  (with-db db-conn
    (update users
      (set-fields {:password password})
      (where {:email_address email_address}))))
