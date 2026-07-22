---
name: lofi-wire
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
description: >
  오늘의집 PD가 디자인 구조 합의·옵션 비교·개념 시각화·핸드오프 전 검토용 Lo-fi 와이어프레임 HTML을
  빠르게 만드는 팀 공용 스킬. 차분한 그레이스케일 톤·정해진 컴포넌트 라이브러리·좌측 컬러 띠 금지 등
  일관된 시각 룰을 자동 적용한다. 자연어 발화 "와이어 만들어줘", "와이어프레임 만들어줘", "lofi", "lo-fi",
  "구조 보여줘", "비교 시안", "옵션 비교", "메타포로 설명", "v2 만들어줘", "v3 만들어줘", "/wireframe"이
  나오면 반드시 트리거. PRD·기술요건·Figma 캡처에서 디자인 구조를 빠르게 잡거나, 동료에게 옵션을 비교
  제시하거나, 추상 개념을 그림으로 풀어 설명할 때 사용. 작성 직후 클로드가 *"공유 링크로 올릴까요?"*
  자동으로 묻고 PD가 OK 시 마스킹 → 미리보기 → 공유 레포(기본 internal) 푸시 → URL 반환.
  단순 텍스트 답변/슬랙 메시지·일반 코드 작성에는 사용하지 않는다.
---

# Lo-fi Wireframe Skill (`lofi-wire`)

오늘의집 PD가 디자인 구조 합의·옵션 비교·개념 설명·핸드오프 전 검토용 Lo-fi 와이어를 만들 때 사용한다.

## 핵심 원칙

- **차분한 그레이스케일 톤** — Lo-fi라서 색·이미지·카피 디테일은 더미. 구조·정보 위계·인터랙션 분기만 명확.
- **좌측 컬러 띠 금지** — 어떤 요소에도 `border-left` 액센트 stripe 금지. (사용자가 와이어 스타일 선호를 메모리·설정 파일로 관리하고 있다면 함께 반영. 없어도 이 룰 자체는 기본 적용.)
- **컴포넌트 라이브러리 재활용** — 매번 새 CSS 쓰지 말고 `assets/component-library.css`의 클래스를 가져다 쓴다. 일관성·속도 둘 다 위함.
- **공유 모드는 PD OK 받은 후에만** — 와이어 만든 직후 *"공유 링크로 올릴까요?"* 한 줄 묻고, PD가 명시적으로 OK 해야만 마스킹·푸시 진행. 매번 공유가 필요한 건 아니라서.

## 4가지 출력 모드

발화에서 추론해 자동 선택. 디테일은 `references/output-modes.md`.

| 모드 | 언제 | 샘플 |
|---|---|---|
| **풀 페이지** | KV + 섹션 N개 + CTA 한 화면 흐름 합의용 | `samples/light-structure-fullpage.html` |
| **N-State 비교** | 같은 화면의 다른 상태/옵션 2~4개 나란히 | `samples/v3-wireframe-state-compare.html` |
| **컴포넌트 비교** | 모듈 헤더·카드 같은 부분 단위 옵션 3안 비교 | `references/output-modes.md` 안 |
| **메타포 설명** | 추상 개념(데이터 흐름·정책 차이 등)을 이모지·박스로 시각화 | `references/output-modes.md` 안 |

→ 발화 예시 매핑:
- "온보딩 라이트화 풀 페이지 와이어" → 풀 페이지
- "옵션 A/B/C 비교 시안" → 컴포넌트 비교
- "이거 그림으로 설명해줘" / "메타포로" → 메타포 설명
- "v3 만들어줘" → 기존 prefix 찾아 다음 버전, N-State 비교일 확률 높음

## 워크플로우 (자연어 우선, 추론 가능한 건 자동)

1. **트리거 발화 감지** → 본 스킬 진입
2. **프로젝트 컨텍스트 자동 로드 (있으면만 — 없어도 OK)**
   - 사용자가 프로젝트별 워크스페이스나 프로젝트 인덱스 문서를 따로 관리하고 있다면 자동으로 참고해서 PD가 매번 PRD 정보 다시 안 줘도 되게 함
   - 그런 워크스페이스가 없으면 그냥 발화에서 받은 정보로 진행
