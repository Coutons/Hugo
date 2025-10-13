# Script untuk membuat artikel baru di Hugo
# Cara pakai: .\new-post.ps1

# Fungsi untuk membersihkan dan membuat slug dari judul
function Get-Slug {
    param (
        [string]$title
    )
    
    # Konversi ke lowercase
    $slug = $title.ToLower()
    
    # Hapus karakter khusus, ganti spasi dengan strip
    $slug = $slug -replace '[^\w\s-]', '' -replace '\s+', '-'
    
    # Hapus strip berulang
    $slug = $slug -replace '-+', '-'
    
    # Hapus strip di awal dan akhir
    $slug = $slug.Trim('-')
    
    return $slug
}

# Dapatkan judul artikel
do {
    $title = Read-Host "Masukkan judul artikel (minimal 5 karakter)"
    if ($title.Length -lt 5) {
        Write-Host "Judul terlalu pendek, minimal 5 karakter" -ForegroundColor Yellow
    }
} while ($title.Length -lt 5)

# Generate slug dari judul
$defaultSlug = Get-Slug $title
$customSlug = Read-Host "Masukkan custom slug (kosongkan untuk menggunakan '$defaultSlug')"

# Gunakan if-else untuk kompatibilitas PowerShell versi lama
if ([string]::IsNullOrWhiteSpace($customSlug)) {
    $slug = $defaultSlug
} else {
    $slug = Get-Slug $customSlug
}

# Tentukan lokasi file
$postPath = "content/posts/$slug"
$mdFile = "$postPath/index.md"
$imagesDir = "static/images/posts/$slug"

# Pastikan direktori content/posts ada
if (-not (Test-Path -Path "content/posts")) {
    New-Item -ItemType Directory -Path "content/posts" -Force | Out-Null
}

# Buat direktori untuk post
if (-not (Test-Path -Path $postPath)) {
    New-Item -ItemType Directory -Path $postPath | Out-Null
    Write-Host "Direktori post dibuat: $postPath" -ForegroundColor Green
}

# Buat direktori untuk gambar
if (-not (Test-Path -Path $imagesDir)) {
    New-Item -ItemType Directory -Path $imagesDir | Out-Null
    Write-Host "Direktori gambar dibuat: $imagesDir" -ForegroundColor Green
}

# Buat front matter untuk post
$dateNow = Get-Date -Format "yyyy-MM-dd"
$dateTimeNow = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"

$frontMatter = @"
---
title: "$title"
date: $($dateNow)
lastmod: $($dateTimeNow)
draft: true
description: "Deskripsi singkat untuk SEO (150-160 karakter)"\ncategories: ["Kategori1"]
tags: ["tag1", "tag2"]
featuredImage: "/images/posts/$slug/featured.jpg"
featuredImageAlt: "Deskripsi gambar untuk aksesibilitas"
canonicalURL: ""
seo_title: "$title - CoursesWyn"
seo_description: "Deskripsi SEO yang menarik (150-160 karakter)"
---

## Pendahuluan
Mulai dengan kalimat pembuka yang menarik dan relevan dengan topik artikel.

## Isi Artikel
Konten utama artikel Anda di sini. Gunakan heading (##, ###) untuk membagi konten menjadi bagian-bagian yang mudah dibaca.

### Sub-judul
Tambahkan sub-judul untuk memecah konten yang panjang.

## Kesimpulan
Ringkasan dari poin-poin penting dalam artikel.

"@

# Tulis ke file
[System.IO.File]::WriteAllText((Resolve-Path .\$mdFile).Path, $frontMatter, [System.Text.Encoding]::UTF8)

# Beri tahu pengguna
Write-Host "`nArtikel berhasil dibuat!" -ForegroundColor Green
Write-Host "Lokasi file: $mdFile"
Write-Host "Lokasi gambar: $imagesDir"

# Buka file di editor default
Start-Process notepad.exe $mdFile

# Tampilkan panduan singkat
Write-Host "`nPanduan singkat:"
Write-Host "1. Edit file markdown yang sudah terbuka"
Write-Host "2. Tambahkan gambar ke folder: $imagesDir"
Write-Host "3. Ganti 'draft: true' menjadi 'draft: false' saat siap publish"
Write-Host "4. Preview dengan menjalankan: hugo server -D"
Write-Host "5. Deploy ke Netlify saat sudah selesai"

# Tanya apakah ingin membuat artikel lain
$createAnother = Read-Host "`nBuat artikel lain? (y/n)"
if ($createAnother -eq 'y' -or $createAnother -eq 'Y') {
    & "$PSCommandPath"
}
