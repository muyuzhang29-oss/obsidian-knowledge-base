---
tags: [Script, Perl, 回归, 测试, 工具]
created: 2026-05-13
updated: 2026-06-02
---

# Perl 回归管理脚本

> 自动化 UVM 回归测试的核心脚本：解析配置 → 编译 → 并行仿真 → 监控结果 → 覆盖率合并

tags: #Perl #Regression #UVM #Verification

---

## 整体架构

```
regression.pl
├── 解析命令行参数 (GetOptions)
├── ana_regress_list()        ← 解析 regression.cfg
├── compile_rgs()             ← 编译 testbench
├── chk_compile_log()         ← 验证编译成功
├── run_simulation()          ← 并行启动仿真
├── check_simulation_process() ← 轮询监控 + pass/fail 判定
├── remove_failed_test_coverage() ← 清理失败用例覆盖率
└── merge_coverage()          ← imc 合并覆盖率
```

---

## 命令行参数

```bash
perl regression.pl -r regression.cfg --timeout 720 --local_sim on --cov on --seed_zero off
```

| 参数 | 含义 | 默认值 |
|------|------|--------|
| `-r / --rgs_list` | 回归配置文件路径 | 硬编码路径 |
| `--timeout` | 最大等待轮询次数 | 720 |
| `--local_sim` | `on`=本地后台运行, `off`=bsub 提交集群 | off |
| `--cov` | 是否收集覆盖率 | off |
| `--seed_zero` | seed 固定为 0（调试用） | off |

---

## 配置文件格式 (regression.cfg)

```
[csr] CompileOption: TB_FILELIST=$ENV{DV_HOME}/tb/ss02_tb/filelist COMP_OPTS='-define SS02_CHIPTOP_DV'
tests: tc_video_trial0   test_mode: aphy_ana_csr_wrp0   rpt_time: 1   sim_options: +csr=test_aphy_ana_csr_wrp0
tests: tc_video_trial1   test_mode: aphy_ana_csr_wrp0   rpt_time: 2
tests: tc_video_trial2   test_mode: aphy_ana_csr_wrp0   rpt_time: 3
```

| 字段 | 含义 |
|------|------|
| `[csr]` | 编译名称，生成 `regress_<时间戳>_csr` 目录 |
| `CompileOption:` | 传给 `make compile` 的编译选项 |
| `tests:` | 测试用例名（对应 Makefile 的 TEST 参数） |
| `test_mode:` | 测试模式（会加 `_0`, `_1` 后缀区分重复） |
| `rpt_time:` | 重复次数，每遍用不同 seed |
| `sim_options:` | 传给仿真的额外参数（`+` 开头的 plusarg） |

`rpt_time: 3` 会把同一个用例展开为 3 个独立仿真实例，每个有独立 seed。

---

## 核心子程序详解

### 1. `ana_regress_list()` — 解析配置

```perl
# 逐行解析，跳过注释(#开头)和空行
# 提取 [编译名]、CompileOption、tests、test_mode、rpt_time、sim_options
# 按 rpt_time 展开，push 到全局数组
@rgs_test_name    # 测试名
@rgs_test_mode    # 模式_序号
@rgs_test_options # 仿真选项
$rgs_test_num     # 总用例数
```

### 2. `compile_rgs()` — 编译

```perl
$rgs_compile_mode = "regress_<时间戳>_<编译名>";
system("make compile $rgs_cmp_opt MODE=$rgs_compile_mode COV=$cov_flag");
```

- `MODE` 用时间戳命名，保证每次回归的编译目录独立不冲突
- `COV=1` 开启覆盖率，`COV=0` 关闭

### 3. `chk_compile_log()` — 编译验证

```perl
# 检查 compile.log 最后 5 行
tail -5 .../compile.log
# 匹配 "Writing initial simulation snapshot: worklib.tb_top.v"
# 不匹配则 die 终止整个回归
```

### 4. `run_simulation()` — 并行仿真

```perl
# 本地模式（后台并行）
make simulate TEST=... SEED=... mode=... &

# 集群模式（bsub 提交）
bsub -q normal make simulate TEST=... SEED=... MODE=...
```