3. **출력 모드 결정** — 발화에서 추론. 모호하면 한 줄 확인.
4. **첨부 문서 수집** — PD가 메시지에 PRD URL·Figma URL·Slack 스레드·Jira 키 등 붙였으면 그대로 받음.
5. **데이터 모드 결정** — 더미(기본) / 실측 / 캡처 인용. 자세한 건 `references/data-modes.md`.
6. **디바이스** — 기본 모바일(375px). 발화에 "PC" 들어 있으면 PC(1200px) 또는 둘 다.
7. **섹션 구성** — 자연어로 받음. 예: "KV + 섹션 3개 + Empty 가이드"
8. **버전 결정** — 같은 prefix(`{project}-{topic}-{kind}`) 기존 파일 있으면 자동 다음 버전. 버전 비교 자동화는 `references/versioning.md`.
9. **생성** — `assets/component-library.css`를 인라인으로 `<style>` 안에 박고, HTML 작성. `~/Downloads/{project}-{topic}-{kind}{-v?}.html` 저장. 네이밍은 `references/naming.md`.
10. **렌더링 자동 검증** — 로컬 서버(또는 헤드리스 크롬)로 열어 스크린샷 캡처 → PD에게 결과 보여줌. 환경에 프리뷰용 MCP 도구가 있으면 그걸 사용.
11. **후속 액션 메뉴** (자동 제시):
    - **공유 링크로 올릴까요?** ← 핵심. PD OK 시 공유 모드 진입 (`references/sharing.md`)
    - **산출물로 프로젝트 문서에 기록할까요?** ← 프로젝트 워크스페이스를 관리 중일 때만
    - **Figma 컴포넌트 네이밍 추천** (PascalCase: `BundleProductCard`, `ModuleHeader` 등)
    - **다음 버전 안내**
    - **와이어 세트(여러 상태·화면)를 다 그렸으면**: *"Figma 설계 구조도 이 기준으로 만들까요?"* 제안 — 상태 매트릭스(진행 단계별 상태 나열) + 일관된 프레임 네이밍(언더바 `U{n}_{유형}_{상태}_{코드}` 식) + 파생 케이스는 변경점 주석으로 대체(화면 미작화) + 같은 상태축 컴포넌트는 한 화면 통합.

## 메타데이터 헤더 (모든 와이어 공통)

```
{프로젝트} {제목}  [LO-FI]  [v{N}?]
{PRD 버전} ({날짜}) · {추가 메타}
[📄 PRD] [📋 기술요건] [🎨 Figma] [💬 Slack]   ← 입력된 링크만 칩으로 노출
{변경 노트 박스}                                  ← v2/v3일 때 자동 생성
```

문서 링크 칩은 `assets/component-library.css`의 `.doc-chip` 클래스 사용. 외부 새 탭(`target="_blank" rel="noopener"`).

## 컴포넌트 라이브러리 (요약)

전체 CSS·클래스 목록은 `assets/component-library.css` 참조. 항상 인라인 `<style>`로 박는다.

| 컴포넌트 | 클래스 | 용도 |
|---|---|---|
| 디바이스 프레임 | `.device` + `.statusbar` + `.screen` | 모바일 시안 컨테이너 |
| 상품 카드 | `.pcard` + `.thumb` + `.pbrand` + `.pname` + `.price` + `.add-btn` | 카루셀·그리드 안 |
| 카루셀 | `.carousel` + peek | 수평 스크롤 + 한 장 살짝 보임 |
| 모듈 헤더 | `.mod-head` + `.mod-hook` + `.mod-title` + `.mod-arrow` | 모듈 헤더 패턴 |
| 칩 | `.chip` + `.chip.on` | 브랜드 칩·필터 |
| 스낵바 | `.snackbar` + `.snackbar-cta` | 액션 후 피드백 |
| 주석 | `.anno` + `h3 .n` 식별자 | A1·A2·A3 |
| 라벨 pill | `.pill.new/.kept/.drop/.cf/.dec` | 내부 모드 전용 — 공유 모드에선 평문 |
| KV 다크 | `.kv` + `.kv-title` + `.kv-card` + `.kv-cta` | 상단 영역 |
| 스텝 | `.step` + `.step-num` + `.step-img` | 사용법 N단계 |
| 비교 매트릭스 | `.compare` (table) | 옵션 비교 표 |
| DIFF 매트릭스 | `.diff-table` (table) | 버전 비교 자동 생성 |
| Empty | `.empty-box` + `.empty-icon` + `.empty-actions` | 빈 상태 가이드 |
| 문서 링크 칩 | `.doc-chip` | 헤더 영역 외부 링크 |

CSS 변수는 항상 다음 토큰만 사용:
```css
--ink:#1f2225; --sub:#6b7177; --line:#d7dbe0; --line2:#e7eaee;
--bg:#f4f5f7; --card:#fff; --ph:#dde1e6; --ph2:#e9ecf0;
--chip:#eef0f3; --note:#f0f2f5;
--accent:#2f6fde; --accentBg:#eaf1fc;
--pink:#ff4d8a; --dark:#0d0e10;
--warn:#fdeecf; --warnInk:#7a5a08;
--good:#e8f3ec; --goodInk:#1f6b3a;
```

## 주석 시스템

- **식별자**: `A1` `A2` `A3` ... (`.anno` 안 `h3 .n`)
- **pill 라벨** — 모드에 따라:
  - **내부 모드**: `NEW` / `KEPT` / `DROP` / `CF` (Needs confirmation) / `DEC` (디자인 결정) / `CONFIRMED`
  - **공유 모드**: pill 라벨 다 빼고 평문으로 변환. *"PICK"*, *"DESIGN PICK"*, *"PD 판단으로 픽 요구"* 같은 내부 워크플로우 표현 절대 금지.

자세한 변환 룰은 `references/share-tone.md`.

