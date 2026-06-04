---
tags: [Script, Python, 自动化, 工具]
created: 2026-04-17
updated: 2026-06-02
---

# 00-Python

tags: #Python #脚本 #自动化

## Python 在验证中的应用

Python 广泛应用于 IC 验证的各个阶段：
- 验证计划管理
- 回归测试自动化
- 日志解析和分析
- 覆盖率处理
- 文档生成

## 基础语法速查

### 变量和数据类型

```python
# 整数
a = 10
b = 0xFF

# 浮点数
pi = 3.14159

# 字符串
name = "IC_Verification"
path = r"C:\project"  # raw string

# 列表
data = [1, 2, 3, 4]
data.append(5)

# 字典
config = {
    "frequency": 100,
    "voltage": 1.2,
    "mode": "async"
}

# 元组 (不可变)
coord = (10, 20)

# 集合
regs = {"AXI", "APB", "I2C"}
```

### 条件判断

```python
if condition:
    print("True")
elif other:
    print("Other")
else:
    print("False")

# 三元表达式
value = "yes" if x > 0 else "no"
```

### 循环

```python
# for 循环
for i in range(10):
    print(i)

# 遍历列表
for item in data:
    print(item)

# 带索引
for i, item in enumerate(data):
    print(f"{i}: {item}")

# while 循环
while count < 100:
    count += 1

# 列表推导式
squares = [x**2 for x in range(10)]
evens = [x for x in range(20) if x % 2 == 0]
```

### 函数

```python
def parse_log(filename, pattern=None):
    """解析日志文件"""
    results = []
    with open(filename, 'r') as f:
        for line in f:
            if pattern and pattern in line:
                results.append(line.strip())
    return results

# 默认参数
def config_reg(addr, value=0, enable=True):
    pass

# 可变参数
def printf(*args, **kwargs):
    print(*args, **kwargs)
```

### 异常处理

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

## 文件操作

### 读写文件

```python
# 读取整个文件
with open("design.sv", "r") as f:
    content = f.read()

# 逐行读取
with open("log.txt", "r") as f:
    for line in f:
        print(line.strip())

# 写入文件
with open("output.txt", "w") as f:
    f.write("Hello\n")
    f.writelines(["line1\n", "line2\n"])

# 追加模式
with open("log.txt", "a") as f:
    f.write("New entry\n")
```

### 路径操作

```python
import os
from pathlib import Path

# 路径拼接
project_root = Path("D:/project")
log_dir = project_root / "logs"

# 检查路径
if log_dir.exists():
    print("Directory exists")

# 列出文件
for f in log_dir.glob("*.log"):
    print(f.name)

# 创建目录
log_dir.mkdir(parents=True, exist_ok=True)
```

## 正则表达式

```python
import re

# 匹配地址
addr_match = re.search(r'@([0-9a-fA-F]+)', line)
if addr_match:
    addr = int(addr_match.group(1), 16)

# 匹配时间戳
time_match = re.search(r'(\d+):(\d+):(\d+)', line)

# 查找所有匹配
errors = re.findall(r'ERROR: (.+)', log_content)

# 替换
new_content = re.sub(r'\bERROR\b', 'WARN', content)

# 编译正则
addr_pattern = re.compile(r'@([0-9a-fA-F]+)')
```

## 系统命令

```python
import subprocess
import os

# 执行命令
result = subprocess.run(["ls", "-la"], capture_output=True, text=True)
print(result.stdout)

# 执行命令并获取返回码
ret = subprocess.call("make sim", shell=True)

# 后台执行
proc = subprocess.Popen(["vsim", "-c"], stdin=subprocess.PIPE)
proc.stdin.write(b"run -all\n")
proc.stdin.close()

# 检查进程
if proc.poll() is None:
    print("Still running")
```

## 日志解析示例

### 解析 UVM 日志

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

### 解析覆盖率报告

```python
import re
import json

def parse_coverage_report(filename):
    """解析覆盖率报告"""
    coverage = {}
    current_section = None

    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()

            # 检测章节
            if 'Line Coverage' in line:
                current_section = 'line'
            elif 'Branch Coverage' in line:
                current_section = 'branch'
            elif 'Functional Coverage' in line:
                current_section = 'functional'

            # 提取覆盖率数值
            match = re.search(r'(\d+\.?\d*)%', line)
            if match and current_section:
                coverage[current_section] = float(match.group(1))

    return coverage

def generate_html_report(coverage_data, output="coverage.html"):
    """生成 HTML 报告"""
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

## 配置管理

```python
import json
import yaml

# JSON 配置
def load_config_json(filename):
    with open(filename, 'r') as f:
        return json.load(f)

def save_config_json(config, filename):
    with open(filename, 'w') as f:
        json.dump(config, f, indent=2)

# YAML 配置
def load_config_yaml(filename):
    with open(filename, 'r') as f:
        return yaml.safe_load(f)

# 配置示例
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

## 并行处理

```python
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
import subprocess

def run_simulation(test_name):
    """运行单个测试"""
    result = subprocess.run(
        ["vsim", "-c", "-do", f"run {test_name}"],
        capture_output=True,
        text=True
    )
    return (test_name, result.returncode)

def run_parallel_tests(test_list, workers=4):
    """并行运行测试"""
    with ProcessPoolExecutor(max_workers=workers) as executor:
        results = list(executor.map(run_simulation, test_list))
    return results

# 使用
tests = [f"test_{i}" for i in range(10)]
results = run_parallel_tests(tests, workers=4)
```

## Excel/CSV 处理

```python
import csv

# CSV 操作
def save_to_csv(data, filename):
    with open(filename, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)

def read_from_csv(filename):
    with open(filename, 'r') as f:
        reader = csv.DictReader(f)
        return list(reader)

# Excel 操作 (需要 openpyxl)
from openpyxl import Workbook, load_workbook

def save_to_excel(data, filename):
    wb = Workbook()
    ws = wb.active
    ws.append(list(data[0].keys()))
    for row in data:
        ws.append(list(row.values()))
    wb.save(filename)
```

## 常用库速查

| 库 | 用途 | 安装 |
|---|------|------|
| `re` | 正则表达式 | 内置 |
| `json` | JSON 处理 | 内置 |
| `csv` | CSV 处理 | 内置 |
| `pathlib` | 路径操作 | 内置 |
| `subprocess` | 执行命令 | 内置 |
| `yaml` | YAML 处理 | `pip install pyyaml` |
| `openpyxl` | Excel 操作 | `pip install openpyxl` |
| `matplotlib` | 绘图 | `pip install matplotlib` |
| `numpy` | 数值计算 | `pip install numpy` |
| `pandas` | 数据分析 | `pip install pandas` |

## 相关链接

- [[01-Log解析]] - 日志解析
- [[00-Makefile]] - 构建工具
- [[00-总索引]] - 返回总索引

---

*创建时间: 2026-04-17*
*更新时间: 2026-04-17*
