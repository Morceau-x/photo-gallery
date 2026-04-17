# Photo Gallery App Spec

A mobile photo management app that uses S3 as the primary backend — no server, all data stored directly in S3.

---

## 1. Local Photo Access

- [ ] Scan and display all photos/videos from the device's local storage (camera roll, albums)
- [ ] Request and manage photo library permissions (iOS Photos, Android MediaStore)
- [ ] Display local photos in a masonry grid grouped by date
- [ ] Support photo and video media types
- [ ] Lazy-load thumbnails from local storage for performance
- [ ] Detect new/deleted local files on app resume

## 2. S3 Photo Access

- [ ] List and display all photos/videos stored in S3
- [ ] Support paginated/incremental listing for large buckets
- [ ] Download S3 images on-demand for full-resolution viewing
- [ ] Cache downloaded S3 images locally with configurable cache size limit
- [ ] Display S3-only photos using thumbnails (avoid downloading full-res just to browse)

## 3. Multi-S3 Storage Support

- [x] Configure multiple S3-compatible storage backends (AWS S3, Backblaze B2, MinIO, Cloudflare R2, etc.)
- [x] Add/edit/remove S3 connections with: endpoint, region, access key, secret key, bucket name
- [x] Securely store credentials in platform keychain (iOS Keychain / Android Keystore)
- [ ] Per-connection status indicator (connected/error/syncing)
- [x] Set a default storage backend for new uploads
- [ ] Browse each S3 backend independently or in a unified view

## 4. Unified Gallery View

- [ ] Merge local and S3 photos into a single timeline view
- [ ] Badge/icon indicating where each photo lives (local only, S3 only, both/synced)
- [ ] Filter view by source: all, local only, S3 only, synced
- [ ] Sort by date taken, date uploaded, file size
- [ ] Group photos by day/month/year

## 5. Upload & Sync

- [ ] Upload individual photos or entire folders/albums to S3
- [ ] Bulk select photos for upload
- [ ] Background upload with progress tracking and retry on failure
- [ ] Configurable upload behavior per album/folder:
  - **Mirror**: keep in sync (local changes reflect on S3)
  - **Backup**: upload to S3, keep local copy
  - **Archive**: upload to S3, delete local copy (S3-only storage)
- [ ] Resume interrupted uploads (multipart upload for large files)
- [ ] Conflict resolution when same file exists on both sides (by hash comparison)
- [ ] Wi-Fi only upload option
- [ ] Upload queue with pause/resume/cancel per item

## 6. S3-Only Storage (Archive Mode)

- [ ] Upload photo to S3 and remove from local device to free space
- [ ] Show S3-only photos as thumbnails in the gallery (downloaded from S3 thumbnail)
- [ ] Download full-res on-demand when user taps to view
- [ ] Option to re-download and save back to local storage
- [ ] "Free up space" bulk action: archive all synced photos older than X days
- [ ] Storage savings indicator (how much local space reclaimed)

## 7. Thumbnail Generation

- [ ] Generate thumbnails client-side before uploading to S3
- [ ] Store thumbnails in a separate S3 prefix (`_thumbnails/{hash}.jpg`)
- [ ] Multiple thumbnail sizes: small (150px) for grid, medium (600px) for preview
- [ ] Generate thumbnails for existing S3 photos that don't have one yet (background task)
- [ ] Use thumbnails for all gallery browsing; only fetch full-res on explicit view
- [ ] JPEG compression with configurable quality for thumbnails
- [ ] Video thumbnails: extract a frame as the thumbnail

## 8. Metadata Management

