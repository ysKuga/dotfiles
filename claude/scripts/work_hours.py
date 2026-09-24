#!/usr/bin/env python3
"""Claude Code のセッション履歴から週別の実作業時間を集計する。

~/.claude/projects/<slug>/*.jsonl の各行タイムスタンプを読み、
イベント間隔がアイドル閾値(既定10分)を超える区間を除外した
「実作業時間」を、週(ISO週) × プロジェクトで集計する。

使い方:
    python work_hours.py [--gap MIN] [--csv]
      --gap MIN  アイドル閾値(分)。既定 10
      --csv      表形式でなく CSV(week,project,hours) で出力
"""
import argparse
import glob
import json
import os
from collections import defaultdict
from datetime import datetime

BASE = os.path.expanduser("~/.claude/projects")
# プロジェクト slug はパスの "/" と "." を "-" に置換したもの
HOME_SLUG = os.path.expanduser("~").replace("/", "-").replace(".", "-")


def parse(ts):
    return datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone()


def collect(gap_sec):
    active = defaultdict(float)  # (week, project) -> 秒
    for proj in sorted(os.listdir(BASE)):
        pdir = os.path.join(BASE, proj)
        if not os.path.isdir(pdir):
            continue
        # 並行セッションの二重計上を避けるため、プロジェクト内の全ファイルをまとめて扱う
        times = []
        for f in glob.glob(os.path.join(pdir, "*.jsonl")):
            with open(f, encoding="utf-8") as fh:
                for line in fh:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        d = json.loads(line)
                    except Exception:
                        continue
                    ts = d.get("timestamp")
                    if ts:
                        try:
                            times.append(parse(ts))
                        except Exception:
                            pass
        if len(times) < 2:
            continue
        times.sort()
        for a, b in zip(times, times[1:]):
            delta = (b - a).total_seconds()
            if delta <= gap_sec:
                iso = a.isocalendar()
                wk = f"{iso[0]}-W{iso[1]:02d}"
                active[(wk, proj)] += delta
    return active


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gap", type=int, default=10, help="アイドル閾値(分)")
    ap.add_argument("--csv", action="store_true", help="CSV 出力")
    args = ap.parse_args()

    active = collect(args.gap * 60)
    weeks = sorted({w for w, _ in active})
    projects = sorted({p for _, p in active})
    short = {p: p.removeprefix(HOME_SLUG).lstrip("-") or "~" for p in projects}
    w = {p: max(8, len(short[p]) + 2) for p in projects}

    if args.csv:
        print("week,project,hours")
        for wk in weeks:
            for p in projects:
                h = active.get((wk, p), 0.0) / 3600
                if h:
                    print(f"{wk},{short[p]},{h:.2f}")
        return

    hdr = f'{"週":10}' + "".join(f"{short[p]:>{w[p]}}" for p in projects) + f'{"合計":>10}'
    print(f"週別 実作業時間 (アイドル{args.gap}分超を除外, 単位:時間)\n")
    print(hdr)
    print("-" * len(hdr))
    grand = 0.0
    col = defaultdict(float)
    for wk in weeks:
        row = f"{wk:10}"
        wtot = 0.0
        for p in projects:
            h = active.get((wk, p), 0.0) / 3600
            col[p] += h
            wtot += h
            row += f"{h:>{w[p]}.2f}" if h else f'{"-":>{w[p]}}'
        grand += wtot
        row += f"{wtot:>10.2f}"
        print(row)
    print("-" * len(hdr))
    print(f'{"合計":10}' + "".join(f"{col[p]:>{w[p]}.2f}" for p in projects) + f"{grand:>10.2f}")


if __name__ == "__main__":
    main()
