# 🤖 Tmux Multi-Agent Communication Demo

A demo system for agent-to-agent communication in a tmux environment.

**📖 Read this in other languages:** [日本語](README.md)

## 🎯 Demo Overview

Experience a peer-style command system: PRESIDENT coordinates while workers discuss and self-assign directly.

### 👥 Agent Configuration

```
📊 PRESIDENT Session (1 pane)
└── PRESIDENT: Project Manager

📊 multiagent Session (4 panes)  
├── worker1: Worker A
├── worker2: Worker B
├── worker3: Worker C
└── worker4: Worker D
```

## 🚀 Quick Start

### 0. Clone Repository

```bash
git clone https://github.com/nishimoto265/Claude-Code-Communication.git
cd Claude-Code-Communication
```

### 1. Setup tmux Environment

⚠️ **Warning**: Existing `multiagent` and `president` sessions will be automatically removed.

```bash
./setup.sh
```

### 2. Attach Sessions

```bash
# Check multiagent session
tmux attach-session -t multiagent

# Check president session (in another terminal)
tmux attach-session -t president
```

### 3. Launch Agent CLI (configure profiles in `config/agent_cli.env`)

**Step 1: Start President**
```bash
# Start in the PRESIDENT pane
tmux send-keys -t president './bin/agent-launch.sh president' C-m
```

**Step 2: Launch All Multiagent Sessions**
```bash
# Launch all panes
for i in {0..3}; do tmux send-keys -t multiagent:0.$i './bin/agent-launch.sh' C-m; done
```

### 4. Run Demo

Type directly in PRESIDENT session:
```
You are the president. Follow the instructions.
```

## 📜 About Instructions

Role-specific instruction files for each agent:
- **PRESIDENT**: `instructions/president.md`
- **worker1-4**: `instructions/worker.md`
- (Reference) **boss1**: `instructions/boss.md` (deprecated role)

**Project Memory Reference**: `CLAUDE.md` (for Claude). For other CLIs, place the appropriate memory file each CLI reads.

**Key Points:**
- **PRESIDENT**: Receive a user task, assign a unique `TASK_ID`, summarize goals/background, and broadcast to all workers with a request to self-organize, discuss, and report progress/completion directly.
- **workers**: Discuss peer-to-peer, agree on a plan/assignment, execute, write `./tmp/<TASK_ID>_workerX_done.txt`, report their status, and have one person confirm "all done" to the PRESIDENT.

## 🎬 Expected Operation Flow

```
1. PRESIDENT → all workers: "TASK_ID=20240607-120000; GOAL=Build a todo app; Background=<user text>; Discuss and decide plan/roles, then report progress/completion directly."
2. workers: Agree on plan/roles (e.g., worker1 requirements, worker2 architecture, worker3 QA, worker4 delivery) or run parallel experiments and compare results.
3. workers: Execute, write `./tmp/20240607-120000_workerX_done.txt`, then one person sends "All tasks completed" with `TASK_ID` to PRESIDENT once all files exist.
```

## 🔧 Manual Operations

### Using agent-send.sh

```bash
# Basic sending
./agent-send.sh [agent_name] [message]

# Examples
./agent-send.sh worker1 "Task completed"
./agent-send.sh president "Final report"

# Check agent list
./agent-send.sh --list
```

## 🧪 Verification & Debug

### Log Checking

```bash
# Check send logs
cat logs/send_log.txt

# Check specific agent logs
grep "worker1" logs/send_log.txt

# Check completion files
ls -la ./tmp/worker*_done.txt
```

### Session Status Check

```bash
# List sessions
tmux list-sessions

# List panes
tmux list-panes -t multiagent
tmux list-panes -t president
```

## 🔄 Environment Reset

```bash
# Delete sessions
tmux kill-session -t multiagent
tmux kill-session -t president

# Delete completion files
rm -f ./tmp/worker*_done.txt

# Rebuild (with auto cleanup)
./setup.sh
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions via pull requests and issues are welcome!

---

🚀 **Experience Agent Communication!** 🤖✨ 
