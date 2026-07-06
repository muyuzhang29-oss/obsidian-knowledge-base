---
tags:
  - tool
  - eda
  - claude
aliases:
  - EDA浠跨湡鎶€鑳?  - Claude Code EDA
---

# 馃洜锔?Claude Code EDA 浠跨湡鎶€鑳?
> [!abstract] 姒傝堪
> 鏈枃妗ｈ褰曚簡 Claude Code 涓厤缃殑 EDA 浠跨湡鎶€鑳斤紝鐢ㄤ簬鑷姩鍖栬繍琛?Cadence xrun 浠跨湡鍜屾煡鐪?SimVision 娉㈠舰銆?
---

## 馃枼锔?鐜姒傝

> [!info] 绯荤粺閰嶇疆
> | 缁勪欢 | 璇存槑 |
> |------|------|
> | **WSL 鍙戣鐗?* | AlmaLinux-8 |
> | **WSL 鐢ㄦ埛** | muyuEDA / 瀵嗙爜: 1220 |
> | **EDA 宸ュ叿** | Cadence Xcelium 23.09 |
> | **宸ュ叿璺緞** | `/opt/eda/cadence/XCELUMMAIN2309/tools/bin/` |
> | **X11 鏄剧ず** | VcXsrv (Windows) + WSLg (澶囩敤) |
> | **tmux 浼氳瘽** | muyu (鍦?AlmaLinux-8 鍐? |

---

## 馃幆 Skill 1: alma-tmux

> [!note] 鐢ㄩ€?> 鎺у埗 AlmaLinux-8 鍐呴儴鐨?tmux 浼氳瘽锛岀渷鍘?`powershell 鈫?wsl 鈫?tmux` 鐨勫眰灞傚祵濂椼€?
### 瑙﹀彂鏂瑰紡

鎻愬埌浠ヤ笅鍏抽敭璇嶆椂鑷姩瑙﹀彂锛?- `alma`銆乣muyuEDA`銆乣muyu session`
- 鎯冲湪 AlmaLinux 閲屾墽琛屽懡浠?
### 鍛戒护妯℃澘

> [!example]- 鍙戦€佸懡浠?> ```bash
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- tmux send-keys -t muyu '<鍛戒护>' Enter"
> ```

> [!example]- 鎹曡幏杈撳嚭
> ```bash
> # 瀹屾暣杈撳嚭
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- bash -c 'tmux capture-pane -t muyu -p -S -'"
>
> # 鏈€鍚?N 琛?> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- bash -c 'tmux capture-pane -t muyu -p -S - | tail -20'"
> ```

> [!example]- 鐗规畩鎸夐敭
> ```bash
> # Ctrl+C
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- tmux send-keys -t muyu C-c"
>
> # Escape
> powershell.exe -Command "wsl -d AlmaLinux-8 -u muyuEDA -- tmux send-keys -t muyu Escape"
> ```

### 浣跨敤绀轰緥

```
鎴戯細鍦?alma 閲岃繍琛?htop
鎴戯細鐪嬬湅 muyu session 鐨勮緭鍑?鎴戯細鍦?AlmaLinux 閲岃涓寘
```

---

## 馃幆 Skill 2: eda-sim

> [!note] 鐢ㄩ€?> 鑷姩鍖?EDA 浠跨湡娴佺▼锛屽寘鎷繍琛?xrun 浠跨湡鍜屾煡鐪?SimVision 娉㈠舰銆?
### 瑙﹀彂鏂瑰紡

鎻愬埌浠ヤ笅鍏抽敭璇嶆椂鑷姩瑙﹀彂锛?- `xrun`銆乣simvision`銆乣simulate`銆乣run test`
- `waveform`銆乣UVM`銆乣DUT verification`
- `浠跨湡`銆乣璺戞祴璇昤銆乣鐪嬫尝褰

### 鍓嶇疆鏉′欢

> [!warning] 鍚姩鍓嶆鏌?> 1. VcXsrv 蹇呴』鍦?Windows 涓婅繍琛?> 2. AlmaLinux-8 鐨?tmux 浼氳瘽 muyu 蹇呴』瀛樺湪
> 3. DISPLAY 鐜鍙橀噺蹇呴』璁剧疆涓?`localhost:0`

### 鍚姩 VcXsrv

```powershell
# 鍦?PowerShell 涓墽琛?Start-Process 'C:\Program Files (x86)\VcXsrv\vcxsrv.exe' -ArgumentList ':0 -multiwindow -ac -nowgl -listen tcp'
```

### 璁剧疆鏄剧ず

```bash
export DISPLAY=localhost:0
```

### 杩愯浠跨湡

> [!example]- 鍩烘湰 UVM 浠跨湡
> ```bash
> cd /home/muyuEDA/<椤圭洰鐩綍>
> xrun <top.sv> -uvm -access +r -gui
> ```

> [!example]- 瀹屾暣绀轰緥
> ```bash
> xrun \
>   +incdir+./sv \
>   +incdir+./tb \
>   -uvm \
>   -access +r \
>   -gui \
>   -sv_seed random \
>   tb_top.sv
> ```

### 甯哥敤 xrun 閫夐」

| 閫夐」 | 璇存槑 |
|------|------|
| `-uvm` | 鍚敤 UVM |
| `-access +r` | 璇绘潈闄愶紝鐢ㄤ簬娉㈠舰杞偍 |
| `-gui` | 鎵撳紑 SimVision GUI |
| `-sv_seed <value>` | 璁剧疆闅忔満绉嶅瓙 |
| `-sv_lib <library>` | 鍔犺浇 DPI 搴?|
| `-incdir <dir>` | 鍖呭惈鐩綍 |
| `-define <macro>` | 瀹氫箟瀹?|
| `-timescale <scale>` | 璁剧疆鏃堕棿鍗曚綅 |
| `-exit` | 浠跨湡缁撴潫鍚庨€€鍑?|
| `+UVM_TESTNAME=<name>` | 鎸囧畾 UVM test |

### 鏌ョ湅娉㈠舰

> [!example]- 鐙珛鎵撳紑 SimVision
> ```bash
> export DISPLAY=localhost:0
> simvision -64 /path/to/wave.vcd &
> ```

> [!example]- SHM 鏁版嵁搴?> ```bash
> simvision -64 /path/to/shm_dir &
> ```

### 鍥炲綊娴嬭瘯

```bash
for TEST in test1 test2 test3; do
  xrun tb_top.sv -uvm -access +r -sv_seed random +UVM_TESTNAME=$TEST -exit
done
```

---

## 馃搨 鏂囦欢璺緞鏄犲皠

| Windows 璺緞 | WSL 璺緞 |
|-------------|---------|
| `C:\Users\MI\` | `/mnt/c/Users/MI/` |
| `D:\` | `/mnt/d/` |
| `E:\` | `/mnt/e/` |
| WSL 涓荤洰褰?| `/home/muyuEDA/` |

> [!tip] 鎻愮ず
> Windows 璺緞鍦?WSL 涓洿鎺ラ€氳繃 `/mnt/` 璁块棶锛屾棤闇€澶嶅埗鏂囦欢銆?
---

## 鉂?甯歌闂

> [!failure]- SimVision 绌虹櫧鎴栧崱椤?> ```powershell
> # 妫€鏌?VcXsrv 鏄惁杩愯
> Get-Process vcxsrv
>
> # 濡傛灉娌℃湁杩愯锛屽惎鍔ㄥ畠
> Start-Process 'C:\Program Files (x86)\VcXsrv\vcxsrv.exe' -ArgumentList ':0 -multiwindow -ac -nowgl -listen tcp'
> ```
>
> 鐒跺悗鍦?WSL 涓細
> ```bash
> export DISPLAY=localhost:0
> ```

> [!failure]- VcXsrv 杩炴帴澶辫触
> 1. 纭闃茬伀澧欏凡鏀捐 VcXsrv
> 2. 浠ョ鐞嗗憳韬唤杩愯 PowerShell锛屾墽琛岋細
> ```powershell
> New-NetFirewallRule -DisplayName "VcXsrv" -Direction Inbound -Program "C:\Program Files (x86)\VcXsrv\vcxsrv.exe" -Action Allow
> ```

> [!failure]- xrun 缂栬瘧閿欒
> - 妫€鏌?include 璺緞锛歚+incdir+./sv`
> - 纭 UVM 搴撳彲鐢紙Xcelium 鑷甫锛?> - 璁剧疆鏃堕棿鍗曚綅锛歚-timescale 1ns/1ps`

> [!failure]- 鏉冮檺闂
> ```bash
> chmod +x <script>
> ls -la <file>  # 妫€鏌ユ枃浠舵潈闄?> ```

---

## 馃捑 瀛樺偍绌洪棿

| 鍒嗗尯 | 鎬诲閲?| 鍙敤 | 璇存槑 |
|------|--------|------|------|
| WSL 鏍圭洰褰?| 1007G | 607G | 瀛樻斁 EDA 宸ュ叿鍜岄」鐩?|
| E:\ | 932G | 89G | WSL 铏氭嫙纾佺洏瀛樻斁浣嶇疆锛岄渶娉ㄦ剰绌洪棿 |

---

## 馃殌 蹇€熷弬鑰?
> [!done] 鍦?Claude Code 涓殑甯哥敤鎸囦护
> ```
> "鍦?alma 閲岃繍琛?xrun tb_top.sv -uvm -gui"   鈫?鑷姩鎵ц浠跨湡
> "鐪嬬湅娉㈠舰"                                     鈫?鑷姩鎵撳紑 SimVision
> "鍦?AlmaLinux 閲岃窇涓€涓嬫祴璇?                    鈫?鑷姩瑙﹀彂 eda-sim skill
> ```

---

*鏈€鍚庢洿鏂帮細2026-05-15*