- seed 默认 `int(rand(3999999999))`，`seed_zero=on` 时固定为 0
- 本地模式追加 `:nostdout` 抑制终端输出

### 5. `check_simulation_process()` — 监控核心

**轮询机制**：每秒检查一次，最多 `$timeout` 轮

```perl
while($timeout_cnt < $timeout) {
    sleep 1;
    # 遍历所有未完成测试
    for each test:
        # 检查 DONE 标志文件是否存在
        if(-e "$DONE_PATH/$mode/$test_$seed/DONE") {
            # 检查 sim log 判定 pass/fail
            # 从待检数组中 splice 移除
        }
    # 全部完成则退出
}
```

**DONE 文件路径**：
```
$DONE_PATH/$rgs_compile_mode/$test_name_$seed/DONE
```

仿真器运行结束后会创建 `DONE` 文件，脚本通过检测该文件判断仿真是否结束。

### 6. `check_simulation_log()` — Pass/Fail 判定

```perl
# 从 sim_<seed>.log 中搜索 UVM 报告
UVM_ERROR : <count>
UVM_FATAL : <count>

# 判定规则：
#   error_count == 0 AND fatal_count == 0 → PASS
#   否则 → FAIL
```

### 7. 覆盖率处理

```perl
# 删除失败用例的覆盖率目录
rm -rf $rgs_compile_mode/cov_work/scope/$test_$seed

# imc 合并通过用例的覆盖率
imc -execcmd "merge * -overwrite -out merged_cov"
```

先删掉失败用例的覆盖率数据，再用 Cadence IMC 合并剩余的，确保覆盖率只反映通过的用例。

---

## 执行流程

```
main
 │
 ├─ 解析命令行参数
 ├─ ana_regress_list()          → 构建测试数组 (@rgs_test_name, ...)
 ├─ compile_rgs()               → make compile
 ├─ chk_compile_log()           → 验证编译成功
 ├─ run_simulation()            → 并行启动 N 个仿真进程
 ├─ check_simulation_process()  → 轮询 DONE 文件
 │   ├─ check_simulation_log()  → 检查 UVM_ERROR / UVM_FATAL
 │   ├─ PASS → 计数 +1
 │   └─ FAIL → 记录命令、日志路径、覆盖率目录
 ├─ 输出 summary（total/pass/fail/running）
 ├─ remove_failed_test_coverage()  (cov=on)
 └─ merge_coverage()              (cov=on)
```

---

## 输出示例

终端输出：
```
id: 0, make simulate TEST=tc_spi_wr TEST_RGS_IDX=csr_0 SEED=12345 ...
id: 1, bsub -q normal make simulate TEST=tc_spi_rd TEST_RGS_IDX=csr_1 SEED=67890 ...

Regress check, time: 20260519143022, round: 45, total: 10, PASS: 7, FAILED: 1, Running: 2
PASS, tc_spi_wr
FAIL, test: tc_spi_crc_err, seed: 99887

################################################################################Regress finish, total: 10, PASS: 8, FAILED: 1, Running: 1
################################################################################failed test: make simulate TEST=tc_spi_crc_err SEED=99887 ...
```

Summary 文件 `regress_summary_<mode>` 会记录相同内容到磁盘。

---

## 实用技巧

### 调试单个用例
```bash
perl regression.pl -r regression.cfg --seed_zero on --timeout 10 --local_sim on
```
固定 seed + 短超时 + 本地运行，方便快速复现。

### 只跑覆盖率
```bash
perl regression.pl -r regression.cfg --cov on --local_sim off
```
bsub 提交集群，跑完自动合并覆盖率。

### 配置文件中跑多轮
```
tests: tc_spi_stress   test_mode: stress   rpt_time: 10
```
同一用例跑 10 遍，每遍不同 seed，覆盖随机性。

---

## 完整脚本源码

