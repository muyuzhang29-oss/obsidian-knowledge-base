---
tags: [Script, Python, 鑷姩鍖? 宸ュ叿]
created: 2026-04-17
updated: 2026-06-02
---

# 00-Python

tags: #Python #鑴氭湰 #鑷姩鍖?

## Python 鍦ㄩ獙璇佷腑鐨勫簲鐢?

Python 骞挎硾搴旂敤浜?IC 楠岃瘉鐨勫悇涓樁娈碉細
- 楠岃瘉璁″垝绠＄悊
- 鍥炲綊娴嬭瘯鑷姩鍖?
- 鏃ュ織瑙ｆ瀽鍜屽垎鏋?
- 瑕嗙洊鐜囧鐞?
- 鏂囨。鐢熸垚

## 鍩虹璇硶閫熸煡

### 鍙橀噺鍜屾暟鎹被鍨?

```python
# 鏁存暟
a = 10
b = 0xFF

# 娴偣鏁?
pi = 3.14159

# 瀛楃涓?
name = "IC_Verification"
path = r"C:\project"  # raw string

# 鍒楄〃
data = [1, 2, 3, 4]
data.append(5)

# 瀛楀吀
config = {
    "frequency": 100,
    "voltage": 1.2,
    "mode": "async"
}

# 鍏冪粍 (涓嶅彲鍙?
coord = (10, 20)

# 闆嗗悎
regs = {"AXI", "APB", "I2C"}
```

### 鏉′欢鍒ゆ柇

```python
if condition:
    print("True")
elif other:
    print("Other")
else:
    print("False")

# 涓夊厓琛ㄨ揪寮?
value = "yes" if x > 0 else "no"
```

### 寰幆

```python
# for 寰幆
for i in range(10):
    print(i)

# 閬嶅巻鍒楄〃
for item in data:
    print(item)

# 甯︾储寮?
for i, item in enumerate(data):
    print(f"{i}: {item}")

# while 寰幆
while count < 100:
    count += 1

# 鍒楄〃鎺ㄥ寮?
squares = [x**2 for x in range(10)]
evens = [x for x in range(20) if x % 2 == 0]
```

### 鍑芥暟

```python
def parse_log(filename, pattern=None):
    """瑙ｆ瀽鏃ュ織鏂囦欢"""
    results = []
    with open(filename, 'r') as f:
        for line in f:
            if pattern and pattern in line:
                results.append(line.strip())
    return results

# 榛樿鍙傛暟
def config_reg(addr, value=0, enable=True):
    pass

# 鍙彉鍙傛暟
def printf(*args, **kwargs):
    print(*args, **kwargs)
```

### 寮傚父澶勭悊

```python
try:
    with open("log.txt", "r") as f:
        content = f.read()
except FileNotFoundError:
    print("File not found")
except Exception as e:
    print(f"Error: {e}")
finally:
    print("Cleanup")
```

## 鏂囦欢鎿嶄綔

### 璇诲啓鏂囦欢

```python
# 璇诲彇鏁翠釜鏂囦欢
with open("design.sv", "r") as f:
    content = f.read()

# 閫愯璇诲彇
with open("log.txt", "r") as f:
    for line in f:
        print(line.strip())

# 鍐欏叆鏂囦欢
with open("output.txt", "w") as f:
    f.write("Hello\n")
    f.writelines(["line1\n", "line2\n"])

# 杩藉姞妯″紡
with open("log.txt", "a") as f:
    f.write("New entry\n")
```

### 璺緞鎿嶄綔

```python
import os
from pathlib import Path

# 璺緞鎷兼帴
project_root = Path("D:/project")
log_dir = project_root / "logs"

# 妫€鏌ヨ矾寰?
if log_dir.exists():
    print("Directory exists")

# 鍒楀嚭鏂囦欢
for f in log_dir.glob("*.log"):
    print(f.name)

# 鍒涘缓鐩綍
log_dir.mkdir(parents=True, exist_ok=True)
```

