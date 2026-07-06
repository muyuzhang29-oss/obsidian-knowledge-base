---
tags: [Script, Perl, 鍥炲綊, 娴嬭瘯, 宸ュ叿]
created: 2026-05-13
updated: 2026-06-02
---

# Perl 鍥炲綊绠＄悊鑴氭湰

> 鑷姩鍖?UVM 鍥炲綊娴嬭瘯鐨勬牳蹇冭剼鏈細瑙ｆ瀽閰嶇疆 鈫?缂栬瘧 鈫?骞惰浠跨湡 鈫?鐩戞帶缁撴灉 鈫?瑕嗙洊鐜囧悎骞?

tags: #Perl #Regression #UVM #Verification

---

## 鏁翠綋鏋舵瀯

```
regression.pl
鈹溾攢鈹€ 瑙ｆ瀽鍛戒护琛屽弬鏁?(GetOptions)
鈹溾攢鈹€ ana_regress_list()        鈫?瑙ｆ瀽 regression.cfg
鈹溾攢鈹€ compile_rgs()             鈫?缂栬瘧 testbench
鈹溾攢鈹€ chk_compile_log()         鈫?楠岃瘉缂栬瘧鎴愬姛
鈹溾攢鈹€ run_simulation()          鈫?骞惰鍚姩浠跨湡
鈹溾攢鈹€ check_simulation_process() 鈫?杞鐩戞帶 + pass/fail 鍒ゅ畾
鈹溾攢鈹€ remove_failed_test_coverage() 鈫?娓呯悊澶辫触鐢ㄤ緥瑕嗙洊鐜?
鈹斺攢鈹€ merge_coverage()          鈫?imc 鍚堝苟瑕嗙洊鐜?
```

---

## 鍛戒护琛屽弬鏁?

```bash
perl regression.pl -r regression.cfg --timeout 720 --local_sim on --cov on --seed_zero off
```

| 鍙傛暟 | 鍚箟 | 榛樿鍊?|
|------|------|--------|
| `-r / --rgs_list` | 鍥炲綊閰嶇疆鏂囦欢璺緞 | 纭紪鐮佽矾寰?|
| `--timeout` | 鏈€澶х瓑寰呰疆璇㈡鏁?| 720 |
| `--local_sim` | `on`=鏈湴鍚庡彴杩愯, `off`=bsub 鎻愪氦闆嗙兢 | off |
| `--cov` | 鏄惁鏀堕泦瑕嗙洊鐜?| off |
| `--seed_zero` | seed 鍥哄畾涓?0锛堣皟璇曠敤锛?| off |

---

## 閰嶇疆鏂囦欢鏍煎紡 (regression.cfg)

```
[csr] CompileOption: TB_FILELIST=$ENV{DV_HOME}/tb/ss02_tb/filelist COMP_OPTS='-define SS02_CHIPTOP_DV'
tests: tc_video_trial0   test_mode: aphy_ana_csr_wrp0   rpt_time: 1   sim_options: +csr=test_aphy_ana_csr_wrp0
tests: tc_video_trial1   test_mode: aphy_ana_csr_wrp0   rpt_time: 2
tests: tc_video_trial2   test_mode: aphy_ana_csr_wrp0   rpt_time: 3
```

| 瀛楁 | 鍚箟 |
|------|------|
| `[csr]` | 缂栬瘧鍚嶇О锛岀敓鎴?`regress_<鏃堕棿鎴?_csr` 鐩綍 |
| `CompileOption:` | 浼犵粰 `make compile` 鐨勭紪璇戦€夐」 |
| `tests:` | 娴嬭瘯鐢ㄤ緥鍚嶏紙瀵瑰簲 Makefile 鐨?TEST 鍙傛暟锛?|
| `test_mode:` | 娴嬭瘯妯″紡锛堜細鍔?`_0`, `_1` 鍚庣紑鍖哄垎閲嶅锛?|
| `rpt_time:` | 閲嶅娆℃暟锛屾瘡閬嶇敤涓嶅悓 seed |
| `sim_options:` | 浼犵粰浠跨湡鐨勯澶栧弬鏁帮紙`+` 寮€澶寸殑 plusarg锛?|

`rpt_time: 3` 浼氭妸鍚屼竴涓敤渚嬪睍寮€涓?3 涓嫭绔嬩豢鐪熷疄渚嬶紝姣忎釜鏈夌嫭绔?seed銆?

---

