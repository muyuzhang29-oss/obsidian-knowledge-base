#!/usr/bin/env python3
"""
Obsidian 知识库健康检查脚本
==========================

功能:
  1. 检测无 Frontmatter 标签的文件
  2. 检测断链（链接指向不存在的笔记）
  3. 检测孤立笔记（没有入链或出链）
  4. 检测文件命名不规范项
  5. 检测重复内容
  6. 生成健康报告（Markdown 格式）

使用方法:
  python 03-知识库健康检查.py
  python 03-知识库健康检查.py --kb-dir "D:\\other\\vault"
  python 03-知识库健康检查.py --output report.md

技术要求:
  - Python 3.8+
  - 仅使用标准库

作者: Claude Code
创建时间: 2026-06-02
"""

import argparse
import hashlib
import re
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path


# ============================================================
# 配置
# ============================================================

# 默认知识库根目录
DEFAULT_KB_DIR = Path(r"D:\obsidian\knowledge-base")

# 默认报告输出路径
DEFAULT_OUTPUT = Path(r"D:\obsidian\knowledge-base\07-Scripts\健康检查报告.md")

# 忽略的目录（不扫描）
IGNORE_DIRS = {
    ".obsidian",
    ".claude",
    ".claudian",
    ".git",
    "copilot",
    ".trash",
}

# 这些是历史审计记录，保留原文但不纳入当前断链/孤立笔记判断。
IGNORE_LINK_CHECK_FILES = {
    "00-索引/03-健康报告.md",
    "00-索引/04-健康报告-修复后.md",
    "00-索引/05-修复总结.md",
}

# Frontmatter 正则：匹配 --- 包裹的 YAML 块
FRONTMATTER_RE = re.compile(r"^\ufeff?---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|$)", re.DOTALL)

# Obsidian wiki 链接: [[target]] 或 [[target|alias]]
# 排除嵌入 ![[...]] 和代码块中的链接
WIKILINK_RE = re.compile(r"(?<!!)\[\[([^\]|#]+?)(?:[|#][^\]]*?)?\]\]")

# 带有路径的链接分隔符
LINK_PATH_SEP = "/"

# 文件名规范：NN-名称.md 或 00-名称.md 的模式
# 放宽规则：允许字母开头的名称（如 UVM-xxx.md, AXI.md 等）
NAMING_PATTERN_STRICT = re.compile(r"^\d{2}-.+\.md$")  # NN-名称.md
NAMING_PATTERN_RELAXED = re.compile(r"^[A-Za-z一-鿿].*\.md$")  # 字母或中文开头


# ============================================================
# 工具函数
# ============================================================

def is_hidden_or_ignored(path: Path) -> bool:
    """判断路径是否应被忽略"""
    parts = path.parts
    for part in parts:
        if part in IGNORE_DIRS or part.startswith("."):
            return True
    return False


def collect_markdown_files(kb_dir: Path) -> list[Path]:
    """收集知识库中所有需要检查的 Markdown 文件"""
    md_files = []
    for p in kb_dir.rglob("*.md"):
        if is_hidden_or_ignored(p.relative_to(kb_dir)):
            continue
        md_files.append(p)
    return sorted(md_files)


def normalize_rel_path(path: Path) -> str:
    """将路径转换为 Obsidian 常用的 / 分隔相对路径"""
    return str(path).replace("\\", "/")


def is_link_check_ignored(path: Path, kb_dir: Path) -> bool:
    """判断某文件是否跳过链接网络检查"""
    rel = normalize_rel_path(path.relative_to(kb_dir))
    return rel in IGNORE_LINK_CHECK_FILES


def read_file_safe(path: Path) -> str:
    """安全读取文件内容，失败返回空字符串"""
    try:
        return path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        try:
            return path.read_text(encoding="gbk")
        except (UnicodeDecodeError, OSError):
            return ""


