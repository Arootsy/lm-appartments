CREATE TABLE `appartments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `owner` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
    `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
    `description` text COLLATE utf8_unicode_ci NOT NULL,
    `price` int(11) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;