## 鏍稿績瀛愮▼搴忚瑙?

### 1. `ana_regress_list()` 鈥?瑙ｆ瀽閰嶇疆

```perl
# 閫愯瑙ｆ瀽锛岃烦杩囨敞閲?#寮€澶?鍜岀┖琛?
# 鎻愬彇 [缂栬瘧鍚峕銆丆ompileOption銆乼ests銆乼est_mode銆乺pt_time銆乻im_options
# 鎸?rpt_time 灞曞紑锛宲ush 鍒板叏灞€鏁扮粍
@rgs_test_name    # 娴嬭瘯鍚?
@rgs_test_mode    # 妯″紡_搴忓彿
@rgs_test_options # 浠跨湡閫夐」
$rgs_test_num     # 鎬荤敤渚嬫暟
```

### 2. `compile_rgs()` 鈥?缂栬瘧

```perl
$rgs_compile_mode = "regress_<鏃堕棿鎴?_<缂栬瘧鍚?";
system("make compile $rgs_cmp_opt MODE=$rgs_compile_mode COV=$cov_flag");
```

- `MODE` 鐢ㄦ椂闂存埑鍛藉悕锛屼繚璇佹瘡娆″洖褰掔殑缂栬瘧鐩綍鐙珛涓嶅啿绐?
- `COV=1` 寮€鍚鐩栫巼锛宍COV=0` 鍏抽棴

### 3. `chk_compile_log()` 鈥?缂栬瘧楠岃瘉

```perl
# 妫€鏌?compile.log 鏈€鍚?5 琛?
tail -5 .../compile.log
# 鍖归厤 "Writing initial simulation snapshot: worklib.tb_top.v"
# 涓嶅尮閰嶅垯 die 缁堟鏁翠釜鍥炲綊
```

### 4. `run_simulation()` 鈥?骞惰浠跨湡

```perl
# 鏈湴妯″紡锛堝悗鍙板苟琛岋級
make simulate TEST=... SEED=... mode=... &

# 闆嗙兢妯″紡锛坆sub 鎻愪氦锛?
bsub -q normal make simulate TEST=... SEED=... MODE=...
```

- seed 榛樿 `int(rand(3999999999))`锛宍seed_zero=on` 鏃跺浐瀹氫负 0
- 鏈湴妯″紡杩藉姞 `:nostdout` 鎶戝埗缁堢杈撳嚭

### 5. `check_simulation_process()` 鈥?鐩戞帶鏍稿績

**杞鏈哄埗**锛氭瘡绉掓鏌ヤ竴娆★紝鏈€澶?`$timeout` 杞?

```perl
while($timeout_cnt < $timeout) {
    sleep 1;
    # 閬嶅巻鎵€鏈夋湭瀹屾垚娴嬭瘯
    for each test:
        # 妫€鏌?DONE 鏍囧織鏂囦欢鏄惁瀛樺湪
        if(-e "$DONE_PATH/$mode/$test_$seed/DONE") {
            # 妫€鏌?sim log 鍒ゅ畾 pass/fail
            # 浠庡緟妫€鏁扮粍涓?splice 绉婚櫎
        }
    # 鍏ㄩ儴瀹屾垚鍒欓€€鍑?
}
```

**DONE 鏂囦欢璺緞**锛?
```
$DONE_PATH/$rgs_compile_mode/$test_name_$seed/DONE
```

浠跨湡鍣ㄨ繍琛岀粨鏉熷悗浼氬垱寤?`DONE` 鏂囦欢锛岃剼鏈€氳繃妫€娴嬭鏂囦欢鍒ゆ柇浠跨湡鏄惁缁撴潫銆?

### 6. `check_simulation_log()` 鈥?Pass/Fail 鍒ゅ畾

```perl
# 浠?sim_<seed>.log 涓悳绱?UVM 鎶ュ憡
UVM_ERROR : <count>
UVM_FATAL : <count>

# 鍒ゅ畾瑙勫垯锛?
#   error_count == 0 AND fatal_count == 0 鈫?PASS
#   鍚﹀垯 鈫?FAIL
```

### 7. 瑕嗙洊鐜囧鐞?

```perl
# 鍒犻櫎澶辫触鐢ㄤ緥鐨勮鐩栫巼鐩綍
rm -rf $rgs_compile_mode/cov_work/scope/$test_$seed

# imc 鍚堝苟閫氳繃鐢ㄤ緥鐨勮鐩栫巼
imc -execcmd "merge * -overwrite -out merged_cov"
```

