-- MySQL schema
--
-- Table structure for table `azn_account`
--

CREATE TABLE IF NOT EXISTS `azn_account` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(40) DEFAULT NULL,
  `email_address` varchar(160) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role_id` bigint(20) unsigned DEFAULT '2',
  `created_on` datetime NOT NULL,
  `verify_uuid` char(36) DEFAULT NULL,
  `verified` boolean DEFAULT '0',
  `last_signed_in_on` datetime DEFAULT NULL,
  `reset_uuid` char(36) DEFAULT NULL,
  `reset_sent_on` datetime DEFAULT NULL,
  `suspended` boolean DEFAULT '0',
  `suspension_reason` varchar(40) DEFAULT NULL,
  `force_reset_pass` boolean DEFAULT '0',
  `age_verified` char(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email_address` (`email_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC AUTO_INCREMENT=1 ;

Set default user role = admin
INSERT INTO `azn_account` (`id`, `role_id`, `email_address`, `created_on`, `password`, `verify_uuid`)
VALUES (1, 1, 'user@email.com', NOW(), UUID(), UUID());

-- --------------------------------------------------------

--
-- Table structure for table `azn_account_details`
--

CREATE TABLE IF NOT EXISTS `azn_account_details` (
  `account_id` bigint(20) unsigned NOT NULL,
  `first_name` varchar(80) DEFAULT NULL,
  `last_name` varchar(80) DEFAULT NULL,
  `country` char(2) DEFAULT NULL,
  `language` char(2) DEFAULT NULL,
  `timezone` varchar(40) DEFAULT NULL,
  `picture` varchar(240) DEFAULT NULL,
  PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------
--
-- Table structure for table `azn_login_providers`
--

CREATE TABLE IF NOT EXISTS `azn_login_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `provider` varchar(100) NOT NULL,
  `provider_uid` varchar(255) NOT NULL,
  `email_address` varchar(200) DEFAULT NULL,
  `display_name` varchar(150) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `profile_url` varchar(300) DEFAULT NULL,
  `website_url` varchar(300) DEFAULT NULL,
  `photo_url` varchar(300) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `provider_uid` (`provider_uid`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 ;

-- --------------------------------------------------------

--
-- Table structure for table `azn_acl_permission`
--

CREATE TABLE IF NOT EXISTS `azn_acl_permission` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(160) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suspended_on` datetime DEFAULT NULL,
  `is_system` boolean NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `key` (`key`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- data for table `azn_acl_permission`
INSERT INTO `azn_acl_permission` (`key`, `description`, `is_system`) VALUES
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

-- --------------------------------------------------------

--
-- Table structure for table `azn_acl_role`
--

CREATE TABLE IF NOT EXISTS `azn_acl_role` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(160) COLLATE utf8_unicode_ci DEFAULT NULL,
  `suspended_on` datetime DEFAULT NULL,
  `is_system` boolean NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- data for table `azn_acl_role`
INSERT INTO `azn_acl_role` (`name`, `description`, `is_system`) VALUES
('user/admin', 'Website Administrator', 1),
('user/free', 'Website user', 0);

-- --------------------------------------------------------

--
-- Table structure for table `azn_rel_account_permission`
--

CREATE TABLE IF NOT EXISTS `azn_rel_account_permission` (
  `account_id` bigint(20) unsigned NOT NULL,
  `permission_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`account_id`,`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



-- --------------------------------------------------------

--
-- Table structure for table `azn_rel_role_permission`
--

CREATE TABLE IF NOT EXISTS `azn_rel_role_permission` (
  `role_id` bigint(20) unsigned NOT NULL,
  `permission_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Giving the Admin role (1) all permissions
INSERT INTO `azn_rel_role_permission` (`role_id`, `permission_id`)
SELECT 1, `id` FROM `azn_acl_permission`;



