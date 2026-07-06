# 01-Log解析

tags: AXI, DDR, Assertion, Ethernet, UVM, Coverage, Protocol

## 日志解析概述

日志解析是验证工程师日常工作的重要部分，用于：
- 分析仿真结果
- 提取错误和警告
- 统计覆盖率数据
- 生成测试报告

## 常见日志格式

### UVM 日志格式

```
# UVM_INFO @ 1000: uvm_test_top.env.agent.driver [DRIVER] Drive transaction
# UVM_ERROR @ 2000: uvm_test_top.env.scoreboard [SCOREBOARD] Data mismatch
# UVM_WARNING @ 1500: uvm_test_top.env.monitor [MONITOR] Unexpected protocol
```

### 仿真器日志

```
# Questa
** Note: (vsim-121) Starting simulation
** Note: (vlog-2286) Compile successful

# VCS
VCS version K-2015.09-SP2
Chronologic VCS simulator
```

### 覆盖率日志

```
# Line Coverage: 98.5%
# Branch Coverage: 92.3%
# Functional Coverage: 100.0%
```

## Python 日志解析脚本

### 基础解析器

```python
#!/usr/bin/env python3
"""
日志解析基础框架
"""

import re
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import List, Dict, Optional


@dataclass
class LogEntry:
    """日志条目"""
    timestamp: float
    severity: str
    component: str
    message: str
    line_number: int


class LogParser:
    """日志解析器基类"""

    # UVM 日志正则
    UVM_PATTERN = re.compile(
        r'# (UVM_\w+)\s+@\s+(\d+):\s+(\S+)\s+\[(\w+)\]\s*(.*)'
    )

    # 标准日志正则
    STD_PATTERN = re.compile(
        r'(?P<timestamp>\d+):(?P<severity>\w+):(?P<component>\S+):(?P<message>.*)'
    )

    def __init__(self, log_file: str):
        self.log_file = Path(log_file)
        self.entries: List[LogEntry] = []

    def parse(self) -> None:
        """解析日志文件"""
        if not self.log_file.exists():
            raise FileNotFoundError(f"Log file not found: {self.log_file}")

        with open(self.log_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line_num, line in enumerate(f, 1):
                entry = self._parse_line(line, line_num)
                if entry:
                    self.entries.append(entry)

    def _parse_line(self, line: str, line_num: int) -> Optional[LogEntry]:
        """解析单行日志"""
        match = self.UVM_PATTERN.match(line)
        if match:
            return LogEntry(
                timestamp=int(match.group(2)),
                severity=match.group(1),
                component=match.group(3),
                message=match.group(5),
                line_number=line_num
            )
        return None

    def get_errors(self) -> List[LogEntry]:
        """获取所有错误"""
        return [e for e in self.entries if 'ERROR' in e.severity]

    def get_warnings(self) -> List[LogEntry]:
        """获取所有警告"""
        return [e for e in self.entries if 'WARNING' in e.severity]

    def get_by_severity(self, severity: str) -> List[LogEntry]:
        """按严重级别获取"""
        return [e for e in self.entries if e.severity == severity]

    def get_by_component(self, component: str) -> List[LogEntry]:
        """按组件获取"""
        return [e for e in self.entries if component in e.component]

    def print_summary(self) -> None:
        """打印摘要"""
        errors = self.get_errors()
        warnings = self.get_warnings()

        print(f"=== Log Summary ===")
        print(f"Total entries: {len(self.entries)}")
        print(f"Errors: {len(errors)}")
        print(f"Warnings: {len(warnings)}")
```

### UVM 日志分析器