def extract_frontmatter(content: str) -> dict | None:
    """提取 YAML Frontmatter，返回简化字典（仅检测 tags/created/updated）"""
    match = FRONTMATTER_RE.match(content)
    if not match:
        return None
    raw = match.group(1)
    result = {"has_tags": False, "has_created": False, "has_updated": False, "raw": raw}
    # 简单关键字检测，不依赖 pyyaml
    if re.search(r"^tags\s*:", raw, re.MULTILINE):
        result["has_tags"] = True
    if re.search(r"^created\s*:", raw, re.MULTILINE):
        result["has_created"] = True
    if re.search(r"^updated\s*:", raw, re.MULTILINE):
        result["has_updated"] = True
    return result


def extract_wikilinks(content: str) -> set[str]:
    """提取文件中所有 wiki 链接的目标名称"""
    links = set()
    # 排除代码块和行内代码中的链接
    in_code_block = False
    lines = content.split("\n")
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("```"):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue
        line = re.sub(r"`[^`\n]+`", "", line)
        # 排除 dataview 代码块内容
        for m in WIKILINK_RE.finditer(line):
            target = m.group(1).strip()
            if target:
                links.add(target)
    return links


def build_note_index(md_files: list[Path], kb_dir: Path) -> dict[str, Path]:
    """
    构建笔记名称到路径的索引。
    键 = 笔记名（不含 .md），值 = 完整路径。
    支持短名称查找（不带目录前缀）和带路径的名称。
    """
    index = {}
    for p in md_files:
        rel = p.relative_to(kb_dir)
        stem = p.stem  # 不含 .md
        # 完整相对路径（不含 .md），用 / 分隔
        full_key = str(rel.with_suffix("")).replace("\\", "/")
        index[full_key] = p
        # 短名称（仅文件名）
        if stem not in index:
            index[stem] = p
        else:
            # 短名称冲突，保留 None 表示有歧义
            index[stem] = None
    return index


def resolve_link(link_target: str, note_index: dict[str, Path], current_file: Path, kb_dir: Path) -> Path | None:
    """
    尝试解析链接目标，返回对应的文件路径。
    支持:
      - 短名称: [[Phase机制]]
      - 带路径: [[02-UVM/01-Phase机制]]
      - 同目录相对: [[01-数据类型]] (在 01-SV语法/ 下)
      - 附件: [[03-Protocol/HSMT/spec.pdf]]
    """
    link_target = link_target.strip().strip("\\")
    link_target = re.sub(r"\.md$", "", link_target)

    # 1. 直接查找完整路径
    if link_target in note_index and note_index[link_target] is not None:
        return note_index[link_target]

    # 2. 尝试当前文件同目录下查找
    current_dir = current_file.parent.relative_to(kb_dir)
    candidate = str(current_dir / link_target).replace("\\", "/")
    if candidate in note_index and note_index[candidate] is not None:
        return note_index[candidate]

    # 3. 尝试附件或非 Markdown 文件
    raw_candidates = [
        kb_dir / link_target,
        current_file.parent / link_target,
    ]
    for candidate_path in raw_candidates:
        try:
            resolved_candidate = candidate_path.resolve()
            resolved_candidate.relative_to(kb_dir)
        except (OSError, ValueError):
            continue
        if resolved_candidate.is_file():
            return resolved_candidate

    # 4. 遍历所有可能的路径前缀
    for key, val in note_index.items():
        if val is None:
            continue
        if key.endswith("/" + link_target) or key == link_target:
            return val

    return None


def compute_content_hash(content: str) -> str:
    """计算内容的哈希值（去除空白字符和 frontmatter 后）"""
    # 去除 frontmatter
    cleaned = FRONTMATTER_RE.sub("", content)
    # 去除空白字符
    cleaned = re.sub(r"\s+", "", cleaned)
    return hashlib.md5(cleaned.encode("utf-8")).hexdigest()


