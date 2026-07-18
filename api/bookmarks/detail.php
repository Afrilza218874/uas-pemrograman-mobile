<?php
/**
 * GET    /api/bookmarks/{id}  — Detail kliping
 * PUT    /api/bookmarks/{id}  — Update catatan, folder, status
 * PATCH  /api/bookmarks/{id}  — Update parsial
 * DELETE /api/bookmarks/{id}  — Hapus kliping
 */

declare(strict_types=1);

require_once __DIR__ . '/../helpers.php';

setCors();

$userId     = requireAuth();
$bookmarkId = (int) ($_GET['id'] ?? 0);
$method     = $_SERVER['REQUEST_METHOD'];
$db         = getDB();

if ($bookmarkId <= 0) {
    errorResponse('ID kliping tidak valid');
}

$stmt = $db->prepare('
    SELECT
        b.bookmark_id, b.user_id, b.folder_id,
        b.title, b.author, b.source_name,
        b.image_url, b.article_url, b.published_date,
        b.description, b.my_notes, b.reading_status, b.saved_at,
        f.folder_name
    FROM bookmarks b
    LEFT JOIN folders f ON b.folder_id = f.folder_id
    WHERE b.bookmark_id = ? AND b.user_id = ?
    LIMIT 1
');
$stmt->execute([$bookmarkId, $userId]);
$bookmark = $stmt->fetch();

if (!$bookmark) {
    errorResponse('Kliping tidak ditemukan', 404);
}

$bookmark['bookmark_id'] = (int) $bookmark['bookmark_id'];
$bookmark['user_id']     = (int) $bookmark['user_id'];
$bookmark['folder_id']   = $bookmark['folder_id'] !== null ? (int) $bookmark['folder_id'] : null;

if ($method === 'GET') {
    successResponse($bookmark);

} elseif ($method === 'PUT' || $method === 'PATCH') {

    $body    = getBody();
    $updates = [];
    $params  = [];

    if (array_key_exists('my_notes', $body)) {
        $updates[] = 'my_notes = ?';
        $params[]  = trim((string) $body['my_notes']);
    }

    if (array_key_exists('folder_id', $body)) {
        $newFolderId = !empty($body['folder_id']) ? (int) $body['folder_id'] : null;

        if ($newFolderId !== null) {
            $stmt = $db->prepare(
                'SELECT folder_id FROM folders WHERE folder_id = ? AND user_id = ? LIMIT 1'
            );
            $stmt->execute([$newFolderId, $userId]);
            if (!$stmt->fetch()) {
                errorResponse('Folder tidak ditemukan', 404);
            }
        }

        $updates[] = 'folder_id = ?';
        $params[]  = $newFolderId;
    }

    if (array_key_exists('reading_status', $body)) {
        $validStatuses = ['Belum Dibaca', 'Selesai'];
        $newStatus = in_array($body['reading_status'], $validStatuses, true)
            ? $body['reading_status']
            : 'Belum Dibaca';
        $updates[] = 'reading_status = ?';
        $params[]  = $newStatus;
    }

    if (empty($updates)) {
        errorResponse('Tidak ada field yang diperbarui');
    }

    $params[] = $bookmarkId;
    $params[] = $userId;
    $sql      = 'UPDATE bookmarks SET ' . implode(', ', $updates)
              . ' WHERE bookmark_id = ? AND user_id = ?';
    $db->prepare($sql)->execute($params);

    $stmt = $db->prepare('
        SELECT
            b.bookmark_id, b.user_id, b.folder_id,
            b.title, b.author, b.source_name,
            b.image_url, b.article_url, b.published_date,
            b.description, b.my_notes, b.reading_status, b.saved_at,
            f.folder_name
        FROM bookmarks b
        LEFT JOIN folders f ON b.folder_id = f.folder_id
        WHERE b.bookmark_id = ?
        LIMIT 1
    ');
    $stmt->execute([$bookmarkId]);
    $updated = $stmt->fetch();
    $updated['bookmark_id'] = (int) $updated['bookmark_id'];
    $updated['folder_id']   = $updated['folder_id'] !== null ? (int) $updated['folder_id'] : null;

    successResponse($updated, 'Kliping berhasil diperbarui');

} elseif ($method === 'DELETE') {

    $stmt = $db->prepare(
        'DELETE FROM bookmarks WHERE bookmark_id = ? AND user_id = ?'
    );
    $stmt->execute([$bookmarkId, $userId]);
    successResponse(null, 'Kliping berhasil dihapus');

} else {
    errorResponse('Method not allowed', 405);
}
