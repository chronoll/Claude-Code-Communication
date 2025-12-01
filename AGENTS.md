# Agent Communication System (Codex CLI 用プロジェクトメモリ)

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **worker1-4** (multiagent:agents): 議論・実行担当（同列のピア）

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **worker1-4**: @instructions/worker.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
- ユーザー → PRESIDENT: 任意のタスク指示
- PRESIDENT: タスク内容を整理し一意の `TASK_ID` を付与。全 worker にゴール/背景/期待アウトプットを共有し、「4人で相談し合い計画を決めて実行、進捗と完了を直接報告」するよう依頼
- workers: 互いに直接議論して分担や進め方を決定し、`./tmp/<TASK_ID>_workerX_done.txt` に成果を記録。全員完了を確認した1人が `TASK_ID` 付きで PRESIDENT に完了を報告
- PRESIDENT: 完了報告を受領し、必要に応じてフォローアップやクローズを行う