## footnote 템플릿

모든 와이어 하단:
```
참고 자료: ...
SSOT: ...
미확정: ...
상품·가격·할인율·로고는 더미 데이터입니다.
```

공유 모드 푸시 시 자동 추가:
> *"공유용 — 민감 정보 마스킹됨. 카피·색·데이터 더미. 내부 SSOT와 다를 수 있음."*

## 저장 위치

- **로컬 모드 (기본)**: `~/Downloads/{project}-{topic}-{kind}{-v?}.html`
- **공유 모드**: 로컬 저장 그대로 + `lofi-wire-share` 레포(기본 **internal** — 사내 org 구성원만 접근) `wires/{project}/{filename}`로 푸시
  - 공유 URL: `https://{본인계정}.github.io/lofi-wire-share/wires/{project}/{filename}`

네이밍 규칙: `references/naming.md`.

## 공유 모드 — PD OK 받기 + 마스킹 + 푸시

매번 와이어 만든 직후 클로드가 자동으로:

> *"공유 링크로 올릴까요? (예: 동료에게 보내고 싶을 때)"*

PD가 OK 하면:
1. **자동 마스킹** — `references/masking-rules.md`의 카테고리별 규칙 적용
2. **수동 추가** — *"이것도 가려"* 발화로 추가 마스킹 가능
3. **미리보기** — `~/Downloads/{filename}.masked.html` 별도 저장 → PD가 직접 열어 확인
4. **컨펌** — PD *"OK 푸시"* 받으면 `scripts/push.sh` 호출 → 레포 푸시 → URL 반환

PD가 *공유 안 한다* 하면 그냥 로컬 파일 그대로. 강제하지 않음.

Rollback: PD *"방금 그거 내려"* 발화 → `scripts/unshare.sh {file}` 실행. `references/sharing.md`.

## 개인화 (선택)

이 스킬은 팀 공용이지만, 아래는 각자 셋업이 필요하거나 취향껏 켤 수 있는 부분:

- **공유 레포** — 각자 `lofi-wire-share`를 만든다 (팀 공용 레포 아님). 기본 가시성은 **internal**(사내 org 구성원만 접근)이며, org 아래 생성을 권장(`bash scripts/setup-repo.sh <org명>`). 사외 공유가 꼭 필요할 때만 `LOFI_SHARE_VISIBILITY=public`으로 명시적 옵트인하고, 그 전에 마스킹 커버리지(개인정보·내부 지표·실가격)를 한 번 더 점검한다.
- **마스킹 패턴** — `assets/masking-patterns.json`의 `internal_names`(팀 구성원 이름) / `internal_metrics` / `internal_codenames` / `real_prices_from_capture` 카테고리는 본인 프로젝트에 맞게 채워두면 자동 마스킹 정확도가 올라간다. 안 채워도 회사 공통 도메인·Jira 키·이메일 마스킹은 기본 동작.
- **톤 커스터마이즈** — 와이어 시각 스타일이나 카피 톤에 대한 개인 선호를 메모리·설정 파일로 관리하고 있다면 자동으로 함께 반영된다. 없어도 스킬 기본 룰만으로 정상 동작.

## 첫 사용 시 셋업 (한 번만, 계정별)

`lofi-wire-share` 레포가 없으면 첫 공유 모드 시도 시 자동 셋업 안내:

```bash
bash {스킬 폴더}/scripts/setup-repo.sh
```

`references/repo-setup.md` 참조. 셋업 한 번 끝나면 이후엔 그냥 푸시만.

## 빠른 참조

| 무엇을 | 어디 |
|---|---|
| 4가지 출력 모드 상세 | `references/output-modes.md` |
| 컴포넌트 CSS 풀 라이브러리 | `assets/component-library.css` |
| 마스킹 룰 + 정규식 | `references/masking-rules.md` + `assets/masking-patterns.json` |
| 데이터 모드 (더미/실측/캡처) | `references/data-modes.md` |
| 파일 네이밍 규칙 | `references/naming.md` |
| 버전 비교 자동화 | `references/versioning.md` |
| 공유 모드 워크플로우 | `references/sharing.md` |
| 레포 셋업 가이드 | `references/repo-setup.md` |
| 공유용 톤 변환 룰 | `references/share-tone.md` |
| 샘플 — N-State 비교 | `samples/v3-wireframe-state-compare.html` |
| 샘플 — 풀 페이지 | `samples/light-structure-fullpage.html` |
| 마스킹 스크립트 | `scripts/mask.py` |
| 푸시 스크립트 | `scripts/push.sh` |
| 언셰어 (롤백) | `scripts/unshare.sh` |
| 레포 셋업 (계정당 1회) | `scripts/setup-repo.sh` |

## 사용하지 않는 경우

- 단순 텍스트 답변·슬랙 메시지 작성 → 일반 응답
- 일반 코드 작성·디버깅 → 일반 응답
- 풀 디자인 시안(Figma 수준 디테일) → Figma에서 직접. 본 스킬은 *Lo-fi 합의용*에만.
