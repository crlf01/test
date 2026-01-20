#!/usr/bin/env python3
"""
简单合并多个 .yar 文件，并按 rule 名去重。
用法: python3 merge_rules.py <rules_dir> <out_file>
"""
import sys
import os
import re

if len(sys.argv) != 3:
    print("Usage: merge_rules.py <rules_dir> <out_file>")
    sys.exit(2)

rules_dir = sys.argv[1]
out_file = sys.argv[2]

rule_re = re.compile(r'^\s*rule\s+([A-Za-z0-9_]+)')
seen = set()
out_rules = []

# read each .yar file
for root, _, files in os.walk(rules_dir):
    for fn in files:
        if not fn.endswith('.yar') and not fn.endswith('.yara'):
            continue
        path = os.path.join(root, fn)
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception:
            continue
        # split by rules, identify rule names and dedupe
        parts = re.split(r'(?m)^\s*rule\s+', content)
        if parts and parts[0].strip()=='':
            parts = parts[1:]
        for p in parts:
            m = re.match(r'([A-Za-z0-9_]+)', p)
            if not m:
                continue
            name = m.group(1)
            rule_text = 'rule ' + p.strip() + '\n\n'
            if name in seen:
                continue
            seen.add(name)
            out_rules.append(rule_text)

with open(out_file, 'w', encoding='utf-8') as o:
    o.write('// Combined YARA rules — deduplicated by rule name\n\n')
    for r in out_rules:
        o.write(r)

print(f"Wrote {len(out_rules)} rules to {out_file}")