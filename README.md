# NewsClip Backend API

REST API untuk aplikasi **NewsClip** — dibangun dengan **PHP Serverless** dan di-deploy ke **Vercel**, menggunakan **TiDB Cloud** sebagai database MySQL-compatible.

---

## 📁 Struktur File

```
backend/
├── api/
│   ├── helpers.php              ← CORS, JWT, DB, Response helpers
│   ├── auth/
│   │   ├── register.php         → POST /api/auth/register
│   │   ├── login.php            → POST /api/auth/login
│   │   └── me.php               → GET  /api/auth/me
│   ├── folders/
│   │   ├── index.php            → GET/POST  /api/folders
│   │   └── detail.php           → GET/PUT/DELETE /api/folders/{id}
│   └── bookmarks/
│       ├── index.php            → GET/POST  /api/bookmarks
│       └── detail.php           → GET/PUT/DELETE /api/bookmarks/{id}
├── schema.sql                   ← SQL untuk TiDB Cloud
├── vercel.json                  ← Konfigurasi routing Vercel
├── .env.example                 ← Template environment variables
└── README.md
```

---

## 🗄️ Step 1 — Setup Database (TiDB Cloud)

1. Buka [https://tidbcloud.com](https://tidbcloud.com) → Daftar/Login
2. Klik **Create Cluster** → pilih **Serverless** (gratis)
3. Beri nama cluster, pilih region terdekat (Singapore)
4. Setelah cluster aktif, klik **Connect** → catat:
   - **Host**: `gateway01.ap-southeast-1.prod.aws.tidbcloud.com`
   - **Port**: `4000`
   - **Username**: `xxxxx.root`
   - **Password**: (yang Anda buat)
5. Klik **SQL Editor** di menu kiri
6. Paste seluruh isi file `schema.sql` → klik **Run**
7. Pastikan muncul 3 tabel: `users`, `folders`, `bookmarks`

---

## 🚀 Step 2 — Deploy ke Vercel

### Import dari GitHub (Cara Mudah)
1. Buka [https://vercel.com/new](https://vercel.com/new)
2. Klik **Import Git Repository**
3. Pilih repo `uas-pemrograman-mobile`
4. **Root Directory** → ganti ke `backend` (penting!)
5. Klik **Deploy**

### Set Environment Variables di Vercel Dashboard

Masuk ke **Settings → Environment Variables** dan tambahkan:

| Name | Value |
|------|-------|
| `DB_HOST` | `gateway01.ap-...tidbcloud.com` |
| `DB_PORT` | `4000` |
| `DB_NAME` | `newsclip` |
| `DB_USER` | `xxxxx.root` |
| `DB_PASS` | password TiDB Anda |
| `JWT_SECRET` | string acak panjang (min 32 char) |

Klik **Redeploy** setelah set env variables.

---

## 🔌 API Endpoints Reference

**Base URL**: `https://newsclip-backend.vercel.app`

### Auth (tidak butuh token)

| Method | Endpoint | Body |
|--------|----------|------|
| POST | `/api/auth/register` | `{username, email, password}` |
| POST | `/api/auth/login` | `{email, password}` |
| GET | `/api/auth/me` | *(Header: Bearer token)* |

### Folders 🔒 (butuh token)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/api/folders` | List semua folder + jumlah kliping |
| POST | `/api/folders` | Buat folder baru `{folder_name}` |
| PUT | `/api/folders/{id}` | Rename folder `{folder_name}` |
| DELETE | `/api/folders/{id}` | Hapus folder |

### Bookmarks 🔒 (butuh token)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| GET | `/api/bookmarks` | Semua kliping |
| GET | `/api/bookmarks?folder_id=1` | Kliping per folder |
| POST | `/api/bookmarks` | Simpan kliping baru |
| PUT | `/api/bookmarks/{id}` | Update catatan/folder/status |
| DELETE | `/api/bookmarks/{id}` | Hapus kliping |

---

## 🧪 Testing dengan Thunder Client

### 1. Register
```json
POST /api/auth/register
{
  "username": "mahasiswa",
  "email": "test@email.com",
  "password": "password123"
}
```

### 2. Login
```json
POST /api/auth/login
{
  "email": "test@email.com",
  "password": "password123"
}
```

### 3. Buat Folder
```json
POST /api/folders
Authorization: Bearer <token>
{
  "folder_name": "Tugas UAS Politik"
}
```

### 4. Simpan Kliping
```json
POST /api/bookmarks
Authorization: Bearer <token>
{
  "title": "Judul berita",
  "article_url": "https://example.com/article",
  "source_name": "BBC News",
  "folder_id": 1
}
```

### 5. Update Catatan
```json
PUT /api/bookmarks/1
Authorization: Bearer <token>
{
  "my_notes": "Analisis pribadi saya...",
  "reading_status": "Selesai"
}
```
