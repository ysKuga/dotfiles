---
allowed-tools: Bash(mkdir:*), Bash(date:*), Bash(pwd:*), Bash(echo:*), Write
description: 複雑な作業用ステアリングディレクトリを作成し、計画ファイルを初期化する
---

## 引数

`$ARGUMENTS`: 開発タイトル（例: `add-auth-feature`）

引数が空の場合、ユーザーにタイトルを求める。

## 手順

### 1. ディレクトリ名決定

```bash
date +%Y%m%d
```

`YYYYMMDD-[タイトル]` 形式でディレクトリ名を構成する。
- スペースはハイフンに置換
- 例: `20260610-add-auth-feature`

### 2. ディレクトリ作成

作業中のプロジェクトルートに `claude/.steering/YYYYMMDD-[title]/` を作成する。

```bash
mkdir -p claude/.steering/YYYYMMDD-[title]
```

### 3. design.md 生成

以下のテンプレートで `claude/.steering/YYYYMMDD-[title]/design.md` を作成する。

**注意:** このファイルはリポジトリで管理される。API トークン・パスワード・個人情報などのセンシティブな情報は記載しないこと。

```markdown
# [タイトル]

## 目的

<!-- この作業で達成すること -->

## 背景・制約

<!-- 判断の前提となる情報 -->

## 実装計画

- [ ] 

## 決定事項

<!-- 検討・決定した内容のログ -->

## 懸念・リスク

<!-- 注意点、未解決の問題 -->
```

### 4. recent.md に追記

`~/.claude/recent.md` に作業エントリを追記する。ファイルが存在しない場合は自動作成される。

```bash
pwd
```

```bash
echo "- $(date +%Y-%m-%d) $(pwd): [タイトル] → claude/.steering/YYYYMMDD-[title]/" >> ~/.claude/recent.md
```

`[タイトル]` と `YYYYMMDD-[title]` は実際の値に置換すること。

### 5. 完了通知

作成したディレクトリパスとファイルをユーザーに通知する。