```python
import re
from collections import Counter
from typing import Dict, List, Tuple


class UVMAnalyzer:
    """UVM 日志分析器"""

    def __init__(self, log_file: str):
        self.log_file = log_file
        self.entries: List[Dict] = []
        self._parse()

    def _parse(self) -> None:
        """解析日志"""
        pattern = re.compile(
            r'# (UVM_\w+)\s+@\s+(\d+):\s+([\w.]+)\s+\[(\w+)\]\s*(.*)'
        )

        with open(self.log_file, 'r') as f:
            for line in f:
                match = pattern.match(line)
                if match:
                    self.entries.append({
                        'severity': match.group(1),
                        'time': int(match.group(2)),
                        'component': match.group(3),
                        'id': match.group(4),
                        'message': match.group(5).strip()
                    })

    def get_objection_count(self) -> Dict[str, int]:
        """统计 objection 数量"""
        objections = {
            'raised': 0,
            'dropped': 0,
            'all_dropped': 0
        }

        for entry in self.entries:
            msg = entry['message']
            if 'raised objection' in msg:
                objections['raised'] += 1
            elif 'dropped objection' in msg:
                objections['dropped'] += 1
            elif 'all objections dropped' in msg:
                objections['all_dropped'] += 1

        return objections

    def get_transaction_stats(self) -> Dict[str, int]:
        """统计 transaction 数量"""
        stats = Counter()

        for entry in self.entries:
            msg = entry['message'].lower()
            if 'transaction' in msg or 'sequence item' in msg:
                if 'started' in msg:
                    stats['started'] += 1
                elif 'completed' in msg:
                    stats['completed'] += 1

        return dict(stats)

    def get_phase_times(self) -> Dict[str, Tuple[int, int]]:
        """获取各 phase 的执行时间"""
        phase_times = {}
        current_phase = None
        phase_start = 0

        for entry in self.entries:
            msg = entry['message']
            time = entry['time']

            # 检测 phase 开始/结束
            if 'starting phase' in msg:
                match = re.search(r'(\w+_phase)', msg)
                if match:
                    current_phase = match.group(1)
                    phase_start = time

            elif 'ending phase' in msg and current_phase:
                if current_phase in phase_times:
                    phase_times[current_phase] = (
                        phase_times[current_phase][0],
                        time
                    )
                else:
                    phase_times[current_phase] = (phase_start, time)

        return phase_times

    def check_test_status(self) -> str:
        """检查测试状态"""
        for entry in self.entries:
            if 'TEST PASSED' in entry['message']:
                return 'PASSED'
            elif 'TEST FAILED' in entry['message']:
                return 'FAILED'
        return 'UNKNOWN'

    def generate_report(self) -> str:
        """生成分析报告"""
        report = []
        report.append("=" * 60)
        report.append("UVM Log Analysis Report")
        report.append("=" * 60)

        # 测试状态
        status = self.check_test_status()
        report.append(f"\nTest Status: {status}")

        # Error/Warning 统计
        errors = [e for e in self.entries if 'ERROR' in e['severity']]
        warnings = [e for e in self.entries if 'WARNING' in e['severity']]

        report.append(f"\nTotal Entries: {len(self.entries)}")
        report.append(f"Errors: {len(errors)}")
        report.append(f"Warnings: {len(warnings)}")

        # 按组件统计
        components = Counter(e['component'] for e in self.entries)
        report.append("\nTop Components:")
        for comp, count in components.most_common(5):
            report.append(f"  {comp}: {count}")

        # Objection 统计
        objections = self.get_objection_count()
        report.append("\nObjection Summary:")
        report.append(f"  Raised: {objections['raised']}")
        report.append(f"  Dropped: {objections['dropped']}")
        report.append(f"  All Dropped: {objections['all_dropped']}")

        # 输出错误详情
        if errors:
            report.append("\nError Details:")
            for err in errors[:10]:  # 只显示前 10 个
                report.append(f"  [{err['time']}] {err['component']}: {err['message'][:50]}")

        return '\n'.join(report)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python uvm_analyzer.py <log_file>")
        sys.exit(1)

    analyzer = UVMAnalyzer(sys.argv[1])
    print(analyzer.generate_report())
```

### 覆盖率日志解析

```python
import re
from dataclasses import dataclass
from typing import List, Dict


@dataclass
class CoverageData:
    """覆盖率数据"""
    type: str
    value: float
    covered: int
    total: int
    bins_covered: int
    bins_total: int


class CoverageParser:
    """覆盖率日志解析器"""

    def __init__(self):
        self.data: List[CoverageData] = []
        self.total_coverage: float = 0.0

    def parse_file(self, filename: str) -> None:
        """解析覆盖率文件"""
        current_type = None
        current_value = 0.0

        with open(filename, 'r') as f:
            for line in f:
                # 提取总体覆盖率
                match = re.search(r'Total Coverage:\s+(\d+\.?\d*)%', line)
                if match:
                    self.total_coverage = float(match.group(1))

                # 提取各类型覆盖率
                match = re.search(r'(Line|Branch|Condition|FSM|Toggle)\s+Coverage:\s+(\d+\.?\d*)%', line)
                if match:
                    current_type = match.group(1)
                    current_value = float(match.group(2))

                # 提取详细信息
                match = re.search(r'Covered:\s+(\d+)/(\d+)\s+\((\d+\.?\d*)%\)', line)
                if match and current_type:
                    self.data.append(CoverageData(
                        type=current_type,
                        value=current_value,
                        covered=int(match.group(1)),
                        total=int(match.group(2)),
                        bins_covered=0,
                        bins_total=0
                    ))

    def get_summary(self) -> Dict[str, float]:
        """获取覆盖率摘要"""
        summary = {'total': self.total_coverage}

        for item in self.data:
            summary[item.type.lower()] = item.value

        return summary

    def check_coverage_goal(self, goal: float = 90.0) -> bool:
        """检查是否达到覆盖率目标"""
        return self.total_coverage >= goal

    def generate_html(self, output: str) -> None:
        """生成 HTML 报告"""
        html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Coverage Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        table {{ border-collapse: collapse; width: 100%; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #4CAF50; color: white; }}
        .pass {{ color: green; font-weight: bold; }}
        .fail {{ color: red; font-weight: bold; }}
    </style>
</head>
<body>
    <h1>Coverage Report</h1>
    <h2>Overall: {self.total_coverage}%</h2>
    <table>
        <tr>
            <th>Type</th>
            <th>Coverage</th>
            <th>Covered/Total</th>
            <th>Status</th>
        </tr>
"""

        for item in self.data:
            status_class = 'pass' if item.value >= 90 else 'fail'
            status_text = 'PASS' if item.value >= 90 else 'FAIL'
            html += f"""
        <tr>
            <td>{item.type}</td>
            <td>{item.value}%</td>
            <td>{item.covered}/{item.total}</td>
            <td class="{status_class}">{status_text}</td>
        </tr>
"""

        html += """
    </table>
</body>
</html>
"""

        with open(output, 'w') as f:
            f.write(html)


# 使用示例
if __name__ == '__main__':
    parser = CoverageParser()
    parser.parse_file('coverage.log')

    summary = parser.get_summary()
    print(f"Total Coverage: {summary['total']}%")

    if parser.check_coverage_goal(95.0):
        print("Coverage goal achieved!")
    else:
        print("Coverage goal not met!")

    parser.generate_html('coverage_report.html')
```

