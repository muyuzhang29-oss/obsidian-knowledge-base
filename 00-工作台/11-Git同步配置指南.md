---
aliases: [Git鍚屾閰嶇疆鎸囧崡, Obsidian Git鍚屾, Git鍚屾]
tags: [Environment, Git, Obsidian, Sync]
created: 2026-06-04
updated: 2026-06-10
---

# Git鍚屾閰嶇疆鎸囧崡

## 姒傝堪

鏈枃妗ｄ粙缁嶅浣曞湪Windows鍜宨Pad涓婇厤缃甇bsidian Git鍚屾鍔熻兘銆?
---

## 涓€銆乄indows閰嶇疆姝ラ

### 1. 瀹夎Git

1. 璁块棶 https://git-scm.com/download/win
2. 涓嬭浇Windows鐗堟湰鐨凣it瀹夎绋嬪簭
3. 杩愯瀹夎绋嬪簭锛屼娇鐢ㄩ粯璁ら€夐」鍗冲彲
4. 瀹夎瀹屾垚鍚庯紝鎵撳紑PowerShell鎴栧懡浠ゆ彁绀虹锛岃緭鍏?`git --version` 楠岃瘉瀹夎

### 2. 閰嶇疆Git鐢ㄦ埛淇℃伅

```powershell
git config --global user.name "浣犵殑鐢ㄦ埛鍚?
git config --global user.email "浣犵殑閭@example.com"
```

### 3. 鍏嬮殕浠撳簱

```powershell
cd D:\obsidian
git clone https://github.com/muyuzhang29-oss/obsidian-knowledge-base.git knowledge-base
```

### 4. 瀹夎Obsidian Git鎻掍欢

1. 鎵撳紑Obsidian
2. 杩涘叆 璁剧疆 鈫?绗笁鏂规彃浠?鈫?娴忚
3. 鎼滅储 "Git" 骞跺畨瑁?"Obsidian Git" 鎻掍欢
4. 鍚敤鎻掍欢

### 5. 閰嶇疆鎻掍欢

鎻掍欢閰嶇疆鏂囦欢浣嶄簬 `.obsidian/plugins/obsidian-git/data.json`锛屼富瑕侀厤缃」锛?
- **鑷姩鍚屾闂撮殧**: 5鍒嗛挓锛?00绉掞級
- **鑷姩pull**: 鍚敤
- **鑷姩push**: 鍚敤
- **鎻愪氦淇℃伅妯℃澘**: `vault backup: {{date}}`

---

## 浜屻€乮Pad閰嶇疆姝ラ

### 1. 瀹夎Working Copy

1. 鍦ˋpp Store鎼滅储 "Working Copy"
2. 涓嬭浇骞跺畨瑁咃紙闇€瑕佷粯璐硅В閿佹帹閫佸姛鑳斤級

### 2. 鍏嬮殕浠撳簱

1. 鎵撳紑Working Copy
2. 鐐瑰嚮鍙充笂瑙?"+" 鎸夐挳
3. 閫夋嫨 "Clone Repository"
4. 杈撳叆浠撳簱鍦板潃锛歚https://github.com/muyuzhang29-oss/obsidian-knowledge-base.git`
5. 閫夋嫨鍏嬮殕浣嶇疆

### 3. 閰嶇疆Obsidian

1. 鎵撳紑Obsidian
2. 鎵撳紑浠撳簱鎵€鍦ㄧ殑鏂囦欢澶?3. 瀹夎骞跺惎鐢∣bsidian Git鎻掍欢
4. 閰嶇疆鑷姩鍚屾

### 4. 鍚屾娴佺▼

鍦╥Pad涓婏紝闇€瑕佹墜鍔ㄨЕ鍙戝悓姝ワ細

1. 鍦∣bsidian涓娇鐢ㄥ懡浠ら潰鏉匡紙Ctrl/Cmd + P锛?2. 杈撳叆 "Git: Pull" 鎷夊彇鏈€鏂版洿鏀?3. 缂栬緫瀹屾垚鍚庯紝杈撳叆 "Git: Commit all" 鎻愪氦鏇存敼
4. 杈撳叆 "Git: Push" 鎺ㄩ€佸埌GitHub

---

## 涓夈€佸父瑙侀棶棰樿В绛?
### Q1: 鎻愮ず "Permission denied" 鎬庝箞鍔烇紵

