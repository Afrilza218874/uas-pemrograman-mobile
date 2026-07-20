<?php
require_once __DIR__ . '/../helpers.php';

// Endpoint publik khusus untuk pengujian / screenshot laporan (tanpa Auth)
successResponse("Ini adalah contoh balasan REST API yang berhasil dimuat.", [
    "aplikasi" => "NewsClip UAS",
    "status" => "Berjalan Normal",
    "koneksi_database" => "Terhubung"
]);
