<?php
/**
 * POST /api/auth/register
 * Endpoint pendaftaran akun baru
 */

declare(strict_types=1);

require_once __DIR__ . '/../helpers.php';

setCors();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    errorResponse('Method not allowed', 405);
}

$body     = getBody();
$username = trim($body['username'] ?? '');
$email    = trim($body['email'] ?? '');
$password = $body['password'] ?? '';

if (empty($username) || empty($email) || empty($password)) {
    errorResponse('Username, email, dan password wajib diisi');
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    errorResponse('Format email tidak valid');
}

if (strlen($password) < 6) {
    errorResponse('Password minimal 6 karakter');
}

if (strlen($username) < 3 || strlen($username) > 50) {
    errorResponse('Username harus antara 3 dan 50 karakter');
}

$db   = getDB();
$stmt = $db->prepare('SELECT user_id FROM users WHERE username = ? OR email = ?');
$stmt->execute([$username, $email]);

if ($stmt->fetch()) {
    errorResponse('Username atau email sudah digunakan', 409);
}

$hashedPassword = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
$stmt = $db->prepare('INSERT INTO users (username, email, password) VALUES (?, ?, ?)');
$stmt->execute([$username, $email, $hashedPassword]);
$userId = (int) $db->lastInsertId();

$token = createJWT(['user_id' => $userId, 'username' => $username]);

successResponse(
    [
        'token'    => $token,
        'user_id'  => $userId,
        'username' => $username,
        'email'    => $email,
    ],
    'Registrasi berhasil',
    201
);
