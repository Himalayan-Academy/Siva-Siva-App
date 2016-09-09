-- phpMyAdmin SQL Dump
-- version 4.0.10.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 06, 2016 at 10:59 AM
-- Server version: 5.5.44-0ubuntu0.14.04.1
-- PHP Version: 5.5.9-1ubuntu4.13



/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `jnanam`
--

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `category_id` int(11) NOT NULL ,
  `name` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `entered_date` timestamp NULL ,
  PRIMARY KEY (`category_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `category_faq`
--

CREATE TABLE `category_faq` (
  `category_faq_id` int(11) NOT NULL ,
  `category_id` int(11) NOT NULL,
  `faq_id` int(11) NOT NULL,
  PRIMARY KEY (`category_faq_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `category_item`
--

CREATE TABLE `category_item` (
  `category_item_id` int(11) NOT NULL ,
  `category_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  PRIMARY KEY (`category_item_id`)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `category_quote`
--

CREATE TABLE `category_quote` (
  `category_quote_id` int(11) NOT NULL ,
  `category_id` int(11) NOT NULL,
  `quote_id` int(11) NOT NULL,
  PRIMARY KEY (`category_quote_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `category_tree`
--

CREATE TABLE `category_tree` (
  `category_tree_id` int(11) NOT NULL ,
  `parent_id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  PRIMARY KEY (`category_tree_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `channel`
--

CREATE TABLE `channel` (
  `channel_id` int(11) NOT NULL ,
  `item_id` int(11) NOT NULL,
  `url` text NOT NULL,
  `channel_name` text NOT NULL,
  PRIMARY KEY (`channel_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `collection`
--

CREATE TABLE `collection` (
  `collection_id` bigint(20) NOT NULL ,
  `name` varchar(255) DEFAULT NULL,
  `thumbnail_url` text,
  `poster_url` text,
  `tags` text,
  `keywords` text,
  PRIMARY KEY (`collection_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `collection_item`
--

CREATE TABLE `collection_item` (
  `collection_item_id` int(11) NOT NULL ,
  `collection_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `play_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`collection_item_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `component`
--

CREATE TABLE `component` (
  `component_id` bigint(20) NOT NULL ,
  `collection_id` int(11) NOT NULL,
  `description` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`component_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `faq`
--

CREATE TABLE `faq` (
  `faq_id` int(11) NOT NULL ,
  `question` text NOT NULL,
  `short_answer` text NOT NULL,
  `long_answer` text NOT NULL,
  `discussion` text,
  `production_notes` text,
  `entered_date` timestamp NULL ,
  `last_modified_date` datetime NOT NULL,
  `entered_by` varchar(255) NOT NULL,
  `last_modified_by` varchar(255) NOT NULL,
  PRIMARY KEY (`faq_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `item`
--

CREATE TABLE `item` (
  `item_id` bigint(20)  NOT NULL ,
  `file_id` varchar(255) NOT NULL,
  `approved_for_public` text DEFAULT 'YES',
  `media_type` text NOT NULL,
  `title` text,
  `sub_title` text,
  `author` text,
  `subject` text,
  `category` text,
  `keywords` text,
  `sales_blurb` text,
  `description` text,
  `language` text DEFAULT NULL,
  `isbn` varchar(255) DEFAULT NULL,
  `product_details` text,
  `edition` text,
  `publisher` text ,
  `thumbnail` varchar(255) DEFAULT NULL,
  `audio_file_transcript` text,
  `duration` int(11) DEFAULT NULL,
  `artists` text,
  `singer` text,
  `composer` text,
  `genre` text,
  `transcription_done` text DEFAULT NULL,
  `model_for_study` text DEFAULT 'NO',
  `deity` text,
  `theme` varchar(255) DEFAULT NULL,
  `ragam` text,
  `talam` text,
  `sruti_tonic` text NOT NULL ,
  `graha_note` text,
  `lyrics_original` text,
  `lyrics_original_transliteration` text,
  `lyrics_literal_translation` text,
  `geo_location` text,
  `transcriber` text,
  `audience` text,
  `content` text ,
  `assigned_to` text,
  `attribution_required` TEXT,
  `contributor` text,
  `copyright_holder` text ,
  `audio_quality` char(1) DEFAULT NULL,
  `copyright` text,
  `coverage` text,
  `component_id` int(11) DEFAULT NULL,
  `compression` text,
  `creator` text,
  `data_type` text,
  `data_unit` text,
  `date_entered` timestamp NOT NULL ,
  `date_created` date DEFAULT NULL,
  `date_taken` date DEFAULT NULL,
  `entered_by` text,
  `file_size` text,
  `file_type` char(1) DEFAULT NULL,
  `format` text,
  `framesize` varchar(9) DEFAULT NULL,
  `identifier` text,
  `isformatof` text,
  `length_in_bytes` decimal(10,0) DEFAULT NULL,
  `location_url` text,
  `locator` text,
  `metadata_data` text,
  `photographer` text,
  `policy` text,
  `production_notes` text,
  `proofed` TEXT DEFAULT NULL,
  `purchase_url` text,
  `data_quality` char(1) DEFAULT NULL,
  `relation` text,
  `rights` text,
  `rect_size` decimal(10,0) DEFAULT NULL,
  `source` text,
  `transcribed_date` date DEFAULT NULL,
  `lyrics_id` int(10) DEFAULT NULL,
  `use_permit_released` TEXT DEFAULT NULL,
  `allowed_groups` varchar(300) DEFAULT 'All',
  `volume_number` int(11) DEFAULT NULL,
  `part_number` int(11) DEFAULT NULL,
  `section_number` decimal(10,0) DEFAULT NULL,
  `chapter_number` int(11) DEFAULT NULL,
  `page_number` int(11) DEFAULT NULL,
  `paragraph_number` int(11) DEFAULT NULL,
  `tags` text,
  `poster` varchar(800) DEFAULT NULL,
  PRIMARY KEY (`item_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `item_faq`
--

CREATE TABLE `item_faq` (
  `item_faq_id` int(11) NOT NULL ,
  `item_id` int(11) NOT NULL,
  `faq_id` int(11) NOT NULL,
  PRIMARY KEY (`item_faq_id`)
);

-- --------------------------------------------------------

--
-- Table structure for table `item_format`
--

CREATE TABLE `item_format` (
  `item_format_id` int(11) NOT NULL ,
  `item_id` int(11) NOT NULL,
  `format_name` varchar(255) NOT NULL,
  `url` text,
  `isbn` varchar(255) DEFAULT NULL,
  `sale_date` datetime DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`item_format_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `item_quote`
--

CREATE TABLE `item_quote` (
  `item_quote_id` int(11) NOT NULL ,
  `item_id` int(11) NOT NULL,
  `quote_id` int(11) NOT NULL,
  PRIMARY KEY (`item_quote_id`)
);

-- --------------------------------------------------------

--
-- Table structure for table `lexicon`
--

CREATE TABLE `lexicon` (
  `lexicon_id` int(11) NOT NULL ,
  `word` varchar(255) NOT NULL,
  `see_also` text,
  `definition` text NOT NULL,
  `production_notes` text NOT NULL,
  PRIMARY KEY (`lexicon_id`)
)  ;

-- --------------------------------------------------------

--
-- Table structure for table `quote`
--

CREATE TABLE `quote` (
  `quote_id` int(11) NOT NULL ,
  `subject` text,
  `content` text NOT NULL,
  `citation` text CHARACTER,
  `source_item_id` int(11) DEFAULT NULL ,
  `source_url` text,
  `approved_for_public` text DEFAULT 'YES',
  `entered_by` varchar(255) NOT NULL,
  `entered_date` timestamp NULL ,
  `last_modified_by` varchar(255) NOT NULL,
  `last_modified_date` datetime NOT NULL,
  `author` varchar(255) NOT NULL,
  `author_dates` varchar(255) DEFAULT NULL,
  `author_info` text,
  `quote_date` date DEFAULT NULL,
  `hinduism_today_usage` datetime DEFAULT NULL,
  `production_notes` text,
  PRIMARY KEY (`quote_id`)
)  ;