鍏堝垹鎺夊け璐ョ敤渚嬬殑瑕嗙洊鐜囨暟鎹紝鍐嶇敤 Cadence IMC 鍚堝苟鍓╀綑鐨勶紝纭繚瑕嗙洊鐜囧彧鍙嶆槧閫氳繃鐨勭敤渚嬨€?

---

## 鎵ц娴佺▼

```
main
 鈹?
 鈹溾攢 瑙ｆ瀽鍛戒护琛屽弬鏁?
 鈹溾攢 ana_regress_list()          鈫?鏋勫缓娴嬭瘯鏁扮粍 (@rgs_test_name, ...)
 鈹溾攢 compile_rgs()               鈫?make compile
 鈹溾攢 chk_compile_log()           鈫?楠岃瘉缂栬瘧鎴愬姛
 鈹溾攢 run_simulation()            鈫?骞惰鍚姩 N 涓豢鐪熻繘绋?
 鈹溾攢 check_simulation_process()  鈫?杞 DONE 鏂囦欢
 鈹?  鈹溾攢 check_simulation_log()  鈫?妫€鏌?UVM_ERROR / UVM_FATAL
 鈹?  鈹溾攢 PASS 鈫?璁℃暟 +1
 鈹?  鈹斺攢 FAIL 鈫?璁板綍鍛戒护銆佹棩蹇楄矾寰勩€佽鐩栫巼鐩綍
 鈹溾攢 杈撳嚭 summary锛坱otal/pass/fail/running锛?
 鈹溾攢 remove_failed_test_coverage()  (cov=on)
 鈹斺攢 merge_coverage()              (cov=on)
```

---

## 杈撳嚭绀轰緥

缁堢杈撳嚭锛?
```
id: 0, make simulate TEST=tc_spi_wr TEST_RGS_IDX=csr_0 SEED=12345 ...
id: 1, bsub -q normal make simulate TEST=tc_spi_rd TEST_RGS_IDX=csr_1 SEED=67890 ...

Regress check, time: 20260519143022, round: 45, total: 10, PASS: 7, FAILED: 1, Running: 2
PASS, tc_spi_wr
FAIL, test: tc_spi_crc_err, seed: 99887

################################################################################Regress finish, total: 10, PASS: 8, FAILED: 1, Running: 1
################################################################################failed test: make simulate TEST=tc_spi_crc_err SEED=99887 ...
```

Summary 鏂囦欢 `regress_summary_<mode>` 浼氳褰曠浉鍚屽唴瀹瑰埌纾佺洏銆?

---

## 瀹炵敤鎶€宸?

### 璋冭瘯鍗曚釜鐢ㄤ緥
```bash
perl regression.pl -r regression.cfg --seed_zero on --timeout 10 --local_sim on
```
鍥哄畾 seed + 鐭秴鏃?+ 鏈湴杩愯锛屾柟渚垮揩閫熷鐜般€?

### 鍙窇瑕嗙洊鐜?
```bash
perl regression.pl -r regression.cfg --cov on --local_sim off
```
bsub 鎻愪氦闆嗙兢锛岃窇瀹岃嚜鍔ㄥ悎骞惰鐩栫巼銆?

### 閰嶇疆鏂囦欢涓窇澶氳疆
```
tests: tc_spi_stress   test_mode: stress   rpt_time: 10
```
鍚屼竴鐢ㄤ緥璺?10 閬嶏紝姣忛亶涓嶅悓 seed锛岃鐩栭殢鏈烘€с€?

---

## 瀹屾暣鑴氭湰婧愮爜

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

## 宸茬煡闂

1. **鍙傛暟閫昏緫鍙嶈浆**锛歚if(defined $regress_list)` 鍧楀唴鐩存帴瑕嗙洊浜嗚矾寰勶紝搴旇鏄?`if(!defined)` 鎵嶄娇鐢ㄩ粯璁ゅ€?
2. **`$passed_num` 鏈０鏄?*锛歚check_simulation_process` 涓娇鐢ㄤ簡 `$passed_num` 浣嗘病鏈?`my` 澹版槑
3. **splice 绱㈠紩闂**锛歠or 寰幆涓?splice 鍚?`$cnt` 浠嶉€掑锛屼細璺宠繃绱ф帴鐨勪笅涓€涓厓绱?

---

*鍒涘缓鏃堕棿: 2026-05-19*