def compute_similarity_hash(content: str) -> str:
    """计算内容的相似度哈希（基于行的集合，用于检测近似重复）"""
    cleaned = FRONTMATTER_RE.sub("", content)
    # 取每行的非空白内容
    lines = set()
    for line in cleaned.split("\n"):
        stripped = line.strip()
        if len(stripped) > 10:  # 忽略太短的行
            lines.add(stripped)
    # 取集合的哈希
    return hashlib.md5(str(sorted(lines)).encode("utf-8")).hexdigest()


# ============================================================
# 检查项实现
# ============================================================

def check_no_frontmatter(md_files: list[Path]) -> list[dict]:
    """检查无 Frontmatter 的文件"""
    issues = []
    for p in md_files:
        content = read_file_safe(p)
        fm = extract_frontmatter(content)
        if fm is None:
            issues.append({
                "file": str(p),
                "type": "缺少 Frontmatter",
                "detail": "文件没有 YAML Frontmatter 块（--- 包裹的元数据）",
            })
    return issues


def check_no_tags(md_files: list[Path]) -> list[dict]:
    """检查有 Frontmatter 但无 tags 的文件"""
    issues = []
    for p in md_files:
        content = read_file_safe(p)
        fm = extract_frontmatter(content)
        if fm is not None and not fm["has_tags"]:
            issues.append({
                "file": str(p),
                "type": "缺少 tags",
                "detail": "有 Frontmatter 但未定义 tags 字段",
            })
    return issues


def check_broken_links(md_files: list[Path], kb_dir: Path) -> list[dict]:
    """检测断链：链接指向不存在的笔记"""
    note_index = build_note_index(md_files, kb_dir)
    issues = []

    for p in md_files:
        if is_link_check_ignored(p, kb_dir):
            continue
        content = read_file_safe(p)
        links = extract_wikilinks(content)
        for link in links:
            # 跳过纯数字/特殊链接（如图片、外部 URL）
            if re.match(r"^\d+$", link):
                continue
            resolved = resolve_link(link, note_index, p, kb_dir)
            if resolved is None:
                issues.append({
                    "file": str(p),
                    "type": "断链",
                    "detail": f"链接 [[{link}]] 指向不存在的笔记",
                    "link": link,
                })
    return issues


def check_orphan_notes(md_files: list[Path], kb_dir: Path) -> list[dict]:
    """检测孤立笔记：没有入链也没有出链的笔记"""
    # 构建出链映射
    out_links: dict[Path, set[str]] = {}
    # 构建入链映射
    in_links: dict[Path, set[Path]] = defaultdict(set)

    note_index = build_note_index(md_files, kb_dir)

    for p in md_files:
        if is_link_check_ignored(p, kb_dir):
            continue
        content = read_file_safe(p)
        links = extract_wikilinks(content)
        out_links[p] = links
        for link in links:
            resolved = resolve_link(link, note_index, p, kb_dir)
            if resolved is not None:
                in_links[resolved].add(p)

    issues = []
    for p in md_files:
        if is_link_check_ignored(p, kb_dir):
            continue
        has_out = len(out_links.get(p, set())) > 0
        has_in = len(in_links.get(p, set())) > 0
        # 跳过索引文件和首页
        if p.name in ("HOME.md",) or "索引" in p.name or "index" in p.name.lower():
            continue
        if not has_out and not has_in:
            issues.append({
                "file": str(p),
                "type": "孤立笔记",
                "detail": "该笔记既没有出链也没有入链，与其他笔记没有关联",
            })
    return issues