## 姝ｅ垯琛ㄨ揪寮?

```python
import re

# 鍖归厤鍦板潃
addr_match = re.search(r'@([0-9a-fA-F]+)', line)
if addr_match:
    addr = int(addr_match.group(1), 16)

# 鍖归厤鏃堕棿鎴?
time_match = re.search(r'(\d+):(\d+):(\d+)', line)

# 鏌ユ壘鎵€鏈夊尮閰?
errors = re.findall(r'ERROR: (.+)', log_content)

# 鏇挎崲
new_content = re.sub(r'\bERROR\b', 'WARN', content)

# 缂栬瘧姝ｅ垯
addr_pattern = re.compile(r'@([0-9a-fA-F]+)')
```

## 绯荤粺鍛戒护

```python
import subprocess
import os

# 鎵ц鍛戒护
result = subprocess.run(["ls", "-la"], capture_output=True, text=True)
print(result.stdout)

# 鎵ц鍛戒护骞惰幏鍙栬繑鍥炵爜
ret = subprocess.call("make sim", shell=True)

# 鍚庡彴鎵ц
proc = subprocess.Popen(["vsim", "-c"], stdin=subprocess.PIPE)
proc.stdin.write(b"run -all\n")
proc.stdin.close()

# 妫€鏌ヨ繘绋?
if proc.poll() is None:
    print("Still running")
```

## 鏃ュ織瑙ｆ瀽绀轰緥

### 瑙ｆ瀽 UVM 鏃ュ織

```python
import re
from collections import defaultdict

class UVMLogParser:
    def __init__(self, log_file):
        self.log_file = log_file
        self.errors = []
        self.warnings = []
        self.info = defaultdict(list)

    def parse(self):
        with open(self.log_file, 'r') as f:
            for line in f:
                if 'UVM_ERROR' in line:
                    self.errors.append(self._extract_info(line))
                elif 'UVM_WARNING' in line:
                    self.warnings.append(self._extract_info(line))
                elif 'UVM_INFO' in line:
                    self._parse_info(line)

    def _extract_info(self, line):
        match = re.search(r'\[([^]]+)\]\s*(.+)', line)
        if match:
            return {
                'severity': match.group(1),
                'message': match.group(2),
                'line': line
            }
        return {'line': line}

    def _parse_info(self, line):
        match = re.search(r'\[(\w+)\]\s*\[(\d+)\]\s*(.+)', line)
        if match:
            component = match.group(1)
            self.info[component].append(match.group(3))

    def print_summary(self):
        print(f"Errors: {len(self.errors)}")
        print(f"Warnings: {len(self.warnings)}")
        print(f"Info components: {len(self.info)}")

if __name__ == "__main__":
    parser = UVMLogParser("sim.log")
    parser.parse()
    parser.print_summary()
```

### 瑙ｆ瀽瑕嗙洊鐜囨姤鍛?

```python
import re
import json

def parse_coverage_report(filename):
    """瑙ｆ瀽瑕嗙洊鐜囨姤鍛?""
    coverage = {}
    current_section = None

    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()

            # 妫€娴嬬珷鑺?
            if 'Line Coverage' in line:
                current_section = 'line'
            elif 'Branch Coverage' in line:
                current_section = 'branch'
            elif 'Functional Coverage' in line:
                current_section = 'functional'

            # 鎻愬彇瑕嗙洊鐜囨暟鍊?
            match = re.search(r'(\d+\.?\d*)%', line)
            if match and current_section:
                coverage[current_section] = float(match.group(1))

    return coverage

def generate_html_report(coverage_data, output="coverage.html"):
    """鐢熸垚 HTML 鎶ュ憡"""
    html = f"""
    <html>
    <head><title>Coverage Report</title></head>
    <body>
    <h1>Coverage Summary</h1>
    <table border="1">
        <tr><th>Type</th><th>Coverage</th></tr>
    """
    for cov_type, value in coverage_data.items():
        color = "green" if value >= 90 else "orange" if value >= 70 else "red"
        html += f'<tr><td>{cov_type}</td><td style="color:{color}">{value}%</td></tr>'
    html += """
    </table>
    </body>
    </html>
    """
    with open(output, 'w') as f:
        f.write(html)
```

