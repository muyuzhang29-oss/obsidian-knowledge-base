---
tags: [Tools, imc, 瑕嗙洊鐜嘳
---

# 00-imc

> Integrated Coverage - 瑕嗙洊鐜囧垎鏋愬伐鍏?
## 姒傝堪

imc (Integrated Coverage Manager) 鏄?Intel FPGA Verification Suite 涓殑瑕嗙洊鐜囧垎鏋愬拰鎶ュ憡宸ュ叿锛岀敤浜庢煡鐪嬨€佸悎骞跺拰鍒嗘瀽浠跨湡瑕嗙洊鐜囨暟鎹€?
## 鍩烘湰璇硶

```bash
imc [options]
```

### 甯哥敤妯″紡

| 妯″紡 | 璇存槑 |
|------|------|
| imc (鏃犲弬鏁? | 鍚姩 GUI |
| imc -batch | 鎵瑰鐞嗘ā寮?|
| imc -load | 鍔犺浇瑕嗙洊鐜囨暟鎹簱 |
| imc -merge | 鍚堝苟瑕嗙洊鐜?|
| imc -code | 鐢熸垚浠ｇ爜瑕嗙洊鐜囨姤鍛?|
| imc -html | 鐢熸垚 HTML 鎶ュ憡 |

---

## 鍛戒护琛岄€夐」

### 鍔犺浇鍜屼繚瀛?
| 閫夐」 | 璇存槑 |
|------|------|
| `-load <db>` | 鍔犺浇瑕嗙洊鐜囨暟鎹簱 |
| `-save <db>` | 淇濆瓨瑕嗙洊鐜囨暟鎹簱 |
| `-session <file>` | 鍔犺浇浼氳瘽鏂囦欢 |
| `-out <dir>` | 杈撳嚭鐩綍 |

### 鍚堝苟

| 閫夐」 | 璇存槑 |
|------|------|
| `-merge` | 鍚堝苟妯″紡 |
| `-out <db>` | 鍚堝苟杈撳嚭鏂囦欢 |
| `-input <db1,db2,...>` | 杈撳叆鏂囦欢鍒楄〃 |
| `-鐏屽叆 <name>=<value>` | 鍚堝苟閫夐」 |

### 鎶ュ憡鐢熸垚

| 閫夐」 | 璇存槑 |
|------|------|
| `-code` | 鐢熸垚浠ｇ爜瑕嗙洊鐜囨姤鍛?|
| `-detail` | 璇︾粏鎶ュ憡 |
| `-html` | 鐢熸垚 HTML 鎶ュ憡 |
| `-execRep` | 鎵ц鎶ュ憡鐢熸垚鍚庢墦寮€ |
| `-cvg` | 鍔熻兘瑕嗙洊鐜囨姤鍛?|
| `-show tests` | 鏄剧ず娴嬭瘯鍒楄〃 |

### 杩囨护

| 閫夐」 | 璇存槑 |
|------|------|
| `-annotate` | 鐢熸垚娉ㄩ噴鏂囦欢 |
| `-tests <test1,test2>` | 鎸囧畾娴嬭瘯 |
| `-modules <mod1,mod2>` | 鎸囧畾妯″潡 |
| `-lines <n>` | 鏈€灏忚瑕嗙洊鐜?|

---

## 甯哥敤鍛戒护

### 鍚姩 GUI

```bash
# 鐩存帴鍚姩 GUI
imc

# 鍔犺浇宸叉湁鏁版嵁搴?imc -load coverage/verilog.ucdb

# 鍔犺浇骞舵墦寮€
imc -load coverage/test.ucdb -session my_session.ses
```

### 鍚堝苟瑕嗙洊鐜囨暟鎹簱

```bash
# 鍚堝苟澶氫釜娴嬭瘯鐨勮鐩栫巼
imc -merge \
    -input "coverage/test1.ucdb,coverage/test2.ucdb,coverage/test3.ucdb" \
    -out coverage/merged.ucdb

# 浣跨敤閫氶厤绗?imc -merge \
    -input coverage/*.ucdb \
    -out coverage/merged.ucdb
```

### 鐢熸垚鎶ュ憡

```bash
# 鐢熸垚璇︾粏鎶ュ憡
imc -load coverage/merged.ucdb \
    -code -detail \
    -out coverage/report

# 鐢熸垚 HTML 鎶ュ憡
imc -load coverage/merged.ucdb \
    -html \
    -execRep \
    -out coverage/html_report

# 鐢熸垚鍔熻兘瑕嗙洊鐜囨姤鍛?imc -load coverage/merged.ucdb \
    -cvg \
    -out coverage/cvg_report
```

### 鎵瑰鐞嗘ā寮?
```bash
# 鐢熸垚鎶ュ憡鍒版枃浠?imc -batch \
    -load coverage/merged.ucdb \
    -code -detail \
    -out coverage/report.txt \
    2>&1 | tee imc.log

# 鐢熸垚娴嬭瘯鍒楄〃
imc -batch \
    -load coverage/merged.ucdb \
    -show tests \
    -show details
```

---

## imc 鍛戒护鏂囦欢

### .tcl 鍛戒护鏂囦欢

```tcl
# generate_report.tcl
database -open cov_db -into merged.ucdb -shlib -code bcesft

load_database merged.ucdb

# 璁剧疆瑕嗙洊鐜囩洰鏍?set coverage_option -weight 100

# 鐢熸垚鎶ュ憡
report -all -file coverage_report.txt
report -coverage -detail -file detail_report.txt

# HTML 鎶ュ憡
report -html -out html_report

# 閫€鍑?exit
```

### 浣跨敤鍛戒护鏂囦欢

```bash
imc -load merged.ucdb -do generate_report.tcl
```

---

## Makefile 闆嗘垚

```makefile
# ============== Coverage Targets ==============
COV_DIR  = coverage
COV_DB   = $(COV_DIR)/merged.ucdb

.PHONY: cov_merge cov_report cov_view cov_clean

# Merge coverage databases
cov_merge: $(COV_DIR)
	@echo "Merging coverage databases..."
	@imc -batch -merge \
		-input "$(wildcard $(COV_DIR)/*.ucdb)" \
		-out $(COV_DB) \
		-log $(COV_DIR)/merge.log

# Generate coverage report
cov_report: $(COV_DB)
	@echo "Generating coverage report..."
	@imc -batch \
		-load $(COV_DB) \
		-code -detail \
		-out $(COV_DIR)/report.txt

	@imc -batch \
		-load $(COV_DB) \
		-html \
		-out $(COV_DIR)/html \
		-hierarchy * \
		-cvg

# View coverage in GUI
cov_view: $(COV_DB)
	imc -load $(COV_DB)

# Clean coverage files
cov_clean:
	rm -rf $(COV_DIR)/*.ucdb
	rm -rf $(COV_DIR)/html
	rm -f $(COV_DIR)/*.txt
```

---

## 瑕嗙洊鐜囩被鍨嬭瑙?
### 浠ｇ爜瑕嗙洊鐜?(Code Coverage)

| 绫诲瀷 | 璇存槑 | 鍚敤閫夐」 |
|------|------|----------|
| **Line** | 璇彞瑕嗙洊 | `b` |
| **Branch** | 鍒嗘敮瑕嗙洊 | `c` |
| **Condition** | 鏉′欢瑕嗙洊 | `e` |
| **FSM** | 鐘舵€佹満瑕嗙洊 | `s` |
| **Toggle** | 缈昏浆瑕嗙洊 | `t` |
| **Path** | 璺緞瑕嗙洊 | `f` |

### 鍔熻兘瑕嗙洊鐜?(Functional Coverage)

```verilog
// 瑕嗙洊缁勫畾涔?covergroup my_cg @(posedge clk);
    option.per_instance = 1;

    cp_cmd: coverpoint cmd {
        bins read  = {READ};
        bins write = {WRITE};
        bins idle  = {IDLE};
    }

    cp_addr: coverpoint addr {
        bins low  = {[0:12'hFFF]};
        bins high = {[12'h1000:12'hFFFF]};
    }

    cross_cmd_addr: cross cp_cmd, cp_addr;
endgroup
```

---

## 瑕嗙洊鐜囧垎鏋愬伐浣滄祦

```mermaid
flowchart TD
    subgraph Sim["浠跨湡闃舵"]
        S1[test1 杩愯]
        S2[test2 杩愯]
        S3[test3 杩愯]
    end

    subgraph DB["鏁版嵁搴?]
        D1[test1.ucdb]
        D2[test2.ucdb]
        D3[test3.ucdb]
    end

    subgraph Merge["鍚堝苟闃舵"]
        IM[imc -merge]
    end

    subgraph Report["鎶ュ憡闃舵"]
        IR[imc -load]
        RC[Report Coverage]
        RH[Report HTML]
        RV[View in GUI]
    end

    S1 --> D1
    S2 --> D2
    S3 --> D3

    D1 --> IM
    D2 --> IM
    D3 --> IM

    IM --> MERGED[merged.ucdb]

    MERGED --> IR
    IR --> RC
    IR --> RH
    IR --> RV
```

---

## 甯哥敤 imc 鍛戒护 (GUI)

### 瑕嗙洊鐜囩洰鏍囪缃?
```
Coverage -> Set Goal...
Coverage -> Coverage Options...
```

### 鎶ュ憡瀵煎嚭

```
Reports -> Generate Report...
Reports -> Export to CSV...
Reports -> Generate HTML...
```

### 瑕嗙洊鐜囪繃婊?
```
Filter -> By Module...
Filter -> By Test...
Filter -> By Coverage Type...
```

---

## 甯歌闂

### 1. 鍚堝苟澶辫触

```bash
# 妫€鏌ユ暟鎹簱鏄惁鎹熷潖
imc -batch -load test.ucdb -show tests

# 娓呯悊鍚庨噸鏂板悎骞?rm -f merged.ucdb
imc -merge -input "*.ucdb" -out merged.ucdb
```

### 2. 瑕嗙洊鐜囦笉鏄剧ず

```bash
# 妫€鏌ユ槸鍚︿娇鐢ㄤ簡姝ｇ‘鐨勮鐩栫巼閫夐」
# 浠跨湡鏃堕渶瑕佹坊鍔?-coverage all
xrun -coverage all -covfile coverage.cfg -R

# 妫€鏌ユ暟鎹簱鏄惁鐢熸垚
ls -la coverage/*.ucdb
```

### 3. 鍐呭瓨涓嶈冻

```bash
# 浣跨敤鍒嗗尯鍚堝苟
imc -merge -input "test*.ucdb" -out merged.ucdb -part 1000
```

---

## 鐩稿叧閾炬帴

- [[00-xrun]] - xrun 浠跨湡鍣?- [[01-瑕嗙洊鐜嘳] - 瑕嗙洊鐜囩煡璇?- [[00-Makefile]] - Makefile 妯℃澘
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?
---

*鍒涘缓鏃堕棿: 2026-04-17*
*鏇存柊鏃堕棿: 2026-04-17*