- [ ] Extract EXIF/metadata from all photos: date taken, GPS, camera, dimensions, orientation
- [ ] Generate a metadata index file stored in S3 (`_metadata/index.json`)
- [ ] Incremental metadata updates (don't rewrite the entire index on each change)
- [ ] Metadata fields per file:
  - Original filename, S3 key, content hash (SHA-256), file size
  - Date taken, date uploaded, date modified
  - Dimensions, orientation, MIME type
  - GPS coordinates (if available)
  - Thumbnail S3 keys
  - Sync status, source device ID
  - User-added tags and favorite flag
- [ ] Sync metadata index across devices (last-write-wins or merge strategy)
- [ ] Rebuild metadata index from S3 contents if index is lost/corrupted

## 9. Organization & Search

- [ ] Create and manage albums/folders (stored as metadata, not S3 prefixes)
- [ ] Tag photos with custom labels
- [ ] Favorite/unfavorite photos
- [ ] Search by date range, tags, filename
- [ ] Filter by media type (photo/video), file size, resolution

## 10. Photo Viewer

- [ ] Full-screen photo viewer with pinch-to-zoom and swipe navigation
- [ ] Video playback for uploaded videos
- [ ] Display EXIF info overlay (date, location, camera, dimensions)
- [ ] Share photo to other apps
- [ ] Delete photo (from local, S3, or both with confirmation)
- [ ] Download full-res S3 photo to local device

## 11. Folder / Album Sync Rules

- [ ] Map local albums to S3 prefixes
- [ ] Per-album sync direction: upload-only, download-only, bidirectional
- [ ] Per-album storage policy: backup (keep both) or archive (S3-only)
- [ ] Sync scheduling: manual, on app open, periodic background sync
- [ ] Sync history log (what was uploaded/downloaded/deleted and when)

## 12. Storage & Cache Management

- [ ] Display storage usage per S3 backend (total objects, total size)
- [ ] Display local cache size with clear cache option
- [ ] Configurable local cache limit (e.g. 500MB, 1GB, 2GB)
- [ ] LRU eviction for cached S3 images
- [ ] Display local device storage usage by the app

## 13. Settings & Configuration

- [ ] App-level settings:
  - Default upload quality (original, high, medium)
  - Upload over cellular toggle
  - Auto-upload camera roll toggle
  - Cache size limit
  - Thumbnail quality
- [ ] Per-S3-backend settings:
  - S3 prefix/path within bucket
  - Custom endpoint URL for S3-compatible services
  - Connection test/validation
- [ ] Export/import app configuration (excluding secrets)

## 14. Offline Support

- [ ] Browse previously cached S3 thumbnails while offline
- [ ] Queue uploads made while offline; execute when connection restores
- [ ] Local-only features fully functional without network
- [ ] Clear indication of connectivity state and pending sync items

## 15. Data Integrity

- [ ] SHA-256 hash verification on upload and download
- [ ] Detect corrupted uploads by comparing local and remote hashes
- [ ] Detect duplicate photos across local and S3 (by content hash)
- [ ] Deduplicate on upload: skip files already present on S3 (matching hash)

## 16. Security

- [ ] All S3 credentials stored in platform secure storage (keychain/keystore)
- [ ] No credentials in app state, logs, or error reports
- [ ] Optional app lock (biometric / PIN)
- [ ] HTTPS-only for all S3 communication
- [ ] Biometric-protected S3 backends ("safe storage"): mark specific S3 connections as biometry-locked
- [ ] Require biometric auth (Face ID / fingerprint) to unlock, browse, or access safe storage contents
- [ ] Safe storage photos hidden from unified gallery view until unlocked
- [ ] Auto-lock safe storages on app background / timeout

## 17. On-Device AI Image Analysis

- [ ] Use Google ML Kit (Flutter plugins) for on-device image analysis on both iOS and Android
- [ ] Object and scene detection: auto-label photos (e.g. "beach", "dog", "food", "car")
- [ ] Face detection: detect faces and group by person (no identification, just clustering)
- [ ] Text recognition (OCR): extract text visible in photos
- [ ] Image classification: categorize photos (landscape, portrait, screenshot, document, etc.)
- [ ] Run analysis on upload and store results in S3 metadata per photo:
  - Detected labels with confidence scores
  - Face count and bounding boxes
  - Extracted text
  - Image category
- [ ] Batch-analyze existing S3 photos that lack AI metadata (background task)
- [ ] Search and filter photos by AI-generated labels

## 18. Shared Albums & Link Sharing

- [ ] Generate shareable links for albums or individual photos (no app install required for viewer)
- [ ] Store shared album definitions in S3 metadata (`_shared/{albumId}.json`)
- [ ] Optional link expiry (1 day, 7 days, 30 days, never)
- [ ] Optional password protection on shared links
- [ ] Allow link recipients to upload photos to a shared album (configurable)
- [ ] Revoke shared links at any time
- [ ] Since no backend: use S3 presigned URLs for link-based access with configurable TTL

## 19. Memories ("On This Day")

- [ ] Surface photos from 1, 2, 3, 5, 10 years ago on the home screen
- [ ] Display memories as a dismissable card/story-style carousel
- [ ] Generate memories from S3 metadata date fields (no server needed)
- [ ] Option to share a memory directly
- [ ] Notification/reminder for new memories (optional, configurable)
- [ ] Exclude specific photos or date ranges from memories

## 20. Map View

- [ ] Display photos on an interactive map using GPS coordinates from EXIF/metadata
- [ ] Cluster nearby photos into groups at lower zoom levels
- [ ] Tap a cluster or pin to browse photos taken at that location
- [ ] Filter map by date range, album, or S3 backend
- [ ] Heatmap mode showing density of photos by location

## 21. Trash / Soft Delete

- [ ] Deleted photos move to a trash folder instead of permanent deletion
- [ ] Store trashed files under a dedicated S3 prefix (`_trash/`)
- [ ] Auto-purge trash after configurable retention period (default 30 days)
- [ ] Browse and restore photos from trash
- [ ] "Empty trash" manual action for immediate permanent deletion
- [ ] Track deletion date in metadata to enforce retention

## 22. End-to-End Encryption

- [ ] Client-side AES-256 encryption of photos before uploading to S3
- [ ] Encrypt thumbnails and metadata files as well
- [ ] Derive encryption key from user-provided passphrase (PBKDF2/Argon2)
- [ ] Store encrypted key material in platform secure storage (keychain/keystore)
- [ ] Decrypt on-device only; S3 stores only ciphertext
- [ ] Per-S3-backend toggle: enable/disable E2EE (some backends may be unencrypted for sharing)
- [ ] Key export/backup flow so user can recover data on a new device

## 23. Live Photos & Motion Photos

- [ ] Detect and preserve iOS Live Photos (HEIC + MOV pair)
- [ ] Detect and preserve Android Motion Photos (embedded video in JPEG)
- [ ] Upload both components together, linked in metadata
- [ ] Play the motion/video component on long-press in gallery and viewer
- [ ] Generate still thumbnail from the photo component
- [ ] Option to extract and save the video component separately

## 24. RAW File Support

- [ ] Detect RAW formats: DNG, CR2, CR3, ARW, NEF, ORF, RW2, RAF
- [ ] Generate a viewable JPEG preview from RAW files for browsing and thumbnails
- [ ] Store original RAW + generated JPEG preview together on S3
- [ ] Display JPEG preview in gallery; download original RAW on explicit request
- [ ] Preserve RAW-specific EXIF data in metadata

## 25. Background Auto-Upload

- [ ] Persistent background sync service (WorkManager on Android / BGTaskScheduler on iOS)
- [ ] Automatically detect and upload new photos even when app is closed
- [ ] Configurable: which albums/folders to auto-upload
- [ ] Respect Wi-Fi only / cellular toggle
- [ ] Upload progress notification in system notification tray
- [ ] Resume uploads after device restart
- [ ] Battery-aware: pause uploads when battery is low (configurable threshold)

## 26. Reverse Geocoding

- [ ] Convert GPS coordinates from EXIF to human-readable place names (city, region, country)
- [ ] Use on-device geocoding when available (Android Geocoder / iOS CLGeocoder)
- [ ] Fallback to offline reverse geocoding database for no-network scenarios
- [ ] Store resolved place names in S3 metadata per photo
- [ ] Search and filter photos by place name
- [ ] Group photos by location in the gallery view
