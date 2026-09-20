# Markdown Writing

- End prose lines with `\` for hard breaks. Plain newlines get swallowed by hover/tooltip renderers (GitHub PR previews, etc).
- Applies to consecutive prose lines only. List items and headings already break correctly, leave them as-is.

# 構造化記述

1文に複数要素(目的・手段・対象・条件・注記等)を接続助詞(〜用に/〜ため/〜が等)で
詰め込まず、要素ごとに箇条書きへ分解する。

## 判断基準

- 文を削っても意味が変わらない箇所で区切れる → 分割対象
- 「かつ」「または」等で並列される項目 → 個別箇条書き

## 例

悪い例:

```
EN 切れ等境界値テスト用に、EN 残量を調整できる UI・リセットボタンを prototype に用意する（proto-03 対象、find-path の変更主対象のため。issue-181-en 当 PR では対応不要）
```

良い例:

```
EN 切れ等境界値テスト用に prototype へ以下を用意する

- 手段
  - EN 残量を調整できる UI
  - リセットボタン
- 対象: proto-03（find-path の変更主対象のため）
- issue-181-en 当 PR では対応不要
```
