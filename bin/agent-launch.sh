#!/usr/bin/env bash
set -euo pipefail

# Agent CLI launcher
# 優先順位: ROLE_<ROLE>_* > PROFILE_<NAME>_* > フォールバック(claude)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${CONFIG_FILE:-${REPO_ROOT}/config/agent_cli.env}"

# dotenv 読み込み
if [ -f "${CONFIG_FILE}" ]; then
  set -a
  # shellcheck source=/dev/null
  source "${CONFIG_FILE}"
  set +a
fi

usage() {
  cat <<'EOF'
Usage: agent-launch.sh [--profile NAME] [ROLE] [-- additional CLI args]
  --profile NAME   一時的に AGENT_PROFILE を上書き
  ROLE             president / boss1 / worker1 / worker2 / worker3 等（省略可）
  以降の引数は対象CLIへそのまま渡されます
EOF
}

PROFILE="${AGENT_PROFILE:-claude}"
ROLE=""
POSITIONAL=()

while (( "$#" )); do
  case "$1" in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      POSITIONAL+=("$@")
      break
      ;;
    *)
      if [[ -z "${ROLE}" ]]; then
        ROLE="$1"
      else
        POSITIONAL+=("$1")
      fi
      shift
      ;;
  esac
done

# 大文字キー生成
upper() { echo "${1}" | tr '[:lower:]-' '[:upper:]_'; }

ROLE_KEY="$(upper "${ROLE:-}")"
PROFILE_KEY="$(upper "${PROFILE}")"

# 変数名組み立て
ROLE_BIN_VAR="ROLE_${ROLE_KEY}_BIN"
ROLE_ARGS_VAR="ROLE_${ROLE_KEY}_ARGS"
PROFILE_BIN_VAR="PROFILE_${PROFILE_KEY}_BIN"
PROFILE_ARGS_VAR="PROFILE_${PROFILE_KEY}_ARGS"

BIN=""
ARGS=""

# 1) ロール別
if [[ -n "${ROLE_KEY}" ]]; then
  BIN="${!ROLE_BIN_VAR-}"
  ARGS="${!ROLE_ARGS_VAR-}"
fi

# 2) プロファイル別
if [[ -z "${BIN}" ]]; then
  BIN="${!PROFILE_BIN_VAR-}"
  ARGS="${!PROFILE_ARGS_VAR-}"
fi

# 3) フォールバック（後方互換）
if [[ -z "${BIN}" ]]; then
  BIN="claude"
  ARGS="--dangerously-skip-permissions"
fi

if [[ -z "${BIN}" ]]; then
  echo "ERROR: AGENT_BIN を決定できません (profile=${PROFILE}, role=${ROLE})" >&2
  exit 1
fi

echo "Launching agent: BIN='${BIN}' ARGS='${ARGS}' PROFILE='${PROFILE}' ROLE='${ROLE}'" >&2
exec ${BIN} ${ARGS} "${POSITIONAL[@]}"
