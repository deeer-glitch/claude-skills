#!/usr/bin/env bash
# lofi-wire — 롤백 스크립트. 잘못 푸시한 파일 제거.
#
# 사용:
#   bash unshare.sh <filename or path>
#
# 예:
#   bash unshare.sh glinda/glinda-onboarding-light-structure.html
#   bash unshare.sh glinda-onboarding-light-structure.html   # 자동 검색

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../.share-config"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[unshare] 공유 레포가 아직 셋업되지 않았어요. 먼저 실행하세요: bash ${SCRIPT_DIR}/setup-repo.sh" >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$CONFIG_FILE"

REPO_DIR="${HOME}/Repos/${REPO_NAME}"

if [[ $# -lt 1 ]]; then
  echo "Usage: unshare.sh <filename or wires/{project}/{file}.html>" >&2
  exit 1
fi

TARGET="$1"

cd "$REPO_DIR"
git fetch origin --quiet
DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
git checkout "$DEFAULT_BRANCH" --quiet
git pull --rebase --quiet

# 파일 경로 해석
if [[ -f "$TARGET" ]]; then
  PATH_TO_REMOVE="$TARGET"
elif [[ -f "wires/$TARGET" ]]; then
  PATH_TO_REMOVE="wires/$TARGET"
else
  # 파일명만 받았으면 wires/ 하위 전부 검색
  FOUND="$(find wires -name "$(basename "$TARGET")" -type f 2>/dev/null | head -n 1)"
  if [[ -z "$FOUND" ]]; then
    echo "[unshare] 파일 못 찾음: $TARGET" >&2
    exit 1
  fi
  PATH_TO_REMOVE="$FOUND"
fi

echo "[unshare] 제거 대상: $PATH_TO_REMOVE"

git rm "$PATH_TO_REMOVE"
git commit -m "unshare: ${PATH_TO_REMOVE}" --quiet
git push origin "$DEFAULT_BRANCH" --quiet

echo "[unshare] 제거 + 푸시 완료."
echo ""
echo "주의: GitHub Pages 캐시는 빌드 사이클 따라 1~10분 지연될 수 있어요."
echo "긴급한 경우 GitHub Settings → Pages → Unpublish site 또는 강제 재배포."
