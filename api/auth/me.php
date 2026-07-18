<?php
/**
 * GET /api/auth/me
 * Ambil profil pengguna yang sedang login
 */

declare(strict_types=1);

require_once __DIR__ . '/../helpers.php';

setCors();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    errorResponse('Method not allowed', 405);
}

$userId = requireAuth();
$db     = getDB();

$stmt = $db->prepare(
    'SELECT user_id, username, email, created_at FROM users WHERE user_id = ? LIMIT 1'
);
$stmt->execute([$userId]);
$user = $stmt->fetch();

if (!$user) {
    errorResponse('Pengguna tidak ditemukan', 404);
}

successResponse($user);
