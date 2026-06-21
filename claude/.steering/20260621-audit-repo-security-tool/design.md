# audit-repo セキュリティツール

## 目的

外部からcloneしたリポジトリに対して `npm install` 等を実行する前に、サプライチェーン攻撃（悪意あるライフサイクルスクリプト等）を検出する。

参考事例: https://dev.to/vladimirnovick/a-linkedin-recruiter-sent-me-malware-disguised-as-a-pre-interview-code-review-2k3j
LinkedIn recruiter が事前コードレビューに見せかけてマルウェアを送付するケース。

## 背景・制約

- Claude Code の PreBashCommand hook と slash command の両方で機能させる
- hook は「警告のみ」(exit 0) とする。ブロックは誤検知リスクが高い
- dotfiles 配下で管理し、install.sh でシンリンクを張る

## 実装内容

- [x] `claude/hooks/audit-repo.sh` — 解析本体
  - `package.json` の lifecycle scripts (`preinstall` / `postinstall` / `prepare` 等) に危険パターンが含まれるか検査
  - `.npmrc` のカスタムレジストリ・未知ホストの auth token
  - JS ファイル中の `eval()` / `new Function()` / `execSync` / 大きな base64 文字列
  - `.husky/` / `.git/hooks/` の不審なフック
  - 深刻度: CRITICAL / HIGH / MEDIUM / INFO の4段階
  - 常に exit 0（警告のみ）
- [x] `claude/commands/audit-repo.md` — `/audit-repo` スラッシュコマンド
  - スクリプトを呼び出し、日本語で結果レポートを生成
  - 最後に「インストール推奨 / 要確認 / インストール不可」で結論を出す
- [x] `claude/settings.json` — PreBashCommand hook 追加
  - `npm install` / `yarn install` / `pnpm install` / `bun install` 等にマッチ
  - timeout: 30000ms
- [x] `install.sh` — 新ファイルのシンリンク追加

## 決定事項

- hook の動作は「警告のみ」に統一（強制ブロックは誤検知でフラストレーションになる）
- スクリプトは python3 で package.json をパース（bash の JSON パースは壊れやすい）
- ワークスペース構成（nested package.json）にも対応（最大20件）

## 懸念・リスク

- 難読化コードの完全な検出は静的解析では限界あり（動的解析は範囲外）
- カスタムレジストリが正当なケース（社内レジストリ等）では HIGH 誤検知が出る
- `prepare` スクリプトは `husky` 等の正当なツールでも使われるため INFO 止まりが妥当