## 閰嶇疆绠＄悊

```python
import json
import yaml

# JSON 閰嶇疆
def load_config_json(filename):
    with open(filename, 'r') as f:
        return json.load(f)

def save_config_json(config, filename):
    with open(filename, 'w') as f:
        json.dump(config, f, indent=2)

# YAML 閰嶇疆
def load_config_yaml(filename):
    with open(filename, 'r') as f:
        return yaml.safe_load(f)

# 閰嶇疆绀轰緥
config = {
    "project": {
        "name": "chip_verification",
        "version": "1.0"
    },
    "simulator": {
        "tool": "vsim",
        "flags": ["-c", "-coverage"]
    },
    "regression": {
        "test_list": ["test1", "test2", "test3"],
        "parallel": 4
    }
}
```

## 骞惰澶勭悊

```python
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
import subprocess

def run_simulation(test_name):
    """杩愯鍗曚釜娴嬭瘯"""
    result = subprocess.run(
        ["vsim", "-c", "-do", f"run {test_name}"],
        capture_output=True,
        text=True
    )
    return (test_name, result.returncode)

def run_parallel_tests(test_list, workers=4):
    """骞惰杩愯娴嬭瘯"""
    with ProcessPoolExecutor(max_workers=workers) as executor:
        results = list(executor.map(run_simulation, test_list))
    return results

# 浣跨敤
tests = [f"test_{i}" for i in range(10)]
results = run_parallel_tests(tests, workers=4)
```

## Excel/CSV 澶勭悊

```python
import csv

# CSV 鎿嶄綔
def save_to_csv(data, filename):
    with open(filename, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)

def read_from_csv(filename):
    with open(filename, 'r') as f:
        reader = csv.DictReader(f)
        return list(reader)

# Excel 鎿嶄綔 (闇€瑕?openpyxl)
from openpyxl import Workbook, load_workbook

def save_to_excel(data, filename):
    wb = Workbook()
    ws = wb.active
    ws.append(list(data[0].keys()))
    for row in data:
        ws.append(list(row.values()))
    wb.save(filename)
```

## 甯哥敤搴撻€熸煡

| 搴?| 鐢ㄩ€?| 瀹夎 |
|---|------|------|
| `re` | 姝ｅ垯琛ㄨ揪寮?| 鍐呯疆 |
| `json` | JSON 澶勭悊 | 鍐呯疆 |
| `csv` | CSV 澶勭悊 | 鍐呯疆 |
| `pathlib` | 璺緞鎿嶄綔 | 鍐呯疆 |
| `subprocess` | 鎵ц鍛戒护 | 鍐呯疆 |
| `yaml` | YAML 澶勭悊 | `pip install pyyaml` |
| `openpyxl` | Excel 鎿嶄綔 | `pip install openpyxl` |
| `matplotlib` | 缁樺浘 | `pip install matplotlib` |
| `numpy` | 鏁板€艰绠?| `pip install numpy` |
| `pandas` | 鏁版嵁鍒嗘瀽 | `pip install pandas` |

## 鐩稿叧閾炬帴

- [[01-Log瑙ｆ瀽]] - 鏃ュ織瑙ｆ瀽
- [[00-Makefile]] - 鏋勫缓宸ュ叿
- [[00-鎬荤储寮昡] - 杩斿洖鎬荤储寮?

---

*鍒涘缓鏃堕棿: 2026-04-17*
*鏇存柊鏃堕棿: 2026-04-17*