def check_naming_convention(md_files: list[Path], kb_dir: Path) -> list[dict]:
    """检测文件命名不规范项"""
    issues = []
    for p in md_files:
        rel = p.relative_to(kb_dir)
        name = p.name
        # 跳过根目录特殊文件
        if name in ("HOME.md",):
            continue

        # 检查：文件名是否包含特殊字符
        if re.search(r"[<>:\"|?*]", name):
            issues.append({
                "file": str(p),
                "type": "命名含特殊字符",
                "detail": f"文件名 '{name}' 包含不允许的特殊字符",
            })

        # 检查：目录名是否以数字编号开头（非根目录文件）
        parent_name = rel.parts[0] if len(rel.parts) > 1 else ""
        if parent_name and not NAMING_PATTERN_STRICT.match(name) and not NAMING_PATTERN_RELAXED.match(name):
            issues.append({
                "file": str(p),
                "type": "命名不规范",
                "detail": f"文件名 '{name}' 不符合 NN-名称.md 或字母/中文开头的规范",
            })

        # 检查：文件名开头或结尾有空格
        if name != name.strip():
            issues.append({
                "file": str(p),
                "type": "命名有空格",
                "detail": f"文件名 '{name}' 开头或结尾有多余空格",
            })

        # 检查：目录名规范
        if parent_name:
            # 允许的目录名模式: NN-名称 或 纯英文/中文名称
            if not re.match(r"^[\d\-A-Za-z一-鿿_\.]+$", parent_name):
                issues.append({
                    "file": str(p),
                    "type": "目录名不规范",
                    "detail": f"所在目录 '{parent_name}' 包含非常规字符",
                })

    return issues


def check_duplicate_content(md_files: list[Path]) -> list[dict]:
    """检测重复内容（完全相同或高度相似）"""
    hash_map: dict[str, list[Path]] = defaultdict(list)
    similarity_map: dict[str, list[Path]] = defaultdict(list)

    for p in md_files:
        content = read_file_safe(p)
        if not content.strip():
            continue
        h = compute_content_hash(content)
        hash_map[h].append(p)
        sh = compute_similarity_hash(content)
        similarity_map[sh].append(p)

    issues = []

    # 完全重复（内容哈希相同）
    seen_hashes = set()
    for h, files in hash_map.items():
        if len(files) > 1:
            if h in seen_hashes:
                continue
            seen_hashes.add(h)
            file_list = ", ".join(str(f) for f in files)
            for f in files:
                issues.append({
                    "file": str(f),
                    "type": "完全重复",
                    "detail": f"与以下文件内容完全相同: {file_list}",
                })

    # 近似重复（相似度哈希相同但内容哈希不同）
    seen_sim = set()
    for sh, files in similarity_map.items():
        if len(files) > 1:
            # 确认不是完全重复
            content_hashes = {compute_content_hash(read_file_safe(f)) for f in files}
            if len(content_hashes) <= 1:
                continue
            if sh in seen_sim:
                continue
            seen_sim.add(sh)
            file_list = ", ".join(str(f) for f in files)
            for f in files:
                issues.append({
                    "file": str(f),
                    "type": "近似重复",
                    "detail": f"与以下文件内容高度相似: {file_list}",
                })

    return issues


# ============================================================
# 报告生成
# ============================================================

