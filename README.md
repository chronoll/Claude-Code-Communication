# 🤖 Tmux Multi-Agent Communication Demo

Agent同士がやり取りするtmux環境のデモシステム

**📖 Read this in other languages:** [English](README-en.md)

## 🎯 デモ概要

PRESIDENT → BOSS → Workers の階層型指示システムを体感できます

### 👥 エージェント構成

```
📊 PRESIDENT セッション (1ペイン)
└── PRESIDENT: プロジェクト統括責任者

📊 multiagent セッション (4ペイン)  
├── boss1: チームリーダー
├── worker1: 実行担当者A
├── worker2: 実行担当者B
└── worker3: 実行担当者C
```

## 🚀 クイックスタート

### 0. リポジトリのクローン

```bash
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication
```

### 1. tmux環境構築

⚠️ **注意**: 既存の `multiagent` と `president` セッションがある場合は自動的に削除されます。

```bash
./setup.sh
```

### 2. セッションアタッチ

```bash
# マルチエージェント確認
tmux attach-session -t multiagent

# プレジデント確認（別ターミナルで）
tmux attach-session -t president
```

### 3. Agent CLI 起動（プロファイルは `config/agent_cli.env` で設定）
※ Claude Code 以外のエージェントも利用可能です。`AGENT_PROFILE` に `cursor` / `gemini` / `codex` を指定すると、対応する CLI で起動します。
config/agent_cli.envに直接書き込むか、./bin/agent-launch.sh --profile <agent名> で毎回指定してください

**手順1: President起動**
```bash
# まず PRESIDENT ペインで起動
tmux send-keys -t president './bin/agent-launch.sh president' C-m
```

**手順2: Multiagent 一括起動**
```bash
# multiagent セッションを一括起動
for i in {0..3}; do tmux send-keys -t multiagent:0.$i './bin/agent-launch.sh' C-m; done
```

### 4. デモ実行

PRESIDENTセッションで直接入力：
```
あなたはpresidentです。指示書に従って
```

## 📜 指示書について

各エージェントの役割別指示書：
- **PRESIDENT**: `instructions/president.md`
- **boss1**: `instructions/boss.md` 
- **worker1,2,3**: `instructions/worker.md`

**プロジェクトメモリ参照**: `CLAUDE.md`（Claude用）。他エージェント利用時は各CLIが参照するメモリファイルを配置。

- **PRESIDENT**: ユーザーから受け取ったタスク内容に一意の `TASK_ID` を付け、ゴール/背景を整理して boss1 に渡し「計画と配分方針（役割分担 or 並列検証など）」を依頼。受信と完了は必ず報告。
- **boss1**: `TASK_ID` を起点に簡潔な計画を立て、状況に応じてサブタスクを分けるか、同一タスクを並列で実施させるかを選び、完了条件付きで配信 → 全員の完了を集約して PRESIDENT に報告。受領/完了/ブロッカーは必ず報告。
- **workers**: 受け取った自分専用のサブタスクまたは並列タスクを実行 → `./tmp/<TASK_ID>_workerX_done.txt` に成果を記録 → 自分の完了を報告し、最後の人が `TASK_ID` 付きで全員完了を報告。受領と進捗/完了は省略しない。

## 🎬 期待される動作フロー

```
1. PRESIDENT → boss1: "TASK_ID=20240607-120000; GOAL=todoアプリを作成; 背景=<ユーザー原文>; 計画と配分方針（役割分担 or 並列検証など）を決めて報告してください"
2. boss1 → workers: 状況に応じた配信  
   例) 役割分担: worker1 要件整理 / worker2 実装方針 / worker3 テスト観点  
       並列検証: 全員同じ手順を試し、結果比較をファイルに記載
3. workers: それぞれサブタスクを実行し、`./tmp/20240607-120000_workerX_done.txt` に成果を記録 → 最後のworker → boss1: "TASK_ID=20240607-120000; 全員作業完了しました"
4. boss1 → PRESIDENT: "TASK_ID=20240607-120000; 全員完了しました; 要約: ..."
```

## 🔧 手動操作

### agent-send.shを使った送信

```bash
# 基本送信
./agent-send.sh [エージェント名] [メッセージ]

# 例
./agent-send.sh boss1 "緊急タスクです"
./agent-send.sh worker1 "作業完了しました"
./agent-send.sh president "最終報告です"

# エージェント一覧確認
./agent-send.sh --list
```

## 🧪 確認・デバッグ

### ログ確認

```bash
# 送信ログ確認
cat logs/send_log.txt

# 特定エージェントのログ
grep "boss1" logs/send_log.txt

# 完了ファイル確認
ls -la ./tmp/worker*_done.txt
```

### セッション状態確認

```bash
# セッション一覧
tmux list-sessions

# ペイン一覧
tmux list-panes -t multiagent
tmux list-panes -t president
```

## 🔄 環境リセット

```bash
# セッション削除
tmux kill-session -t multiagent
tmux kill-session -t president

# 完了ファイル削除
rm -f ./tmp/worker*_done.txt

# 再構築（自動クリア付き）
./setup.sh
```

---

## 📄 ライセンス

このプロジェクトは[MIT License](LICENSE)の下で公開されています。

## 🤝 コントリビューション

プルリクエストやIssueでのコントリビューションを歓迎いたします！

---

🚀 **Agent Communication を体感してください！** 🤖✨ 
