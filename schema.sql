-- ============================================================
--  NewsClip — Database Schema
--  Compatible: TiDB Cloud Serverless (MySQL 8.0+)
--  Instructions: Run this file in TiDB Cloud SQL Editor
--  Database: test (default TiDB Cloud Serverless database)
-- ============================================================

USE test;

-- ------------------------------------------------------------
-- Table 1: users
-- Menyimpan data akun pengguna aplikasi
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    user_id    INT          NOT NULL AUTO_INCREMENT,
    username   VARCHAR(50)  NOT NULL,
    email      VARCHAR(100) NOT NULL,
    password   VARCHAR(255) NOT NULL,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_username (username),
    UNIQUE KEY uq_users_email    (email)
);

-- ------------------------------------------------------------
-- Table 2: folders
-- Menyimpan kategori/folder buatan pengguna
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS folders (
    folder_id   INT          NOT NULL AUTO_INCREMENT,
    user_id     INT          NOT NULL,
    folder_name VARCHAR(100) NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (folder_id),
    KEY idx_folders_user_id (user_id),
    CONSTRAINT fk_folders_user_id
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- Table 3: bookmarks
-- Menyimpan artikel kliping beserta catatan & metadata personal
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS bookmarks (
    bookmark_id    INT          NOT NULL AUTO_INCREMENT,
    user_id        INT          NOT NULL,
    folder_id      INT                   DEFAULT NULL,

    -- Data dari NewsAPI (Fakta)
    title          VARCHAR(500) NOT NULL,
    author         VARCHAR(200)          DEFAULT NULL,
    source_name    VARCHAR(200)          DEFAULT NULL,
    image_url      TEXT                  DEFAULT NULL,
    article_url    TEXT         NOT NULL,
    published_date DATETIME              DEFAULT NULL,
    description    TEXT                  DEFAULT NULL,

    -- Data Inputan Pengguna (Dinamis)
    my_notes       TEXT                  DEFAULT NULL,
    reading_status ENUM('Belum Dibaca','Selesai')
                               NOT NULL  DEFAULT 'Belum Dibaca',
    saved_at       TIMESTAMP    NOT NULL  DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (bookmark_id),
    KEY idx_bookmarks_user_id   (user_id),
    KEY idx_bookmarks_folder_id (folder_id),
    CONSTRAINT fk_bookmarks_user_id
        FOREIGN KEY (user_id)   REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_bookmarks_folder_id
        FOREIGN KEY (folder_id) REFERENCES folders(folder_id)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- Verifikasi: tampilkan semua tabel yang telah dibuat
-- ------------------------------------------------------------
SHOW TABLES;
