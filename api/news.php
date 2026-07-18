<?php
/**
 * NewsAPI Proxy
 * Mem-bypass limitasi CORS NewsAPI untuk aplikasi Web (Flutlab)
 */
require_once __DIR__ . '/helpers.php';
setCors();

$endpoint = $_GET['endpoint'] ?? '';
if (empty($endpoint)) {
    errorResponse('Endpoint required', 400);
}

// Hapus endpoint dari GET parameters agar tidak ikut masuk ke URL NewsAPI
unset($_GET['endpoint']);

// Pastikan ada '/' di awal endpoint jika belum ada
$endpoint = ltrim($endpoint, '/');

// Build query string untuk diteruskan
$queryString = http_build_query($_GET);
$url = "https://newsapi.org/v2/{$endpoint}?{$queryString}";

// Ambil data via cURL (Server-to-Server)
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
// NewsAPI mewajibkan header User-Agent untuk server-to-server request
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'User-Agent: NewsClip-Backend-Proxy/1.0'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

http_response_code($httpCode);
header('Content-Type: application/json; charset=UTF-8');
echo $response;
