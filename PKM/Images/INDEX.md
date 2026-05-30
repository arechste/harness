# Images

Single shared image bucket. **Images live here, never duplicated elsewhere** — other PKM/Journal/Deliverables files embed via `![[Images/YYYY/MM/filename.ext]]`.

## Layout

Nested by `YYYY/MM/` to keep directory listings manageable:

```
Images/
├── 2026/
│   ├── 05/
│   │   ├── screenshot-of-X.png
│   │   └── photo-of-Y.jpg
│   └── 06/
└── 2027/
```

## Conventions

- Filename: kebab-case, descriptive, no spaces. Add a short context suffix if needed (e.g., `tailscale-acl-error-2026-05-30.png`).
- Source files only — no thumbnails, no resized variants. Embed at display size in the consuming markdown.
- If an image is sensitive (whiteboard with credentials, screenshot exposing tokens), it does NOT go here — same rules as `PKM/Documents/`.
- Empty for now.
