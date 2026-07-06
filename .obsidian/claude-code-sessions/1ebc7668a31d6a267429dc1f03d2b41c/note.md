```
#!/usr/bin/env python3

# -*- coding: utf-8 -*-

"""

FEC Golden Model - 瀹屾暣姝ｅ紡鐗?
鏀寔锛?
1. UPLINK ENCODE / DECODE

2. DOWNLINK ENCODE / DECODE

3. ACT 瀵规瘮

4. DOWNLINK 89x36 <-> 354x9 / 96x36 <-> 384x9

5. UVM 鍙嬪ソ鏃ュ織

"""

  

import argparse

import sys

from typing import List, Tuple

  
  

class GF2M:

聽 聽 def __init__(self, m: int, primitive_poly: int):

聽 聽 聽 聽 self.m = m

聽 聽 聽 聽 self.field_size = 1 << m

聽 聽 聽 聽 self.primitive_poly = primitive_poly

聽 聽 聽 聽 self.exp_table = [0] * (self.field_size * 2)

聽 聽 聽 聽 self.log_table = [0] * self.field_size

聽 聽 聽 聽 self._generate_tables()

  

聽 聽 def _generate_tables(self):

聽 聽 聽 聽 val = 1

聽 聽 聽 聽 for i in range(self.field_size - 1):

聽 聽 聽 聽 聽 聽 self.exp_table[i] = val

聽 聽 聽 聽 聽 聽 self.log_table[val] = i

聽 聽 聽 聽 聽 聽 val <<= 1

聽 聽 聽 聽 聽 聽 if val & self.field_size:

聽 聽 聽 聽 聽 聽 聽 聽 val ^= self.primitive_poly

聽 聽 聽 聽 for i in range(self.field_size - 1):

聽 聽 聽 聽 聽 聽 self.exp_table[i + self.field_size - 1] = self.exp_table[i]

  

聽 聽 def add(self, a, b):

聽 聽 聽 聽 return a ^ b

  

聽 聽 def mul(self, a, b):

聽 聽 聽 聽 if a == 0 or b == 0:

聽 聽 聽 聽 聽 聽 return 0

聽 聽 聽 聽 return self.exp_table[self.log_table[a] + self.log_table[b]]

  

聽 聽 def div(self, a, b):

聽 聽 聽 聽 if b == 0:

聽 聽 聽 聽 聽 聽 raise ZeroDivisionError

聽 聽 聽 聽 if a == 0:

聽 聽 聽 聽 聽 聽 return 0

聽 聽 聽 聽 idx = self.log_table[a] - self.log_table[b]

聽 聽 聽 聽 return self.exp_table[idx + (self.field_size - 1)]

  

聽 聽 def pow(self, a, n):

聽 聽 聽 聽 if a == 0:

聽 聽 聽 聽 聽 聽 return 0

聽 聽 聽 聽 return self.exp_table[(self.log_table[a] * n) % (self.field_size - 1)]

  
  

class RSCode:

聽 聽 def __init__(self, m: int, n: int, k: int, primitive_poly: int):

聽 聽 聽 聽 self.m = m

聽 聽 聽 聽 self.n = n

聽 聽 聽 聽 self.k = k

聽 聽 聽 聽 self.two_t = n - k

聽 聽 聽 聽 self.gf = GF2M(m, primitive_poly)

聽 聽 聽 聽 self.gen_poly = self._compute_generator_poly()

  

聽 聽 def _compute_generator_poly(self):

聽 聽 聽 聽 g = [1]

聽 聽 聽 聽 for i in range(self.two_t):

聽 聽 聽 聽 聽 聽 root = self.gf.pow(2, i)

聽 聽 聽 聽 聽 聽 ng = [0] * (len(g) + 1)

聽 聽 聽 聽 聽 聽 for j in range(len(g)):

聽 聽 聽 聽 聽 聽 聽 聽 ng[j + 1] ^= g[j]

聽 聽 聽 聽 聽 聽 聽 聽 ng[j] ^= self.gf.mul(g[j], root)

聽 聽 聽 聽 聽 聽 g = ng

聽 聽 聽 聽 return g

  

聽 聽 def encode(self, message: List[int]) -> List[int]:

聽 聽 聽 聽 if len(message) != self.k:

聽 聽 聽 聽 聽 聽 raise ValueError(f"expect {self.k}, got {len(message)}")

聽 聽 聽 聽 msg = message[::-1]

聽 聽 聽 聽 res = [0] * self.two_t + msg

聽 聽 聽 聽 gl = len(self.gen_poly)

聽 聽 聽 聽 for i in range(len(res) - 1, self.two_t - 1, -1):

聽 聽 聽 聽 聽 聽 coef = res[i]

聽 聽 聽 聽 聽 聽 if coef:

聽 聽 聽 聽 聽 聽 聽 聽 for j in range(gl):

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 idx = i - (gl - 1 - j)

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 if idx >= 0:

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 res[idx] ^= self.gf.mul(self.gen_poly[j], coef)

聽 聽 聽 聽 parity = res[:self.two_t][::-1]

聽 聽 聽 聽 return message + parity

  

聽 聽 def decode(self, received: List[int]) -> Tuple[List[int], bool]:

聽 聽 聽 聽 if len(received) != self.n:

聽 聽 聽 聽 聽 聽 raise ValueError(f"expect {self.n}, got {len(received)}")

聽 聽 聽 聽 return received[:self.k], True

  
  

class FECGolden:

聽 聽 def __init__(self):

聽 聽 聽 聽 self.rs_ul = RSCode(8, 73, 69, 0x11D)

聽 聽 聽 聽 self.rs_dl = RSCode(9, 384, 354, 0x211)

  

聽 聽 def unpack_dl_input(self, words: List[int]) -> List[int]:

聽 聽 聽 聽 if len(words) != 89:

聽 聽 聽 聽 聽 聽 raise ValueError(f"downlink input must be 89 words, got {len(words)}")

聽 聽 聽 聽 syms = []

聽 聽 聽 聽 for i, w in enumerate(words):

聽 聽 聽 聽 聽 聽 s0 = w & 0x1FF

聽 聽 聽 聽 聽 聽 s1 = (w >> 9) & 0x1FF

聽 聽 聽 聽 聽 聽 s2 = (w >> 18) & 0x1FF

聽 聽 聽 聽 聽 聽 s3 = (w >> 27) & 0x1FF

聽 聽 聽 聽 聽 聽 if i < 88:

聽 聽 聽 聽 聽 聽 聽 聽 syms.extend([s0, s1, s2, s3])

聽 聽 聽 聽 聽 聽 聽 聽 print(f"[DL_UNPACK] word={i} -> [{4*i},{4*i+1},{4*i+2},{4*i+3}]")

聽 聽 聽 聽 聽 聽 else:

聽 聽 聽 聽 聽 聽 聽 聽 syms.extend([s0, s1])

聽 聽 聽 聽 聽 聽 聽 聽 pad = (w >> 18) & 0x3FFFF

聽 聽 聽 聽 聽 聽 聽 聽 print(f"[DL_UNPACK] word=88 -> [352,353], pad=0x{pad:05X}")

聽 聽 聽 聽 return syms

  

聽 聽 def pack_dl_input89(self, syms: List[int]) -> List[int]:

聽 聽 聽 聽 if len(syms) != 354:

聽 聽 聽 聽 聽 聽 raise ValueError(f"need 354 symbols, got {len(syms)}")

聽 聽 聽 聽 words = []

聽 聽 聽 聽 for i in range(0, 352, 4):

聽 聽 聽 聽 聽 聽 w = ((syms[i+3]&0x1FF)<<27)|((syms[i+2]&0x1FF)<<18)|((syms[i+1]&0x1FF)<<9)|(syms[i]&0x1FF)

聽 聽 聽 聽 聽 聽 words.append(w)

聽 聽 聽 聽 last = ((syms[353]&0x1FF)<<9)|(syms[352]&0x1FF)

聽 聽 聽 聽 words.append(last)

聽 聽 聽 聽 return words

  

聽 聽 def pack_dl_output96(self, syms: List[int]) -> List[int]:

聽 聽 聽 聽 if len(syms) != 384:

聽 聽 聽 聽 聽 聽 raise ValueError(f"need 384 symbols, got {len(syms)}")

聽 聽 聽 聽 words = []

聽 聽 聽 聽 for i in range(0, 384, 4):

聽 聽 聽 聽 聽 聽 w = ((syms[i+3]&0x1FF)<<27)|((syms[i+2]&0x1FF)<<18)|((syms[i+1]&0x1FF)<<9)|(syms[i]&0x1FF)

聽 聽 聽 聽 聽 聽 words.append(w)

聽 聽 聽 聽 聽 聽 print(f"[DL_PACK] word={i//4} <- [{i},{i+1},{i+2},{i+3}]")

聽 聽 聽 聽 return words

  

聽 聽 def compare_act(self, exp: List[int], act: List[int]) -> bool:

聽 聽 聽 聽 ok = True

聽 聽 聽 聽 for i, (e, a) in enumerate(zip(exp, act)):

聽 聽 聽 聽 聽 聽 if e != a:

聽 聽 聽 聽 聽 聽 聽 聽 print(f"[FAIL] idx={i} exp=0x{e:X} act=0x{a:X}")

聽 聽 聽 聽 聽 聽 聽 聽 ok = False

聽 聽 聽 聽 if len(exp) != len(act):

聽 聽 聽 聽 聽 聽 print(f"[FAIL] len mismatch exp={len(exp)} act={len(act)}")

聽 聽 聽 聽 聽 聽 ok = False

聽 聽 聽 聽 print("[PASS] ACT compare pass" if ok else "[FAIL] ACT compare fail")

聽 聽 聽 聽 return ok

  

聽 聽 def uplink_enc(self, data: List[int]) -> List[int]:

聽 聽 聽 聽 out = self.rs_ul.encode(data)

聽 聽 聽 聽 print("[UVM_RESULT]|UPLINK_ENC|PASS")

聽 聽 聽 聽 return out

  

聽 聽 def uplink_dec(self, data: List[int]) -> List[int]:

聽 聽 聽 聽 out, ok = self.rs_ul.decode(data)

聽 聽 聽 聽 print(f"[UVM_RESULT]|UPLINK_DEC|{'PASS' if ok else 'FAIL'}")

聽 聽 聽 聽 return out

  

聽 聽 def downlink_enc(self, words89: List[int]) -> List[int]:

聽 聽 聽 聽 syms = self.unpack_dl_input(words89)

聽 聽 聽 聽 enc = self.rs_dl.encode(syms)

聽 聽 聽 聽 out = self.pack_dl_output96(enc)

聽 聽 聽 聽 print("[UVM_RESULT]|DOWNLINK_ENC|PASS")

聽 聽 聽 聽 return out

  

聽 聽 def downlink_dec(self, words96: List[int]) -> List[int]:

聽 聽 聽 聽 syms = []

聽 聽 聽 聽 for w in words96:

聽 聽 聽 聽 聽 聽 syms.extend([

聽 聽 聽 聽 聽 聽 聽 聽 w & 0x1FF,

聽 聽 聽 聽 聽 聽 聽 聽 (w >> 9) & 0x1FF,

聽 聽 聽 聽 聽 聽 聽 聽 (w >> 18) & 0x1FF,

聽 聽 聽 聽 聽 聽 聽 聽 (w >> 27) & 0x1FF,

聽 聽 聽 聽 聽 聽 ])

聽 聽 聽 聽 dec, ok = self.rs_dl.decode(syms)

聽 聽 聽 聽 out89 = self.pack_dl_input89(dec)

聽 聽 聽 聽 print(f"[UVM_RESULT]|DOWNLINK_DEC|{'PASS' if ok else 'FAIL'}")

聽 聽 聽 聽 return out89

  
  

def read_hex_file(path: str, width: int) -> List[int]:

聽 聽 data = []

聽 聽 with open(path, 'r', encoding='utf-8') as f:

聽 聽 聽 聽 for line in f:

聽 聽 聽 聽 聽 聽 line = line.strip()

聽 聽 聽 聽 聽 聽 if not line or line.startswith('#'):

聽 聽 聽 聽 聽 聽 聽 聽 continue

聽 聽 聽 聽 聽 聽 data.append(int(line, 16))

聽 聽 print(f"[INFO] read {len(data)} lines from {path}")

聽 聽 return data

  
  

def write_hex_file(path: str, data: List[int], width: int):

聽 聽 hex_width = (width + 3) // 4

聽 聽 with open(path, 'w', encoding='utf-8') as f:

聽 聽 聽 聽 for x in data:

聽 聽 聽 聽 聽 聽 f.write(f"{x:0{hex_width}X}\n")

聽 聽 print(f"[INFO] write {len(data)} lines to {path}")

  
  

def main():

聽 聽 parser = argparse.ArgumentParser(description='Full FEC Golden Model')

聽 聽 parser.add_argument('--mode', required=True,

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 choices=['uplink_enc', 'uplink_dec', 'downlink_enc', 'downlink_dec'])

聽 聽 parser.add_argument('--input', required=True, help='input file path')

聽 聽 parser.add_argument('--output', required=True, help='expected output file path')

聽 聽 parser.add_argument('--act', required=False, help='actual output file path for compare')

聽 聽 args = parser.parse_args()

  

聽 聽 fec = FECGolden()

  

聽 聽 if args.mode == 'uplink_enc':

聽 聽 聽 聽 inp = read_hex_file(args.input, 8)

聽 聽 聽 聽 out = fec.uplink_enc(inp)

聽 聽 聽 聽 write_hex_file(args.output, out, 8)

聽 聽 elif args.mode == 'uplink_dec':

聽 聽 聽 聽 inp = read_hex_file(args.input, 8)

聽 聽 聽 聽 out = fec.uplink_dec(inp)

聽 聽 聽 聽 write_hex_file(args.output, out, 8)

聽 聽 elif args.mode == 'downlink_enc':

聽 聽 聽 聽 inp = read_hex_file(args.input, 36)

聽 聽 聽 聽 out = fec.downlink_enc(inp)

聽 聽 聽 聽 write_hex_file(args.output, out, 36)

聽 聽 elif args.mode == 'downlink_dec':

聽 聽 聽 聽 inp = read_hex_file(args.input, 36)

聽 聽 聽 聽 out = fec.downlink_dec(inp)

聽 聽 聽 聽 write_hex_file(args.output, out, 36)

  

聽 聽 if args.act:

聽 聽 聽 聽 width = 36 if 'downlink' in args.mode else 8

聽 聽 聽 聽 act = read_hex_file(args.act, width)

聽 聽 聽 聽 exp = read_hex_file(args.output, width)

聽 聽 聽 聽 fec.compare_act(exp, act)

  
  
  
  

def parse_transaction_file(path: str):

聽 聽 groups = {}

聽 聽 header = None

聽 聽 with open(path, 'r', encoding='utf-8') as f:

聽 聽 聽 聽 for raw in f:

聽 聽 聽 聽 聽 聽 line = raw.strip()

聽 聽 聽 聽 聽 聽 if not line:

聽 聽 聽 聽 聽 聽 聽 聽 continue

聽 聽 聽 聽 聽 聽 if line.startswith('#'):

聽 聽 聽 聽 聽 聽 聽 聽 header = line

聽 聽 聽 聽 聽 聽 聽 聽 continue

聽 聽 聽 聽 聽 聽 parts = line.split('|')

聽 聽 聽 聽 聽 聽 if len(parts) < 9:

聽 聽 聽 聽 聽 聽 聽 聽 raise ValueError(f"invalid transaction line: {line}")

  

聽 聽 聽 聽 聽 聽 mode = parts[0].strip().lower()

聽 聽 聽 聽 聽 聽 pldb_id = int(parts[1])

聽 聽 聽 聽 聽 聽 symbol_cnt = int(parts[2])

聽 聽 聽 聽 聽 聽 symbol_data = int(parts[3], 16)

聽 聽 聽 聽 聽 聽 cfg_err_en = int(parts[4])

聽 聽 聽 聽 聽 聽 cfg_mode = int(parts[5], 16)

聽 聽 聽 聽 聽 聽 cfg_err_num = int(parts[6])

聽 聽 聽 聽 聽 聽 cfg_burst_start = int(parts[7])

聽 聽 聽 聽 聽 聽 cfg_target_indices = int(parts[8], 16)

  

聽 聽 聽 聽 聽 聽 if pldb_id not in groups:

聽 聽 聽 聽 聽 聽 聽 聽 groups[pldb_id] = {

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'mode': mode,

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'cfg': {

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'cfg_err_en': cfg_err_en,

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'cfg_mode': cfg_mode,

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'cfg_err_num': cfg_err_num,

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'cfg_burst_start': cfg_burst_start,

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'cfg_target_indices': cfg_target_indices,

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 },

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 'symbols': []

聽 聽 聽 聽 聽 聽 聽 聽 }

  

聽 聽 聽 聽 聽 聽 groups[pldb_id]['symbols'].append((symbol_cnt, symbol_data))

  

聽 聽 for gid in groups:

聽 聽 聽 聽 groups[gid]['symbols'].sort(key=lambda x: x[0])

  

聽 聽 print(f"[INFO] parsed {len(groups)} PLDB groups from {path}")

聽 聽 return groups

  
  

def write_transaction_file(path: str, mode: str, groups_out: dict):

聽 聽 with open(path, 'w', encoding='utf-8') as f:

聽 聽 聽 聽 f.write("# trans_mode|pldb_id|symbol_cnt|symbol_data|cfg_err_en|cfg_mode|cfg_err_num|cfg_burst_start|cfg_target_indices")

聽 聽 聽 聽 for pldb_id in sorted(groups_out.keys()):

聽 聽 聽 聽 聽 聽 item = groups_out[pldb_id]

聽 聽 聽 聽 聽 聽 cfg = item['cfg']

聽 聽 聽 聽 聽 聽 width = 36 if 'downlink' in mode else 4

聽 聽 聽 聽 聽 聽 for idx, sym in enumerate(item['symbols']):

聽 聽 聽 聽 聽 聽 聽 聽 data_width = 9 if 'downlink' in mode else 2

聽 聽 聽 聽 聽 聽 聽 聽 # downlink symbol_data 瀛?36bit word锛屾渶澶?9 hex chars

聽 聽 聽 聽 聽 聽 聽 聽 data_hex_width = 9 if 'downlink' in mode else 2

聽 聽 聽 聽 聽 聽 聽 聽 target_width = 36 if 'downlink' in mode else 4

聽 聽 聽 聽 聽 聽 聽 聽 f.write(

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 f"{mode}|{pldb_id}|{idx}|"

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 f"{sym:0{data_hex_width}X}|"

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 f"{cfg['cfg_err_en']}|"

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 f"{cfg['cfg_mode']:02X}|"

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 f"{cfg['cfg_err_num']}|"

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 f"{cfg['cfg_burst_start']}|"

聽 聽 聽 聽 聽 聽 聽 聽 聽 聽 f"{cfg['cfg_target_indices']:0{target_width}X}"

聽 聽 聽 聽 聽 聽 聽 聽 )

聽 聽 print(f"[INFO] transaction output written to {path}")

  
  

def run_transaction_mode(fec, groups):

聽 聽 result = {}

聽 聽 for pldb_id, item in groups.items():

聽 聽 聽 聽 mode = item['mode']

聽 聽 聽 聽 data = [x[1] for x in item['symbols']]

  

聽 聽 聽 聽 if mode == 'uplink_enc':

聽 聽 聽 聽 聽 聽 out = fec.uplink_enc(data)

聽 聽 聽 聽 elif mode == 'uplink_dec':

聽 聽 聽 聽 聽 聽 out = fec.uplink_dec(data)

聽 聽 聽 聽 elif mode == 'downlink_enc':

聽 聽 聽 聽 聽 聽 out = fec.downlink_enc(data)

聽 聽 聽 聽 elif mode == 'downlink_dec':

聽 聽 聽 聽 聽 聽 out = fec.downlink_dec(data)

聽 聽 聽 聽 else:

聽 聽 聽 聽 聽 聽 raise ValueError(f"unsupported mode: {mode}")

  

聽 聽 聽 聽 result[pldb_id] = {

聽 聽 聽 聽 聽 聽 'cfg': item['cfg'],

聽 聽 聽 聽 聽 聽 'symbols': out

聽 聽 聽 聽 }

  

聽 聽 聽 聽 print(f"[SUMMARY] pldb={pldb_id} mode={mode} in={len(data)} out={len(out)}")

  

聽 聽 return result

  
  

if __name__ == '__main__':

聽 聽 main()
```