def generate_report(
    kb_dir: Path,
    no_frontmatter: list[dict],
    no_tags: list[dict],
    broken_links: list[dict],
    orphan_notes: list[dict],
    naming_issues: list[dict],
    duplicates: list[dict],
    total_files: int,
) -> str:
    """生成 Markdown 格式的健康检查报告"""
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    total_issues = (
        len(no_frontmatter) + len(no_tags) + len(broken_links)
        + len(orphan_notes) + len(naming_issues) + len(duplicates)
    )

    # 健康评分（满分 100，每个问题扣 2 分，最低 0 分）
    score = max(0, 100 - total_issues * 2)
    if score >= 90:
        grade = "优秀"
        grade_emoji = "A"
    elif score >= 75:
        grade = "良好"
        grade_emoji = "B"
    elif score >= 60:
        grade = "及格"
        grade_emoji = "C"
    else:
        grade = "需要改进"
        grade_emoji = "D"

    lines = []
    lines.append("---")
    lines.append("tags: [健康检查, 报告]")
    lines.append(f"created: {datetime.now().strftime('%Y-%m-%d')}")
    lines.append(f"updated: {datetime.now().strftime('%Y-%m-%d')}")
    lines.append("---")
    lines.append("")
    lines.append("# 知识库健康检查报告")
    lines.append("")
    lines.append(f"> [!info] 检查时间")
    lines.append(f"> {now}")
    lines.append("")
    lines.append(f"> [!{'tip' if score >= 75 else 'warning'}] 健康评分: {grade_emoji} ({score}分 - {grade})")
    lines.append(f">")
    lines.append(f"> | 指标 | 数值 |")
    lines.append(f"> |------|------|")
    lines.append(f"> | 总文件数 | {total_files} |")
    lines.append(f"> | 问题总数 | {total_issues} |")
    lines.append(f"> | 健康评分 | {score}/100 |")
    lines.append("")
    lines.append("---")
    lines.append("")

    # 问题汇总表
    lines.append("## 问题汇总")
    lines.append("")
    lines.append("| 检查项 | 问题数 | 状态 |")
    lines.append("|--------|--------|------|")

    check_items = [
        ("无 Frontmatter", len(no_frontmatter)),
        ("缺少 tags", len(no_tags)),
        ("断链", len(broken_links)),
        ("孤立笔记", len(orphan_notes)),
        ("命名不规范", len(naming_issues)),
        ("重复内容", len(duplicates)),
    ]

    for name, count in check_items:
        status = "通过" if count == 0 else f"{count} 个问题"
        icon = "PASS" if count == 0 else "WARN"
        lines.append(f"| {name} | {count} | {icon} {status} |")

    lines.append("")
    lines.append("---")
    lines.append("")

    # 详细报告
    sections = [
        ("无 Frontmatter 的文件", no_frontmatter, "这些文件缺少 YAML Frontmatter 元数据块。建议在文件开头添加 `---` 包裹的元数据。"),
        ("缺少 tags 的文件", no_tags, "这些文件有 Frontmatter 但未定义 `tags` 字段。建议添加标签以便分类检索。"),
        ("断链", broken_links, "这些链接指向的笔记不存在。请检查链接目标是否正确，或创建缺失的笔记。"),
        ("孤立笔记", orphan_notes, "这些笔记没有与其他笔记建立链接关系。建议添加相关链接。"),
        ("命名不规范", naming_issues, "这些文件或目录的命名不符合规范。建议使用 `NN-名称.md` 格式。"),
        ("重复内容", duplicates, "这些文件与其他文件内容相同或高度相似。建议合并或区分内容。"),
    ]

    for title, items, description in sections:
        lines.append(f"## {title}")
        lines.append("")
        lines.append(f"> [!note] 说明")
        lines.append(f"> {description}")
        lines.append("")

        if not items:
            lines.append("无问题。")
        else:
            # 按文件分组
            lines.append("| 序号 | 文件 | 详情 |")
            lines.append("|------|------|------|")
            for i, item in enumerate(items, 1):
                file_path = item["file"]
                # 使用相对路径
                try:
                    rel_path = str(Path(file_path).relative_to(kb_dir)).replace("\\", "/")
                except ValueError:
                    rel_path = file_path
                detail = item["detail"]
                lines.append(f"| {i} | `{rel_path}` | {detail} |")

        lines.append("")
        lines.append("---")
        lines.append("")

    # 建议
    lines.append("## 改进建议")
    lines.append("")

    suggestions = []
    if no_frontmatter:
        suggestions.append("1. **添加 Frontmatter** - 为缺少元数据的文件添加 YAML Frontmatter，包含 `tags`、`created`、`updated` 字段")
    if no_tags:
        suggestions.append("2. **完善标签** - 为所有笔记添加分类标签，便于 Dataview 查询和检索")
    if broken_links:
        suggestions.append("3. **修复断链** - 检查并修复所有断链，确保笔记间链接完整")
    if orphan_notes:
        suggestions.append("4. **关联孤立笔记** - 为孤立笔记添加出链或入链，融入知识网络")
    if naming_issues:
        suggestions.append("5. **统一命名** - 按照 `NN-名称.md` 规范重命名文件")
    if duplicates:
        suggestions.append("6. **去重合并** - 合并重复内容，避免信息冗余")

    if not suggestions:
        lines.append("知识库状态良好，无需特别改进。继续保持良好的笔记习惯！")
    else:
        for s in suggestions:
            lines.append(s)

    lines.append("")
    lines.append("---")
    lines.append("")
    lines.append(f"*报告生成时间: {now}*")
    lines.append(f"*检查脚本: `07-Scripts/03-知识库健康检查.py`*")

    return "\n".join(lines)


