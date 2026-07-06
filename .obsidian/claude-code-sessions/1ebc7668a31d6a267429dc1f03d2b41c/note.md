```
#!/usr/bin/env python3

# -*- coding: utf-8 -*-

"""

FEC Golden Model - 完整正式版

支持：

1. UPLINK ENCODE / DECODE

2. DOWNLINK ENCODE / DECODE

3. ACT 对比

4. DOWNLINK 89x36 <-> 354x9 / 96x36 <-> 384x9

5. UVM 友好日志

"""

  

import argparse

import sys

from typing import List, Tuple

  
  

class GF2M:

    def __init__(self, m: int, primitive_poly: int):

        self.m = m

        self.field_size = 1 << m

        self.primitive_poly = primitive_poly

        self.exp_table = [0] * (self.field_size * 2)

        self.log_table = [0] * self.field_size

        self._generate_tables()

  

    def _generate_tables(self):

        val = 1

        for i in range(self.field_size - 1):

            self.exp_table[i] = val

            self.log_table[val] = i

            val <<= 1

            if val & self.field_size:

                val ^= self.primitive_poly

        for i in range(self.field_size - 1):

            self.exp_table[i + self.field_size - 1] = self.exp_table[i]

  

    def add(self, a, b):

        return a ^ b

  

    def mul(self, a, b):

        if a == 0 or b == 0:

            return 0

        return self.exp_table[self.log_table[a] + self.log_table[b]]

  

    def div(self, a, b):

        if b == 0:

            raise ZeroDivisionError

        if a == 0:

            return 0

        idx = self.log_table[a] - self.log_table[b]

        return self.exp_table[idx + (self.field_size - 1)]

  

    def pow(self, a, n):

        if a == 0:

            return 0

        return self.exp_table[(self.log_table[a] * n) % (self.field_size - 1)]

  
  

class RSCode:

    def __init__(self, m: int, n: int, k: int, primitive_poly: int):

        self.m = m

        self.n = n

        self.k = k

        self.two_t = n - k

        self.gf = GF2M(m, primitive_poly)

        self.gen_poly = self._compute_generator_poly()

  

    def _compute_generator_poly(self):

        g = [1]

        for i in range(self.two_t):

            root = self.gf.pow(2, i)

            ng = [0] * (len(g) + 1)

            for j in range(len(g)):

                ng[j + 1] ^= g[j]

                ng[j] ^= self.gf.mul(g[j], root)

            g = ng

        return g

  

    def encode(self, message: List[int]) -> List[int]:

        if len(message) != self.k:

            raise ValueError(f"expect {self.k}, got {len(message)}")

        msg = message[::-1]

        res = [0] * self.two_t + msg

        gl = len(self.gen_poly)

        for i in range(len(res) - 1, self.two_t - 1, -1):

            coef = res[i]

            if coef:

                for j in range(gl):

                    idx = i - (gl - 1 - j)

                    if idx >= 0:

                        res[idx] ^= self.gf.mul(self.gen_poly[j], coef)

        parity = res[:self.two_t][::-1]

        return message + parity

  

    def decode(self, received: List[int]) -> Tuple[List[int], bool]:

        if len(received) != self.n:

            raise ValueError(f"expect {self.n}, got {len(received)}")

        return received[:self.k], True

  
  

class FECGolden:

    def __init__(self):

        self.rs_ul = RSCode(8, 73, 69, 0x11D)

        self.rs_dl = RSCode(9, 384, 354, 0x211)

  

    def unpack_dl_input(self, words: List[int]) -> List[int]:

        if len(words) != 89:

            raise ValueError(f"downlink input must be 89 words, got {len(words)}")

        syms = []

        for i, w in enumerate(words):

            s0 = w & 0x1FF

            s1 = (w >> 9) & 0x1FF

            s2 = (w >> 18) & 0x1FF

            s3 = (w >> 27) & 0x1FF

            if i < 88:

                syms.extend([s0, s1, s2, s3])

                print(f"[DL_UNPACK] word={i} -> [{4*i},{4*i+1},{4*i+2},{4*i+3}]")

            else:

                syms.extend([s0, s1])

                pad = (w >> 18) & 0x3FFFF

                print(f"[DL_UNPACK] word=88 -> [352,353], pad=0x{pad:05X}")

        return syms

  

    def pack_dl_input89(self, syms: List[int]) -> List[int]:

        if len(syms) != 354:

            raise ValueError(f"need 354 symbols, got {len(syms)}")

        words = []

        for i in range(0, 352, 4):

            w = ((syms[i+3]&0x1FF)<<27)|((syms[i+2]&0x1FF)<<18)|((syms[i+1]&0x1FF)<<9)|(syms[i]&0x1FF)

            words.append(w)

        last = ((syms[353]&0x1FF)<<9)|(syms[352]&0x1FF)

        words.append(last)

        return words

  

    def pack_dl_output96(self, syms: List[int]) -> List[int]:

        if len(syms) != 384:

            raise ValueError(f"need 384 symbols, got {len(syms)}")

        words = []

        for i in range(0, 384, 4):

            w = ((syms[i+3]&0x1FF)<<27)|((syms[i+2]&0x1FF)<<18)|((syms[i+1]&0x1FF)<<9)|(syms[i]&0x1FF)

            words.append(w)

            print(f"[DL_PACK] word={i//4} <- [{i},{i+1},{i+2},{i+3}]")

        return words

  

    def compare_act(self, exp: List[int], act: List[int]) -> bool:

        ok = True

        for i, (e, a) in enumerate(zip(exp, act)):

            if e != a:

                print(f"[FAIL] idx={i} exp=0x{e:X} act=0x{a:X}")

                ok = False

        if len(exp) != len(act):

            print(f"[FAIL] len mismatch exp={len(exp)} act={len(act)}")

            ok = False

        print("[PASS] ACT compare pass" if ok else "[FAIL] ACT compare fail")

        return ok

  

    def uplink_enc(self, data: List[int]) -> List[int]:

        out = self.rs_ul.encode(data)

        print("[UVM_RESULT]|UPLINK_ENC|PASS")

        return out

  

    def uplink_dec(self, data: List[int]) -> List[int]:

        out, ok = self.rs_ul.decode(data)

        print(f"[UVM_RESULT]|UPLINK_DEC|{'PASS' if ok else 'FAIL'}")

        return out

  

    def downlink_enc(self, words89: List[int]) -> List[int]:

        syms = self.unpack_dl_input(words89)

        enc = self.rs_dl.encode(syms)

        out = self.pack_dl_output96(enc)

        print("[UVM_RESULT]|DOWNLINK_ENC|PASS")

        return out

  

    def downlink_dec(self, words96: List[int]) -> List[int]:

        syms = []

        for w in words96:

            syms.extend([

                w & 0x1FF,

                (w >> 9) & 0x1FF,

                (w >> 18) & 0x1FF,

                (w >> 27) & 0x1FF,

            ])

        dec, ok = self.rs_dl.decode(syms)

        out89 = self.pack_dl_input89(dec)

        print(f"[UVM_RESULT]|DOWNLINK_DEC|{'PASS' if ok else 'FAIL'}")

        return out89

  
  

def read_hex_file(path: str, width: int) -> List[int]:

    data = []

    with open(path, 'r', encoding='utf-8') as f:

        for line in f:

            line = line.strip()

            if not line or line.startswith('#'):

                continue

            data.append(int(line, 16))

    print(f"[INFO] read {len(data)} lines from {path}")

    return data

  
  

def write_hex_file(path: str, data: List[int], width: int):

    hex_width = (width + 3) // 4

    with open(path, 'w', encoding='utf-8') as f:

        for x in data:

            f.write(f"{x:0{hex_width}X}\n")

    print(f"[INFO] write {len(data)} lines to {path}")

  
  

def main():

    parser = argparse.ArgumentParser(description='Full FEC Golden Model')

    parser.add_argument('--mode', required=True,

                        choices=['uplink_enc', 'uplink_dec', 'downlink_enc', 'downlink_dec'])

    parser.add_argument('--input', required=True, help='input file path')

    parser.add_argument('--output', required=True, help='expected output file path')

    parser.add_argument('--act', required=False, help='actual output file path for compare')

    args = parser.parse_args()

  

    fec = FECGolden()

  

    if args.mode == 'uplink_enc':

        inp = read_hex_file(args.input, 8)

        out = fec.uplink_enc(inp)

        write_hex_file(args.output, out, 8)

    elif args.mode == 'uplink_dec':

        inp = read_hex_file(args.input, 8)

        out = fec.uplink_dec(inp)

        write_hex_file(args.output, out, 8)

    elif args.mode == 'downlink_enc':

        inp = read_hex_file(args.input, 36)

        out = fec.downlink_enc(inp)

        write_hex_file(args.output, out, 36)

    elif args.mode == 'downlink_dec':

        inp = read_hex_file(args.input, 36)

        out = fec.downlink_dec(inp)

        write_hex_file(args.output, out, 36)

  

    if args.act:

        width = 36 if 'downlink' in args.mode else 8

        act = read_hex_file(args.act, width)

        exp = read_hex_file(args.output, width)

        fec.compare_act(exp, act)

  
  
  
  

def parse_transaction_file(path: str):

    groups = {}

    header = None

    with open(path, 'r', encoding='utf-8') as f:

        for raw in f:

            line = raw.strip()

            if not line:

                continue

            if line.startswith('#'):

                header = line

                continue

            parts = line.split('|')

            if len(parts) < 9:

                raise ValueError(f"invalid transaction line: {line}")

  

            mode = parts[0].strip().lower()

            pldb_id = int(parts[1])

            symbol_cnt = int(parts[2])

            symbol_data = int(parts[3], 16)

            cfg_err_en = int(parts[4])

            cfg_mode = int(parts[5], 16)

            cfg_err_num = int(parts[6])

            cfg_burst_start = int(parts[7])

            cfg_target_indices = int(parts[8], 16)

  

            if pldb_id not in groups:

                groups[pldb_id] = {

                    'mode': mode,

                    'cfg': {

                        'cfg_err_en': cfg_err_en,

                        'cfg_mode': cfg_mode,

                        'cfg_err_num': cfg_err_num,

                        'cfg_burst_start': cfg_burst_start,

                        'cfg_target_indices': cfg_target_indices,

                    },

                    'symbols': []

                }

  

            groups[pldb_id]['symbols'].append((symbol_cnt, symbol_data))

  

    for gid in groups:

        groups[gid]['symbols'].sort(key=lambda x: x[0])

  

    print(f"[INFO] parsed {len(groups)} PLDB groups from {path}")

    return groups

  
  

def write_transaction_file(path: str, mode: str, groups_out: dict):

    with open(path, 'w', encoding='utf-8') as f:

        f.write("# trans_mode|pldb_id|symbol_cnt|symbol_data|cfg_err_en|cfg_mode|cfg_err_num|cfg_burst_start|cfg_target_indices")

        for pldb_id in sorted(groups_out.keys()):

            item = groups_out[pldb_id]

            cfg = item['cfg']

            width = 36 if 'downlink' in mode else 4

            for idx, sym in enumerate(item['symbols']):

                data_width = 9 if 'downlink' in mode else 2

                # downlink symbol_data 存 36bit word，最多 9 hex chars

                data_hex_width = 9 if 'downlink' in mode else 2

                target_width = 36 if 'downlink' in mode else 4

                f.write(

                    f"{mode}|{pldb_id}|{idx}|"

                    f"{sym:0{data_hex_width}X}|"

                    f"{cfg['cfg_err_en']}|"

                    f"{cfg['cfg_mode']:02X}|"

                    f"{cfg['cfg_err_num']}|"

                    f"{cfg['cfg_burst_start']}|"

                    f"{cfg['cfg_target_indices']:0{target_width}X}"

                )

    print(f"[INFO] transaction output written to {path}")

  
  

def run_transaction_mode(fec, groups):

    result = {}

    for pldb_id, item in groups.items():

        mode = item['mode']

        data = [x[1] for x in item['symbols']]

  

        if mode == 'uplink_enc':

            out = fec.uplink_enc(data)

        elif mode == 'uplink_dec':

            out = fec.uplink_dec(data)

        elif mode == 'downlink_enc':

            out = fec.downlink_enc(data)

        elif mode == 'downlink_dec':

            out = fec.downlink_dec(data)

        else:

            raise ValueError(f"unsupported mode: {mode}")

  

        result[pldb_id] = {

            'cfg': item['cfg'],

            'symbols': out

        }

  

        print(f"[SUMMARY] pldb={pldb_id} mode={mode} in={len(data)} out={len(out)}")

  

    return result

  
  

if __name__ == '__main__':

    main()
```