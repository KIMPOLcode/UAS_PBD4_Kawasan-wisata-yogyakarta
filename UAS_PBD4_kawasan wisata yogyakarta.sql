-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 25, 2024 at 04:41 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uas`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `count_zonas` ()   BEGIN
    DECLARE total INT;

    
    SELECT COUNT(*) INTO total FROM Zona;

    
    SELECT CONCAT('Total zona yang tersedia: ', total) AS hasil;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_pedagang_by_zona_acara` (IN `zona_id` INT, IN `acara_id` INT)   BEGIN
    DECLARE pedagang_count INT;
    
    
    SELECT COUNT(*) INTO pedagang_count
    FROM Pedagang p
    JOIN Pedagang_Acara pa ON p.id_pedagang = pa.id_pedagang
    WHERE p.id_zona = zona_id AND pa.id_acara = acara_id;
    
    
    IF pedagang_count > 0 THEN
        SELECT CONCAT('Jumlah pedagang yang berjualan di zona ', zona_id, ' dan mengikuti acara ', acara_id, ': ', pedagang_count) AS hasil;
    ELSE
        SELECT 'Tidak ada pedagang yang sesuai dengan kriteria';
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `get_all_zonas` () RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE result TEXT;
    SET result = (
        SELECT CONCAT('[', GROUP_CONCAT(
            CONCAT(
                '{"id_zona": ', id_zona,
                ', "nama_zona": "', nama_zona,
                '", "deskripsi": "', deskripsi,
                '", "kapasitas": ', kapasitas, '}'
            )
        ORDER BY id_zona SEPARATOR ', '), ']')
        FROM Zona
    );
    RETURN result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_pedagang_by_zona_acara` (`zona_id` INT, `acara_id` INT) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
    DECLARE result TEXT;
    SET result = (
        SELECT CONCAT('[', GROUP_CONCAT(
            CONCAT(
                '{"id_pedagang": ', p.id_pedagang,
                ', "nama_pedagang": "', p.nama_pedagang,
                '", "jenis_dagangan": "', p.jenis_dagangan, '"}'
            )
        ORDER BY p.id_pedagang SEPARATOR ', '), ']')
        FROM Pedagang p
        JOIN Pedagang_Acara pa ON p.id_pedagang = pa.id_pedagang
        WHERE p.id_zona = zona_id AND pa.id_acara = acara_id
    );
    RETURN result;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `acara`
--

CREATE TABLE `acara` (
  `id_acara` int(11) NOT NULL,
  `nama_acara` varchar(100) DEFAULT NULL,
  `tanggal` date DEFAULT NULL,
  `id_zona` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `acara`
--

INSERT INTO `acara` (`id_acara`, `nama_acara`, `tanggal`, `id_zona`) VALUES
(1, 'Festival Kuliner', '2024-07-10', 2),
(2, 'Pameran Seni Rupa', '2024-08-15', 3),
(3, 'Pentas Musik Tradisional', '2024-09-20', 3),
(4, 'Pesta Rakyat', '2024-10-05', 4),
(5, 'Lomba Lukis Anak', '2024-11-25', 4);

-- --------------------------------------------------------

--
-- Table structure for table `barang`
--

CREATE TABLE `barang` (
  `id_barang` int(11) NOT NULL,
  `id_pedagang` int(11) DEFAULT NULL,
  `nama_barang` varchar(100) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `barang`
--

INSERT INTO `barang` (`id_barang`, `id_pedagang`, `nama_barang`, `stok`, `harga`) VALUES
(2, 1, 'Celana', 30, 120000.00),
(3, 2, 'Sepatu', 20, 250000.00),
(4, 3, 'Tas', 40, 180000.00),
(5, 3, 'Topi', 15, 75000.00),
(7, 1, 'Baju', 60, 150000.00);

--
-- Triggers `barang`
--
DELIMITER $$
CREATE TRIGGER `after_delete_barang` AFTER DELETE ON `barang` FOR EACH ROW BEGIN
    INSERT INTO Log_Barang (event_type, id_barang, id_pedagang, nama_barang, stok_after, harga_after)
    VALUES ('AFTER DELETE', OLD.id_barang, OLD.id_pedagang, OLD.nama_barang, OLD.stok, OLD.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_barang` AFTER INSERT ON `barang` FOR EACH ROW BEGIN
    INSERT INTO Log_Barang (event_type, id_barang, id_pedagang, nama_barang, stok_after, harga_after)
    VALUES ('AFTER INSERT', NEW.id_barang, NEW.id_pedagang, NEW.nama_barang, NEW.stok, NEW.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_barang` AFTER UPDATE ON `barang` FOR EACH ROW BEGIN
    IF OLD.stok != NEW.stok OR OLD.harga != NEW.harga THEN
        INSERT INTO Log_Barang (event_type, id_barang, id_pedagang, nama_barang, stok_before, stok_after, harga_before, harga_after)
        VALUES ('AFTER UPDATE', NEW.id_barang, NEW.id_pedagang, NEW.nama_barang, OLD.stok, NEW.stok, OLD.harga, NEW.harga);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_barang` BEFORE DELETE ON `barang` FOR EACH ROW BEGIN
    INSERT INTO Log_Barang (event_type, id_barang, id_pedagang, nama_barang, stok_before, harga_before)
    VALUES ('BEFORE DELETE', OLD.id_barang, OLD.id_pedagang, OLD.nama_barang, OLD.stok, OLD.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_barang` BEFORE INSERT ON `barang` FOR EACH ROW BEGIN
    INSERT INTO Log_Barang (event_type, id_barang, id_pedagang, nama_barang, stok_before, harga_before)
    VALUES ('BEFORE INSERT', NEW.id_barang, NEW.id_pedagang, NEW.nama_barang, NEW.stok, NEW.harga);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_barang` BEFORE UPDATE ON `barang` FOR EACH ROW BEGIN
    IF OLD.stok != NEW.stok OR OLD.harga != NEW.harga THEN
        INSERT INTO Log_Barang (event_type, id_barang, id_pedagang, nama_barang, stok_before, stok_after, harga_before, harga_after)
        VALUES ('BEFORE UPDATE', OLD.id_barang, OLD.id_pedagang, OLD.nama_barang, OLD.stok, NEW.stok, OLD.harga, NEW.harga);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `cascaded_view`
-- (See below for the actual view)
--
CREATE TABLE `cascaded_view` (
`id_penjualan` int(11)
,`id_barang` int(11)
,`id_pelanggan` int(11)
,`jumlah` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `fasilitas`
--

CREATE TABLE `fasilitas` (
  `id_fasilitas` int(11) NOT NULL,
  `nama_fasilitas` varchar(50) DEFAULT NULL,
  `tipe_fasilitas` varchar(50) DEFAULT NULL,
  `id_zona` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fasilitas`
--

INSERT INTO `fasilitas` (`id_fasilitas`, `nama_fasilitas`, `tipe_fasilitas`, `id_zona`) VALUES
(1, 'Toilet Umum', 'Kebersihan', 1),
(2, 'Tempat Duduk', 'Kenyamanan', 1),
(3, 'Pusat Informasi', 'Informasi', 2),
(4, 'Tempat Sampah', 'Kebersihan', 3),
(5, 'Area Parkir', 'Transportasi', 4);

-- --------------------------------------------------------

--
-- Stand-in structure for view `horizontal_view`
-- (See below for the actual view)
--
CREATE TABLE `horizontal_view` (
`id_barang` int(11)
,`nama_barang` varchar(100)
,`harga` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `inside_view`
-- (See below for the actual view)
--
CREATE TABLE `inside_view` (
`id_penjualan` int(11)
,`id_barang` int(11)
,`id_pelanggan` int(11)
,`jumlah` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `local_view`
-- (See below for the actual view)
--
CREATE TABLE `local_view` (
`id_penjualan` int(11)
,`id_barang` int(11)
,`id_pelanggan` int(11)
,`jumlah` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `log_barang`
--

CREATE TABLE `log_barang` (
  `id_log` int(11) NOT NULL,
  `event_type` varchar(50) DEFAULT NULL,
  `id_barang` int(11) DEFAULT NULL,
  `id_pedagang` int(11) DEFAULT NULL,
  `nama_barang` varchar(100) DEFAULT NULL,
  `stok_before` int(11) DEFAULT NULL,
  `stok_after` int(11) DEFAULT NULL,
  `harga_before` decimal(10,2) DEFAULT NULL,
  `harga_after` decimal(10,2) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_barang`
--

INSERT INTO `log_barang` (`id_log`, `event_type`, `id_barang`, `id_pedagang`, `nama_barang`, `stok_before`, `stok_after`, `harga_before`, `harga_after`, `timestamp`) VALUES
(3, 'BEFORE INSERT', 0, 1, 'Baju', 60, NULL, 150000.00, NULL, '2024-07-24 13:20:58'),
(4, 'AFTER INSERT', 7, 1, 'Baju', NULL, 60, NULL, 150000.00, '2024-07-24 13:20:58'),
(5, 'BEFORE UPDATE', 1, 1, 'Baju', 50, 75, 150000.00, 2000000.00, '2024-07-24 13:24:03'),
(6, 'AFTER UPDATE', 1, 1, 'Baju', 50, 75, 150000.00, 2000000.00, '2024-07-24 13:24:03'),
(7, 'BEFORE DELETE', 1, 1, 'Baju', 75, NULL, 2000000.00, NULL, '2024-07-24 13:27:23'),
(8, 'AFTER DELETE', 1, 1, 'Baju', NULL, 75, NULL, 2000000.00, '2024-07-24 13:27:23');

-- --------------------------------------------------------

--
-- Table structure for table `pedagang`
--

CREATE TABLE `pedagang` (
  `id_pedagang` int(11) NOT NULL,
  `nama_pedagang` varchar(50) DEFAULT NULL,
  `jenis_dagangan` varchar(50) DEFAULT NULL,
  `id_zona` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pedagang`
--

INSERT INTO `pedagang` (`id_pedagang`, `nama_pedagang`, `jenis_dagangan`, `id_zona`) VALUES
(1, 'Sate Pak Joko', 'Makanan', 2),
(2, 'Batik Bu Siti', 'Kerajinan', 3),
(3, 'Es Dawet Bu Rina', 'Minuman', 2),
(4, 'Lukisan Pak Budi', 'Seni', 3),
(5, 'Mainan Anak', 'Hiburan', 4);

-- --------------------------------------------------------

--
-- Table structure for table `pedagang_acara`
--

CREATE TABLE `pedagang_acara` (
  `id_pedagang` int(11) NOT NULL,
  `id_acara` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pedagang_acara`
--

INSERT INTO `pedagang_acara` (`id_pedagang`, `id_acara`) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 3),
(5, 4);

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `nama_pelanggan` varchar(100) NOT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `telepon` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pelanggan`
--

INSERT INTO `pelanggan` (`id_pelanggan`, `nama_pelanggan`, `alamat`, `email`, `telepon`) VALUES
(1, 'John Doe', 'Jl. Raya No. 123', 'john.doe@example.com', '081234567890'),
(2, 'Jane Smith', 'Jl. Mawar No. 45', 'jane.smith@example.com', '085678912345'),
(3, 'Michael Johnson', 'Jl. Melati No. 78', 'michael.johnson@example.com', '081112223344'),
(4, 'Pelanggan Baru', 'Alamat Baru', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `penjualan`
--

CREATE TABLE `penjualan` (
  `id_penjualan` int(11) NOT NULL,
  `id_barang` int(11) DEFAULT NULL,
  `id_pelanggan` int(11) DEFAULT NULL,
  `tanggal_penjualan` date DEFAULT NULL,
  `jumlah` int(11) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vertical_view`
-- (See below for the actual view)
--
CREATE TABLE `vertical_view` (
`id_pelanggan` int(11)
,`nama_pelanggan` varchar(100)
,`alamat` varchar(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `zona`
--

CREATE TABLE `zona` (
  `id_zona` int(11) NOT NULL,
  `nama_zona` varchar(50) DEFAULT NULL,
  `deskripsi` text DEFAULT NULL,
  `kapasitas` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `zona`
--

INSERT INTO `zona` (`id_zona`, `nama_zona`, `deskripsi`, `kapasitas`) VALUES
(1, 'Zona A', 'Kawasan utama pedestrian', 500),
(2, 'Zona B', 'Kawasan belanja dan kuliner', 300),
(3, 'Zona C', 'Kawasan seni dan budaya', 200),
(4, 'Zona D', 'Kawasan rekreasi keluarga', 400),
(5, 'Zona E', 'Kawasan pameran dan festival', 350);

-- --------------------------------------------------------

--
-- Structure for view `cascaded_view`
--
DROP TABLE IF EXISTS `cascaded_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cascaded_view`  AS SELECT `inside_view`.`id_penjualan` AS `id_penjualan`, `inside_view`.`id_barang` AS `id_barang`, `inside_view`.`id_pelanggan` AS `id_pelanggan`, `inside_view`.`jumlah` AS `jumlah` FROM `inside_view`WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `horizontal_view`
--
DROP TABLE IF EXISTS `horizontal_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horizontal_view`  AS SELECT `barang`.`id_barang` AS `id_barang`, `barang`.`nama_barang` AS `nama_barang`, `barang`.`harga` AS `harga` FROM `barang` ;

-- --------------------------------------------------------

--
-- Structure for view `inside_view`
--
DROP TABLE IF EXISTS `inside_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `inside_view`  AS SELECT `penjualan`.`id_penjualan` AS `id_penjualan`, `penjualan`.`id_barang` AS `id_barang`, `penjualan`.`id_pelanggan` AS `id_pelanggan`, `penjualan`.`jumlah` AS `jumlah` FROM `penjualan`WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `local_view`
--
DROP TABLE IF EXISTS `local_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `local_view`  AS SELECT `inside_view`.`id_penjualan` AS `id_penjualan`, `inside_view`.`id_barang` AS `id_barang`, `inside_view`.`id_pelanggan` AS `id_pelanggan`, `inside_view`.`jumlah` AS `jumlah` FROM `inside_view`WITH LOCAL CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `vertical_view`
--
DROP TABLE IF EXISTS `vertical_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vertical_view`  AS SELECT `pelanggan`.`id_pelanggan` AS `id_pelanggan`, `pelanggan`.`nama_pelanggan` AS `nama_pelanggan`, `pelanggan`.`alamat` AS `alamat` FROM `pelanggan` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `acara`
--
ALTER TABLE `acara`
  ADD PRIMARY KEY (`id_acara`),
  ADD KEY `id_zona` (`id_zona`);

--
-- Indexes for table `barang`
--
ALTER TABLE `barang`
  ADD PRIMARY KEY (`id_barang`),
  ADD KEY `id_pedagang` (`id_pedagang`);

--
-- Indexes for table `fasilitas`
--
ALTER TABLE `fasilitas`
  ADD PRIMARY KEY (`id_fasilitas`),
  ADD KEY `id_zona` (`id_zona`);

--
-- Indexes for table `log_barang`
--
ALTER TABLE `log_barang`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `pedagang`
--
ALTER TABLE `pedagang`
  ADD PRIMARY KEY (`id_pedagang`),
  ADD KEY `id_zona` (`id_zona`);

--
-- Indexes for table `pedagang_acara`
--
ALTER TABLE `pedagang_acara`
  ADD PRIMARY KEY (`id_pedagang`,`id_acara`),
  ADD KEY `id_acara` (`id_acara`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`);

--
-- Indexes for table `penjualan`
--
ALTER TABLE `penjualan`
  ADD PRIMARY KEY (`id_penjualan`),
  ADD KEY `id_pelanggan` (`id_pelanggan`),
  ADD KEY `idx_barang_pelanggan` (`id_barang`,`id_pelanggan`),
  ADD KEY `idx_tanggal_jumlah` (`tanggal_penjualan`,`jumlah`);

--
-- Indexes for table `zona`
--
ALTER TABLE `zona`
  ADD PRIMARY KEY (`id_zona`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `barang`
--
ALTER TABLE `barang`
  MODIFY `id_barang` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `log_barang`
--
ALTER TABLE `log_barang`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `pelanggan`
--
ALTER TABLE `pelanggan`
  MODIFY `id_pelanggan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `penjualan`
--
ALTER TABLE `penjualan`
  MODIFY `id_penjualan` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `acara`
--
ALTER TABLE `acara`
  ADD CONSTRAINT `acara_ibfk_1` FOREIGN KEY (`id_zona`) REFERENCES `zona` (`id_zona`);

--
-- Constraints for table `barang`
--
ALTER TABLE `barang`
  ADD CONSTRAINT `barang_ibfk_1` FOREIGN KEY (`id_pedagang`) REFERENCES `pedagang` (`id_pedagang`);

--
-- Constraints for table `fasilitas`
--
ALTER TABLE `fasilitas`
  ADD CONSTRAINT `fasilitas_ibfk_1` FOREIGN KEY (`id_zona`) REFERENCES `zona` (`id_zona`);

--
-- Constraints for table `pedagang`
--
ALTER TABLE `pedagang`
  ADD CONSTRAINT `pedagang_ibfk_1` FOREIGN KEY (`id_zona`) REFERENCES `zona` (`id_zona`);

--
-- Constraints for table `penjualan`
--
ALTER TABLE `penjualan`
  ADD CONSTRAINT `penjualan_ibfk_1` FOREIGN KEY (`id_barang`) REFERENCES `barang` (`id_barang`),
  ADD CONSTRAINT `penjualan_ibfk_2` FOREIGN KEY (`id_pelanggan`) REFERENCES `pelanggan` (`id_pelanggan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