# ============================================================
# 主程序
# ============================================================

def main():
    parser = argparse.ArgumentParser(
        description="Obsidian 知识库健康检查脚本",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python 03-知识库健康检查.py
  python 03-知识库健康检查.py --kb-dir "D:\\my-vault"
  python 03-知识库健康检查.py --output report.md
        """,
    )
    parser.add_argument(
        "--kb-dir",
        type=Path,
        default=DEFAULT_KB_DIR,
        help="知识库根目录路径 (默认: D:\\obsidian\\knowledge-base)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="报告输出路径 (默认: 07-Scripts/健康检查报告.md)",
    )
    args = parser.parse_args()

    kb_dir: Path = args.kb_dir.resolve()
    output_path: Path = args.output.resolve()

    if not kb_dir.is_dir():
        print(f"错误: 知识库目录不存在: {kb_dir}")
        sys.exit(1)

    print(f"知识库路径: {kb_dir}")
    print(f"报告输出:   {output_path}")
    print()

    # 收集文件
    print("[1/6] 收集 Markdown 文件...")
    md_files = collect_markdown_files(kb_dir)
    print(f"  共找到 {len(md_files)} 个 Markdown 文件")
    print()

    # 执行检查
    print("[2/6] 检查 Frontmatter...")
    no_frontmatter = check_no_frontmatter(md_files)
    no_tags = check_no_tags(md_files)
    print(f"  无 Frontmatter: {len(no_frontmatter)} 个")
    print(f"  缺少 tags:     {len(no_tags)} 个")
    print()

    print("[3/6] 检测断链...")
    broken_links = check_broken_links(md_files, kb_dir)
    print(f"  断链: {len(broken_links)} 个")
    print()

    print("[4/6] 检测孤立笔记...")
    orphan_notes = check_orphan_notes(md_files, kb_dir)
    print(f"  孤立笔记: {len(orphan_notes)} 个")
    print()

    print("[5/6] 检查命名规范...")
    naming_issues = check_naming_convention(md_files, kb_dir)
    print(f"  命名问题: {len(naming_issues)} 个")
    print()

    print("[6/6] 检测重复内容...")
    duplicates = check_duplicate_content(md_files)
    print(f"  重复内容: {len(duplicates)} 个")
    print()

    # 生成报告
    report = generate_report(
        kb_dir=kb_dir,
        no_frontmatter=no_frontmatter,
        no_tags=no_tags,
        broken_links=broken_links,
        orphan_notes=orphan_notes,
        naming_issues=naming_issues,
        duplicates=duplicates,
        total_files=len(md_files),
    )

    # 写入报告
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(report, encoding="utf-8")
    print(f"报告已生成: {output_path}")

    # 输出摘要
    total_issues = (
        len(no_frontmatter) + len(no_tags) + len(broken_links)
        + len(orphan_notes) + len(naming_issues) + len(duplicates)
    )
    print()
    print("=" * 50)
    print(f"  检查完成: 共发现 {total_issues} 个问题")
    print(f"  无 Frontmatter: {len(no_frontmatter)}")
    print(f"  缺少 tags:     {len(no_tags)}")
    print(f"  断链:          {len(broken_links)}")
    print(f"  孤立笔记:      {len(orphan_notes)}")
    print(f"  命名问题:      {len(naming_issues)}")
    print(f"  重复内容:      {len(duplicates)}")
    print("=" * 50)


if __name__ == "__main__":
    main()
