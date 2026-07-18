<?php
/**
 * GET  /api/folders  — Ambil semua folder milik user
 * POST /api/folders  — Buat folder baru
 */

declare(strict_types=1);

require_once __DIR__ . '/../helpers.php';

setCors();

$userId = requireAuth();
$method = $_SERVER['REQUEST_METHOD'];
$db     = getDB();

if ($method === 'GET') {

    $stmt = $db->prepare('
        SELECT
            f.folder_id,
            f.folder_name,
            f.created_at,
            COUNT(b.bookmark_id) AS bookmark_count
        FROM folders f
        LEFT JOIN bookmarks b
            ON b.folder_id = f.folder_id AND b.user_id = f.user_id
        WHERE f.user_id = ?
        GROUP BY f.folder_id, f.folder_name, f.created_at
        ORDER BY f.created_at DESC
    ');
    $stmt->execute([$userId]);
    $folders = $stmt->fetchAll();

    foreach ($folders as &$folder) {
        $folder['folder_id']      = (int) $folder['folder_id'];
        $folder['bookmark_count'] = (int) $folder['bookmark_count'];
    }
    unset($folder);

    successResponse($folders);

} elseif ($method === 'POST') {

    $body       = getBody();
    $folderName = trim($body['folder_name'] ?? '');

    if (empty($folderName)) {
        errorResponse('Nama folder wajib diisi');
    }

    if (strlen($folderName) > 100) {
        errorResponse('Nama folder maksimal 100 karakter');
    }

    $stmt = $db->prepare(
        'SELECT folder_id FROM folders WHERE user_id = ? AND folder_name = ? LIMIT 1'
    );
    $stmt->execute([$userId, $folderName]);
    if ($stmt->fetch()) {
        errorResponse('Folder dengan nama tersebut sudah ada', 409);
    }

    $stmt = $db->prepare('INSERT INTO folders (user_id, folder_name) VALUES (?, ?)');
    $stmt->execute([$userId, $folderName]);
    $folderId = (int) $db->lastInsertId();

    successResponse(
        [
            'folder_id'      => $folderId,
            'user_id'        => $userId,
            'folder_name'    => $folderName,
            'created_at'     => date('Y-m-d H:i:s'),
            'bookmark_count' => 0,
        ],
        'Folder berhasil dibuat',
        201
    );

} else {
    errorResponse('Method not allowed', 405);
}
