#!/usr/bin/env bash
# lofi-wire — 첫 사용 시 공유 레포 셋업.
# 사용법: setup-repo.sh [owner]   (owner 생략 시 본인 계정. 사내 org 권장 — internal 가시성은 org에서만 동작)
# 환경변수: LOFI_SHARE_VISIBILITY=internal(기본)|private|public
# - {owner}/lofi-wire-share 레포 생성 (기본 internal — 사내 org 구성원만 접근)
# - README 추가
# - main 브랜치 GitHub Pages 활성화
# - 로컬 클론
# - .share-config에 REPO_OWNER/REPO_NAME 저장 (push.sh / unshare.sh가 읽음)
#
# 한 번만 실행. 이후엔 push.sh / unshare.sh가 알아서.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../.share-config"
REPO_NAME="lofi-wire-share"

echo "[setup] lofi-wire 공유 레포 셋업 시작..."

# 1) gh 인증 확인
if ! gh auth status >/dev/null 2>&1; then
  echo "[setup] gh CLI 인증이 필요해요. 'gh auth login' 실행 후 다시 시도하세요." >&2
  exit 1
fi

# 2) 소유자 결정 — 인자/환경변수 우선, 없으면 본인 계정
REPO_OWNER="${LOFI_SHARE_OWNER:-${1:-}}"
[[ -z "$REPO_OWNER" ]] && REPO_OWNER="$(gh api user --jq .login)"
REPO_FULL="${REPO_OWNER}/${REPO_NAME}"
REPO_DIR="${HOME}/Repos/${REPO_NAME}"

# 가시성 — 기본 internal (사내 org 구성원만). public은 명시적 옵트인.
VISIBILITY="${LOFI_SHARE_VISIBILITY:-internal}"
case "$VISIBILITY" in internal|private|public) ;; *)
  echo "[setup] LOFI_SHARE_VISIBILITY는 internal|private|public 중 하나여야 해요: $VISIBILITY" >&2; exit 1;;
esac
if [[ "$VISIBILITY" == "public" ]]; then
  echo "[setup] ⚠️  public 레포 — 와이어가 공개 인터넷에 노출됩니다(검색엔진 인덱싱 가능)."
  echo "[setup]     사외 공유가 꼭 필요한 경우에만 사용하고, 마스킹 커버리지를 한 번 더 점검하세요."
fi

echo "[setup] 소유자: ${REPO_OWNER} → 레포 ${REPO_FULL} (${VISIBILITY})"

# 3) 레포 존재 확인 → 없으면 생성
if gh repo view "$REPO_FULL" >/dev/null 2>&1; then
  echo "[setup] 레포 이미 존재: $REPO_FULL"
else
  echo "[setup] 레포 생성..."
  if ! gh repo create "$REPO_FULL" --"$VISIBILITY" \
    --description "Lo-fi 와이어 공유 — 마스킹 적용된 디자인 시안. 내부 SSOT와 다를 수 있음." \
    --add-readme \
    --confirm; then
    echo "[setup] 레포 생성 실패." >&2
    if [[ "$VISIBILITY" == "internal" ]]; then
      echo "[setup] internal 가시성은 Enterprise org에서만 가능해요. 사내 org 아래로 만드세요:" >&2
      echo "[setup]   bash ${BASH_SOURCE[0]} <org명>" >&2
      echo "[setup] 사외 공유가 꼭 필요한 경우에만: LOFI_SHARE_VISIBILITY=public bash ${BASH_SOURCE[0]}" >&2
    fi
    exit 1
  fi
fi

# 4) 로컬 클론
if [[ ! -d "$REPO_DIR/.git" ]]; then
  mkdir -p "$(dirname "$REPO_DIR")"
  gh repo clone "$REPO_FULL" "$REPO_DIR"
fi

cd "$REPO_DIR"

# 5) README 보강
cat > README.md <<EOF
# ${REPO_NAME}

오늘의집 PD의 Lo-fi 와이어프레임 공유 레포 (\`lofi-wire\` 스킬로 생성).

## 주의

- 이 레포의 모든 와이어는 **자동 마스킹된 공유본**입니다.
- 카피·색·가격·로고는 **더미 데이터**이며, 실제 디자인·정책·내부 SSOT와 다를 수 있어요.
- 내부 시스템 정보(PRD·Jira·Slack·실측 데이터 등)는 마스킹되어 있습니다.
- 외부 공유 목적의 **참고용 시안**입니다.

## 구조

\`\`\`
wires/
└── {project}/
    └── {topic}-{kind}{-v?}.html
\`\`\`

## 만든 사람

[@${REPO_OWNER}](https://github.com/${REPO_OWNER}) — \`lofi-wire\` 스킬로 생성.
EOF

# 6) wires/ 디렉토리 + 빈 index
mkdir -p wires
if [[ ! -f index.html ]]; then
  cat > index.html <<EOF
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>${REPO_NAME}</title>
<style>
  body { font-family: -apple-system, "Apple SD Gothic Neo", sans-serif; max-width: 720px; margin: 60px auto; padding: 0 24px; color: #1f2225; line-height: 1.6; }
  h1 { font-size: 24px; }
  code { background: #f0f2f5; padding: 2px 6px; border-radius: 4px; font-size: 13px; }
  .note { background: #fff8e1; border: 1px solid #f0d469; border-radius: 8px; padding: 12px 16px; font-size: 13px; color: #7a5a08; margin: 20px 0; }
</style>
</head>
<body>
  <h1>${REPO_NAME}</h1>
  <p>Lo-fi 와이어 공유 레포. 개별 와이어는 <code>wires/{project}/{file}.html</code> 경로로 접근.</p>
  <div class="note">⚠️ 모든 파일은 자동 마스킹된 공유본입니다. 카피·색·데이터 더미.</div>
</body>
</html>
EOF
fi

# 7) 커밋 + 푸시
DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

git add README.md wires index.html 2>/dev/null || true
if git diff --cached --quiet 2>/dev/null; then
  echo "[setup] 변경 사항 없음."
else
  git commit -m "setup: ${REPO_NAME} initial scaffold" --quiet
  git push origin "$DEFAULT_BRANCH" --quiet
fi

# 8) GitHub Pages 활성화
echo "[setup] GitHub Pages 활성화 시도..."
gh api -X POST "repos/${REPO_FULL}/pages" \
  -f "source[branch]=${DEFAULT_BRANCH}" \
  -f "source[path]=/" \
  >/dev/null 2>&1 \
  && echo "[setup] Pages 활성화 완료." \
  || echo "[setup] Pages 이미 활성화돼 있거나 수동 활성화 필요. Settings → Pages 확인."

# 9) 다음 실행(push.sh/unshare.sh)이 읽을 설정 저장
cat > "$CONFIG_FILE" <<EOF
REPO_OWNER=${REPO_OWNER}
REPO_NAME=${REPO_NAME}
EOF

echo ""
echo "✅ 셋업 완료."
echo "   레포: https://github.com/${REPO_FULL}"
echo "   Pages URL 베이스: https://${REPO_OWNER}.github.io/${REPO_NAME}/"
echo "   로컬 클론: ${REPO_DIR}"
