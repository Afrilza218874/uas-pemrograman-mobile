<?php
/**
 * NewsClip Backend — Shared Helpers
 * Berisi: CORS, Response, JWT (HS256), Database (TiDB Cloud/PDO)
 *
 * Di-include oleh semua endpoint. Bukan endpoint langsung.
 */

declare(strict_types=1);

// ============================================================
// CORS — Izinkan semua origin (Flutter app)
// ============================================================
function setCors(): void
{
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Content-Type: application/json; charset=UTF-8');

    // Handle preflight request
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit();
    }
}

// ============================================================
// RESPONSE HELPERS
// ============================================================
function jsonResponse(array $data, int $code = 200): void
{
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit();
}

function successResponse(mixed $data = null, string $message = 'Success', int $code = 200): void
{
    $response = ['success' => true, 'message' => $message];
    if ($data !== null) {
        $response['data'] = $data;
    }
    jsonResponse($response, $code);
}

function errorResponse(string $message, int $code = 400): void
{
    jsonResponse(['success' => false, 'message' => $message], $code);
}

// ============================================================
// REQUEST BODY
// ============================================================
function getBody(): array
{
    $raw = file_get_contents('php://input');
    $decoded = json_decode($raw ?: '', true);
    return is_array($decoded) ? $decoded : [];
}

// ============================================================
// DATABASE — TiDB Cloud via PDO (MySQL-compatible)
// ============================================================
function getDB(): PDO
{
    $host   = getenv('DB_HOST')   ?: '';
    $port   = getenv('DB_PORT')   ?: '4000';
    $dbname = getenv('DB_NAME')   ?: '';
    $user   = getenv('DB_USER')   ?: '';
    $pass   = getenv('DB_PASS')   ?: '';

    if (empty($host) || empty($dbname) || empty($user)) {
        errorResponse('Database configuration is missing', 500);
    }

    $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";

    // TiDB Cloud membutuhkan SSL. Cari system CA bundle.
    $caBundles = [
        '/etc/pki/tls/certs/ca-bundle.crt',      // Amazon Linux (Vercel)
        '/etc/ssl/certs/ca-certificates.crt',     // Debian/Ubuntu
        '/usr/local/etc/openssl/cert.pem',         // macOS
    ];

    $pdoOptions = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
    ];

    foreach ($caBundles as $caPath) {
        if (file_exists($caPath)) {
            $pdoOptions[PDO::MYSQL_ATTR_SSL_CA] = $caPath;
            break;
        }
    }

    try {
        return new PDO($dsn, $user, $pass, $pdoOptions);
    } catch (PDOException $e) {
        // [DEBUG] Tampilkan informasi user yang dipakai (jangan tampilkan password penuh)
        $maskedPass = empty($pass) ? 'EMPTY' : substr($pass, 0, 2) . '***';
        $debugInfo = " Host: $host | User: $user | Pass: $maskedPass";
        
        errorResponse('Database connection failed: ' . $e->getMessage() . $debugInfo, 500);
    }
}

// ============================================================
// JWT — HS256 Implementation (tanpa library eksternal)
// ============================================================
function _jwtSecret(): string
{
    return getenv('JWT_SECRET') ?: 'newsclip_default_secret_change_me';
}

function _base64urlEncode(string $data): string
{
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function _base64urlDecode(string $data): string
{
    $padLen = strlen($data) % 4;
    if ($padLen !== 0) {
        $data .= str_repeat('=', 4 - $padLen);
    }
    return base64_decode(strtr($data, '-_', '+/'));
}

function createJWT(array $payload): string
{
    $header   = _base64urlEncode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
    $payload  = array_merge($payload, [
        'iat' => time(),
        'exp' => time() + (7 * 24 * 3600), // Token berlaku 7 hari
    ]);
    $payloadB = _base64urlEncode(json_encode($payload));
    $sig      = _base64urlEncode(
        hash_hmac('sha256', "{$header}.{$payloadB}", _jwtSecret(), true)
    );
    return "{$header}.{$payloadB}.{$sig}";
}

function verifyJWT(string $token): ?array
{
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return null;
    }

    [$header, $payloadB, $sig] = $parts;

    // Verifikasi signature
    $expected = _base64urlEncode(
        hash_hmac('sha256', "{$header}.{$payloadB}", _jwtSecret(), true)
    );
    if (!hash_equals($expected, $sig)) {
        return null;
    }

    // Decode payload
    $payload = json_decode(_base64urlDecode($payloadB), true);
    if (!is_array($payload)) {
        return null;
    }

    // Cek expiry
    if (isset($payload['exp']) && $payload['exp'] < time()) {
        return null;
    }

    return $payload;
}

// ============================================================
// AUTH MIDDLEWARE
// ============================================================
function requireAuth(): int
{
    // Ambil Authorization header (support berbagai environment)
    $authHeader = '';

    if (!empty($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    } elseif (!empty($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    } elseif (function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }

    if (empty($authHeader) || !str_starts_with($authHeader, 'Bearer ')) {
        errorResponse('Unauthorized: Token tidak ditemukan', 401);
    }

    $token   = substr($authHeader, 7);
    $payload = verifyJWT($token);

    if ($payload === null) {
        errorResponse('Unauthorized: Token tidak valid atau sudah kedaluwarsa', 401);
    }

    return (int) $payload['user_id'];
}
