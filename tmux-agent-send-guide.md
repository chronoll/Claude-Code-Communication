# Tmux + Agent-send.sh 利用ガイド

## 目次

1. [概要](#概要)
2. [tmux基礎知識](#tmux基礎知識)
   - [tmuxとは何か](#tmuxとは何か)
   - [基本概念の階層構造](#基本概念の階層構造)
   - [Agent-send.shが前提とするtmux構成](#agent-sendshが前提とするtmux構成)
3. [環境セットアップ](#環境セットアップ)
4. [使用方法](#使用方法)
5. [実践ガイド](#実践ガイド)
   - [tmux初心者向け準備手順](#tmux初心者向け準備手順)
   - [よくあるエラーと対処法](#よくあるエラーと対処法)
   - [おすすめ作業フロー](#おすすめ作業フロー)
   - [実践例](#実践例)
6. [トラブルシューティング](#トラブルシューティング)
7. [参考資料](#参考資料)

## 概要

このガイドは、tmuxとagent-send.shを組み合わせたマルチエージェント通信システムの利用方法を説明します。複数のClaudeエージェント（PRESIDENT, boss1, worker1-3）が協調して作業を行うための環境構築と操作手順を提供します。

## tmux基礎知識

### tmuxとは何か
tmux（Terminal Multiplexer）は、1つのターミナル画面で複数のシェルセッションを同時に扱えるツールです。リモート作業や長時間実行プロセスの管理に便利です。

### 基本概念の階層構造

#### 1. セッション（Session）
- tmuxの最上位単位
- 一つのプロジェクトや作業単位に対応
- デタッチ（切り離し）してもバックグラウンドで継続実行
- 例：`president`セッション、`multiagent`セッション

#### 2. ウィンドウ（Window）
- セッション内の作業タブのようなもの
- それぞれ独立したシェル環境
- タブ切り替えで素早く移動可能

#### 3. ペイン（Pane）
- ウィンドウを分割した個別領域
- 一つのウィンドウ内で複数の作業を並行実行
- 垂直・水平分割が可能

### Agent-send.shが前提とするtmux構成

#### セッション構成
1. **presidentセッション**: 統括責任者（PRESIDENT）用の独立セッション
2. **multiagentセッション**: チーム作業用セッション
   - agents ウィンドウ: boss1, worker1, worker2, worker3が並行作業

#### 通信の仕組み
- `agent-send.sh [相手] "[メッセージ]"`でメッセージ送信
- 各エージェントは決められたペイン（0.0, 0.1, 0.2, 0.3）に配置
- tmux send-keysコマンドで直接メッセージを送信

この構成により、複数のエージェントが独立して作業しつつ、相互にメッセージ交換できる分散作業環境が実現されています。

## 環境セットアップ

[この部分は他のworkerが担当]

## 使用方法

### agent-send.sh 機能解説

#### 📋 主要機能

##### 1. エージェント間メッセージ送信
tmuxセッション経由でエージェント間の安全なメッセージ送信を実現

**対応エージェント:**
- president (統括責任者) - presidentセッション
- boss1 (チームリーダー) - multiagent:agents.0
- worker1 (実行担当A) - multiagent:agents.1
- worker2 (実行担当B) - multiagent:agents.2  
- worker3 (実行担当C) - multiagent:agents.3

##### 2. --listオプション機能
現在のエージェント状態とtmuxセッション接続状況を確認

**表示内容:**
- 各エージェントの起動状況
- tmuxターゲット情報
- セッション接続状態（起動中/未起動）

##### 3. 動的インデックス対応
base-indexやpane-base-indexが異なる環境でも動作

##### 4. 自動ログ記録
全送信メッセージを logs/send_log.txt に自動保存

#### 🚀 基本的な使用方法

##### 通常のメッセージ送信
```bash
./agent-send.sh [エージェント名] "[メッセージ内容]"
```

**具体例:**
- プロジェクト開始指示
  ```bash
  ./agent-send.sh president "todoアプリ開発プロジェクト開始"
  ```

- チームリーダーへタスク配分指示
  ```bash
  ./agent-send.sh boss1 "TASK_ID=123; GOAL=UI作成; 3名に役割分担してください"
  ```

- 作業完了報告
  ```bash
  ./agent-send.sh worker1 "TASK_ID=123; HTML構造作成完了"
  ```

##### エージェント状況確認
```bash
./agent-send.sh --list
```

##### エラーハンドリング
- 存在しないエージェント名 → エラーメッセージと利用可能エージェント表示
- 未起動セッション → セッション不存在エラー
- 不正な引数 → 使用方法ガイド表示

#### 🔍 送信プロセス
1. ターゲットエージェント確認
2. tmuxセッション存在確認
3. メッセージ送信（Ctrl-C → メッセージ入力 → Enter）
4. ログ自動記録
5. 送信完了通知

スクリプトはエージェント協調システムの通信基盤として設計されており、TASK_IDベースのタスク管理と組み合わせて使用します。

### その他の使用方法

[この部分は他のworkerが担当]

## 実践ガイド

### tmux初心者向け準備手順

#### 1. tmuxの基本確認
- tmuxがインストールされているか確認: `which tmux`
- tmuxバージョン確認: `tmux -V`
- 必要に応じてインストール: `brew install tmux` (macOS) / `sudo apt install tmux` (Ubuntu)

#### 2. セッション確認コマンド
- 現在のセッション一覧: `tmux list-sessions` または `tmux ls`
- 特定セッションの存在確認: `tmux has-session -t president`
- ペインの確認: `tmux list-panes -t multiagent`

#### 3. agent-send.sh実行権限設定
```bash
chmod +x ./agent-send.sh
```

### よくあるエラーと対処法

#### エラー1: 「セッション 'xxx' が見つかりません」
**原因**: 対象のtmuxセッションが起動していない  
**対処法**: 
- `tmux ls` でセッション一覧を確認
- 必要なセッションを起動: `tmux new-session -d -s president`
- multiagentセッションの場合は適切なペイン構成で起動

#### エラー2: 「不明なエージェント 'xxx'」
**原因**: サポートされていないエージェント名を指定  
**対処法**: 
- `./agent-send.sh --list` で利用可能エージェントを確認
- 正しいエージェント名を使用: president, boss1, worker1, worker2, worker3

#### エラー3: 「Permission denied」
**原因**: スクリプトに実行権限がない  
**対処法**: `chmod +x ./agent-send.sh`

#### エラー4: メッセージが送信されない
**原因**: ターゲットペインが応答していない  
**対処法**: 
- ターゲットペインがアクティブか確認
- Claude Codeが正常に動作しているか確認
- セッションを再起動

### おすすめ作業フロー

#### 基本的な使用パターン
1. **事前準備**
   ```bash
   # セッション状態確認
   ./agent-send.sh --list
   
   # 必要に応じてセッション起動
   ```

2. **タスク開始時**
   ```bash
   # PRESIDENT から boss1 に指示
   ./agent-send.sh boss1 "TASK_ID=20251129-172148; GOAL=<タスク内容>; 詳細=<詳細説明>"
   ```

3. **進行中の確認**
   ```bash
   # ログ確認
   tail logs/send_log.txt
   
   # 完了ファイル確認
   ls -la ./tmp/*_done.txt
   ```

4. **完了確認**
   ```bash
   # 全worker完了ファイルの存在確認
   ls ./tmp/20251129-172148_worker*_done.txt
   ```

#### 効率的な運用のコツ
- **TASK_ID統一**: すべてのメッセージと完了ファイルで同じTASK_IDを使用
- **段階的確認**: 各エージェントの応答を確認してから次のステップへ
- **ログ活用**: send_log.txtで送信履歴を追跡
- **エラー時の迅速対応**: --listコマンドで接続状態を即座に確認

#### 並列作業時の注意点
- 同じTASK_IDで複数workerが同時作業
- 完了ファイル名の重複を避ける
- 最後に完了したworkerが全体報告を担当

### 実践例

#### シンプルなタスク実行
```bash
# 1. boss1に指示送信
./agent-send.sh boss1 "TASK_ID=test-001; GOAL=Hello World出力; worker1に簡単な表示タスクを依頼"

# 2. 進捗確認
./agent-send.sh --list

# 3. 完了確認
ls ./tmp/test-001_*_done.txt
```

#### 複雑なタスクの分割例
```bash
# 役割分担パターン
./agent-send.sh boss1 "TASK_ID=complex-001; GOAL=Webアプリ作成; worker1=HTML, worker2=CSS, worker3=JavaScript担当で分割実行"
```

この実践ガイドにより、tmux初心者でもagent-send.shを使用したマルチエージェント連携を円滑に開始できます。

## トラブルシューティング

### デバッグ用コマンド
```bash
# セッション詳細確認
tmux show-options -t multiagent

# ペイン構成確認  
tmux list-panes -t multiagent:agents

# ログ確認
tail -f logs/send_log.txt

# base-index確認
tmux show-options -g base-index
tmux show-options -g pane-base-index
```

### 接続テスト
```bash
# エージェント一覧表示（接続状態確認）
./agent-send.sh --list

# テストメッセージ送信
./agent-send.sh worker1 "接続テスト"
```

### セッション再起動手順
1. 既存セッション終了: `tmux kill-session -t multiagent`
2. 新規セッション作成: `tmux new-session -d -s multiagent`
3. ウィンドウ・ペイン構成を再作成
4. Claude Code再起動

## 参考資料

[この部分は他のworkerが担当]