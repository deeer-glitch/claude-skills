#!/usr/bin/env bash
# 디어 개인 스킬 동기화: 개인 레포(deeer-glitch/claude-skills, main 직접 push)
# + 팀 공용 레포(Ohouse-product-design/AI-Skill, PR 생성)
#
# 사용법:
#   sync-skill.sh <skill-name> ["커밋 메시지"] [--personal-only]
#
# 예:
#   sync-skill.sh design-review "feat(design-review): STEP 5 크리틱 포맷 교체"
#   sync-skill.sh lofi-wire --personal-only
set -euo pipefail

PERSONAL="$HOME/claude-skills"
TEAM_CACHE="$HOME/.cache/ai-skill-sync"
TEAM_REPO="Ohouse-product-design/AI-Skill"
# 디어 소유 스킬만 동기화 허용 (팀원 스킬 덮어쓰기 방지 가드)
MY_SKILLS=(state-verifier spec-policy-handoff design-review user-voice lofi-wire jira-qa-bug)

SKILL="${1:-}"
MSG="${2:-}"
PERSONAL_ONLY=false
for arg in "$@"; do [[ "$arg" == "--personal-only" ]] && PERSONAL_ONLY=true; done
[[ "$MSG" == "--personal-only" ]] && MSG=""

if [[ -z "$SKILL" ]]; then
  echo "사용법: sync-skill.sh <skill-name> [\"커밋 메시지\"] [--personal-only]"
  echo "동기화 가능 스킬: ${MY_SKILLS[*]}"
  exit 1
fi
[[ -z "$MSG" ]] && MSG="sync($SKILL): update"

if [[ ! " ${MY_SKILLS[*]} " == *" $SKILL "* ]]; then
  echo "중단: '$SKILL' 은 MY_SKILLS 목록에 없음 (팀원 스킬 보호 가드)"
  echo "디어 소유 스킬이 맞다면 스크립트 상단 MY_SKILLS에 추가 후 재실행"
  exit 1
fi
if [[ ! -d "$PERSONAL/skills/$SKILL" ]]; then
  echo "중단: $PERSONAL/skills/$SKILL 폴더 없음"
  exit 1
fi

echo "=== 1/2 개인 레포 (deeer-glitch/claude-skills) ==="
cd "$PERSONAL"
git switch main -q
git pull --ff-only origin main -q
PATHS=("skills/$SKILL")
[[ -f "dist/cursor/$SKILL.mdc" ]] && PATHS+=("dist/cursor/$SKILL.mdc")
if [[ -n "$(git status --porcelain -- "${PATHS[@]}")" ]]; then
  git add -- "${PATHS[@]}"
  git commit -q -m "$MSG"
  git push -q origin main
  echo "완료: main에 커밋·푸시 ($MSG)"
else
  echo "변경 없음: 개인 레포는 이미 최신"
fi

if $PERSONAL_ONLY; then
  echo "(--personal-only) 팀 레포 동기화는 건너뜀"
  exit 0
fi

echo "=== 2/2 팀 레포 ($TEAM_REPO) PR ==="
if [[ -d "$TEAM_CACHE/.git" ]]; then
  git -C "$TEAM_CACHE" fetch -q origin main
  git -C "$TEAM_CACHE" checkout -q -B main origin/main
else
  gh repo clone "$TEAM_REPO" "$TEAM_CACHE" -- -q
fi
rsync -a --delete "$PERSONAL/skills/$SKILL/" "$TEAM_CACHE/skills/$SKILL/"
if [[ -f "$PERSONAL/dist/cursor/$SKILL.mdc" ]]; then
  mkdir -p "$TEAM_CACHE/dist/cursor"
  cp "$PERSONAL/dist/cursor/$SKILL.mdc" "$TEAM_CACHE/dist/cursor/$SKILL.mdc"
fi
cd "$TEAM_CACHE"
if [[ -z "$(git status --porcelain)" ]]; then
  echo "변경 없음: 팀 레포는 이미 최신"
  exit 0
fi
BR="sync/$SKILL-$(date +%Y%m%d-%H%M)"
git checkout -q -b "$BR"
git add -A
git commit -q -m "$MSG"
git push -q origin "$BR"
gh pr create --repo "$TEAM_REPO" --base main --head "$BR" --title "$MSG" \
  --body "개인 레포(deeer-glitch/claude-skills)에서 동기화한 변경입니다. 상세는 diff 참고."
echo "완료: 팀 레포 PR 생성 (머지는 검토 후 진행)"
