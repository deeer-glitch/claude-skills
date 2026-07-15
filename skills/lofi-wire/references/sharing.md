# Sharing — 공유 모드 워크플로우

매번 와이어 만들고 렌더링 검증 직후 클로드가 자동으로 묻는다:

> *"공유 링크로 올릴까요?"* (예: 다른 직군 동료에게 보내고 싶을 때)

PD가 OK 하면 아래 시퀀스. *OK 안 하면 그냥 로컬 파일로 끝.*

## 시퀀스

```
[1] 자동 마스킹
  ↓
[2] 미리보기 (.masked.html)
  ↓
[3] PD 직접 확인
  ↓
[4] "OK 푸시" 받기
  ↓
[5] 레포 푸시 + Pages URL 반환
```

### [1] 자동 마스킹

```bash
python3 ~/.claude/skills/lofi-wire/scripts/mask.py ~/Downloads/{filename}.html
```

- `assets/masking-patterns.json` 규칙 자동 적용
- 결과: `~/Downloads/{filename}.masked.html`
- footnote에 *공유용 마스킹 안내* 자동 추가

### [2] 미리보기

PD에게:
> *"마스킹된 미리보기 파일 만들었어요: `~/Downloads/{filename}.masked.html` — 한 번 열어보시고 확인 부탁드려요. 더 가릴 부분 있으면 알려주시고, OK면 '푸시'라고 해주세요."*

→ PD가 *"이것도 가려"* 추가하면 `mask.py --extra '{"patterns":[{"pattern":"...","replace":"..."}]}'` 재실행.

### [3] 컨펌

PD 발화 패턴:
- *"OK 푸시"* / *"올려"* / *"좋아 올려줘"* → 푸시 진행
- *"이거 더 가려"* / *"이건 빼"* → 추가 마스킹 후 [2]로
- *"그만"* / *"취소"* / *"안 할래"* → 중단, 로컬만

### [4] 푸시

```bash
bash ~/.claude/skills/lofi-wire/scripts/push.sh ~/Downloads/{filename}.masked.html {project_slug}
```

스크립트가:
- 본인 공유 레포 로컬 클론 (없으면 자동 클론)
- `wires/{project_slug}/{original_filename}.html` 경로로 복사 (`.masked.html` 확장자 떼고 원본 이름으로)
- 커밋 + 푸시 (main 브랜치)
- Pages URL 반환

### [5] URL 반환

푸시 끝나면 PD에게:
> *"공유 URL: `https://{본인계정}.github.io/lofi-wire-share/wires/{project}/{filename}`*
> *GitHub Pages 빌드까지 30초~1분 정도 걸려요. 빌드 후 슬랙·메일 등에 붙여서 공유 가능."*

## Rollback (PD *"방금 그거 내려"*)

```bash
bash ~/.claude/skills/lofi-wire/scripts/unshare.sh {filename or path}
```

- 레포에서 `git rm` + 푸시
- GitHub Pages 캐시는 1~10분 지연 가능. 긴급하면 Settings → Pages → Unpublish.

## 첫 사용 시 (레포가 없으면)

`push.sh`가 자동 클론 시도. 클론/설정 파일이 없으면 PD한테:
> *"공유 레포가 없어요. 처음이라면 셋업 한 번 돌릴게요:*
> *`bash ~/.claude/skills/lofi-wire/scripts/setup-repo.sh`*
> *돌리면 본인 GitHub 계정 아래 레포 생성 + Pages 활성화까지 한 번에. OK 주시면 진행."*

`references/repo-setup.md` 참조.

## 주의 사항

- **자동 마스킹 100% 믿지 X.** 새 패턴은 [3]에서 PD가 잡아야 함. 발견되면 `masking-patterns.json` + `masking-rules.md` 둘 다 업데이트.
- **공유 모드는 발동 안 강제.** 매번 와이어가 공유용은 아니라서. PD가 OK 안 하면 그냥 로컬만.
- **민감 정보 사고 시 빠르게 unshare.** 그리고 패턴 보강.
- **공유 레포는 개인 소유.** 팀 공용 레포가 아니라 각자 자기 GitHub 계정 아래 만든다 — 첫 사용자마다 `setup-repo.sh` 한 번씩 실행 필요.