### 多文件合并分析

```python
import os
from pathlib import Path
from typing import List, Dict
import re


class MultiLogAnalyzer:
    """多日志文件分析器"""

    def __init__(self, log_dir: str):
        self.log_dir = Path(log_dir)
        self.logs: Dict[str, str] = {}
        self.results: Dict[str, Dict] = {}

    def load_logs(self, pattern: str = "*.log") -> None:
        """加载所有日志文件"""
        for log_file in self.log_dir.glob(pattern):
            self.logs[log_file.stem] = log_file.read_text()

    def analyze_all(self) -> None:
        """分析所有日志"""
        for name, content in self.logs.items():
            self.results[name] = self._analyze_single(content)

    def _analyze_single(self, content: str) -> Dict:
        """分析单个日志"""
        errors = len(re.findall(r'UVM_ERROR', content))
        warnings = len(re.findall(r'UVM_WARNING', content))

        # 检查测试结果
        passed = bool(re.search(r'TEST\s+PASSED', content))
        failed = bool(re.search(r'TEST\s+FAILED', content))

        # 提取覆盖率
        coverage_match = re.search(r'Total Coverage:\s+(\d+\.?\d*)%', content)
        coverage = float(coverage_match.group(1)) if coverage_match else 0.0

        return {
            'errors': errors,
            'warnings': warnings,
            'passed': passed,
            'failed': failed,
            'coverage': coverage,
            'status': 'PASS' if passed and errors == 0 else 'FAIL'
        }

    def generate_regression_report(self, output: str) -> None:
        """生成回归测试报告"""
        total = len(self.results)
        passed = sum(1 for r in self.results.values() if r['status'] == 'PASS')

        lines = []
        lines.append("=" * 80)
        lines.append("REGRESSION TEST REPORT")
        lines.append("=" * 80)
        lines.append(f"\nTotal Tests: {total}")
        lines.append(f"Passed: {passed}")
        lines.append(f"Failed: {total - passed}")
        lines.append(f"Pass Rate: {100.0 * passed / total:.1f}%")
        lines.append("\n" + "-" * 80)
        lines.append(f"{'Test Name':<30} {'Errors':<10} {'Warnings':<12} {'Coverage':<12} {'Status'}")
        lines.append("-" * 80)

        for name, result in sorted(self.results.items()):
            lines.append(
                f"{name:<30} "
                f"{result['errors']:<10} "
                f"{result['warnings']:<12} "
                f"{result['coverage']:<12.1f}% "
                f"{result['status']}"
            )

        lines.append("-" * 80)

        with open(output, 'w') as f:
            f.write('\n'.join(lines))

        print('\n'.join(lines))
```

## 常用正则表达式

```python
# UVM 日志
UVM_LOG = r'# (UVM_\w+)\s+@\s+(\d+):\s+([\w.]+)\s+\[(\w+)\]\s*(.*)'

# 时间戳
TIMESTAMP = r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})'

# 地址
ADDRESS = r'(0x)?([0-9a-fA-F]+)'

# 数字
NUMBER = r'(\d+\.?\d*)'

# 错误级别
SEVERITY = r'(ERROR|WARNING|INFO|FATAL)'

# 覆盖率
COVERAGE = r'([\w\s]+)Coverage:\s+(\d+\.?\d*)%'
```

## 相关链接

- [[00-Python]] - Python 基础
- [[00-Makefile]] - 构建工具
- [[00-总索引]] - 返回总索引
- [[UVM源代码研究]] - UVM核心机制源代码分析

---

*创建时间: 2026-04-17*
*更新时间: 2026-04-27*

