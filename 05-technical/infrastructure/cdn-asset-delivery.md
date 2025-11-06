# CDN & Asset Delivery - Доставка контента

**Статус:** draft  
**Версия:** 1.0.0  
**Дата создания:** 2025-11-06  
**Последнее обновление:** 2025-11-06 23:00  
**Приоритет:** высокий (Performance)

**api-readiness:** in-review  
**api-readiness-check-date:** 2025-11-06 23:00

---

## Краткое описание

CDN для быстрой доставки игровых ассетов игрокам по всему миру.

**Микрофича:** CDN (static assets, patches, updates)

---

## 🌍 CDN Strategy

**Providers:**
- Cloudflare (primary)
- AWS CloudFront (backup)

**PoPs (Points of Presence):**
- North America: 15+ locations
- Europe: 12+ locations
- Asia: 10+ locations
- Latency: < 50ms для 95% игроков

---

## 📦 Asset Types

### Static Assets (не меняются)

```
Images:
- Textures (4K, 2K, 1K - multiple resolutions)
- UI icons
- Loading screens

3D Models:
- Weapons
- Armor
- NPCs
- Environment

Audio:
- Music tracks
- Sound effects
- Voice lines (localized)

Videos:
- Cutscenes
- Trailers
```

**CDN caching:** Permanent (version-based URLs)

### Dynamic Assets (обновляются)

```
Patches:
- Game client updates
- Hotfixes
- Content patches

Versioned:
- game-client-v1.2.3.exe
- patch-v1.2.3-to-v1.2.4.zip

CDN caching: Until new version
```

---

## 🚀 Delivery Optimization

**Compression:**
```
Gzip: Text files, JSON (-70% size)
Brotli: HTML, CSS, JS (-80% size)
Image optimization: WebP format (-30% vs PNG)
Video: H.265 codec (-50% vs H.264)
```

**Lazy Loading:**
```
Download priority:
1. Core game (required to start)
2. Tutorial zone assets
3. Starter weapons/armor
4. Other zones (as player approaches)

Background downloading while playing!
```

---

## 📊 Структура

```
CDN Structure:

cdn.necpgame.com/
  /assets/
    /textures/
      /weapons/
        mantis-blades-v1.0.webp
      /armor/
    /models/
    /audio/
    /videos/
  /patches/
    /client/
      game-v1.2.3.exe
      patch-v1.2.3-to-v1.2.4.zip
  /downloads/
    /full/
      necpgame-installer-v1.2.3.exe
```

---

## 🔗 Связанные документы

- `api-gateway-architecture.md`

---

## История изменений

- v1.0.0 (2025-11-06 23:00) - Создание CDN архитектуры