```perl
#!/usr/bin/perl -w
use strict;
use Cwd;
use Sys::Hostname;
use Getopt::Long;
Getopt::Long::Configure("no_ignore_case");

my $regress_list;
my $timeout;
my $local_sim;
my $cov;
my $seed_zero;

my $rgs_cmp_name;
my $rgs_cmp_opt;
my $current_time;
my $rgs_compile_mode;

my $rgs_test_name;
my $rgs_test_mode;
my $rgs_test_options;
my $rgs_sim_cmd;
my $rgs_seed;
my $rgs_test_num = 0;
my @fail_test_log;
my @fail_test_cmd;
my @fail_test_covdir;
my $fail_test_num = 0;
my $cov_flag = 0;

usage if !GetOptions('rgs_list|r=s' => \$regress_list,
    'timeout=i' => \$timeout,
    'local_sim=s' => \$local_sim,
    'cov=s' => \$cov,
    'seed_zero=s' => \$seed_zero,
);

if(defined $regress_list) {
    $regress_list = "/rhome/ind/groups/degrp_serdes/proj/SS11/rev0/digital/users/ind639/digital_fe/dv/blocks/spi/sim/regression.cfg";
    #$regress_list = "/rhome/ind/groups/degrp_serdes/proj/SS02/rev1/digital/users/ind548/digital_fe/dv/blocks/video_it/sim/regression.cfg";
}

if(defined $timeout) {
    $timeout = 720;
}

if(defined $local_sim) {
    $local_sim = "off";
}

if(defined $cov) {
    $cov = "off";
}

if(!defined $seed_zero) {
    $seed_zero = "off";
}

sub usage {
    print STDERR <<USAGE;
usage:
options:
USAGE
    exit(1);
}

##############################################################################
#[csr] CompileOption: TB_FILELIST=$ENV{DV_HOME}/tb/ss02_tb/filelist COMP_OPTS=' -define SS02_CHIPTOP_DV'
#tests: tc_video_trial0      test_mode: aphy_ana_csr_wrp0  rpt_time: 1  sim_options: +csr=test_aphy_ana_csr_wrp0
#tests: tc_video_trial1                                         rpt_time: 2
#tests: tc_video_trial2                                         rpt_time: 3
##############################################################################

sub ana_regress_list {
    my $test_name;
    my $test_mode;
    my $test_opts;
    my $test_time;
    my $cnt;
    my $test_idx;
    open RGS_LIST, "<$regress_list" || die "Error, cannot open regression list: $!\n";
    while(<RGS_LIST>) {
        if(m/^#/ || m/^\s+$/) {
            #comment in regression list file
        } else {
            if(m/\\[(\w+\\)]/) {    #for [csr], get compile name csr
                $rgs_cmp_name = $1;
            }
            if(m/CompileOption:/) {
                $rgs_cmp_opt = $';
                chomp($rgs_cmp_opt); #remove \n
            }
            $test_mode = "";
            $test_opts = "";
            $test_idx = 1;
            $test_idx = 0;
            #tests: tc_video_trial0      test_mode: aphy_ana_csr_wrp0  rpt_time: 1  sim_options: +csr=test_aphy_ana_csr_wrp0
            if(m/tests:/) {
                if(m/tests:\s*(\w+)/) {   # for tc_video_trial0
                    $test_name = $1;
                }
                if(m/test_mode:\s*(\w+)/) {  #for aphy_ana_csr_wrp0
                    $test_mode = $1;
                }
                if(m/rpt_time:\s*(\d+)/) {    #for 1
                    $test_time = $1;
                }
                if(m/sim_options:/) {       #for +csr=test_aphy_ana_csr_wrp0
                    $test_opts = $';         # $' means the text after matching pattern sim_options
                    chomp($test_opts);
                }
                for($cnt = 0; $cnt < $test_time; $cnt++) {
                    push(@rgs_test_name, $test_name);
                    push(@rgs_test_mode, $test_mode."_".$cnt);
                    push(@rgs_test_options, $test_opts);
                    $rgs_test_num++;
                }
            }
        }
    }
    close RGS_LIST;
}

sub get_current_time {
    my $current_time;
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
    $mon = $mon+1;
    $year = $year+1900;
    if($mday < 10) {$mday = "0".$mday;}
    if($min < 10) {$min = "0".$min;}
    if($hour < 10) {$hour = "0".$hour;}
    $current_time = $year.$mon.$mday.$hour.$min.$sec;
    return $current_time
}

sub compile_rgs {
    my $current_time = &get_current_time();
    $rgs_compile_mode = "regress_".$current_time."_".$rgs_cmp_name;
    my $cmd = "make compile $rgs_cmp_opt MODE=$rgs_compile_mode COV=$cov_flag";
    #my $cmd = "bsub -q normal -K make compile $rgs_cmp_opt mode=$rgs_compile_mode";  #for bsub compile
    print "$cmd\n";
    system($cmd);
}

sub chk_compile_log {
    my $lastlines = `tail -5 /sim/ind/ind639/proj/SS11_REV0/SS11_REV0/$rgs_compile_mode/compile.log`;
    if($lastlines =~ m/Writing initial simulation snapshot: worklib.tb_top.v/) {
        print "Compile successfully, dir: $rgs_compile_mode\n";
    } else {
        die "Compile failed, see log: $rgs_compile_mode/compile.log\n"
    }
}

sub run_simulation {
    my $cmd;
    for(my $scnt = 0; $scnt < $rgs_test_num; $scnt++) {
        my $seed = int(rand(3999999999));
        if($seed_zero eq "on") {
            $seed = 0;
        }
        $rgs_seed[$scnt] = $seed;
        if($local_sim eq "on") {
            $rgs_test_options[$scnt] .= ":nostdout ".$rgs_test_options[$scnt];
            $cmd = "make simulate TEST=$rgs_test_name[$scnt] TEST_RGS_IDX=$rgs_test_mode[$scnt] SEED=$seed mode=$rgs_compile_mode  COV=$cov_flag SIM_OPTS='$rgs_test_options[$scnt]' &";
        } else {
            $cmd = "bsub -q normal make simulate TEST=$rgs_test_name[$scnt] TEST_RGS_IDX=$rgs_test_mode[$scnt] SEED=$seed MODE=$rgs_compile_mode  COV=$cov_flag SIM_OPTS='$rgs_test_options[$scnt]'";
        }
        print "id: $scnt, $cmd\n";
        push(@rgs_sim_cmd, $cmd);
        system($cmd);
    }
}

sub check_simulation_process {
    my $total_cnt = 0;
    my $checked_num = 0;
    my $some_test_done = 0;
    my $timeout_cnt = 0;
    while($timeout_cnt < $timeout) {
        $some_test_done = 0;
        sleep 1;
        my $current_time = &get_current_time();
        $total_cnt = $rgs_test_num - $checked_num;
        $passed_num = $checked_num - $fail_test_num;
        print "Regress check, time: $current_time, round: $timeout_cnt, total: $rgs_test_num, PASS: $passed_num, FAILED: $fail_test_num, Running: $total_cnt\n";
        for(my $cnt = 0; $cnt < $total_cnt; $cnt++) {
            $some_test_done = 0;
            my $sdone_path = "$DONE_PATH/$rgs_compile_mode/$rgs_test_name[$cnt]_$rgs_seed[$cnt]/DONE";
            print "################################################################################\n";
            my $log_path = "$rgs_compile_mode/$rgs_test_name[$cnt]_$rgs_seed[$cnt]/sim_$rgs_seed[$cnt].log";
            print "################################################################################ LOG PATH: $log_path ################################################################################\n";
            my $abs_path = `abs_path $sdone_path`;
            chomp($abs_path);
            print "DONE ABS PATH: $abs_path\n";
            if(-e $sdone_path) {
                print "################################################################################\n";
                my $pass_flag = &check_simulation_log($log_path);
                print "################################################################################\n";
                if($pass_flag) {
                    print "PASS, $rgs_test_name[$cnt]\n";
                } else {
                    print "FAIL, test: $rgs_test_name[$cnt], seed: $rgs_seed[$cnt]\n";
                    push(@fail_test_cmd, $rgs_sim_cmd[$cnt]);
                    push(@fail_test_log, $log_path);
                    push(@fail_test_covdir, "$rgs_test_name[$cnt]_$rgs_seed[$cnt]");
                    $fail_test_num++;
                }
                splice (@rgs_test_name, $cnt, 1);
                splice (@rgs_test_mode, $cnt, 1);
                splice (@rgs_seed, $cnt, 1);
                splice (@rgs_sim_cmd, $cnt, 1);
                $checked_num++;
                $some_test_done = 1;
            }
        }
        if($checked_num == $rgs_test_num) {
            print "All simulation finished\n";
            last;
        }
        $timeout_cnt++;
    }
    open RGS_STAT, ">regress_summary_$rgs_compile_mode" || die "Error, cannot open file: $!\n";
    $total_cnt = $rgs_test_num - $checked_num;
    $passed_num = $checked_num - $fail_test_num;
    print "################################################################################\n";
    print "Regress finish, total: $rgs_test_num, PASS: $passed_num, FAILED: $fail_test_num, Running: $total_cnt\n";
    print "################################################################################\n";
    printf RGS_STAT "################################################################################\n";
    printf RGS_STAT "Regress finish, total: $rgs_test_num, PASS: $passed_num, FAILED: $fail_test_num, Running: $total_cnt\n";
    printf RGS_STAT "################################################################################\n";
    if($timeout_cnt >= $timeout) {
        print "regression timeout\n";
        $total_cnt = $rgs_test_num - $checked_num;
        for(my $cnt = 0; $cnt < $total_cnt; $cnt++) {
            print "running test: $rgs_test_name[$cnt]_$rgs_test_mode[$cnt], seed: $rgs_seed[$cnt]\n";
            printf RGS_STAT "running test: $rgs_test_name[$cnt]_$rgs_test_mode[$cnt], seed: $rgs_seed[$cnt]\n";
        }
    }
    $total_cnt = $fail_test_num;
    for(my $cnt = 0; $cnt < $total_cnt; $cnt++) {
        print "$cnt $fail_test_cmd[$cnt]\n";
        printf RGS_STAT "failed test: $fail_test_cmd[$cnt]\n";
    }
    close RGS_STAT;
}

sub check_simulation_log {
    my $pass_flag = 0;
    my $uvm_error_flag = 1;
    my $uvm_fatal_flag = 1;
    my $my_log = $_[0];
    open RGS_LOG, "<$my_log" || die "Error, cannot open sim log: $!\n";
    while(<RGS_LOG>) {
        if(m/UVM_ERROR :\s*(\d+)/) {
            if($1 == 0) {$uvm_error_flag = 0;}
        }
        if(m/UVM_FATAL :\s*(\d+)/) {
            if($1 == 0) {$uvm_fatal_flag = 0;}
        }
    }
    close RGS_LOG;
    if(($uvm_error_flag == 0) & ($uvm_fatal_flag == 0)) {
        $pass_flag = 1;
    }
    return $pass_flag;
}

sub remove_failed_test_coverage {
    for(my $cnt = 0; $cnt < $fail_test_num; $cnt++) {
        my $cmd = "rm -rf $rgs_compile_mode/cov_work/scope/$fail_test_covdir[$cnt]";
        print "$cmd\n";
        system($cmd);
    }
}

sub merge_coverage {
    my $pwd = `pwd`;
    chdir $rgs_compile_mode;
    my $cmd = "imc -execcmd \"merge * -overwrite -out merged_cov\"";
    print "$cmd\n";
    system($cmd);
    chdir $pwd;
    print "#########################################\n";
    print "merge coverage done\n";
    print "#########################################\n";
}

if($cov eq "on") {$cov_flag = 1;}
&ana_regress_list;
&compile_rgs;
&chk_compile_log;
&run_simulation;
&check_simulation_process;
if($cov eq "on") {&remove_failed_test_coverage;}
if($cov eq "on") {&merge_coverage;}
```

---

## 已知问题

1. **参数逻辑反转**：`if(defined $regress_list)` 块内直接覆盖了路径，应该是 `if(!defined)` 才使用默认值
2. **`$passed_num` 未声明**：`check_simulation_process` 中使用了 `$passed_num` 但没有 `my` 声明
3. **splice 索引问题**：for 循环中 splice 后 `$cnt` 仍递增，会跳过紧接的下一个元素

---

*创建时间: 2026-05-19*
