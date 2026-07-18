<?php
/**
 * GET  /api/bookmarks             — Ambil semua kliping milik user
 * GET  /api/bookmarks?folder_id=X — Kliping dalam folder tertentu
 * POST /api/bookmarks             — Simpan kliping baru dari NewsAPI
 */

declare(strict_types=1);

require_once __DIR__ . '/../helpers.php';

setCors();

$userId = requireAuth();
$method = $_SERVER['REQUEST_METHOD'];
$db     = getDB();

if ($method === 'GET') {

    $folderId = isset($_GET['folder_id']) ? (int) $_GET['folder_id'] : null;

    if ($folderId !== null && $folderId > 0) {
        $stmt = $db->prepare('
            SELECT
                b.bookmark_id, b.user_id, b.folder_id,
                b.title, b.author, b.source_name,
                b.image_url, b.article_url, b.published_date,
                b.description, b.my_notes, b.reading_status, b.saved_at,
                f.folder_name
            FROM bookmarks b
            LEFT JOIN folders f ON b.folder_id = f.folder_id
            WHERE b.user_id = ? AND b.folder_id = ?
            ORDER BY b.saved_at DESC
        ');
        $stmt->execute([$userId, $folderId]);
    } else {
        $stmt = $db->prepare('
            SELECT
                b.bookmark_id, b.user_id, b.folder_id,
                b.title, b.author, b.source_name,
                b.image_url, b.article_url, b.published_date,
                b.description, b.my_notes, b.reading_status, b.saved_at,
                f.folder_name
            FROM bookmarks b
            LEFT JOIN folders f ON b.folder_id = f.folder_id
            WHERE b.user_id = ?
            ORDER BY b.saved_at DESC
        ');
        $stmt->execute([$userId]);
    }

    $bookmarks = $stmt->fetchAll();

    foreach ($bookmarks as &$bm) {
        $bm['bookmark_id'] = (int) $bm['bookmark_id'];
        $bm['user_id']     = (int) $bm['user_id'];
        $bm['folder_id']   = $bm['folder_id'] !== null ? (int) $bm['folder_id'] : null;
    }
    unset($bm);

    successResponse($bookmarks);

} elseif ($method === 'POST') {

    $body = getBody();

    $title      = trim($body['title'] ?? '');
    $articleUrl = trim($body['article_url'] ?? '');

    if (empty($title)) {
        errorResponse('Judul artikel wajib diisi');
    }
    if (empty($articleUrl)) {
        errorResponse('URL artikel wajib diisi');
    }

    $author        = trim($body['author'] ?? '');
    $sourceName    = trim($body['source_name'] ?? '');
    $imageUrl      = trim($body['image_url'] ?? '');
    $publishedDate = !empty($body['published_date'])
        ? date('Y-m-d H:i:s', strtotime($body['published_date']))
        : null;
    $description   = trim($body['description'] ?? '');
    $myNotes       = trim($body['my_notes'] ?? '');
    $folderId      = !empty($body['folder_id']) ? (int) $body['folder_id'] : null;

    $validStatuses = ['Belum Dibaca', 'Selesai'];
    $readingStatus = in_array($body['reading_status'] ?? '', $validStatuses, true)
        ? $body['reading_status']
        : 'Belum Dibaca';

    if ($folderId !== null) {
        $stmt = $db->prepare(
            'SELECT folder_id FROM folders WHERE folder_id = ? AND user_id = ? LIMIT 1'
        );
        $stmt->execute([$folderId, $userId]);
        if (!$stmt->fetch()) {
            errorResponse('Folder tidak ditemukan', 404);
        }
    }

    $stmt = $db->prepare(
        'SELECT bookmark_id FROM bookmarks WHERE user_id = ? AND article_url = ? LIMIT 1'
    );
    $stmt->execute([$userId, $articleUrl]);
    if ($stmt->fetch()) {
        errorResponse('Artikel sudah ada di kliping Anda', 409);
    }

    $stmt = $db->prepare('
        INSERT INTO bookmarks
            (user_id, folder_id, title, author, source_name, image_url,
             article_url, published_date, description, my_notes, reading_status)
        VALUES
            (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ');
    $stmt->execute([
        $userId, $folderId, $title, $author, $sourceName,
        $imageUrl, $articleUrl, $publishedDate, $description,
        $myNotes, $readingStatus,
    ]);
    $bookmarkId = (int) $db->lastInsertId();

    successResponse(
        [
            'bookmark_id'    => $bookmarkId,
            'user_id'        => $userId,
            'folder_id'      => $folderId,
            'title'          => $title,
            'author'         => $author,
            'source_name'    => $sourceName,
            'image_url'      => $imageUrl,
            'article_url'    => $articleUrl,
            'published_date' => $publishedDate,
            'description'    => $description,
            'my_notes'       => $myNotes,
            'reading_status' => $readingStatus,
            'saved_at'       => date('Y-m-d H:i:s'),
            'folder_name'    => null,
        ],
        'Artikel berhasil dikliping',
        201
    );

} else {
    errorResponse('Method not allowed', 405);
}
