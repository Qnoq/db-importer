-- phpMyAdmin SQL Dump
-- version 4.9.11
-- https://www.phpmyadmin.net/
--
-- Hôte : db5018931408.hosting-data.io
-- Généré le : jeu. 06 nov. 2025 à 22:55
-- Version du serveur : 8.0.36
-- Version de PHP : 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `dbs14922760`
--

-- --------------------------------------------------------

--
-- Structure de la table `activity`
--

CREATE TABLE `activity` (
  `act_id` int NOT NULL,
  `par_id` int DEFAULT NULL,
  `act_code` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_active` tinyint(1) DEFAULT '1',
  `act_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int DEFAULT NULL,
  `act_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `act_deleted` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `act_correspondance` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_estAmountProQuo` double(8,2) DEFAULT NULL,
  `act_estAmountProReq` double(8,2) DEFAULT NULL,
  `act_travaux` tinyint UNSIGNED DEFAULT NULL,
  `act_type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_forPreventive` int NOT NULL DEFAULT '1',
  `act_forCurative` int NOT NULL DEFAULT '1',
  `act_codeWs` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT '',
  `act_equRequired` int NOT NULL DEFAULT '0',
  `act_nameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_namePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_namePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `act_nameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `activity_detail`
--

CREATE TABLE `activity_detail` (
  `actDet_id` bigint UNSIGNED NOT NULL,
  `act_id` int NOT NULL,
  `actDet_code` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `actDet_active` int NOT NULL DEFAULT '0',
  `actDet_createdDate` timestamp NULL DEFAULT NULL,
  `actDet_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `actDet_equipment` int DEFAULT '0',
  `actDet_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_estAmountProQuo` double(8,2) DEFAULT NULL,
  `actDet_estAmountProReq` double(8,2) DEFAULT NULL,
  `actDet_nameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_nameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_namePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_nameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_nameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_nameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_namePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_nameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `actDet_nameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `api_link`
--

CREATE TABLE `api_link` (
  `apiLin_id` bigint UNSIGNED NOT NULL,
  `apiLin_code` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `apiLin_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_type` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_apiAddress` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_apiKey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_ftpHost` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_ftpPort` int DEFAULT NULL,
  `apiLin_ftpUserName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_ftpPassword` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_ftpPrivateKey` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apiLin_ftpRoot` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `article`
--

CREATE TABLE `article` (
  `art_id` int NOT NULL,
  `art_code` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_active` tinyint(1) DEFAULT '1',
  `art_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `art_updatedDate` datetime DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `art_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_namePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_namePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `art_nameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `authorised_ip`
--

CREATE TABLE `authorised_ip` (
  `autIp_id` bigint UNSIGNED NOT NULL,
  `autIp_ipValue` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `autIp_active` int NOT NULL DEFAULT '0',
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `autIp_createdDate` timestamp NULL DEFAULT NULL,
  `autIp_updatedDate` timestamp NULL DEFAULT NULL,
  `autIp_email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `autIp_key` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `billingcompany`
--

CREATE TABLE `billingcompany` (
  `bil_id` int NOT NULL,
  `bil_numberCompta` varchar(7) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_socialReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_address1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cit_id` int DEFAULT NULL,
  `dep_id` int DEFAULT NULL,
  `reg_id` int DEFAULT NULL,
  `cou_id` int DEFAULT NULL,
  `bil_phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_fax` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tva_id` int DEFAULT NULL,
  `bil_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `bil_siret` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_tvaIntra` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payPer_id` int DEFAULT NULL,
  `bil_paymentPeriod` smallint DEFAULT NULL,
  `bil_active` tinyint(1) DEFAULT '1',
  `cus_id` int DEFAULT NULL,
  `bil_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `bil_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `bil_city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_zipCode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `bil_import` tinyint(1) DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `bil_deleted` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `sig_id` int DEFAULT NULL,
  `bil_correspondance` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `budget`
--

CREATE TABLE `budget` (
  `bud_id` bigint UNSIGNED NOT NULL,
  `bud_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bud_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `bud_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `bud_startDate` timestamp NULL DEFAULT NULL,
  `bud_endDate` timestamp NULL DEFAULT NULL,
  `bud_createdDate` timestamp NULL DEFAULT NULL,
  `bud_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `bud_curative` int NOT NULL DEFAULT '1',
  `bud_preventive` int NOT NULL DEFAULT '1',
  `bud_reglementaire` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `budget_capex`
--

CREATE TABLE `budget_capex` (
  `budCap_id` bigint UNSIGNED NOT NULL,
  `budCap_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `budCap_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sig_id` int NOT NULL,
  `budCap_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `budCap_year` int NOT NULL,
  `budCap_createdDate` timestamp NULL DEFAULT NULL,
  `budCap_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `budFam_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `budget_family`
--

CREATE TABLE `budget_family` (
  `budFam_id` bigint UNSIGNED NOT NULL,
  `budFam_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `budFam_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `budFam_active` tinyint(1) DEFAULT NULL,
  `budFam_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `budFam_createdDate` date DEFAULT NULL,
  `budFam_updatedDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `budget_opex`
--

CREATE TABLE `budget_opex` (
  `budOpe_id` bigint UNSIGNED NOT NULL,
  `budOpe_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `budOpe_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sig_id` int NOT NULL,
  `budOpe_main` int NOT NULL DEFAULT '0',
  `budOpe_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `budOpe_year` int NOT NULL,
  `budOpe_createdDate` timestamp NULL DEFAULT NULL,
  `budOpe_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `budFam_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `campaign`
--

CREATE TABLE `campaign` (
  `cam_id` bigint UNSIGNED NOT NULL,
  `cam_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cam_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cam_startedDate` date DEFAULT NULL,
  `cam_endDate` date DEFAULT NULL,
  `cam_completed` tinyint(1) DEFAULT '0',
  `cam_completedDate` date DEFAULT NULL,
  `cam_createdDate` date DEFAULT NULL,
  `cam_updatedDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sig_id` int DEFAULT NULL,
  `cam_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'I',
  `cam_filled` int NOT NULL DEFAULT '0',
  `cam_filledDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `campaign_sites`
--

CREATE TABLE `campaign_sites` (
  `camSit_id` bigint UNSIGNED NOT NULL,
  `cam_id` int NOT NULL,
  `sit_id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `camSit_createdDate` date DEFAULT NULL,
  `camSit_updatedDate` date DEFAULT NULL,
  `camSit_readed` int NOT NULL DEFAULT '0',
  `camSit_filled` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `checklist`
--

CREATE TABLE `checklist` (
  `che_id` bigint UNSIGNED NOT NULL,
  `che_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `checklist_element`
--

CREATE TABLE `checklist_element` (
  `cheEle_id` bigint UNSIGNED NOT NULL,
  `che_id` int NOT NULL,
  `cheEle_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cheEle_isFile` int NOT NULL DEFAULT '0',
  `cheEle_order` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `city`
--

CREATE TABLE `city` (
  `cit_id` int NOT NULL,
  `cit_name` varchar(30) DEFAULT NULL,
  `cit_zc` varchar(10) DEFAULT NULL,
  `dep_id` int DEFAULT NULL,
  `reg_id` int DEFAULT NULL,
  `cou_id` int DEFAULT NULL,
  `cit_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `cit_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `cit_deleted` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `contact`
--

CREATE TABLE `contact` (
  `con_id` bigint UNSIGNED NOT NULL,
  `con_firstname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_lastname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pro_id` int DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `con_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_fonction` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `con_cni` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_updatedDate` datetime DEFAULT NULL,
  `con_createdDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `contract`
--

CREATE TABLE `contract` (
  `con_id` int NOT NULL,
  `con_startDate` date DEFAULT NULL,
  `con_endDate` date DEFAULT NULL,
  `con_description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `con_deleted` tinyint(1) DEFAULT NULL,
  `con_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int NOT NULL,
  `con_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `con_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `con_refNumber` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `con_budget` double(8,2) DEFAULT NULL,
  `con_nbDiPrev` int DEFAULT NULL,
  `con_type` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'P',
  `con_typeContract` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'P',
  `con_showFilesSiteInterface` int DEFAULT '1',
  `con_showAllSitesInterface` int DEFAULT '0',
  `con_typeContratPeriod` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'C',
  `con_nbHeuresMax` double(8,2) DEFAULT NULL,
  `con_typePeriode` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_idInvoice` int DEFAULT NULL,
  `con_monitoring` int DEFAULT '1',
  `con_invoiceEstimate` int DEFAULT '0',
  `conFor_id` int DEFAULT NULL,
  `con_active` int DEFAULT '1',
  `con_suiviRapport` int DEFAULT NULL,
  `con_linkInvoiceDI` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `contract_file`
--

CREATE TABLE `contract_file` (
  `conFil_id` bigint UNSIGNED NOT NULL,
  `con_id` int NOT NULL,
  `conFil_description` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conFil_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conFil_oldName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conFil_ext` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conFil_createdDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `conFil_updatedDate` date DEFAULT NULL,
  `conFil_visibleProvider` int NOT NULL DEFAULT '1',
  `conFil_visibleSite` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `contract_formula`
--

CREATE TABLE `contract_formula` (
  `conFor_id` int UNSIGNED NOT NULL,
  `conFor_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conFor_formula` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conFor_createdDate` timestamp NOT NULL,
  `conFor_updatedDate` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `contract_invoice`
--

CREATE TABLE `contract_invoice` (
  `conInv_id` bigint UNSIGNED NOT NULL,
  `con_id` int NOT NULL,
  `conInv_description` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conInv_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conInv_oldName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conInv_ext` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `conInv_intNb` int NOT NULL DEFAULT '0',
  `conInv_intList` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `conInv_amountHt` double(8,2) NOT NULL DEFAULT '0.00',
  `conInv_amountTtc` double(8,2) NOT NULL DEFAULT '0.00',
  `conInv_createdDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `conInv_updatedDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `contract_provider`
--

CREATE TABLE `contract_provider` (
  `conPro_id` int UNSIGNED NOT NULL,
  `con_id` int NOT NULL,
  `pro_id` int NOT NULL,
  `sig_id` int DEFAULT NULL,
  `conPro_sitids` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conPro_periodicity` enum('H','M','T','S','A') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conPro_createdDate` timestamp NOT NULL,
  `conPro_updatedDate` timestamp NOT NULL,
  `conPro_invPeriodicity` enum('H','M','T','S','A') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `conPro_totalAmount` double DEFAULT NULL,
  `conPro_estimatedInvAmount` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `country`
--

CREATE TABLE `country` (
  `cou_id` int NOT NULL,
  `cou_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `cou_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `cou_indicative` smallint NOT NULL,
  `cou_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int NOT NULL,
  `com_idUpdater` int NOT NULL,
  `cou_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int NOT NULL,
  `com_idCreator` int NOT NULL,
  `cou_deleted` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `currency`
--

CREATE TABLE `currency` (
  `cur_id` int UNSIGNED NOT NULL,
  `cur_code` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cur_nameFr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cur_active` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `currency_rate`
--

CREATE TABLE `currency_rate` (
  `curRat_id` int UNSIGNED NOT NULL,
  `cur_code` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `curRat_date` date NOT NULL,
  `curRat_rate` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `customer`
--

CREATE TABLE `customer` (
  `cus_id` int NOT NULL,
  `cus_socialReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cus_address1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cus_address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cit_id` int DEFAULT NULL,
  `cou_id` int DEFAULT NULL,
  `cus_phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cus_mobile` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cus_fax` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cus_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `cus_active` tinyint(1) DEFAULT '1',
  `cus_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `cus_updatedDate` datetime DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `cus_import` tinyint(1) DEFAULT NULL,
  `cus_city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cus_zipCode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `cus_deleted` tinyint(1) DEFAULT NULL,
  `cus_logo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `delais_devis`
--

CREATE TABLE `delais_devis` (
  `proQuo_id` int DEFAULT NULL,
  `pro_id` int DEFAULT NULL,
  `proQuo_requestDate` date DEFAULT NULL,
  `proQuo_desiredDateReturn` date DEFAULT NULL,
  `proQuo_realDateReturn` date DEFAULT NULL,
  `proQuo_validatedDate` datetime DEFAULT NULL,
  `delai_retour` int DEFAULT NULL,
  `delai_retour_souhait` int DEFAULT NULL,
  `delai_validation` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `delais_interventions`
--

CREATE TABLE `delais_interventions` (
  `int_id` int DEFAULT NULL,
  `int_createdDate` datetime DEFAULT NULL,
  `annee` varchar(4) DEFAULT NULL,
  `mois` varchar(2) DEFAULT NULL,
  `jour` varchar(2) DEFAULT NULL,
  `delai_planif` int DEFAULT NULL,
  `delai_achev_planif` int DEFAULT NULL,
  `delai_ach` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `department`
--

CREATE TABLE `department` (
  `dep_id` bigint UNSIGNED NOT NULL,
  `dep_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dep_managerName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dep_informations` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `dep_updatedDate` datetime DEFAULT NULL,
  `dep_createdDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `department_activities`
--

CREATE TABLE `department_activities` (
  `depAct_id` bigint UNSIGNED NOT NULL,
  `dep_id` int DEFAULT NULL,
  `act_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `divers`
--

CREATE TABLE `divers` (
  `div_id` int NOT NULL,
  `div_order` tinyint DEFAULT NULL,
  `div_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `div_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `div_texteFr` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `div_texteEn` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `div_active` tinyint(1) DEFAULT '1',
  `div_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `div_defaut` tinyint(1) DEFAULT NULL,
  `div_value` int DEFAULT NULL,
  `div_updatedDate` datetime DEFAULT NULL,
  `div_createdDate` datetime DEFAULT NULL,
  `div_color` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `div_nameDa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_texteDa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_nameDe` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_texteDe` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_nameEs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_texteEs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_nameIt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_texteIt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_nameNl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_texteNl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_nameNo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_texteNo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_namePl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_textePl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_namePt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_textePt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_nameSv` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `div_texteSv` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dynfields`
--

CREATE TABLE `dynfields` (
  `dyn_id` bigint UNSIGNED NOT NULL,
  `dyn_table` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_field` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_datatype` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_size` int DEFAULT NULL,
  `dyn_helpMessage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_required` int DEFAULT '0',
  `dyn_uppercase` int DEFAULT '0',
  `dyn_listValuesType` int DEFAULT '0',
  `dyn_order` int DEFAULT '1',
  `dyn_colMd` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_blocCard` int DEFAULT '0',
  `dyn_blocCardname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_listValues` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dyn_editbySite` int NOT NULL DEFAULT '0',
  `dyn_forCampaign` int NOT NULL DEFAULT '0',
  `cam_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dynfields_list_values`
--

CREATE TABLE `dynfields_list_values` (
  `dynLisVal_id` bigint UNSIGNED NOT NULL,
  `dyn_id` int NOT NULL,
  `dynLisVal_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `dynfields_site`
--

CREATE TABLE `dynfields_site` (
  `sit_id` int NOT NULL,
  `sit_dirRegion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sit_respRegion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipement_space_repartition`
--

CREATE TABLE `equipement_space_repartition` (
  `equSpa_id` bigint UNSIGNED NOT NULL,
  `equ_id` int NOT NULL,
  `spa_id` int NOT NULL,
  `equSpaRep_percent` double(8,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipments`
--

CREATE TABLE `equipments` (
  `equ_id` bigint UNSIGNED NOT NULL,
  `equ_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_mark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFam_id` int DEFAULT NULL,
  `equ_type` tinyint(1) DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `act_id` int DEFAULT NULL,
  `actDet_id` int DEFAULT NULL,
  `equ_stock` int DEFAULT NULL,
  `equ_serialNumber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_internalNumber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_nextActionDate` date DEFAULT NULL,
  `equ_endGuaranteeDate` date DEFAULT NULL,
  `equ_entrepot` tinyint DEFAULT NULL,
  `equ_installDate` timestamp NULL DEFAULT NULL,
  `equ_barCode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_buyPriceHt` decimal(11,2) DEFAULT NULL,
  `equ_providerName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_proIdInstaller` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_id` int DEFAULT NULL,
  `equ_createdDate` timestamp NULL DEFAULT NULL,
  `equ_updatedDate` timestamp NULL DEFAULT NULL,
  `equ_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `equ_reference` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_qrcode_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitEnt_id` int DEFAULT NULL,
  `equ_place` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equLoc_id` int DEFAULT NULL,
  `equ_numImmo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_typeGaz` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_importId` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipments_logs`
--

CREATE TABLE `equipments_logs` (
  `equLog_id` bigint UNSIGNED NOT NULL,
  `equ_id` int DEFAULT NULL,
  `equLog_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equLog_texte` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equLog_createdDate` timestamp NULL DEFAULT NULL,
  `equLog_updatedDate` timestamp NULL DEFAULT NULL,
  `equLog_deletedDate` timestamp NULL DEFAULT NULL,
  `use_id` int DEFAULT NULL,
  `equLog_deleted` int DEFAULT '0',
  `equ_status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipments_temp`
--

CREATE TABLE `equipments_temp` (
  `equ_id` bigint UNSIGNED NOT NULL DEFAULT '0',
  `equ_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_mark` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFam_id` int DEFAULT NULL,
  `equ_type` tinyint(1) DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `act_id` int DEFAULT NULL,
  `actDet_id` int DEFAULT NULL,
  `equ_stock` int DEFAULT NULL,
  `equ_serialNumber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_internalNumber` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_nextActionDate` date DEFAULT NULL,
  `equ_endGuaranteeDate` date DEFAULT NULL,
  `equ_entrepot` tinyint DEFAULT NULL,
  `equ_installDate` timestamp NULL DEFAULT NULL,
  `equ_barCode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_buyPriceHt` decimal(11,2) DEFAULT NULL,
  `equ_providerName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_proIdInstaller` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `con_id` int DEFAULT NULL,
  `equ_createdDate` timestamp NULL DEFAULT NULL,
  `equ_updatedDate` timestamp NULL DEFAULT NULL,
  `equ_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `equ_reference` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_qrcode_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitEnt_id` int DEFAULT NULL,
  `equ_place` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equLoc_id` int DEFAULT NULL,
  `equ_numImmo` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_typeGaz` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equ_importId` int DEFAULT NULL,
  `importer` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipment_family`
--

CREATE TABLE `equipment_family` (
  `equFam_id` bigint UNSIGNED NOT NULL,
  `act_id` int NOT NULL,
  `actDet_id` int DEFAULT NULL,
  `equFam_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `equFam_mark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFam_reference` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFam_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `equFam_createdDate` timestamp NULL DEFAULT NULL,
  `equFam_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `equFam_status` char(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFam_category` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFam_type` tinyint(1) DEFAULT NULL,
  `equFam_filepath` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFam_information` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipment_family_files`
--

CREATE TABLE `equipment_family_files` (
  `equFamFil_id` bigint UNSIGNED NOT NULL,
  `equFam_id` int NOT NULL,
  `equFamFil_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFamFil_oldName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFamFil_ext` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFamFil_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFamFil_createdDate` timestamp NULL DEFAULT NULL,
  `equFamFil_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `equFamFil_deleted` int NOT NULL DEFAULT '0',
  `cat_id` int DEFAULT NULL,
  `equFamFil_principal` tinyint(1) DEFAULT '0',
  `equFamFil_notice` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipment_file`
--

CREATE TABLE `equipment_file` (
  `equFil_id` bigint UNSIGNED NOT NULL,
  `equ_id` int NOT NULL,
  `equFil_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFil_oldName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFil_ext` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFil_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `equFil_createdDate` timestamp NULL DEFAULT NULL,
  `equFil_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `equFil_deleted` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `equipment_localisation`
--

CREATE TABLE `equipment_localisation` (
  `equLoc_id` bigint UNSIGNED NOT NULL,
  `equLoc_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `par_id` int DEFAULT NULL,
  `equLoc_withoutParent` tinyint(1) DEFAULT '0',
  `equLoc_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `equLoc_updatedDate` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `events`
--

CREATE TABLE `events` (
  `eve_id` bigint UNSIGNED NOT NULL,
  `OwnCon_id` int NOT NULL,
  `eve_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `eve_date` date DEFAULT NULL,
  `eve_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eve_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `eve_createdDate` date DEFAULT NULL,
  `eve_updatedDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `factures_mensuelles_curr`
--

CREATE TABLE `factures_mensuelles_curr` (
  `mois` varchar(7) DEFAULT NULL,
  `montant` decimal(32,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `factures_mensuelles_prev`
--

CREATE TABLE `factures_mensuelles_prev` (
  `mois` varchar(7) DEFAULT NULL,
  `montant` decimal(32,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `import_contract_data`
--

CREATE TABLE `import_contract_data` (
  `id` int UNSIGNED NOT NULL,
  `num_ligne` int DEFAULT '0',
  `sig_id` int DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `sit_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sit_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sta_id` int DEFAULT '0',
  `int_otherReference` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_conStartDate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_conEndDate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_planningDate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_realDate` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_amount` double DEFAULT NULL,
  `import` int DEFAULT '0',
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_type` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_statut` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `import_data`
--

CREATE TABLE `import_data` (
  `id` bigint UNSIGNED NOT NULL,
  `code_import` int NOT NULL,
  `line_value` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `import_proinv`
--

CREATE TABLE `import_proinv` (
  `id` bigint UNSIGNED NOT NULL,
  `id_import` int NOT NULL DEFAULT '0',
  `proReq_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `proInv_amountHT` double(8,2) DEFAULT NULL,
  `proInv_amountTTC` double(8,2) DEFAULT NULL,
  `provider_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `staImp_id` int NOT NULL DEFAULT '0',
  `importable` int NOT NULL DEFAULT '0',
  `proInv_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `intervention`
--

CREATE TABLE `intervention` (
  `int_id` int NOT NULL,
  `int_nextId` int DEFAULT NULL,
  `int_number` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_id` int DEFAULT NULL,
  `cus_id` int DEFAULT NULL,
  `sig_id` int DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `bil_id` int DEFAULT NULL,
  `act_id` int DEFAULT NULL,
  `int_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_desiredPlanningDate` date DEFAULT NULL,
  `int_achievementDate` date DEFAULT NULL,
  `int_closingDate` date DEFAULT NULL,
  `int_description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `int_urgency` int DEFAULT '0',
  `int_complex` int DEFAULT '0',
  `int_astreinte` int DEFAULT '0',
  `int_updatedDate` datetime DEFAULT NULL,
  `int_createdDate` datetime DEFAULT NULL,
  `int_estimatedRate` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idAssigned` int DEFAULT NULL,
  `int_deleted` int DEFAULT '0',
  `con_id` int DEFAULT NULL,
  `pro_idAssigned` int DEFAULT NULL,
  `int_type` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `int_amountHT` double DEFAULT NULL,
  `int_planningDate` date DEFAULT NULL,
  `int_prevId` int DEFAULT NULL,
  `sitCon_id` int DEFAULT NULL,
  `actDet_id` int DEFAULT NULL,
  `int_closed` int NOT NULL DEFAULT '0',
  `int_refused` int NOT NULL DEFAULT '0',
  `int_linkKey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_datePossible` date DEFAULT NULL,
  `int_dateLater` date DEFAULT NULL,
  `bud_id` int DEFAULT NULL,
  `int_imported` int NOT NULL DEFAULT '0',
  `int_importNumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `gcalendarEventId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_startPlanningHour` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_endPlanningHour` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_estimatedAmount` double(8,2) NOT NULL DEFAULT '0.00',
  `int_sumProQuo` double DEFAULT '0',
  `int_sumProInv` double DEFAULT '0',
  `int_budType` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'OPEX',
  `int_budYear` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_signInvoice` tinyint(1) DEFAULT '0',
  `int_signInvoiceTxt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `wor_id` int DEFAULT NULL,
  `int_otherReference` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_signInvoiceDate` date DEFAULT NULL,
  `int_signInvoiceAmount` decimal(10,2) DEFAULT NULL,
  `int_nbHeures` double(8,2) DEFAULT NULL,
  `int_conStartDate` date DEFAULT NULL,
  `int_conEndDate` date DEFAULT NULL,
  `conInv_id` int DEFAULT NULL,
  `budFam_id` int DEFAULT NULL,
  `sitEnt_id` int DEFAULT NULL,
  `int_contactSite` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_coordSite` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_planningHour` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilBi_id` int DEFAULT NULL,
  `int_linkKey_binumeric` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_idAgentAssigned` int DEFAULT NULL,
  `bc_numDpai` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `webInt_key` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_techIds` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_bi_tech`
--

CREATE TABLE `intervention_bi_tech` (
  `intBiTec_id` bigint UNSIGNED NOT NULL,
  `intBiTec_techName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_id` int NOT NULL DEFAULT '0',
  `intBiTec_job` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `intBiTec_equipment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `intBiTec_nbPeople` int NOT NULL DEFAULT '1',
  `intBiTec_siteComment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `intBiTec_nameSignataire` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `intBiTec_validated` int NOT NULL DEFAULT '0',
  `intBiTec_validatedTime` datetime DEFAULT NULL,
  `intBiTec_date` datetime DEFAULT NULL,
  `intBiTec_dateTech` datetime DEFAULT NULL,
  `intBiTec_step` int DEFAULT '0',
  `intBiTec_filesTech` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `intBiTec_techComment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `intBiTec_spentTimeHours` int DEFAULT NULL,
  `intBiTec_spentTimeMn` int DEFAULT NULL,
  `intFil_idTampon` int DEFAULT '0',
  `intFil_idSignature` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_equipment`
--

CREATE TABLE `intervention_equipment` (
  `intEqu_id` bigint UNSIGNED NOT NULL,
  `int_id` int NOT NULL,
  `intEqu_comment` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `equSit_id` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_file`
--

CREATE TABLE `intervention_file` (
  `intFil_id` smallint NOT NULL,
  `int_id` int DEFAULT '0',
  `intFil_name` varchar(255) DEFAULT '',
  `intFil_oldName` varchar(255) DEFAULT '',
  `intFil_ext` varchar(4) DEFAULT NULL,
  `cat_id` int DEFAULT '0',
  `intFil_visibleProvider` int DEFAULT '1',
  `intFil_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `intFil_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `intFil_deleted` tinyint(1) DEFAULT NULL,
  `intFil_description` varchar(255) DEFAULT NULL,
  `intFil_size` int DEFAULT NULL,
  `intFil_visibleSite` int NOT NULL DEFAULT '1',
  `intFil_statutRapport` int DEFAULT NULL,
  `intFil_rapportTreated` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_file_category`
--

CREATE TABLE `intervention_file_category` (
  `intFilCat_id` bigint UNSIGNED NOT NULL,
  `intFilCat_order` int NOT NULL DEFAULT '1',
  `intFilCat_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `intFilCat_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_active` int DEFAULT '1',
  `intFilCat_updatedDate` datetime DEFAULT NULL,
  `intFilCat_createdDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `intFilCat_valParam` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_correspondance` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_forDi` int NOT NULL DEFAULT '1',
  `intFilCat_forSite` int NOT NULL DEFAULT '1',
  `intFilCat_forSign` int NOT NULL DEFAULT '1',
  `intFilCat_forSiteContracts` int DEFAULT '1',
  `intFilCat_forWorksites` int DEFAULT '1',
  `intFilCat_forLinkInfosDi` int NOT NULL DEFAULT '0',
  `intFilCat_forDiSites` int NOT NULL DEFAULT '0',
  `intFilCat_StaAnomalie` int DEFAULT '0',
  `intFilCat_nameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_nameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_namePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_nameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_nameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_nameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_namePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_nameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intFilCat_nameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_log`
--

CREATE TABLE `intervention_log` (
  `intLog_id` int NOT NULL,
  `int_id` int DEFAULT NULL,
  `intLog_type` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intLog_texte` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `use_id` int DEFAULT NULL,
  `intLog_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `intLog_deleted` tinyint(1) DEFAULT '0',
  `sta_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_message`
--

CREATE TABLE `intervention_message` (
  `intMes_id` int NOT NULL,
  `use_id` int DEFAULT NULL,
  `intMes_private` tinyint(1) DEFAULT NULL,
  `intMes_to` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `intMes_moreAddresses` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `intMes_object` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `intMes_texte` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `int_id` int DEFAULT NULL,
  `intMes_updatedDate` datetime DEFAULT NULL,
  `intMes_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idUpdater` int DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `intMes_deleted` tinyint(1) DEFAULT '0',
  `intMes_visProvider` int NOT NULL DEFAULT '0',
  `intMes_visSite` int NOT NULL DEFAULT '0',
  `proQuo_id` int DEFAULT NULL,
  `original_proQuo_message_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_message_link_file`
--

CREATE TABLE `intervention_message_link_file` (
  `intMesLinFil_id` int NOT NULL,
  `intMes_id` int DEFAULT NULL,
  `intFil_id` int DEFAULT NULL,
  `intMesLinFil_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `intMesLinFil_deleted` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `payload` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `langue`
--

CREATE TABLE `langue` (
  `lan_id` smallint UNSIGNED NOT NULL,
  `lan_name` varchar(50) NOT NULL DEFAULT '',
  `lan_abbr` varchar(5) NOT NULL DEFAULT '',
  `lan_picto` varchar(255) NOT NULL DEFAULT '',
  `lan_active` tinyint(1) NOT NULL DEFAULT '1',
  `lan_default` tinyint(1) DEFAULT NULL,
  `lan_nameFr` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameEn` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameDa` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameDe` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameEs` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameIt` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameNl` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameNo` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_namePl` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_namePt` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lan_nameSv` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Structure de la table `langue_traduction`
--

CREATE TABLE `langue_traduction` (
  `lanTra_id` bigint UNSIGNED NOT NULL,
  `lanTra_fr` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `lanTra_en` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_da` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_de` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_es` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_it` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_nl` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_no` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_pl` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_pt` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lanTra_sv` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `merchandising`
--

CREATE TABLE `merchandising` (
  `mer_id` bigint UNSIGNED NOT NULL,
  `mer_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mer_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `mer_startDate` date DEFAULT NULL,
  `mer_endDate` date DEFAULT NULL,
  `mer_createdDate` timestamp NULL DEFAULT NULL,
  `mer_updatedDate` timestamp NULL DEFAULT NULL,
  `mer_relanceCount` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `merchandising_photos`
--

CREATE TABLE `merchandising_photos` (
  `merPho_id` bigint UNSIGNED NOT NULL,
  `merPho_previous_id` int DEFAULT NULL,
  `merPho_version` int NOT NULL DEFAULT '1',
  `merPho_is_latest` tinyint(1) NOT NULL DEFAULT '1',
  `mer_id` int DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `use_id` int DEFAULT NULL,
  `merSta_id` int DEFAULT NULL,
  `merPho_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `merPho_score_quality` decimal(2,1) DEFAULT NULL,
  `merPho_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `merPho_missing_elements` tinyint(1) DEFAULT '0',
  `merPho_missing_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `merPho_createdDate` timestamp NULL DEFAULT NULL,
  `merPho_updatedDate` timestamp NULL DEFAULT NULL,
  `merPho_isAuto` tinyint DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `merchandising_sites`
--

CREATE TABLE `merchandising_sites` (
  `merSit_id` bigint UNSIGNED NOT NULL,
  `mer_id` int DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `merSit_createdDate` timestamp NULL DEFAULT NULL,
  `merSit_updatedDate` timestamp NULL DEFAULT NULL,
  `merSit_score_timing` decimal(2,1) DEFAULT NULL,
  `merSit_relanceCount` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `merchandising_status`
--

CREATE TABLE `merchandising_status` (
  `merSta_id` bigint UNSIGNED NOT NULL,
  `merSta_label` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `merSta_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `merSta_order` int DEFAULT NULL,
  `merSta_active` tinyint(1) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `model_has_permissions`
--

CREATE TABLE `model_has_permissions` (
  `permission_id` bigint UNSIGNED NOT NULL,
  `model_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `model_id` bigint UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `model_has_roles`
--

CREATE TABLE `model_has_roles` (
  `role_id` bigint UNSIGNED NOT NULL,
  `model_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `model_id` bigint UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

CREATE TABLE `notifications` (
  `id` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `notifiable_type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `notifiable_id` bigint UNSIGNED NOT NULL,
  `data` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `notifications_user`
--

CREATE TABLE `notifications_user` (
  `use_id` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `create_user` int NOT NULL DEFAULT '0',
  `add_proQuo_presta` int NOT NULL DEFAULT '0',
  `int_planification_presta` int NOT NULL DEFAULT '0',
  `int_realisation_presta` int NOT NULL DEFAULT '0',
  `add_int_site` int NOT NULL DEFAULT '0',
  `add_int_message` int NOT NULL DEFAULT '0',
  `receive_site_mail` int NOT NULL DEFAULT '0',
  `receive_provider_mail` int NOT NULL DEFAULT '0',
  `add_merch_site` int NOT NULL DEFAULT '0',
  `relance_merch_site` int NOT NULL DEFAULT '0',
  `comment_merch_site` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `operation_log`
--

CREATE TABLE `operation_log` (
  `opeLog_id` bigint UNSIGNED NOT NULL,
  `opeLog_table` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opeLog_tableId` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opeLog_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `opeLog_texte` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `use_id` int DEFAULT NULL,
  `opeLog_createdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `owner`
--

CREATE TABLE `owner` (
  `own_id` bigint UNSIGNED NOT NULL,
  `own_type` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `own_numberCompta` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `own_socialReason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `own_address1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `own_address2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `own_zipCode` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `own_city` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cou_id` int DEFAULT NULL,
  `own_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `own_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tva_id` int DEFAULT NULL,
  `own_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `own_createdDate` timestamp NULL DEFAULT NULL,
  `own_updatedDate` timestamp NULL DEFAULT NULL,
  `own_active` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `owner_contract`
--

CREATE TABLE `owner_contract` (
  `ownCon_id` bigint UNSIGNED NOT NULL,
  `ownCon_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sig_id` int NOT NULL,
  `sit_id` int NOT NULL,
  `ownCon_date` date DEFAULT NULL,
  `ownCon_startDate` date DEFAULT NULL,
  `ownCon_endDate` date DEFAULT NULL,
  `ind_id` int DEFAULT NULL,
  `ownCon_exo` int NOT NULL DEFAULT '0',
  `sec_id` int DEFAULT NULL,
  `ownCon_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ownCon_position` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ownCon_idPart1` int NOT NULL,
  `ownCon_idPart2` int NOT NULL,
  `ownCon_unlimited` int DEFAULT '0',
  `ownCon_surface` double(8,2) DEFAULT '0.00',
  `ownCon_nbYearsStrict` int DEFAULT '0',
  `ownCon_noticePeriod` int DEFAULT '0',
  `ownCon_signBailDate` date DEFAULT NULL,
  `ownCon_madLocalDate` date DEFAULT NULL,
  `ownCon_worksConfPreneur` int DEFAULT '0',
  `ownCon_worksListPreneur` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ownCon_renoncRecours` int DEFAULT '0',
  `ownCon_rembAssurance` int DEFAULT '0',
  `ownCon_sessionGaranty` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ownCon_bailEndPromise` int DEFAULT '0',
  `ownCon_tacRecond` int DEFAULT '0',
  `ownCon_parking` int DEFAULT '0',
  `ownCon_parquingExpl` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownCon_quaiLivr` int DEFAULT '0',
  `ownCon_quaiLivExpl` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownCon_compactZone` int DEFAULT '0',
  `ownCon_dateFirstRentIndex` date DEFAULT NULL,
  `ownCon_rentBaseValue` decimal(10,2) DEFAULT NULL,
  `ownCon_rentLimitValue` decimal(10,2) DEFAULT NULL,
  `ownCon_rentFrequence` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'M',
  `ownCon_rentTermType` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'ECHOIR',
  `ownCon_rentPaiementMode` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownCon_rentTva` int DEFAULT '0',
  `ownCon_foncTaxValue` decimal(10,2) DEFAULT NULL,
  `ownCon_foncTaxMonth` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '01',
  `ownCon_foncTaxApplDate` date DEFAULT NULL,
  `ownCon_baseIlc` decimal(10,2) DEFAULT NULL,
  `ownCon_revType` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownCon_inprogressRentValue` decimal(10,2) DEFAULT NULL,
  `ownCon_active` int NOT NULL DEFAULT '1',
  `sitEnt_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `owner_contract_file`
--

CREATE TABLE `owner_contract_file` (
  `ownConFil_id` bigint UNSIGNED NOT NULL,
  `ownCon_id` int NOT NULL,
  `ownConFil_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownConFil_oldName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownConFil_ext` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cat_id` int NOT NULL,
  `ownConFil_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownConFil_createdDate` date DEFAULT NULL,
  `ownConFil_updatedDate` date DEFAULT NULL,
  `use_idCreator` int NOT NULL,
  `use_idUpdater` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `owner_file`
--

CREATE TABLE `owner_file` (
  `ownFil_id` bigint UNSIGNED NOT NULL,
  `own_id` int NOT NULL,
  `ownFil_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownFil_oldName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownFil_ext` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cat_id` int NOT NULL,
  `ownFil_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownFil_createdDate` date DEFAULT NULL,
  `ownFil_updatedDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `parameter`
--

CREATE TABLE `parameter` (
  `par_id` bigint UNSIGNED NOT NULL,
  `par_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `par_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `par_descriptionFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `par_descriptionEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `par_value` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `payment_periods`
--

CREATE TABLE `payment_periods` (
  `payPer_id` bigint UNSIGNED NOT NULL,
  `payPer_order` int NOT NULL,
  `payPer_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `payPer_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `payPer_value` int DEFAULT NULL,
  `payPer_active` int DEFAULT NULL,
  `payPer_updatedDate` datetime DEFAULT NULL,
  `payPer_createdDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `payPer_deleted` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `permissions`
--

CREATE TABLE `permissions` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `guard_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `provider`
--

CREATE TABLE `provider` (
  `pro_id` int NOT NULL,
  `pro_numberCompta` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_socialReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_siret` varchar(17) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_address1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cou_id` int DEFAULT '1',
  `proSta_id` int DEFAULT NULL COMMENT 'divers = provider_status',
  `pro_phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_mobile` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_fax` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_active` tinyint(1) DEFAULT '1',
  `pro_selectable` tinyint DEFAULT '1',
  `pro_lat` decimal(10,8) DEFAULT NULL,
  `pro_lng` decimal(11,8) DEFAULT NULL,
  `pro_formattedAddress` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_maxInterventionInProgress` smallint DEFAULT NULL,
  `pro_prices` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `pro_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `pro_private` tinyint(1) DEFAULT '1',
  `pro_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `pro_updatedDate` datetime DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `pro_city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_zipCode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_deleted` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `pro_tvaDefault` int DEFAULT '1',
  `pro_satisfactionQuality` int DEFAULT '0',
  `pro_correspondance` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_email2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_email3` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_email4` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_legalStatus` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_infosContacts` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `pro_callWs` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'N',
  `pro_adressWs` char(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_codeWs` char(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_bpuInfo` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `pro_docsUpToDate` int NOT NULL DEFAULT '0',
  `pro_defaultLang` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'Fr',
  `pro_apiActive` int DEFAULT '0',
  `pro_apiKey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `provider_defaults`
--

CREATE TABLE `provider_defaults` (
  `proDef_id` bigint UNSIGNED NOT NULL,
  `pro_id` int NOT NULL,
  `proDef_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `proDef_updatedDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `sig_id` int DEFAULT NULL,
  `sit_ids` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `act_ids` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `provider_file`
--

CREATE TABLE `provider_file` (
  `proFil_id` bigint UNSIGNED NOT NULL,
  `pro_id` int NOT NULL,
  `proFil_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `proFil_oldName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `proFil_ext` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proFil_createdDate` timestamp NULL DEFAULT NULL,
  `proFil_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `proFil_description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `cat_id` int NOT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `proFil_deleted` int DEFAULT NULL,
  `proFil_bpu` int DEFAULT '0',
  `proFil_dueDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `provider_file_category`
--

CREATE TABLE `provider_file_category` (
  `proFilCat_id` bigint UNSIGNED NOT NULL,
  `proFilCat_order` int DEFAULT NULL,
  `proFilCat_nameFr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `proFilCat_nameEn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_active` int DEFAULT NULL,
  `proFilCat_updatedDate` datetime DEFAULT NULL,
  `proFilCat_createdDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `proFilCat_deleted` int DEFAULT NULL,
  `proFilCat_obligatory` tinyint(1) DEFAULT '0',
  `proFilCat_nameEs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_nameIt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_namePl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_nameNl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_nameDe` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_nameSv` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_namePt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_nameDa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proFilCat_nameNo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `provider_invoice`
--

CREATE TABLE `provider_invoice` (
  `proInv_id` int NOT NULL,
  `int_id` int DEFAULT NULL,
  `pro_id` int DEFAULT NULL,
  `proInv_number` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proInv_achievementDate` date DEFAULT NULL,
  `proInv_deadlineDate` date DEFAULT NULL,
  `proInv_payed` tinyint(1) DEFAULT NULL,
  `proInv_paymentDate` date DEFAULT NULL,
  `proInv_providerNumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_id` int DEFAULT NULL,
  `proInv_amountHT` decimal(10,2) DEFAULT NULL,
  `proInv_tva` decimal(11,2) DEFAULT NULL,
  `proInv_amountTTC` decimal(10,2) DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `proReq_id` int DEFAULT NULL,
  `proInv_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `com_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `proInv_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `proInv_updatedDate` datetime DEFAULT NULL,
  `proInv_deleted` tinyint(1) DEFAULT NULL,
  `proInv_validated` tinyint(1) DEFAULT NULL,
  `proInv_validatedDate` datetime DEFAULT NULL,
  `proInv_checkDate` datetime DEFAULT NULL,
  `tva_id` int DEFAULT NULL,
  `intFil_id` int DEFAULT NULL,
  `con_intList` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `con_intCount` int DEFAULT '0',
  `proInv_sendedBc` int DEFAULT '0',
  `proInv_curAmountHT` double DEFAULT NULL,
  `proInv_curRate` double DEFAULT NULL,
  `cur_code` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `provider_link_activity`
--

CREATE TABLE `provider_link_activity` (
  `proAct_id` int NOT NULL,
  `pro_id` int DEFAULT NULL,
  `act_id` int DEFAULT NULL,
  `proLinAct_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `proLinAct_deleted` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `provider_quote`
--

CREATE TABLE `provider_quote` (
  `proQuo_id` int NOT NULL,
  `int_id` int DEFAULT NULL,
  `proQuo_number` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_id` int DEFAULT NULL,
  `proQuo_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proQuo_description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `proQuo_requestDate` date DEFAULT NULL,
  `proQuo_desiredDateReturn` date DEFAULT NULL,
  `proQuo_realDateReturn` date DEFAULT NULL,
  `sta_id` int DEFAULT NULL,
  `proQuo_amountHT` decimal(10,2) DEFAULT NULL,
  `proQuo_tva` decimal(10,2) DEFAULT NULL,
  `proQuo_amountTTC` decimal(10,2) DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `proQuo_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `proQuo_updatedDate` datetime DEFAULT NULL,
  `proReq_id` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `proQuo_deleted` tinyint(1) DEFAULT NULL,
  `proQuo_validated` tinyint(1) DEFAULT NULL COMMENT '1:Validé, 2:Refusé',
  `proQuo_validatedDate` datetime DEFAULT NULL,
  `tva_id` int DEFAULT NULL,
  `intFil_id` int DEFAULT NULL,
  `proQuo_lastRelaunchDate` date DEFAULT NULL,
  `intFil_id_bpa` int DEFAULT NULL,
  `proQuo_providerNumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proQuo_sended` int NOT NULL DEFAULT '0',
  `proQuo_lastSendedUseId` int DEFAULT NULL,
  `proQuo_lastSendedDate` timestamp NULL DEFAULT NULL,
  `proQuo_curAmountHT` double DEFAULT NULL,
  `proQuo_curRate` double DEFAULT NULL,
  `cur_code` varchar(3) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `provider_quote_message`
--

CREATE TABLE `provider_quote_message` (
  `proQuoMes_id` int UNSIGNED NOT NULL,
  `use_id` int NOT NULL,
  `proQuoMes_object` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proQuoMes_texte` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `proQuo_id` int NOT NULL,
  `int_id` int NOT NULL,
  `proQuoMes_writer` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proQuoMes_readed` int DEFAULT '0',
  `proQuoMes_createdDate` timestamp NOT NULL,
  `proQuoMes_updatedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `provider_request`
--

CREATE TABLE `provider_request` (
  `proReq_id` int NOT NULL,
  `int_id` int DEFAULT NULL,
  `proReq_number` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `pro_id` int DEFAULT NULL,
  `proReq_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proReq_description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `proReq_requestDate` date DEFAULT NULL,
  `proReq_planningDate` date DEFAULT NULL,
  `proReq_qualityControlDate` date DEFAULT NULL,
  `proReq_achievementDate` date DEFAULT NULL,
  `sta_id` int DEFAULT NULL,
  `proReq_amountHT` decimal(10,2) DEFAULT NULL,
  `proReq_tva` decimal(10,2) DEFAULT NULL,
  `proReq_amountTTC` decimal(10,2) DEFAULT NULL,
  `proReq_satisfactionQuality` tinyint DEFAULT NULL,
  `proReq_satisfactionComment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `proReq_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `proReq_updatedDate` datetime DEFAULT NULL,
  `proQuo_id` int DEFAULT NULL,
  `proInv_id` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `proReq_deleted` tinyint(1) DEFAULT NULL,
  `proReq_validated` tinyint(1) DEFAULT NULL,
  `tva_id` int DEFAULT NULL,
  `intFilBi_id` int DEFAULT NULL,
  `proReq_lastRelaunchDate` date DEFAULT NULL,
  `proReq_linkKey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proReq_proQuoProRefNumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proReq_desiredPlanningDate` date DEFAULT NULL,
  `proReq_sended` int NOT NULL DEFAULT '0',
  `proReq_lastSendedUseId` int DEFAULT NULL,
  `proReq_lastSendedDate` timestamp NULL DEFAULT NULL,
  `proReq_planningHour` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `proReq_linkKey_binumeric` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `provider_request_bi`
--

CREATE TABLE `provider_request_bi` (
  `proReqBi_id` bigint UNSIGNED NOT NULL,
  `proReq_id` int NOT NULL DEFAULT '0',
  `int_id` int NOT NULL DEFAULT '0',
  `proReqBi_job` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `proReqBi_equipment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `proReqBi_nbPeople` int NOT NULL DEFAULT '1',
  `proReqBi_siteComment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `proReqBi_nameSignataire` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proReqBi_validated` int NOT NULL DEFAULT '0',
  `proReqBi_validatedTime` datetime DEFAULT NULL,
  `proReqBi_date` datetime DEFAULT NULL,
  `proReqBi_dateTech` datetime DEFAULT NULL,
  `proReqBi_step` int DEFAULT '0',
  `proReqBi_filesTech` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proReqBi_providerComment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `proReqBi_spentTimeHours` int DEFAULT NULL,
  `proReqBi_spentTimeMn` int DEFAULT NULL,
  `intFil_idTampon` int DEFAULT '0',
  `intFil_idSignature` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `region`
--

CREATE TABLE `region` (
  `reg_id` bigint UNSIGNED NOT NULL,
  `sec_id` int DEFAULT NULL,
  `reg_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reg_managerName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reg_updatedDate` datetime DEFAULT NULL,
  `reg_createdDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `rights_admin`
--

CREATE TABLE `rights_admin` (
  `rig_id` bigint UNSIGNED NOT NULL,
  `rig_element` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rig_admin` int NOT NULL DEFAULT '1',
  `rig_respMaintenance` int NOT NULL DEFAULT '1',
  `rig_respSecteur` int NOT NULL DEFAULT '1',
  `rig_respSite` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `roles`
--

CREATE TABLE `roles` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `guard_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `role_has_permissions`
--

CREATE TABLE `role_has_permissions` (
  `permission_id` bigint UNSIGNED NOT NULL,
  `role_id` bigint UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `secteur`
--

CREATE TABLE `secteur` (
  `sec_id` int NOT NULL,
  `sec_name` varchar(255) DEFAULT NULL,
  `sec_code` varchar(255) DEFAULT NULL,
  `bil_id` int DEFAULT NULL,
  `sec_active` tinyint(1) DEFAULT '1',
  `old_id` int DEFAULT NULL,
  `sec_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int DEFAULT NULL,
  `sec_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sec_deleted` varchar(1) DEFAULT '0',
  `sec_import` tinyint(1) DEFAULT NULL,
  `sig_id` int DEFAULT NULL,
  `sec_dirName` varchar(100) DEFAULT NULL,
  `sec_correspondance` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Structure de la table `secteur_site`
--

CREATE TABLE `secteur_site` (
  `secSit_id` int NOT NULL,
  `sec_id` int NOT NULL,
  `sit_id` int NOT NULL,
  `secSit_deleted` tinyint(1) DEFAULT NULL,
  `secSit_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sel_intervention`
--

CREATE TABLE `sel_intervention` (
  `sel_permanent` int DEFAULT '0',
  `sel_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `createdDate` date DEFAULT NULL,
  `createdDate2` date DEFAULT NULL,
  `planningDate` date DEFAULT NULL,
  `planningDate2` date DEFAULT NULL,
  `sel_type` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `int_type` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_id` int DEFAULT NULL,
  `pro_id` int DEFAULT NULL,
  `int_title` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_id` int DEFAULT NULL,
  `sit_code` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `con_id` int DEFAULT NULL,
  `bil_id` int DEFAULT NULL,
  `sig_id` int DEFAULT NULL,
  `cus_id` int DEFAULT NULL,
  `proQuo_number` int DEFAULT NULL,
  `proReq_number` int DEFAULT NULL,
  `cusQuo_number` int DEFAULT NULL,
  `cusInv_number` int DEFAULT NULL,
  `intStaGro_id` int DEFAULT NULL,
  `sta_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `customerRef` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `urgency` int DEFAULT NULL,
  `astreinte` int DEFAULT NULL,
  `complex` int DEFAULT NULL,
  `excludeCA` int DEFAULT NULL,
  `number` int DEFAULT NULL,
  `sel_free1` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sel_free2` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sended_mails`
--

CREATE TABLE `sended_mails` (
  `senMai_id` bigint UNSIGNED NOT NULL,
  `use_id` int NOT NULL,
  `senMai_date` date NOT NULL,
  `senMai_time` time NOT NULL,
  `senMai_object` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `senMai_body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `senMai_to` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `senMai_toCc` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `senMai_createdDate` timestamp NOT NULL,
  `senMai_updatedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sign`
--

CREATE TABLE `sign` (
  `sig_id` int NOT NULL,
  `cus_id` int DEFAULT NULL,
  `sig_socialReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_address1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cit_id` int DEFAULT NULL,
  `dep_id` int DEFAULT NULL,
  `reg_id` int DEFAULT NULL,
  `cou_id` int DEFAULT NULL,
  `sig_phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_fax` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_active` tinyint(1) DEFAULT '1',
  `sig_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sig_updatedDate` datetime DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sig_city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_zipCode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_deleted` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `sig_correspondance` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_logo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_useLogoText` int NOT NULL DEFAULT '0',
  `sig_useLogoMail` int NOT NULL DEFAULT '0',
  `sig_dafAmount` decimal(15,2) DEFAULT NULL,
  `sig_dafEmail` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sig_dafEmailSend` int DEFAULT '0',
  `sig_codeWs` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sign_budget`
--

CREATE TABLE `sign_budget` (
  `sigBud_id` bigint UNSIGNED NOT NULL,
  `sig_id` int NOT NULL,
  `act_id` int NOT NULL,
  `sigBud_year` int NOT NULL,
  `sigBud_amountHt` decimal(15,2) DEFAULT NULL,
  `sigBud_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sigBud_createdDate` timestamp NULL DEFAULT NULL,
  `sigBud_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sign_file`
--

CREATE TABLE `sign_file` (
  `sigFil_id` bigint UNSIGNED NOT NULL,
  `sig_id` int NOT NULL,
  `sigFil_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigFil_oldName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigFil_ext` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigFil_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cat_id` int NOT NULL,
  `sigFil_createdDate` timestamp NULL DEFAULT NULL,
  `sigFil_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sigFil_deleted` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sign_texte`
--

CREATE TABLE `sign_texte` (
  `sigTex_id` bigint UNSIGNED NOT NULL,
  `sig_id` int NOT NULL,
  `sigTex_active` int NOT NULL DEFAULT '1',
  `sigTex_textFr` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sigTex_textEn` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sigTex_code` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textEs` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textIt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textPl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textNl` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textDe` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textSv` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textPt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textDa` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sigTex_textNo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site`
--

CREATE TABLE `site` (
  `sit_id` int NOT NULL,
  `sit_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_code` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_address1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cou_id` int DEFAULT '1',
  `sit_phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_fax` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sig_id` int DEFAULT NULL,
  `sit_active` tinyint(1) DEFAULT '1',
  `sit_lat` decimal(10,8) DEFAULT NULL,
  `sit_lng` decimal(11,8) DEFAULT NULL,
  `sit_formattedAddress` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sit_updatedDate` datetime DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sit_import` tinyint(1) DEFAULT NULL,
  `sit_city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_deleted` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `bil_id` int DEFAULT NULL,
  `sit_zipCode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_hours` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sit_type` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_emailDirector` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sitImp_id` int DEFAULT NULL,
  `sec_id` int DEFAULT '0',
  `sit_surface` decimal(10,2) DEFAULT NULL,
  `sit_correspondance` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_internalComment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sit_openDate` timestamp NULL DEFAULT NULL,
  `sit_respName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_code1` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_siret` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_typo` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_dirCoName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_conceptType` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_conceptTypeComment` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_lastDateCs` date DEFAULT NULL,
  `sit_erpCategory` int DEFAULT NULL,
  `sit_portable` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_pdlEnedis` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_powerEnedis` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_propertyManagement` int DEFAULT NULL,
  `sit_ownerId` int DEFAULT NULL,
  `sit_ownerinvoiceEmail` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_ownerEndDate` date DEFAULT NULL,
  `sit_comFrequency` int DEFAULT NULL,
  `reg_id` int DEFAULT NULL,
  `sit_emailCopy` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_surfaceReserve` decimal(10,2) DEFAULT NULL,
  `sit_emailCopyCreateDI` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_defaultLang` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT 'Fr',
  `sit_importId` int DEFAULT NULL,
  `sit_emailCopyBI` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_activity_amounts`
--

CREATE TABLE `site_activity_amounts` (
  `sitActAmo_id` bigint UNSIGNED NOT NULL,
  `sit_id` int NOT NULL,
  `act_id` int NOT NULL,
  `sitActAmo_estAmountProQuo` double(8,2) DEFAULT NULL,
  `sitActAmo_estAmountProReq` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sitActAmo_createdDate` timestamp NULL DEFAULT NULL,
  `sitActAmo_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_budget`
--

CREATE TABLE `site_budget` (
  `sitBud_id` bigint UNSIGNED NOT NULL,
  `sit_id` int NOT NULL,
  `act_id` int NOT NULL,
  `sitBud_year` int NOT NULL,
  `sitBud_amountHt` decimal(15,2) DEFAULT NULL,
  `sitBud_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sitBud_createdDate` timestamp NULL DEFAULT NULL,
  `sitBud_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_control`
--

CREATE TABLE `site_control` (
  `sitCon_id` bigint UNSIGNED NOT NULL,
  `sit_id` int NOT NULL,
  `act_id` int NOT NULL,
  `sitCon_realised` int NOT NULL DEFAULT '0',
  `sitCon_action` int NOT NULL DEFAULT '0',
  `sitCon_title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sitCon_description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sitCon_visitDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sitCon_createdDate` timestamp NULL DEFAULT NULL,
  `sitCon_updatedDate` timestamp NULL DEFAULT NULL,
  `pro_idAssigned` int DEFAULT NULL,
  `sitCon_deleted` int DEFAULT '0',
  `actDet_id` int DEFAULT NULL,
  `sitCon_remindDate` timestamp NULL DEFAULT NULL,
  `che_id` int DEFAULT NULL,
  `sitCon_emailAlertSended` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_control_checkelements`
--

CREATE TABLE `site_control_checkelements` (
  `sitConChe_id` bigint UNSIGNED NOT NULL,
  `sitCon_id` int NOT NULL,
  `cheEle_id` int NOT NULL,
  `sitConFil_id` int DEFAULT NULL,
  `sitConChe_checked` int NOT NULL DEFAULT '0',
  `intFil_id` int DEFAULT NULL,
  `sitConChe_textValue` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_control_file`
--

CREATE TABLE `site_control_file` (
  `sitConFil_id` bigint UNSIGNED NOT NULL,
  `sitCon_id` int NOT NULL,
  `sitConFil_description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sitConFil_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sitConFil_oldName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sitConFil_ext` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sitConFil_createdDate` timestamp NULL DEFAULT NULL,
  `sitConFil_updatedDate` timestamp NULL DEFAULT NULL,
  `sitConFil_type` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sitConFil_visibleProvider` int NOT NULL DEFAULT '1',
  `sitConFil_visibleSite` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_control_file_category`
--

CREATE TABLE `site_control_file_category` (
  `sitConFilCat_id` bigint UNSIGNED NOT NULL,
  `sitConFilCat_order` int DEFAULT NULL,
  `sitConFilCat_nameFr` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitConFilCat_nameEn` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitConFilCat_initial` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitConFilCat_color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitConFilCat_active` int DEFAULT NULL,
  `sitConFilCat_deleted` int DEFAULT NULL,
  `sitConFilCat_createdDate` date DEFAULT NULL,
  `sitConFilCat_updatedDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_entity`
--

CREATE TABLE `site_entity` (
  `sitEnt_id` bigint UNSIGNED NOT NULL,
  `sit_id` int NOT NULL,
  `sitEnt_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitEnt_comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_file`
--

CREATE TABLE `site_file` (
  `sitFil_id` bigint UNSIGNED NOT NULL,
  `sit_id` int NOT NULL,
  `sitFil_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sitFil_oldName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sitFil_ext` varchar(4) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `cat_id` int NOT NULL,
  `sitFil_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `use_idCreator` int NOT NULL,
  `sitFil_updatedDate` timestamp NULL DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sitFil_deleted` int DEFAULT NULL,
  `sitFil_description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sitFil_visibleProvider` int NOT NULL DEFAULT '1',
  `sitFil_visibleSite` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_implantation`
--

CREATE TABLE `site_implantation` (
  `sitImp_id` bigint UNSIGNED NOT NULL,
  `sitImp_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_space`
--

CREATE TABLE `site_space` (
  `sitSpa_id` bigint UNSIGNED NOT NULL,
  `sit_id` int NOT NULL,
  `spa_id` int NOT NULL,
  `sitSpa_comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sitSpa_surface` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `site_temp`
--

CREATE TABLE `site_temp` (
  `sit_id` int NOT NULL DEFAULT '0',
  `sit_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_code` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_address1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `cou_id` int DEFAULT '1',
  `sit_phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_fax` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sig_id` int DEFAULT NULL,
  `sit_active` tinyint(1) DEFAULT '1',
  `sit_lat` decimal(10,8) DEFAULT NULL,
  `sit_lng` decimal(11,8) DEFAULT NULL,
  `sit_formattedAddress` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sit_updatedDate` datetime DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `sit_import` tinyint(1) DEFAULT NULL,
  `sit_city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_deleted` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `bil_id` int DEFAULT NULL,
  `sit_zipCode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_hours` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sit_type` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_emailDirector` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sitImp_id` int DEFAULT NULL,
  `sec_id` int DEFAULT '0',
  `sit_surface` int DEFAULT NULL,
  `sit_correspondance` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_internalComment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sit_openDate` timestamp NULL DEFAULT NULL,
  `sit_respName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_code1` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_siret` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_typo` varchar(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_dirCoName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_conceptType` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_conceptTypeComment` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_lastDateCs` date DEFAULT NULL,
  `sit_erpCategory` int DEFAULT NULL,
  `sit_portable` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_pdlEnedis` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_powerEnedis` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_propertyManagement` int DEFAULT NULL,
  `sit_ownerId` int DEFAULT NULL,
  `sit_ownerinvoiceEmail` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sit_ownerEndDate` date DEFAULT NULL,
  `sit_comFrequency` int DEFAULT NULL,
  `importer` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `space`
--

CREATE TABLE `space` (
  `spa_id` bigint UNSIGNED NOT NULL,
  `spa_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `spa_updatedDate` datetime DEFAULT NULL,
  `spa_createdDate` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `status`
--

CREATE TABLE `status` (
  `sta_id` bigint UNSIGNED NOT NULL,
  `sta_type` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sta_order` int DEFAULT NULL,
  `sta_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sta_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_active` int DEFAULT '1',
  `sta_color` varchar(15) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_preventive` int DEFAULT NULL,
  `staGro_id` int DEFAULT NULL,
  `sta_curative` int DEFAULT NULL,
  `sta_updatedDate` date DEFAULT NULL,
  `sta_createdDate` date DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `sta_sitNameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sendMailSite` int NOT NULL DEFAULT '0',
  `sta_mailSiteObjectFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_mailSiteObjectEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_mailSiteTextFr` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sta_mailSiteTextEn` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sta_sendMailUser` int NOT NULL DEFAULT '0',
  `sta_mailuserAddress` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_mailuserObjectFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_mailUserObjectEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_mailUserTextFr` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sta_mailUserTextEn` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `sta_stats` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT '0',
  `sta_nameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_nameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_namePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_nameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_nameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_nameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_namePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_nameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_nameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNamePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNamePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNamePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNamePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_proNameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `sta_sitNameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `status_group`
--

CREATE TABLE `status_group` (
  `staGro_id` bigint UNSIGNED NOT NULL,
  `staGro_order` int NOT NULL DEFAULT '0',
  `staGro_libelleFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `staGro_active` int NOT NULL DEFAULT '1',
  `staGro_createdDate` date DEFAULT NULL,
  `staGro_updatedDate` date DEFAULT NULL,
  `staGro_libelleEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libelleEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libelleIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libellePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libelleNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libelleDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libelleSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libellePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libelleDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `staGro_libelleNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `status_params`
--

CREATE TABLE `status_params` (
  `staPar_id` bigint UNSIGNED NOT NULL,
  `staPar_type` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `staPar_code` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `staPar_descriptionFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `staPar_value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `staPar_descriptionEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `status_rules`
--

CREATE TABLE `status_rules` (
  `staRul_id` bigint UNSIGNED NOT NULL,
  `staRul_table` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `staRul_type` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `staRul_active` int NOT NULL DEFAULT '1',
  `staRul_staId` int NOT NULL,
  `staRul_intStaId` int NOT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `staRul_createdDate` timestamp NULL DEFAULT NULL,
  `staRul_updatedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `survey`
--

CREATE TABLE `survey` (
  `sur_id` bigint UNSIGNED NOT NULL,
  `sit_id` int DEFAULT NULL,
  `sur_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sur_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `sur_startDate` date DEFAULT NULL,
  `sur_endDate` date DEFAULT NULL,
  `sur_createdDate` timestamp NOT NULL,
  `sur_updatedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `survey_answers`
--

CREATE TABLE `survey_answers` (
  `surAns_id` bigint UNSIGNED NOT NULL,
  `use_id` int NOT NULL,
  `sit_id` int NOT NULL,
  `sur_id` int NOT NULL,
  `surQue_id` int NOT NULL,
  `surAns_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `surAns_createdDate` timestamp NOT NULL,
  `surAns_updatedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `survey_questions`
--

CREATE TABLE `survey_questions` (
  `surQue_id` bigint UNSIGNED NOT NULL,
  `surSec_id` int NOT NULL,
  `surQue_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `surQue_typeField` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `surQue_fieldRequired` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `surQue_createdDate` timestamp NOT NULL,
  `surQue_updatedDate` timestamp NULL DEFAULT NULL,
  `surQue_order` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `survey_questions_options`
--

CREATE TABLE `survey_questions_options` (
  `surQueOpt_id` bigint UNSIGNED NOT NULL,
  `surQue_id` bigint UNSIGNED NOT NULL,
  `surQueOpt_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `surQueOpt_createdDate` timestamp NOT NULL,
  `surQueOpt_updatedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `survey_sections`
--

CREATE TABLE `survey_sections` (
  `surSec_id` bigint UNSIGNED NOT NULL,
  `sur_id` int NOT NULL,
  `surSec_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `surSec_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `surSec_createdDate` timestamp NOT NULL,
  `surSec_updatedDate` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `survey_sites`
--

CREATE TABLE `survey_sites` (
  `surSit_id` bigint UNSIGNED NOT NULL,
  `sur_id` int NOT NULL,
  `sit_id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `surSit_createdDate` date DEFAULT NULL,
  `surSit_updatedDate` date DEFAULT NULL,
  `surSit_readed` int DEFAULT '0',
  `surSit_filled` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `texte`
--

CREATE TABLE `texte` (
  `tex_id` int NOT NULL,
  `tex_nameFr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_nameEn` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_textFr` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textEn` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_modified` datetime DEFAULT NULL,
  `tex_created` datetime DEFAULT NULL,
  `tex_updatedDate` datetime DEFAULT NULL,
  `tex_createdDate` datetime DEFAULT NULL,
  `tex_deleted` tinyint(1) DEFAULT NULL,
  `tex_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `tex_code` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `sig_option` int NOT NULL DEFAULT '0',
  `tex_nameEs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_nameIt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_namePl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_nameNl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_nameDe` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_nameSv` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_namePt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_nameDa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_nameNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tex_textEs` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textIt` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textPl` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textNl` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textDe` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textSv` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textPt` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textDa` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `tex_textNo` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `tva`
--

CREATE TABLE `tva` (
  `tva_id` int NOT NULL,
  `tva_order` tinyint DEFAULT NULL,
  `tva_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `tva_value` decimal(5,2) DEFAULT NULL,
  `tva_active` tinyint(1) DEFAULT '1',
  `cou_id` int DEFAULT NULL,
  `tva_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `tva_updatedDate` datetime DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `com_idUpdater` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `com_idCreator` int DEFAULT NULL,
  `tva_deleted` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_mobile` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_active` tinyint(1) NOT NULL DEFAULT '1',
  `use_lastVisit` datetime DEFAULT NULL,
  `use_lastIP` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `use_pwdSendedDate` datetime DEFAULT NULL,
  `use_deleted` tinyint(1) DEFAULT '0',
  `use_idCreator` int DEFAULT NULL,
  `pro_id` int DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `token_2fa` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `token_2fa_expiry` datetime DEFAULT NULL,
  `use_fonction` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_gmailAddress` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_useGmailCalendar` int NOT NULL DEFAULT '0',
  `use_sigId` int DEFAULT NULL,
  `use_assocTech` int DEFAULT '0',
  `use_limiteEngagement` decimal(10,2) DEFAULT NULL,
  `google_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_limiteEngagementFacture` decimal(10,2) DEFAULT NULL,
  `use_defaultLang` varchar(2) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_superAdmin` int DEFAULT '0',
  `use_signature` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `use_consultant` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_department`
--

CREATE TABLE `user_department` (
  `useDep_id` bigint UNSIGNED NOT NULL,
  `use_id` int DEFAULT NULL,
  `dep_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_imports`
--

CREATE TABLE `user_imports` (
  `useImp_id` bigint UNSIGNED NOT NULL,
  `id_import` int NOT NULL,
  `useImp_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `useImp_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `useImp_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `useImp_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `useImp_function` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `useImp_signId` int DEFAULT NULL,
  `useImp_sitCode` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `useImp_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `useImp_mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `importable` int DEFAULT NULL,
  `comment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `generate_password` int DEFAULT '0',
  `send_login_password` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_log`
--

CREATE TABLE `user_log` (
  `useLog_id` int NOT NULL,
  `use_id` int DEFAULT NULL,
  `useLog_ip` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `useLog_connectionDate` datetime DEFAULT NULL,
  `useLog_lastActionDate` datetime DEFAULT NULL,
  `useLog_lastAction` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `useLog_valid` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_params`
--

CREATE TABLE `user_params` (
  `usePar_id` bigint UNSIGNED NOT NULL,
  `use_id` int NOT NULL,
  `usePar_diNewOnglet` int NOT NULL DEFAULT '1',
  `usePar_editPdfOption` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL DEFAULT 'see',
  `usePar_template` int DEFAULT '2',
  `usePar_menuFixe` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_region`
--

CREATE TABLE `user_region` (
  `useReg_id` bigint UNSIGNED NOT NULL,
  `use_id` int DEFAULT NULL,
  `reg_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `user_secteur`
--

CREATE TABLE `user_secteur` (
  `useSec_id` int NOT NULL,
  `use_id` int NOT NULL,
  `sec_id` int NOT NULL,
  `useSec_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `useSec_deleted` tinyint(1) DEFAULT NULL,
  `use_idCreator` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Structure de la table `user_sign`
--

CREATE TABLE `user_sign` (
  `useSig_id` int NOT NULL,
  `use_id` int DEFAULT NULL,
  `sig_id` int DEFAULT NULL,
  `useSig_createdDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int NOT NULL,
  `useSig_deleted` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Structure de la table `user_site`
--

CREATE TABLE `user_site` (
  `useSit_id` int NOT NULL,
  `use_id` int NOT NULL,
  `sit_id` int NOT NULL,
  `useSit_deleted` tinyint(1) DEFAULT NULL,
  `useSit_createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_idCreator` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Structure de la table `veritas_intervention`
--

CREATE TABLE `veritas_intervention` (
  `verInt_id` bigint UNSIGNED NOT NULL,
  `verTra_id` int NOT NULL,
  `int_api` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_repertoire` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_elanNumber` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_date_debut` datetime NOT NULL,
  `int_date_fin` datetime NOT NULL,
  `int_dt` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_desc_presta` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_id_site` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_prs_cod` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_nom_site` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_client` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_lieu` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_nom_batiment` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_dept` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_ville` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_intervenant` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_cb_exe` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_dt_libelle` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `int_elanId` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `veritas_observation`
--

CREATE TABLE `veritas_observation` (
  `verObs_id` bigint UNSIGNED NOT NULL,
  `verInt_id` int NOT NULL,
  `verTra_id` int NOT NULL,
  `obs_num_rap` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_niv_loc_1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_niv_loc_2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_niv_loc_3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_niv_loc_4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_nature` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_marque` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_num_serie` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `eqp_num_interne` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_chapitre` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_point_examine` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_actions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `obs_critere1` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_critere2` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_critere3` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_critere4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_critere5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_critere6` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `obs_libelle_C1` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `obs_libelle_C2` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `obs_libelle_C3` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `obs_libelle_C4` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `obs_libelle_C5` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `obs_libelle_C6` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `obs_date_prem_emiss` datetime NOT NULL,
  `eqp_annee_mes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `num_fiche` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `veritas_rapport`
--

CREATE TABLE `veritas_rapport` (
  `verRap_id` bigint UNSIGNED NOT NULL,
  `verInt_id` int NOT NULL,
  `verTra_id` int NOT NULL,
  `nom_rap` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `etat` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `num_serie` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `num_interne` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `num_ordre_rap` int DEFAULT NULL,
  `rap_date_premiere_diffusion` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `veritas_traitement`
--

CREATE TABLE `veritas_traitement` (
  `verTra_id` bigint UNSIGNED NOT NULL,
  `verTra_date` datetime NOT NULL,
  `verTra_file` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `verTra_result` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `webservice_intervention`
--

CREATE TABLE `webservice_intervention` (
  `webInt_id` bigint UNSIGNED NOT NULL,
  `webInt_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `webInt_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `webInt_file` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `webInt_done` int DEFAULT '0',
  `pro_id` int DEFAULT NULL,
  `int_id` int DEFAULT NULL,
  `proQuo_id` int DEFAULT NULL,
  `proReq_id` int DEFAULT NULL,
  `intMes_id` int DEFAULT NULL,
  `intFil_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `worksite`
--

CREATE TABLE `worksite` (
  `wor_id` bigint UNSIGNED NOT NULL,
  `sig_id` int NOT NULL,
  `sit_id` int NOT NULL,
  `wor_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wor_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `wor_refNumber` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wor_createdDate` date DEFAULT NULL,
  `wor_closingDate` date DEFAULT NULL,
  `wor_estimatedAmount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `worCat_id` int DEFAULT NULL,
  `wor_closed` int NOT NULL DEFAULT '0',
  `wor_startDate` date DEFAULT NULL,
  `wor_endDate` date DEFAULT NULL,
  `wor_sinister` int NOT NULL DEFAULT '0',
  `wor_updatedDate` date DEFAULT NULL,
  `sta_id` int DEFAULT NULL,
  `wor_responsibleThird` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wor_sinisterDate` date DEFAULT NULL,
  `wor_deductibleAmount` decimal(10,2) DEFAULT NULL,
  `wor_provisionAmount` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `worksite_budgets`
--

CREATE TABLE `worksite_budgets` (
  `worBud_id` bigint UNSIGNED NOT NULL,
  `act_id` int DEFAULT NULL,
  `wor_id` int DEFAULT NULL,
  `worBud_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `worBud_createdDate` date DEFAULT NULL,
  `worBud_updatedDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `worksite_category`
--

CREATE TABLE `worksite_category` (
  `worCat_id` bigint UNSIGNED NOT NULL,
  `worCat_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `worCat_createdDate` date DEFAULT NULL,
  `worCat_active` int NOT NULL DEFAULT '1',
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `worCat_updatedDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `worksite_file`
--

CREATE TABLE `worksite_file` (
  `worFil_id` bigint UNSIGNED NOT NULL,
  `wor_id` int DEFAULT NULL,
  `worFil_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `worFil_oldName` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `worFil_ext` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `worFil_createdDate` date DEFAULT NULL,
  `wor_closingDate` date DEFAULT NULL,
  `wor_estimatedAmount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `worFil_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `worFil_deleted` int DEFAULT NULL,
  `worFil_size` int DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `worFil_updatedDate` date DEFAULT NULL,
  `cat_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `worksite_reimbursement`
--

CREATE TABLE `worksite_reimbursement` (
  `worRei_id` bigint UNSIGNED NOT NULL,
  `wor_id` int DEFAULT NULL,
  `worRei_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `worRei_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `worRei_amountHt` decimal(11,2) DEFAULT NULL,
  `worRei_payed` int NOT NULL DEFAULT '0',
  `worRei_createdDate` date DEFAULT NULL,
  `use_idCreator` int DEFAULT NULL,
  `use_idUpdater` int DEFAULT NULL,
  `worRei_updatedDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `activity`
--
ALTER TABLE `activity`
  ADD PRIMARY KEY (`act_id`),
  ADD KEY `intStaGro_id` (`par_id`);

--
-- Index pour la table `activity_detail`
--
ALTER TABLE `activity_detail`
  ADD PRIMARY KEY (`actDet_id`);

--
-- Index pour la table `api_link`
--
ALTER TABLE `api_link`
  ADD PRIMARY KEY (`apiLin_id`);

--
-- Index pour la table `article`
--
ALTER TABLE `article`
  ADD PRIMARY KEY (`art_id`);

--
-- Index pour la table `authorised_ip`
--
ALTER TABLE `authorised_ip`
  ADD PRIMARY KEY (`autIp_id`);

--
-- Index pour la table `billingcompany`
--
ALTER TABLE `billingcompany`
  ADD PRIMARY KEY (`bil_id`);

--
-- Index pour la table `budget`
--
ALTER TABLE `budget`
  ADD PRIMARY KEY (`bud_id`);

--
-- Index pour la table `budget_capex`
--
ALTER TABLE `budget_capex`
  ADD PRIMARY KEY (`budCap_id`);

--
-- Index pour la table `budget_family`
--
ALTER TABLE `budget_family`
  ADD PRIMARY KEY (`budFam_id`);

--
-- Index pour la table `budget_opex`
--
ALTER TABLE `budget_opex`
  ADD PRIMARY KEY (`budOpe_id`);

--
-- Index pour la table `campaign`
--
ALTER TABLE `campaign`
  ADD PRIMARY KEY (`cam_id`);

--
-- Index pour la table `campaign_sites`
--
ALTER TABLE `campaign_sites`
  ADD PRIMARY KEY (`camSit_id`);

--
-- Index pour la table `checklist`
--
ALTER TABLE `checklist`
  ADD PRIMARY KEY (`che_id`);

--
-- Index pour la table `checklist_element`
--
ALTER TABLE `checklist_element`
  ADD PRIMARY KEY (`cheEle_id`);

--
-- Index pour la table `city`
--
ALTER TABLE `city`
  ADD PRIMARY KEY (`cit_id`),
  ADD KEY `CPC` (`cit_zc`),
  ADD KEY `NomC` (`cit_name`);

--
-- Index pour la table `contact`
--
ALTER TABLE `contact`
  ADD PRIMARY KEY (`con_id`);

--
-- Index pour la table `contract`
--
ALTER TABLE `contract`
  ADD PRIMARY KEY (`con_id`);

--
-- Index pour la table `contract_file`
--
ALTER TABLE `contract_file`
  ADD PRIMARY KEY (`conFil_id`);

--
-- Index pour la table `contract_formula`
--
ALTER TABLE `contract_formula`
  ADD PRIMARY KEY (`conFor_id`);

--
-- Index pour la table `contract_invoice`
--
ALTER TABLE `contract_invoice`
  ADD PRIMARY KEY (`conInv_id`);

--
-- Index pour la table `contract_provider`
--
ALTER TABLE `contract_provider`
  ADD PRIMARY KEY (`conPro_id`);

--
-- Index pour la table `country`
--
ALTER TABLE `country`
  ADD PRIMARY KEY (`cou_id`);

--
-- Index pour la table `currency`
--
ALTER TABLE `currency`
  ADD PRIMARY KEY (`cur_id`);

--
-- Index pour la table `currency_rate`
--
ALTER TABLE `currency_rate`
  ADD PRIMARY KEY (`curRat_id`),
  ADD KEY `currency_rate_currat_date_index` (`curRat_date`);

--
-- Index pour la table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`cus_id`),
  ADD KEY `id` (`cus_id`);

--
-- Index pour la table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`dep_id`);

--
-- Index pour la table `department_activities`
--
ALTER TABLE `department_activities`
  ADD PRIMARY KEY (`depAct_id`);

--
-- Index pour la table `divers`
--
ALTER TABLE `divers`
  ADD PRIMARY KEY (`div_id`);

--
-- Index pour la table `dynfields`
--
ALTER TABLE `dynfields`
  ADD PRIMARY KEY (`dyn_id`);

--
-- Index pour la table `dynfields_list_values`
--
ALTER TABLE `dynfields_list_values`
  ADD PRIMARY KEY (`dynLisVal_id`);

--
-- Index pour la table `dynfields_site`
--
ALTER TABLE `dynfields_site`
  ADD PRIMARY KEY (`sit_id`);

--
-- Index pour la table `equipement_space_repartition`
--
ALTER TABLE `equipement_space_repartition`
  ADD PRIMARY KEY (`equSpa_id`);

--
-- Index pour la table `equipments`
--
ALTER TABLE `equipments`
  ADD PRIMARY KEY (`equ_id`);

--
-- Index pour la table `equipments_logs`
--
ALTER TABLE `equipments_logs`
  ADD PRIMARY KEY (`equLog_id`);

--
-- Index pour la table `equipment_family`
--
ALTER TABLE `equipment_family`
  ADD PRIMARY KEY (`equFam_id`);

--
-- Index pour la table `equipment_family_files`
--
ALTER TABLE `equipment_family_files`
  ADD PRIMARY KEY (`equFamFil_id`);

--
-- Index pour la table `equipment_file`
--
ALTER TABLE `equipment_file`
  ADD PRIMARY KEY (`equFil_id`);

--
-- Index pour la table `equipment_localisation`
--
ALTER TABLE `equipment_localisation`
  ADD PRIMARY KEY (`equLoc_id`);

--
-- Index pour la table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`eve_id`);

--
-- Index pour la table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `failed_jobs_uuid_index` (`uuid`(191));

--
-- Index pour la table `import_contract_data`
--
ALTER TABLE `import_contract_data`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `import_data`
--
ALTER TABLE `import_data`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `import_proinv`
--
ALTER TABLE `import_proinv`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `intervention`
--
ALTER TABLE `intervention`
  ADD PRIMARY KEY (`int_id`),
  ADD KEY `idx_int_type` (`int_type`),
  ADD KEY `idx_int_statut` (`sta_id`),
  ADD KEY `idx_int_site` (`sit_id`),
  ADD KEY `idx_int_contract` (`con_id`),
  ADD KEY `intervention_sitcon_id_index` (`sitCon_id`);

--
-- Index pour la table `intervention_bi_tech`
--
ALTER TABLE `intervention_bi_tech`
  ADD PRIMARY KEY (`intBiTec_id`);

--
-- Index pour la table `intervention_equipment`
--
ALTER TABLE `intervention_equipment`
  ADD PRIMARY KEY (`intEqu_id`);

--
-- Index pour la table `intervention_file`
--
ALTER TABLE `intervention_file`
  ADD PRIMARY KEY (`intFil_id`),
  ADD KEY `int_id` (`int_id`);

--
-- Index pour la table `intervention_file_category`
--
ALTER TABLE `intervention_file_category`
  ADD PRIMARY KEY (`intFilCat_id`);

--
-- Index pour la table `intervention_log`
--
ALTER TABLE `intervention_log`
  ADD PRIMARY KEY (`intLog_id`),
  ADD KEY `int_id` (`int_id`),
  ADD KEY `use_id` (`use_id`);

--
-- Index pour la table `intervention_message`
--
ALTER TABLE `intervention_message`
  ADD PRIMARY KEY (`intMes_id`),
  ADD KEY `use_id` (`use_id`),
  ADD KEY `int_id` (`int_id`);

--
-- Index pour la table `intervention_message_link_file`
--
ALTER TABLE `intervention_message_link_file`
  ADD PRIMARY KEY (`intMesLinFil_id`),
  ADD KEY `intMes_id` (`intMes_id`),
  ADD KEY `intFil_id` (`intFil_id`);

--
-- Index pour la table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Index pour la table `langue`
--
ALTER TABLE `langue`
  ADD PRIMARY KEY (`lan_id`);

--
-- Index pour la table `langue_traduction`
--
ALTER TABLE `langue_traduction`
  ADD PRIMARY KEY (`lanTra_id`);

--
-- Index pour la table `merchandising`
--
ALTER TABLE `merchandising`
  ADD PRIMARY KEY (`mer_id`);

--
-- Index pour la table `merchandising_photos`
--
ALTER TABLE `merchandising_photos`
  ADD PRIMARY KEY (`merPho_id`);

--
-- Index pour la table `merchandising_sites`
--
ALTER TABLE `merchandising_sites`
  ADD PRIMARY KEY (`merSit_id`);

--
-- Index pour la table `merchandising_status`
--
ALTER TABLE `merchandising_status`
  ADD PRIMARY KEY (`merSta_id`);

--
-- Index pour la table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  ADD KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Index pour la table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  ADD KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Index pour la table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`);

--
-- Index pour la table `notifications_user`
--
ALTER TABLE `notifications_user`
  ADD PRIMARY KEY (`use_id`);

--
-- Index pour la table `operation_log`
--
ALTER TABLE `operation_log`
  ADD PRIMARY KEY (`opeLog_id`);

--
-- Index pour la table `owner`
--
ALTER TABLE `owner`
  ADD PRIMARY KEY (`own_id`);

--
-- Index pour la table `owner_contract`
--
ALTER TABLE `owner_contract`
  ADD PRIMARY KEY (`ownCon_id`);

--
-- Index pour la table `owner_contract_file`
--
ALTER TABLE `owner_contract_file`
  ADD PRIMARY KEY (`ownConFil_id`);

--
-- Index pour la table `owner_file`
--
ALTER TABLE `owner_file`
  ADD PRIMARY KEY (`ownFil_id`);

--
-- Index pour la table `parameter`
--
ALTER TABLE `parameter`
  ADD PRIMARY KEY (`par_id`);

--
-- Index pour la table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- Index pour la table `payment_periods`
--
ALTER TABLE `payment_periods`
  ADD PRIMARY KEY (`payPer_id`);

--
-- Index pour la table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `provider`
--
ALTER TABLE `provider`
  ADD PRIMARY KEY (`pro_id`);

--
-- Index pour la table `provider_defaults`
--
ALTER TABLE `provider_defaults`
  ADD PRIMARY KEY (`proDef_id`);

--
-- Index pour la table `provider_file`
--
ALTER TABLE `provider_file`
  ADD PRIMARY KEY (`proFil_id`);

--
-- Index pour la table `provider_file_category`
--
ALTER TABLE `provider_file_category`
  ADD PRIMARY KEY (`proFilCat_id`);

--
-- Index pour la table `provider_invoice`
--
ALTER TABLE `provider_invoice`
  ADD PRIMARY KEY (`proInv_id`),
  ADD KEY `cusQuo_id` (`proReq_id`);

--
-- Index pour la table `provider_link_activity`
--
ALTER TABLE `provider_link_activity`
  ADD PRIMARY KEY (`proAct_id`),
  ADD KEY `pro_id` (`pro_id`,`act_id`);

--
-- Index pour la table `provider_quote`
--
ALTER TABLE `provider_quote`
  ADD PRIMARY KEY (`proQuo_id`),
  ADD KEY `int_id` (`int_id`);

--
-- Index pour la table `provider_quote_message`
--
ALTER TABLE `provider_quote_message`
  ADD PRIMARY KEY (`proQuoMes_id`);

--
-- Index pour la table `provider_request`
--
ALTER TABLE `provider_request`
  ADD PRIMARY KEY (`proReq_id`),
  ADD KEY `int_id` (`int_id`),
  ADD KEY `pro_id` (`pro_id`);

--
-- Index pour la table `provider_request_bi`
--
ALTER TABLE `provider_request_bi`
  ADD PRIMARY KEY (`proReqBi_id`);

--
-- Index pour la table `region`
--
ALTER TABLE `region`
  ADD PRIMARY KEY (`reg_id`);

--
-- Index pour la table `rights_admin`
--
ALTER TABLE `rights_admin`
  ADD PRIMARY KEY (`rig_id`);

--
-- Index pour la table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`role_id`),
  ADD KEY `role_has_permissions_role_id_foreign` (`role_id`);

--
-- Index pour la table `secteur`
--
ALTER TABLE `secteur`
  ADD PRIMARY KEY (`sec_id`);

--
-- Index pour la table `secteur_site`
--
ALTER TABLE `secteur_site`
  ADD PRIMARY KEY (`secSit_id`);

--
-- Index pour la table `sended_mails`
--
ALTER TABLE `sended_mails`
  ADD PRIMARY KEY (`senMai_id`);

--
-- Index pour la table `sign`
--
ALTER TABLE `sign`
  ADD PRIMARY KEY (`sig_id`),
  ADD KEY `cus_id` (`cus_id`),
  ADD KEY `cit_id` (`cit_id`),
  ADD KEY `dep_id` (`dep_id`),
  ADD KEY `reg_id` (`reg_id`),
  ADD KEY `cou_id` (`cou_id`);

--
-- Index pour la table `sign_budget`
--
ALTER TABLE `sign_budget`
  ADD PRIMARY KEY (`sigBud_id`);

--
-- Index pour la table `sign_file`
--
ALTER TABLE `sign_file`
  ADD PRIMARY KEY (`sigFil_id`);

--
-- Index pour la table `sign_texte`
--
ALTER TABLE `sign_texte`
  ADD PRIMARY KEY (`sigTex_id`);

--
-- Index pour la table `site`
--
ALTER TABLE `site`
  ADD PRIMARY KEY (`sit_id`),
  ADD KEY `ens_id` (`sig_id`),
  ADD KEY `cou_id` (`cou_id`),
  ADD KEY `sig_id` (`sig_id`);

--
-- Index pour la table `site_activity_amounts`
--
ALTER TABLE `site_activity_amounts`
  ADD PRIMARY KEY (`sitActAmo_id`);

--
-- Index pour la table `site_budget`
--
ALTER TABLE `site_budget`
  ADD PRIMARY KEY (`sitBud_id`);

--
-- Index pour la table `site_control`
--
ALTER TABLE `site_control`
  ADD PRIMARY KEY (`sitCon_id`);

--
-- Index pour la table `site_control_checkelements`
--
ALTER TABLE `site_control_checkelements`
  ADD PRIMARY KEY (`sitConChe_id`);

--
-- Index pour la table `site_control_file`
--
ALTER TABLE `site_control_file`
  ADD PRIMARY KEY (`sitConFil_id`);

--
-- Index pour la table `site_control_file_category`
--
ALTER TABLE `site_control_file_category`
  ADD PRIMARY KEY (`sitConFilCat_id`);

--
-- Index pour la table `site_entity`
--
ALTER TABLE `site_entity`
  ADD PRIMARY KEY (`sitEnt_id`);

--
-- Index pour la table `site_file`
--
ALTER TABLE `site_file`
  ADD PRIMARY KEY (`sitFil_id`);

--
-- Index pour la table `site_implantation`
--
ALTER TABLE `site_implantation`
  ADD PRIMARY KEY (`sitImp_id`);

--
-- Index pour la table `site_space`
--
ALTER TABLE `site_space`
  ADD PRIMARY KEY (`sitSpa_id`);

--
-- Index pour la table `space`
--
ALTER TABLE `space`
  ADD PRIMARY KEY (`spa_id`);

--
-- Index pour la table `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`sta_id`);

--
-- Index pour la table `status_group`
--
ALTER TABLE `status_group`
  ADD PRIMARY KEY (`staGro_id`);

--
-- Index pour la table `status_params`
--
ALTER TABLE `status_params`
  ADD PRIMARY KEY (`staPar_id`);

--
-- Index pour la table `status_rules`
--
ALTER TABLE `status_rules`
  ADD PRIMARY KEY (`staRul_id`);

--
-- Index pour la table `survey`
--
ALTER TABLE `survey`
  ADD PRIMARY KEY (`sur_id`);

--
-- Index pour la table `survey_answers`
--
ALTER TABLE `survey_answers`
  ADD PRIMARY KEY (`surAns_id`);

--
-- Index pour la table `survey_questions`
--
ALTER TABLE `survey_questions`
  ADD PRIMARY KEY (`surQue_id`);

--
-- Index pour la table `survey_questions_options`
--
ALTER TABLE `survey_questions_options`
  ADD PRIMARY KEY (`surQueOpt_id`);

--
-- Index pour la table `survey_sections`
--
ALTER TABLE `survey_sections`
  ADD PRIMARY KEY (`surSec_id`);

--
-- Index pour la table `survey_sites`
--
ALTER TABLE `survey_sites`
  ADD PRIMARY KEY (`surSit_id`);

--
-- Index pour la table `texte`
--
ALTER TABLE `texte`
  ADD PRIMARY KEY (`tex_id`);

--
-- Index pour la table `tva`
--
ALTER TABLE `tva`
  ADD PRIMARY KEY (`tva_id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Index pour la table `user_department`
--
ALTER TABLE `user_department`
  ADD PRIMARY KEY (`useDep_id`);

--
-- Index pour la table `user_imports`
--
ALTER TABLE `user_imports`
  ADD PRIMARY KEY (`useImp_id`);

--
-- Index pour la table `user_log`
--
ALTER TABLE `user_log`
  ADD PRIMARY KEY (`useLog_id`),
  ADD KEY `use_id` (`use_id`);

--
-- Index pour la table `user_params`
--
ALTER TABLE `user_params`
  ADD PRIMARY KEY (`usePar_id`);

--
-- Index pour la table `user_region`
--
ALTER TABLE `user_region`
  ADD PRIMARY KEY (`useReg_id`);

--
-- Index pour la table `user_secteur`
--
ALTER TABLE `user_secteur`
  ADD PRIMARY KEY (`useSec_id`),
  ADD KEY `use_id` (`use_id`),
  ADD KEY `sec_id` (`sec_id`);

--
-- Index pour la table `user_sign`
--
ALTER TABLE `user_sign`
  ADD PRIMARY KEY (`useSig_id`),
  ADD KEY `cus_id` (`sig_id`),
  ADD KEY `use_id` (`use_id`);

--
-- Index pour la table `user_site`
--
ALTER TABLE `user_site`
  ADD PRIMARY KEY (`useSit_id`),
  ADD KEY `use_id` (`use_id`),
  ADD KEY `sit_id` (`sit_id`);

--
-- Index pour la table `veritas_intervention`
--
ALTER TABLE `veritas_intervention`
  ADD PRIMARY KEY (`verInt_id`);

--
-- Index pour la table `veritas_observation`
--
ALTER TABLE `veritas_observation`
  ADD PRIMARY KEY (`verObs_id`),
  ADD KEY `veritas_observation_verint_id_index` (`verInt_id`);

--
-- Index pour la table `veritas_rapport`
--
ALTER TABLE `veritas_rapport`
  ADD PRIMARY KEY (`verRap_id`),
  ADD KEY `veritas_rapport_verint_id_index` (`verInt_id`);

--
-- Index pour la table `veritas_traitement`
--
ALTER TABLE `veritas_traitement`
  ADD PRIMARY KEY (`verTra_id`);

--
-- Index pour la table `webservice_intervention`
--
ALTER TABLE `webservice_intervention`
  ADD PRIMARY KEY (`webInt_id`);

--
-- Index pour la table `worksite`
--
ALTER TABLE `worksite`
  ADD PRIMARY KEY (`wor_id`);

--
-- Index pour la table `worksite_budgets`
--
ALTER TABLE `worksite_budgets`
  ADD PRIMARY KEY (`worBud_id`);

--
-- Index pour la table `worksite_category`
--
ALTER TABLE `worksite_category`
  ADD PRIMARY KEY (`worCat_id`);

--
-- Index pour la table `worksite_file`
--
ALTER TABLE `worksite_file`
  ADD PRIMARY KEY (`worFil_id`);

--
-- Index pour la table `worksite_reimbursement`
--
ALTER TABLE `worksite_reimbursement`
  ADD PRIMARY KEY (`worRei_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `activity`
--
ALTER TABLE `activity`
  MODIFY `act_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `activity_detail`
--
ALTER TABLE `activity_detail`
  MODIFY `actDet_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `api_link`
--
ALTER TABLE `api_link`
  MODIFY `apiLin_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `article`
--
ALTER TABLE `article`
  MODIFY `art_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `authorised_ip`
--
ALTER TABLE `authorised_ip`
  MODIFY `autIp_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `billingcompany`
--
ALTER TABLE `billingcompany`
  MODIFY `bil_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `budget`
--
ALTER TABLE `budget`
  MODIFY `bud_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `budget_capex`
--
ALTER TABLE `budget_capex`
  MODIFY `budCap_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `budget_family`
--
ALTER TABLE `budget_family`
  MODIFY `budFam_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `budget_opex`
--
ALTER TABLE `budget_opex`
  MODIFY `budOpe_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `campaign`
--
ALTER TABLE `campaign`
  MODIFY `cam_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `campaign_sites`
--
ALTER TABLE `campaign_sites`
  MODIFY `camSit_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `checklist`
--
ALTER TABLE `checklist`
  MODIFY `che_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `checklist_element`
--
ALTER TABLE `checklist_element`
  MODIFY `cheEle_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `city`
--
ALTER TABLE `city`
  MODIFY `cit_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `contact`
--
ALTER TABLE `contact`
  MODIFY `con_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `contract`
--
ALTER TABLE `contract`
  MODIFY `con_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `contract_file`
--
ALTER TABLE `contract_file`
  MODIFY `conFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `contract_formula`
--
ALTER TABLE `contract_formula`
  MODIFY `conFor_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `contract_invoice`
--
ALTER TABLE `contract_invoice`
  MODIFY `conInv_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `contract_provider`
--
ALTER TABLE `contract_provider`
  MODIFY `conPro_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `country`
--
ALTER TABLE `country`
  MODIFY `cou_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `currency`
--
ALTER TABLE `currency`
  MODIFY `cur_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `currency_rate`
--
ALTER TABLE `currency_rate`
  MODIFY `curRat_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `customer`
--
ALTER TABLE `customer`
  MODIFY `cus_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `department`
--
ALTER TABLE `department`
  MODIFY `dep_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `department_activities`
--
ALTER TABLE `department_activities`
  MODIFY `depAct_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `divers`
--
ALTER TABLE `divers`
  MODIFY `div_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dynfields`
--
ALTER TABLE `dynfields`
  MODIFY `dyn_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `dynfields_list_values`
--
ALTER TABLE `dynfields_list_values`
  MODIFY `dynLisVal_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipement_space_repartition`
--
ALTER TABLE `equipement_space_repartition`
  MODIFY `equSpa_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipments`
--
ALTER TABLE `equipments`
  MODIFY `equ_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipments_logs`
--
ALTER TABLE `equipments_logs`
  MODIFY `equLog_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipment_family`
--
ALTER TABLE `equipment_family`
  MODIFY `equFam_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipment_family_files`
--
ALTER TABLE `equipment_family_files`
  MODIFY `equFamFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipment_file`
--
ALTER TABLE `equipment_file`
  MODIFY `equFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `equipment_localisation`
--
ALTER TABLE `equipment_localisation`
  MODIFY `equLoc_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `events`
--
ALTER TABLE `events`
  MODIFY `eve_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `import_contract_data`
--
ALTER TABLE `import_contract_data`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `import_data`
--
ALTER TABLE `import_data`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `import_proinv`
--
ALTER TABLE `import_proinv`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention`
--
ALTER TABLE `intervention`
  MODIFY `int_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention_bi_tech`
--
ALTER TABLE `intervention_bi_tech`
  MODIFY `intBiTec_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention_equipment`
--
ALTER TABLE `intervention_equipment`
  MODIFY `intEqu_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention_file`
--
ALTER TABLE `intervention_file`
  MODIFY `intFil_id` smallint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention_file_category`
--
ALTER TABLE `intervention_file_category`
  MODIFY `intFilCat_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention_log`
--
ALTER TABLE `intervention_log`
  MODIFY `intLog_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention_message`
--
ALTER TABLE `intervention_message`
  MODIFY `intMes_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `intervention_message_link_file`
--
ALTER TABLE `intervention_message_link_file`
  MODIFY `intMesLinFil_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `langue`
--
ALTER TABLE `langue`
  MODIFY `lan_id` smallint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `langue_traduction`
--
ALTER TABLE `langue_traduction`
  MODIFY `lanTra_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `merchandising`
--
ALTER TABLE `merchandising`
  MODIFY `mer_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `merchandising_photos`
--
ALTER TABLE `merchandising_photos`
  MODIFY `merPho_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `merchandising_sites`
--
ALTER TABLE `merchandising_sites`
  MODIFY `merSit_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `merchandising_status`
--
ALTER TABLE `merchandising_status`
  MODIFY `merSta_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `operation_log`
--
ALTER TABLE `operation_log`
  MODIFY `opeLog_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `owner`
--
ALTER TABLE `owner`
  MODIFY `own_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `owner_contract`
--
ALTER TABLE `owner_contract`
  MODIFY `ownCon_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `owner_contract_file`
--
ALTER TABLE `owner_contract_file`
  MODIFY `ownConFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `owner_file`
--
ALTER TABLE `owner_file`
  MODIFY `ownFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `parameter`
--
ALTER TABLE `parameter`
  MODIFY `par_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `payment_periods`
--
ALTER TABLE `payment_periods`
  MODIFY `payPer_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider`
--
ALTER TABLE `provider`
  MODIFY `pro_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_defaults`
--
ALTER TABLE `provider_defaults`
  MODIFY `proDef_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_file`
--
ALTER TABLE `provider_file`
  MODIFY `proFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_file_category`
--
ALTER TABLE `provider_file_category`
  MODIFY `proFilCat_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_invoice`
--
ALTER TABLE `provider_invoice`
  MODIFY `proInv_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_link_activity`
--
ALTER TABLE `provider_link_activity`
  MODIFY `proAct_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_quote`
--
ALTER TABLE `provider_quote`
  MODIFY `proQuo_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_quote_message`
--
ALTER TABLE `provider_quote_message`
  MODIFY `proQuoMes_id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_request`
--
ALTER TABLE `provider_request`
  MODIFY `proReq_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `provider_request_bi`
--
ALTER TABLE `provider_request_bi`
  MODIFY `proReqBi_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `region`
--
ALTER TABLE `region`
  MODIFY `reg_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `rights_admin`
--
ALTER TABLE `rights_admin`
  MODIFY `rig_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `secteur`
--
ALTER TABLE `secteur`
  MODIFY `sec_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `secteur_site`
--
ALTER TABLE `secteur_site`
  MODIFY `secSit_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `sended_mails`
--
ALTER TABLE `sended_mails`
  MODIFY `senMai_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `sign`
--
ALTER TABLE `sign`
  MODIFY `sig_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `sign_budget`
--
ALTER TABLE `sign_budget`
  MODIFY `sigBud_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `sign_file`
--
ALTER TABLE `sign_file`
  MODIFY `sigFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `sign_texte`
--
ALTER TABLE `sign_texte`
  MODIFY `sigTex_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site`
--
ALTER TABLE `site`
  MODIFY `sit_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_activity_amounts`
--
ALTER TABLE `site_activity_amounts`
  MODIFY `sitActAmo_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_budget`
--
ALTER TABLE `site_budget`
  MODIFY `sitBud_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_control`
--
ALTER TABLE `site_control`
  MODIFY `sitCon_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_control_checkelements`
--
ALTER TABLE `site_control_checkelements`
  MODIFY `sitConChe_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_control_file`
--
ALTER TABLE `site_control_file`
  MODIFY `sitConFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_control_file_category`
--
ALTER TABLE `site_control_file_category`
  MODIFY `sitConFilCat_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_entity`
--
ALTER TABLE `site_entity`
  MODIFY `sitEnt_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_file`
--
ALTER TABLE `site_file`
  MODIFY `sitFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_implantation`
--
ALTER TABLE `site_implantation`
  MODIFY `sitImp_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `site_space`
--
ALTER TABLE `site_space`
  MODIFY `sitSpa_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `space`
--
ALTER TABLE `space`
  MODIFY `spa_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `status`
--
ALTER TABLE `status`
  MODIFY `sta_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `status_group`
--
ALTER TABLE `status_group`
  MODIFY `staGro_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `status_params`
--
ALTER TABLE `status_params`
  MODIFY `staPar_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `status_rules`
--
ALTER TABLE `status_rules`
  MODIFY `staRul_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `survey`
--
ALTER TABLE `survey`
  MODIFY `sur_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `survey_answers`
--
ALTER TABLE `survey_answers`
  MODIFY `surAns_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `survey_questions`
--
ALTER TABLE `survey_questions`
  MODIFY `surQue_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `survey_questions_options`
--
ALTER TABLE `survey_questions_options`
  MODIFY `surQueOpt_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `survey_sections`
--
ALTER TABLE `survey_sections`
  MODIFY `surSec_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `survey_sites`
--
ALTER TABLE `survey_sites`
  MODIFY `surSit_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `texte`
--
ALTER TABLE `texte`
  MODIFY `tex_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `tva`
--
ALTER TABLE `tva`
  MODIFY `tva_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_department`
--
ALTER TABLE `user_department`
  MODIFY `useDep_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_imports`
--
ALTER TABLE `user_imports`
  MODIFY `useImp_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_log`
--
ALTER TABLE `user_log`
  MODIFY `useLog_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_params`
--
ALTER TABLE `user_params`
  MODIFY `usePar_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_region`
--
ALTER TABLE `user_region`
  MODIFY `useReg_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_secteur`
--
ALTER TABLE `user_secteur`
  MODIFY `useSec_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_sign`
--
ALTER TABLE `user_sign`
  MODIFY `useSig_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `user_site`
--
ALTER TABLE `user_site`
  MODIFY `useSit_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `veritas_intervention`
--
ALTER TABLE `veritas_intervention`
  MODIFY `verInt_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `veritas_observation`
--
ALTER TABLE `veritas_observation`
  MODIFY `verObs_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `veritas_rapport`
--
ALTER TABLE `veritas_rapport`
  MODIFY `verRap_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `veritas_traitement`
--
ALTER TABLE `veritas_traitement`
  MODIFY `verTra_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `webservice_intervention`
--
ALTER TABLE `webservice_intervention`
  MODIFY `webInt_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `worksite`
--
ALTER TABLE `worksite`
  MODIFY `wor_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `worksite_budgets`
--
ALTER TABLE `worksite_budgets`
  MODIFY `worBud_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `worksite_category`
--
ALTER TABLE `worksite_category`
  MODIFY `worCat_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `worksite_file`
--
ALTER TABLE `worksite_file`
  MODIFY `worFil_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `worksite_reimbursement`
--
ALTER TABLE `worksite_reimbursement`
  MODIFY `worRei_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
