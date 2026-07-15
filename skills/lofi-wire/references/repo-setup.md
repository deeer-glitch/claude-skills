# Repo Setup — lofi-wire-share 첫 셋업

공유 모드를 처음 사용할 때 한 번만 실행. 본인 GitHub 계정 아래 개인 공유 레포를 만든다 (팀 공용 레포 아님 — 각자 자기 계정에 만든다).

## 자동 셋업 (권장)

```bash
bash ~/.claude/skills/lofi-wire/scripts/setup-repo.sh
```

스크립트가 하는 일:
1. `gh auth status` 인증 확인
2. `gh api user`로 본인 GitHub 계정 자동 감지
3. `{본인계정}/lofi-wire-share` 공개 레포 생성 (없으면)
4. 로컬 클론 (`~/Repos/lofi-wire-share/`)
5. README + index.html scaffold
6. 첫 커밋 + 푸시
7. GitHub Pages 활성화 (main 브랜치, root)
8. `~/.claude/skills/lofi-wire/.share-config`에 계정·레포명 저장 (이후 `push.sh`/`unshare.sh`가 읽음)

## 수동 셋업 (자동이 실패하면)

아래에서 `{owner}`는 본인 GitHub 계정명으로 치환.

### 1. 레포 생성
```bash
gh repo create {owner}/lofi-wire-share --public \
  --description "Lo-fi 와이어 공유 — 마스킹 적용된 디자인 시안." \
  --add-readme
```

### 2. 로컬 클론
```bash
mkdir -p ~/Repos
gh repo clone {owner}/lofi-wire-share ~/Repos/lofi-wire-share
cd ~/Repos/lofi-wire-share
mkdir -p wires
```

### 3. GitHub Pages 활성화
- 웹에서: `https://github.com/{owner}/lofi-wire-share/settings/pages`
- Branch: `main`, Folder: `/ (root)` 선택 → Save
- 또는 API:
  ```bash
  gh api -X POST repos/{owner}/lofi-wire-share/pages \
    -f "source[branch]=main" -f "source[path]=/"
  ```

### 4. 첫 푸시
```bash
echo "scaffold" > .placeholder
git add .
git commit -m "setup: initial scaffold"
git push origin main
```

### 5. 설정 파일 저장
```bash
cat > ~/.claude/skills/lofi-wire/.share-config <<EOF
REPO_OWNER={owner}
REPO_NAME=lofi-wire-share
EOF
```

## Pages URL 형식

```
https://{owner}.github.io/lofi-wire-share/wires/{project}/{filename}.html
```

## 빌드 지연

GitHub Pages 빌드는 푸시 후 보통 30초 ~ 1분. 종종 5분까지. PD한테 *"빌드 후 슬랙 공유 가능"* 안내.

## 보안 체크

- 레포는 **public** — 누구나 볼 수 있음
- README에 *"마스킹된 공유본"* 명시
- 첫 푸시 전 *마스킹 동작 한 번 테스트* 권장

## 폴더 구조 (목표)

```
lofi-wire-share/
├── README.md
├── index.html
└── wires/
    ├── {project-a}/
    │   ├── {project-a}-onboarding-light-structure.html
    │   ├── {project-a}-onboarding-brand-curation-plp-wireframe-v3.html
    │   └── ...
    ├── {project-b}/
    │   └── ...
    └── ...
```
