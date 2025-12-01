#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# tmuxのbase-indexとpane-base-indexを動的に取得
get_tmux_indices() {
    local session="$1"
    local window_index=$(tmux show-options -t "$session" -g base-index 2>/dev/null | awk '{print $2}')
    local pane_index=$(tmux show-options -t "$session" -g pane-base-index 2>/dev/null | awk '{print $2}')

    # デフォルト値
    window_index=${window_index:-0}
    pane_index=${pane_index:-0}

    echo "$window_index $pane_index"
}

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "president") echo "president" ;;
        "worker1"|"worker2"|"worker3"|"worker4")
            # multiagentセッションのindexを動的に取得
            if tmux has-session -t multiagent 2>/dev/null; then
                local indices=($(get_tmux_indices multiagent))
                local window_index=${indices[0]}
                local pane_index=${indices[1]}

                # window名で取得（base-indexに依存しない）
                local window_name="agents"

                # pane番号を計算
                case "$1" in
                    "worker1") echo "multiagent:$window_name.$((pane_index))" ;;
                    "worker2") echo "multiagent:$window_name.$((pane_index + 1))" ;;
                    "worker3") echo "multiagent:$window_name.$((pane_index + 2))" ;;
                    "worker4") echo "multiagent:$window_name.$((pane_index + 3))" ;;
                esac
            else
                echo ""
            fi
            ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  president - プロジェクト統括責任者
  worker1   - 実行担当者A
  worker2   - 実行担当者B
  worker3   - 実行担当者C
  worker4   - 実行担当者D

使用例:
  $0 president "指示書に従って"
  $0 worker1 "作業完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="

    # presidentセッション確認
    if tmux has-session -t president 2>/dev/null; then
        echo "  president → president       (プロジェクト統括責任者)"
    else
        echo "  president → [未起動]        (プロジェクト統括責任者)"
    fi

    # multiagentセッション確認
    if tmux has-session -t multiagent 2>/dev/null; then
        local worker1_target=$(get_agent_target "worker1")
        local worker2_target=$(get_agent_target "worker2")
        local worker3_target=$(get_agent_target "worker3")
        local worker4_target=$(get_agent_target "worker4")

        echo "  worker1   → ${worker1_target:-[エラー]}  (実行担当者A)"
        echo "  worker2   → ${worker2_target:-[エラー]}  (実行担当者B)"
        echo "  worker3   → ${worker3_target:-[エラー]}  (実行担当者C)"
        echo "  worker4   → ${worker4_target:-[エラー]}  (実行担当者D)"
    else
        echo "  worker1   → [未起動]        (実行担当者A)"
        echo "  worker2   → [未起動]        (実行担当者B)"
        echo "  worker3   → [未起動]        (実行担当者C)"
        echo "  worker4   → [未起動]        (実行担当者D)"
    fi
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
        
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 