**A**: 闇€瑕侀厤缃甋SH瀵嗛挜鎴栦娇鐢ㄤ釜浜鸿闂护鐗岋紙PAT锛夈€?
浣跨敤HTTPS + PAT鏂瑰紡锛?1. 璁块棶 GitHub 鈫?Settings 鈫?Developer settings 鈫?Personal access tokens
2. 鐢熸垚鏂颁护鐗岋紝鍕鹃€?`repo` 鏉冮檺
3. 鍦ㄦ帹閫佹椂浣跨敤浠ょ墝浣滀负瀵嗙爜

### Q2: 濡備綍瑙ｅ喅鍚堝苟鍐茬獊锛?
**A**: 
1. 鎵撳紑鏈夊啿绐佺殑鏂囦欢
2. 鎵惧埌 `<<<<<<<` 鍜?`>>>>>>>` 鏍囪
3. 鎵嬪姩閫夋嫨瑕佷繚鐣欑殑鍐呭
4. 鍒犻櫎鍐茬獊鏍囪
5. 鎻愪氦鏇存敼

### Q3: 鍚屾閫熷害寰堟參鎬庝箞鍔烇紵

**A**:
- 妫€鏌ョ綉缁滆繛鎺?- 鍑忓皯澶у瀷浜岃繘鍒舵枃浠讹紙鍥剧墖銆丳DF绛夛級
- 浣跨敤 `.gitignore` 鎺掗櫎涓嶉渶瑕佸悓姝ョ殑鏂囦欢

### Q4: 濡備綍鏌ョ湅鍚屾鍘嗗彶锛?
**A**: 
- 鍦∣bsidian涓娇鐢ㄥ懡浠?"Git: View history"
- 鎴栧湪鍛戒护琛屾墽琛?`git log --oneline`

### Q5: 璇垹浜嗘枃浠舵€庝箞鍔烇紵

**A**:
```powershell
git checkout -- 鏂囦欢鍚? # 鎭㈠鍗曚釜鏂囦欢
git checkout .  # 鎭㈠鎵€鏈夋枃浠?```

---

## 鍥涖€佹棩甯镐娇鐢ㄨ鏄?
### 鎺ㄨ崘宸ヤ綔娴佺▼

1. **寮€濮嬪伐浣滃墠**: 鍏堟媺鍙栨渶鏂版洿鏀?   - Obsidian鍛戒护: `Git: Pull`
   - 鍛戒护琛? `git pull`

2. **宸ヤ綔杩囩▼涓?*: 瀹氭湡鎻愪氦锛堝缓璁瘡瀹屾垚涓€涓富棰樺氨鎻愪氦锛?   - Obsidian鍛戒护: `Git: Commit all`
   - 鍛戒护琛? `git add . && git commit -m "鎻忚堪"`

3. **宸ヤ綔缁撴潫鍚?*: 鎺ㄩ€佸埌杩滅▼浠撳簱
   - Obsidian鍛戒护: `Git: Push`
   - 鍛戒护琛? `git push`

### 蹇嵎閿缃?
寤鸿鍦∣bsidian涓负甯哥敤Git鎿嶄綔璁剧疆蹇嵎閿細

1. 杩涘叆 璁剧疆 鈫?蹇嵎閿?2. 鎼滅储 "Git"
3. 涓轰互涓嬪懡浠よ缃揩鎹烽敭锛?   - Git: Pull 鈫?`Ctrl+Shift+P`
   - Git: Commit all 鈫?`Ctrl+Shift+C`
   - Git: Push 鈫?`Ctrl+Shift+U`

---

## 浜斻€侀厤缃枃浠跺弬鑰?
### .gitignore 鏂囦欢鍐呭

```
# Obsidian宸ヤ綔鍖烘枃浠?.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/workspace

# 绯荤粺鏂囦欢
desktop.ini
Thumbs.db
.DS_Store

# 涓存椂鏂囦欢
*.tmp
*.bak
*.swp
```

### Obsidian Git 鎻掍欢閰嶇疆

鏂囦欢浣嶇疆锛歚.obsidian/plugins/obsidian-git/data.json`

```json
{
  "autoSaveInterval": 300,
  "autoPullInterval": 300,
  "autoPullOnBoot": true,
  "autoCommitMessage": "vault backup: {{date}}",
  "autoCommitOnFileChange": false,
  "syncOnSave": false
}
```

---

*鏈€鍚庢洿鏂? 2026-06-02*

