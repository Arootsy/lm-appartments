CREATE TABLE IF NOT EXISTS `owned_appartments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `rent` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

ALTER TABLE `owned_appartments`
    ADD COLUMN IF NOT EXISTS `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
    ADD COLUMN IF NOT EXISTS `owner` varchar(50) NOT NULL,
    ADD COLUMN IF NOT EXISTS `name` varchar(255) NOT NULL,
    ADD COLUMN IF NOT EXISTS `price` int(11) NOT NULL,
    ADD COLUMN IF NOT EXISTS `rent` int(11) DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS `created_at` timestamp NOT NULL DEFAULT current_timestamp();

ALTER TABLE `owned_appartments`
    ENGINE=InnoDB 
    AUTO_INCREMENT=4 
    DEFAULT CHARSET=utf8mb3 
    COLLATE=utf8mb3_unicode_ci;