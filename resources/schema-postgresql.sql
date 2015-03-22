-- PostgreSQL schema
-- Converted by https://github.com/lanyrd/mysql-postgresql-converter

START TRANSACTION;
SET standard_conforming_strings=off;
SET escape_string_warning=off;
SET CONSTRAINTS ALL DEFERRED;

CREATE TABLE "azn_account" (
    "id" bigint  NOT NULL,
    "username" varchar(80) DEFAULT NULL,
    "email_address" varchar(320) NOT NULL,
    "password" varchar(510) DEFAULT NULL,
    "role_id" bigint  DEFAULT '2',
    "created_on" timestamp with time zone NOT NULL,
    "verify_uuid" uuid DEFAULT NULL,
    "verified" int4 DEFAULT '0',
    "last_signed_in_on" timestamp with time zone DEFAULT NULL,
    "reset_uuid" uuid DEFAULT NULL,
    "reset_sent_on" timestamp with time zone DEFAULT NULL,
    "suspended" int4 DEFAULT '0',
    "suspension_reason" varchar(80) DEFAULT NULL,
    "force_reset_pass" int4 DEFAULT '0',
    "age_verified" char(1) DEFAULT '0',
    PRIMARY KEY ("id"),
    UNIQUE ("email_address"),
    UNIQUE ("username")
);

-- Set default user role = admin
INSERT INTO "azn_account" ("id", "role_id", "email_address", "created_on", "password", "verify_uuid")
VALUES (1, 1, 'user@email.com', NOW(), uuid_in(md5(now()::text)::cstring), uuid_in(md5(now()::text)::cstring));

CREATE TABLE "azn_account_details" (
    "account_id" bigint  NOT NULL,
    "first_name" varchar(160) DEFAULT NULL,
    "last_name" varchar(160) DEFAULT NULL,
    "country" char(2) DEFAULT NULL,
    "language" char(2) DEFAULT NULL,
    "timezone" varchar(80) DEFAULT NULL,
    "picture" varchar(480) DEFAULT NULL,
    PRIMARY KEY ("account_id")
);

CREATE TABLE "azn_acl_permission" (
    "id" bigint  NOT NULL,
    "key" varchar(160) NOT NULL,
    "description" varchar(320) DEFAULT NULL,
    "suspended_on" timestamp with time zone DEFAULT NULL,
    "is_system" int4 NOT NULL DEFAULT '0',
    PRIMARY KEY ("id")
);

-- data for table "azn_acl_permission"
INSERT INTO "azn_acl_permission" ("key", "description", "is_system") VALUES
('create_roles', 'Create new roles', 1),
('retrieve_roles', 'View existing roles', 1),
('update_roles', 'Update existing roles', 1),
('delete_roles', 'Delete existing roles', 1),
('create_permissions', 'Create new permissions', 1),
('retrieve_permissions', 'View existing permissions', 1),
('update_permissions', 'Update existing permissions', 1),
('delete_permissions', 'Delete existing permissions', 1),
('create_accounts', 'Create new accounts', 1),
('retrieve_accounts', 'View existing accounts', 1),
('update_accounts', 'Update existing accounts', 1),
('delete_accounts', 'Delete existing accounts', 1),
('ban_accounts', 'Ban and Unban existing accounts', 1),
('password_reset_accounts', 'Force user to reset password upon next login', 1);

CREATE TABLE "azn_acl_role" (
    "id" bigint  NOT NULL,
    "name" varchar(160) NOT NULL,
    "description" varchar(320) DEFAULT NULL,
    "suspended_on" timestamp with time zone DEFAULT NULL,
    "is_system" int4 NOT NULL DEFAULT '0',
    PRIMARY KEY ("id"),
    UNIQUE ("name")
);

-- data for table "azn_acl_role"
INSERT INTO "azn_acl_role" ("name", "description", "is_system") VALUES
('user/admin', 'Website Administrator', 1),
('user/free', 'Website user', 0);

CREATE TABLE "azn_login_providers" (
    "id" integer NOT NULL,
    "account_id" integer NOT NULL,
    "provider" varchar(200) NOT NULL,
    "provider_uid" varchar(510) NOT NULL,
    "email_address" varchar(400) DEFAULT NULL,
    "display_name" varchar(300) DEFAULT NULL,
    "first_name" varchar(200) DEFAULT NULL,
    "last_name" varchar(200) DEFAULT NULL,
    "profile_url" varchar(600) DEFAULT NULL,
    "website_url" varchar(600) DEFAULT NULL,
    "photo_url" varchar(600) DEFAULT NULL,
    "created_at" timestamp with time zone NOT NULL,
    PRIMARY KEY ("id"),
    UNIQUE ("provider_uid")
);

CREATE TABLE "azn_rel_account_permission" (
    "account_id" bigint  NOT NULL,
    "permission_id" bigint  NOT NULL,
    PRIMARY KEY ("account_id","permission_id")
);

CREATE TABLE "azn_rel_role_permission" (
    "role_id" bigint  NOT NULL,
    "permission_id" bigint  NOT NULL,
    PRIMARY KEY ("role_id","permission_id")
);

-- Giving the Admin role (1) all permissions
INSERT INTO "azn_rel_role_permission" ("role_id", "permission_id")
SELECT 1, "id" FROM "azn_acl_permission";

-- Post-data save --
COMMIT;
START TRANSACTION;

-- Typecasts --
ALTER TABLE "azn_account" ALTER COLUMN "verified" DROP DEFAULT, ALTER COLUMN "verified" TYPE boolean USING CAST("verified" as boolean);
ALTER TABLE "azn_account" ALTER COLUMN "suspended" DROP DEFAULT, ALTER COLUMN "suspended" TYPE boolean USING CAST("suspended" as boolean);
ALTER TABLE "azn_account" ALTER COLUMN "force_reset_pass" DROP DEFAULT, ALTER COLUMN "force_reset_pass" TYPE boolean USING CAST("force_reset_pass" as boolean);
ALTER TABLE "azn_acl_permission" ALTER COLUMN "is_system" DROP DEFAULT, ALTER COLUMN "is_system" TYPE boolean USING CAST("is_system" as boolean);
ALTER TABLE "azn_acl_role" ALTER COLUMN "is_system" DROP DEFAULT, ALTER COLUMN "is_system" TYPE boolean USING CAST("is_system" as boolean);

-- Foreign keys --

-- Sequences --
CREATE SEQUENCE azn_account_id_seq;
SELECT setval('azn_account_id_seq', max(id)) FROM azn_account;
ALTER TABLE "azn_account" ALTER COLUMN "id" SET DEFAULT nextval('azn_account_id_seq');
CREATE SEQUENCE azn_acl_permission_id_seq;
SELECT setval('azn_acl_permission_id_seq', max(id)) FROM azn_acl_permission;
ALTER TABLE "azn_acl_permission" ALTER COLUMN "id" SET DEFAULT nextval('azn_acl_permission_id_seq');
CREATE SEQUENCE azn_acl_role_id_seq;
SELECT setval('azn_acl_role_id_seq', max(id)) FROM azn_acl_role;
ALTER TABLE "azn_acl_role" ALTER COLUMN "id" SET DEFAULT nextval('azn_acl_role_id_seq');
CREATE SEQUENCE azn_login_providers_id_seq;
SELECT setval('azn_login_providers_id_seq', max(id)) FROM azn_login_providers;
ALTER TABLE "azn_login_providers" ALTER COLUMN "id" SET DEFAULT nextval('azn_login_providers_id_seq');

-- Full Text keys --

COMMIT;
