# AI Skill

오늘의집 PD팀 공용 Claude 스킬 저장소입니다.
[PD AI Workflow Map](https://ohouse-product-design.github.io/AI-Workflow/%5BYH%5DLoadmap/ai-workflow-map.html) — **3. Handoff & QA** 그룹 스킬을 포함하며, 팀 전체 워크플로우를 커버하는 방향으로 지속 확장됩니다.

---

## 스킬 목록

| 스킬명 | 설명 | 트리거 | 도메인 | 상태 |
|---|---|---|---|---|
| **state-verifier** | 디자인 단계 UI 상태 누락 및 엣지케이스 자동 탐지 | `상태 체크해줘` / `엣지케이스 뽑아줘` | 콘텐츠 | ✅ 운영 중 |
| **spec-policy-handoff** | Figma 화면 구조 기반 핸드오프 주석 초안 생성 | `주석 써줘` / `spec 달아줘` | 콘텐츠 | ✅ 운영 중 |
| **design-review** | 디자인 리뷰 워크플로 (페르소나→VOC→리뷰→스펙→크리틱) | `#페르소나` / `#유저보이스` / `#리뷰` / `#스펙` / `#크리틱` | 공통 | ✅ 운영 중 |
| **user-voice** | 유대시 VOC 조회 및 디자인/기획 근거 활용 | `유저 의견 찾아줘` / `VOC 근거` | 공통 | ✅ 운영 중 |
| **lofi-wire** | Lo-fi 와이어프레임 HTML 생성 — 구조 합의·옵션 비교·개념 시각화·핸드오프 전 검토용. 그레이스케일 톤 + 공용 컴포넌트 라이브러리 자동 적용, 마스킹 후 개인 GitHub Pages로 공유 가능 | `와이어 만들어줘` / `lofi` / `구조 보여줘` / `옵션 비교` | 공통 | ✅ 운영 중 |
| **wording-check** | 내부 공유 글 다듬기 — 포맷은 유지하고 읽는 사람 기준으로 문장 교정, 프로덕트·오늘의집 용어 지향 | `워딩 점검해줘` / `글 다듬어줘` | 공통 | ✅ 운영 중 |
| **jira-qa-bug** | QA/검수 단계 버그(디자인·정책·스펙·콘텐츠)를 Jira 티켓으로 발행 — 프로젝트 매핑·라벨·본문 구조·담당자 lookup·발행 전 컨펌 박제 | `버그 티켓 만들어` / `QA 버그 등록` / `지라 버그 티켓` | 공통 | ✅ 운영 중 |

> 도메인 컬럼은 스킬이 최적화된 도메인을 나타내요. 다른 도메인에서 사용할 때는 해당 도메인 케이스를 SKILL.md에 추가하면 품질이 올라갑니다.

---

## 설치

### Claude Code

`CLAUDE.md`에 스킬 경로를 추가하세요 (`shared/CLAUDE.md.template` 참고).

```markdown
## Skills
- state-verifier: ~/claude-skills/skills/state-verifier/SKILL.md
- spec-policy-handoff: ~/claude-skills/skills/spec-policy-handoff/SKILL.md
- design-review: ~/claude-skills/skills/design-review/SKILL.md
- user-voice: ~/claude-skills/skills/user-voice/SKILL.md
- lofi-wire: ~/claude-skills/skills/lofi-wire/SKILL.md
- wording-check: ~/claude-skills/skills/wording-check/SKILL.md
- jira-qa-bug: ~/claude-skills/skills/jira-qa-bug/SKILL.md
```

### Cursor

1. `.mdc` 파일 빌드

```bash
~/claude-skills/scripts/build-cursor.sh
```

2. 프로젝트에 심볼릭 링크 설정

```bash
~/claude-skills/scripts/setup-cursor.sh /path/to/your/project
```

---

## 스킬 업데이트 받기

```bash
cd ~/claude-skills && git pull origin main
```

---

## 새 스킬 추가하는 법

`skills/{스킬명}/` 폴더를 만들고 SKILL.md와 cursor.yaml을 작성한 뒤 PR을 올려주세요.
기존 스킬 폴더를 참고하면 됩니다.

스킬 수정 후에는 빌드 스크립트를 실행해 Cursor용 `.mdc` 파일을 업데이트하세요.

```bash
~/claude-skills/scripts/build-cursor.sh
```

> 특정 도메인(커머스, O2O, 글로벌, 홈) 특화 스킬의 경우, 위 스킬 목록 테이블에 도메인을 명시해 주세요.

---

## 문의 및 개선 제안

사용 중 이슈나 아이디어는 [Issues](https://github.com/Ohouse-product-design/AI-Skill/issues)에 남겨주세요.
