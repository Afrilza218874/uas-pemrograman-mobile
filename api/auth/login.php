<?php
/**
 * POST /api/auth/login
 * Endpoint login pengguna
 */

declare(strict_types=1);

require_once __DIR__ . '/../helpers.php';

setCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('Method not allowed', 405);
}

$body     = getBody();
$email    = trim($body['email'] ?? '');
$password = $body['password'] ?? '';

if (empty($email) || empty($password)) {
    errorResponse('Email dan password wajib diisi');
}

$db   = getDB();
$stmt = $db->prepare(
    'SELECT user_id, username, email, password FROM users WHERE email = ? LIMIT 1'
);
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password'])) {
    errorResponse('Email atau password salah', 401);
}

$token = createJWT([
    'user_id'  => $user['user_id'],
    'username' => $user['username'],
]);

successResponse(
    [
        'token'    => $token,
        'user_id'  => $user['user_id'],
        'username' => $user['username'],
        'email'    => $user['email'],
    ],
    'Login berhasil'
);
