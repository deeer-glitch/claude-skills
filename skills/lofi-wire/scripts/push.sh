#!/usr/bin/env bash
# lofi-wire — 공유 모드 푸시 스크립트.
# PD OK 받은 후 호출. 마스킹된 HTML을 본인 lofi-wire-share 레포에 푸시 → GitHub Pages URL 반환.
#
# 사용:
#   bash push.sh <masked_html_path> <project_slug>
#
# 예:
#   bash push.sh ~/Downloads/glinda-onboarding-light-structure.masked.html glinda

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../.share-config"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[push] 공유 레포가 아직 셋업되지 않았어요. 먼저 실행하세요: bash ${SCRIPT_DIR}/setup-repo.sh" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

REPO_DIR="${HOME}/Repos/${REPO_NAME}"
PAGES_BASE="https://${REPO_OWNER}.github.io/${REPO_NAME}"

if [[ $# -lt 2 ]]; then
  echo "Usage: push.sh <masked_html_path> <project_slug>" >&2
  exit 1
fi

MASKED_PATH="$1"
PROJECT_SLUG="$2"

if [[ ! -f "$MASKED_PATH" ]]; then
  echo "[push] 마스킹된 파일이 없습니다: $MASKED_PATH" >&2
  exit 1
fi

# 레포 로컬 클론 없으면 클론
if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "[push] 로컬 클론 없음. 클론 시작..."
  mkdir -p "$(dirname "$REPO_DIR")"
  gh repo clone "${REPO_OWNER}/${REPO_NAME}" "$REPO_DIR" \
    || { echo "[push] 클론 실패. setup-repo.sh 먼저 실행하세요." >&2; exit 1; }
fi

# 최신화
cd "$REPO_DIR"
git fetch origin --quiet
DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
git checkout "$DEFAULT_BRANCH" --quiet
git pull --rebase --quiet

# 파일 복사 — masked.html 끝 빼고 원본 이름으로
TARGET_DIR="wires/${PROJECT_SLUG}"
mkdir -p "$TARGET_DIR"

ORIGINAL_FILENAME="$(basename "$MASKED_PATH" .masked.html).html"
TARGET_PATH="${TARGET_DIR}/${ORIGINAL_FILENAME}"
cp "$MASKED_PATH" "$TARGET_PATH"

# 커밋 + 푸시
git add "$TARGET_PATH"
COMMIT_MSG="add: ${PROJECT_SLUG}/${ORIGINAL_FILENAME}"
if git diff --cached --quiet; then
  echo "[push] 변경 사항 없음 (이미 같은 내용)."
else
  git commit -m "$COMMIT_MSG" --quiet
  git push origin "$DEFAULT_BRANCH" --quiet
  echo "[push] 커밋 + 푸시 완료."
fi

# Pages URL 반환
PAGES_URL="${PAGES_BASE}/${TARGET_DIR}/${ORIGINAL_FILENAME}"
echo ""
echo "🔗 공유 URL:"
echo "   ${PAGES_URL}"
echo ""
echo "(GitHub Pages 빌드까지 30초~1분 정도 걸릴 수 있어요)"
