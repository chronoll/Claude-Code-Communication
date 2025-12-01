# Agent Communication System (Codex CLI 用プロジェクトメモリ)

## エージェント構成
- **PRESIDENT** (別セッション): 統括責任者
- **boss1** (multiagent:agents): チームリーダー
- **worker1,2,3** (multiagent:agents): 実行担当

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## 基本フロー
- ユーザー → PRESIDENT: 任意のタスク指示
- PRESIDENT: タスク内容を整理し一意の `TASK_ID` を付与。boss1 に「計画・配分方針（役割分担 or 並列検証など）」を依頼して送信
- boss1: 簡潔な計画を立て、worker1/2/3 に状況に合うサブタスクや並列タスク＋完了条件を配信し、完了を集約
- workers: 与えられたタスクのみ実行（並列同一タスクの指示もあり得る） → `./tmp/<TASK_ID>_workerX_done.txt` を作成 → 最後の人が報告
- boss1 → PRESIDENT: `TASK_ID` 付きで全員完了を報告
