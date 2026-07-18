<?php
/**
 * GET    /api/folders/{id}  — Detail folder
 * PUT    /api/folders/{id}  — Rename folder
 * PATCH  /api/folders/{id}  — Rename folder (alias)
 * DELETE /api/folders/{id}  — Hapus folder
 */

declare(strict_types=1);

require_once __DIR__ . '/../helpers.php';

setCors();

$userId   = requireAuth();
$folderId = (int) ($_GET['id'] ?? 0);
$method   = $_SERVER['REQUEST_METHOD'];
$db       = getDB();

if ($folderId <= 0) {
    errorResponse('ID folder tidak valid');
}

$stmt = $db->prepare('
    SELECT folder_id, folder_name, created_at
    FROM folders
    WHERE folder_id = ? AND user_id = ?
    LIMIT 1
');
$stmt->execute([$folderId, $userId]);
$folder = $stmt->fetch();

if (!$folder) {
    errorResponse('Folder tidak ditemukan', 404);
}

if ($method === 'GET') {
    $folder['folder_id'] = (int) $folder['folder_id'];
    successResponse($folder);

} elseif ($method === 'PUT' || $method === 'PATCH') {

    $body       = getBody();
    $folderName = trim($body['folder_name'] ?? '');

    if (empty($folderName)) {
        errorResponse('Nama folder wajib diisi');
    }

    if (strlen($folderName) > 100) {
        errorResponse('Nama folder maksimal 100 karakter');
    }

    $stmt = $db->prepare('
        SELECT folder_id FROM folders
        WHERE user_id = ? AND folder_name = ? AND folder_id != ?
        LIMIT 1
    ');
    $stmt->execute([$userId, $folderName, $folderId]);
    if ($stmt->fetch()) {
        errorResponse('Folder dengan nama tersebut sudah ada', 409);
    }

    $stmt = $db->prepare(
        'UPDATE folders SET folder_name = ? WHERE folder_id = ? AND user_id = ?'
    );
    $stmt->execute([$folderName, $folderId, $userId]);

    successResponse(
        [
            'folder_id'   => $folderId,
            'folder_name' => $folderName,
            'created_at'  => $folder['created_at'],
        ],
        'Folder berhasil diperbarui'
    );

} elseif ($method === 'DELETE') {

    $stmt = $db->prepare('DELETE FROM folders WHERE folder_id = ? AND user_id = ?');
    $stmt->execute([$folderId, $userId]);
    successResponse(null, 'Folder berhasil dihapus');

} else {
    errorResponse('Method not allowed', 405);
}
