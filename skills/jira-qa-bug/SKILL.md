---
name: jira-qa-bug
description: >
  오늘의집 PD가 QA/검수 단계에서 발견한 버그(디자인·정책·스펙·콘텐츠)를 Jira 티켓으로 발행하는 팀 공용 스킬.
  "QA 버그 등록", "버그 티켓 만들어", "디자인 리포팅 티켓", "지라 버그 티켓",
  "리포팅 티켓 발행" 같은 표현이 나오면 반드시 이 스킬을 사용할 것.
  COMMWEB·OHSIOS·OHSAND·CONTWEB 영역별 기본 프로젝트 매핑,
  라벨/Priority 디폴트, 본문 구조, 담당자 lookup, 발행 전 컨펌 워크플로우가 박제되어 있다.
  최초 사용 시 개인 셋업(주 프로젝트·도메인·담당자)을 자동 추론 또는 wizard로 진행한다.
---

# Jira QA Bug Report

오늘의집 PD가 QA/검수 단계에서 발견한 버그(디자인·정책·스펙·콘텐츠)를 Jira 티켓으로 등록할 때 사용하는 팀 공용 스킬.

---

## 0. 환경 상수

- `cloudId`: `0d334135-ec08-4c00-8411-7a081dce39ca` (ohouse.atlassian.net)
- 보고자: 현재 로그인된 Atlassian 계정 (자동)
- 개인 설정 저장 위치: `~/.claude/skill-prefs/jira-qa-bug.md`

---

## Step 0 — 개인 셋업 (하이브리드)

**스킬 진입 시 가장 먼저 수행.** 이미 셋업된 사용자는 자동으로 스킵된다.

### 0-1. 기존 설정 확인

```
Read ~/.claude/skill-prefs/jira-qa-bug.md
```

파일이 있고 유효한 값이 있으면 → 그대로 적용하고 **Step 1로 진행**.
파일이 없거나 비어있으면 → 0-2로 진입.

> 사용자가 "설정 다시", "프로젝트 바꿀래" 등을 명시하면 0-2 강제 실행.

### 0-2. 자동 추론 (먼저 시도)

본인의 최근 Jira 티켓을 조회해서 패턴 추출:

```jql
reporter = currentUser() ORDER BY created DESC
```

(최대 20개, fields: `summary, project, labels, components, assignee`)

추출 항목:
- **주 프로젝트** (가장 많이 등장한 프로젝트 키, 상위 2~3개)
- **주 도메인 라벨** (`Commerce`, `community`, `Content` 등)
- **주 담당자** (assignee 빈도 상위)
- **주 워크스트림** (제목의 `[xxx]` prefix 빈도)

추출 결과를 표로 보여주고:
```
이게 맞나요? 수정할 부분 알려주세요. OK면 저장합니다.
```

사용자 컨펌 후 0-4로.

### 0-3. Setup Wizard (자동 추론 실패 시 폴백)

티켓이 0개거나 매우 적으면(<3) 직접 묻는다:

1. 주로 작업하는 영역은? (커머스 / 콘텐츠 / iOS 앱 / Android 앱 / 기타)
2. 자주 쓰는 도메인 라벨은? (예: `Commerce`, `community`, `Content`, `댓글경험개선` 등)
3. 자주 핸드오프하는 개발자는? (이름 1~3명, 후에 lookup으로 ID 매핑)
4. 현재 진행 중인 워크스트림은? (제목 prefix용, 예: `글린다 온보딩`, `콘텐츠 개편`)

### 0-4. 설정 저장

`~/.claude/skill-prefs/jira-qa-bug.md` 에 다음 형식으로 저장:

```markdown
---
updated: YYYY-MM-DD
---

# Jira Design Bug — 개인 설정

## 주 프로젝트
- COMMWEB (또는 OHSIOS, OHSAND, CONTWEB 등)

## 주 도메인 라벨
- Commerce

## 주 담당자
- Woogi Shin (accountId: 63d3a56fce7f4b4e14fa7def)
- Ian Kim (accountId: ...)

## 주 워크스트림
- 글린다 온보딩
- 패키지할인
```

저장 완료 안내 후 Step 1 진행.

---

## Step 1 — 컨텍스트 파악

사용자가 줄 정보:
- 화면/캡처 (QA 환경 vs 디자인 비교)
- 작업명 (예: 글린다 온보딩, 콘텐츠 개편, 댓글 UI 개선)
- 실험군 구분 (A안/B안/C안) — 다변량 실험이면 명시
- 영향 플랫폼 (PC, Mobile, iOS, Android)
- 담당자 이름 (한글 별명 가능)
- 관련 에픽 키 (있다면)

부족한 정보는 개인 설정의 디폴트값을 우선 적용. 디폴트도 없으면 사용자에게 묻기.

---

## Step 2 — 프로젝트 자동 매핑

| 작업 영역 | 프로젝트 키 |
|---------|----------|
| 커머스 (글린다·장바구니·결제·쿠폰·상품 등) | `COMMWEB` |
| 콘텐츠/커뮤니티/CDP/리뷰 (웹) | `CONTWEB` |
| iOS 앱 QA | `OHSIOS` |
| Android 앱 QA | `OHSAND` |
| 기획·PRD·전략 에픽 (참고만) | `COMMPO` |

규칙:
- iOS/Android 동일 이슈는 양쪽 프로젝트에 각각 발행
- COMMWEB/CONTWEB은 PC와 Mobile Web을 한 티켓에 섹션 분리
- 영역이 모호하면 사용자에게 확인

---

## Step 2.5 — 에픽(parent) 라우팅: 티켓 종류로 구분

발행 대상 버그의 성격에 따라 parent 에픽을 다르게 건다.

| 티켓 종류 | parent 에픽 | 이유 |
|---------|-----------|------|
| QA 검증회차 기능 버그 | QA 에픽 (`QA-xxxxx`) | QA 라운드 결함 추적·집계 |
| 디자인 버그 / 로그 티켓 | 해당 **PO 에픽** | 제품 스코프·소유권이 PO에 있음, QA 결함 지표 오염 방지 |

규칙:
- 디자인/로그 버그는 QA 에픽 하위에 두지 않는다. PO 에픽 키는 개인 설정의 워크스트림 항목에서 로드.
- 디자인/로그 버그 발행 시:
  - Verifier = 리포터(PD 본인)
  - 라벨에서 `RC_BUG` 제거 (`RC_BUG`는 QA 검증회차 기능결함 마커)
  - 기존 QA Verifier가 있었다면 Watcher로 추가 (루프에서 빠지지 않게)

---

## Step 3 — 필드 디폴트

| 필드 | 기본값 |
|------|-------|
| issueTypeName | **`Bug`** (한국어 "버그"는 API 거부) |
| Priority | `P2` |
| 라벨 | 개인 설정의 도메인 라벨 + `RC_BUG` |
| RC 회차 라벨 (`RC1`~`RC10`) | 사용자가 회차 명시 시에만 추가 |

도메인 라벨 가이드:
- 커머스 영역 → `Commerce`
- 콘텐츠/커뮤니티 → `community` (소문자) 또는 `Content`
- 특정 프로젝트 라벨이 있으면 함께 (예: `댓글경험개선`, `C&C_Renewal`, `CDP인기글`)

### 워크스트림별 세부 필드 (개인 설정에서 로드)

`~/.claude/skill-prefs/jira-qa-bug.md`의 워크스트림 표에서 다음을 읽어와 발행 시 자동 적용:
| 필드 | API 경로 | 참고 |
|------|---------|------|
| Watcher 멤버 | `customfield_10036` | 배열, `{accountId}` 객체 |
| Verifier | `customfield_10045` | 단일 사용자 객체 `{accountId}` — 디폴트 + 그 주 가장 많이 태그된 분으로 교체 가능 |
| Fix Version | `fixVersions: [{id: "..."}]` | 현재 RC 회차 릴리스 버전 |
| Affects Version | `versions: [{id: "..."}]` | 동일 |
| Release Date | `customfield_10312` | `YYYY-MM-DD` |

워크스트림이 개인 설정에 없으면 사용자에게 확인 후 패턴 캡처.

---

## Step 4 — 담당자 lookup

이름이 한글 별명이거나 영문화 표기가 다양할 수 있으므로 **반드시 `lookupJiraAccountId` 호출**해서 후보 확인.

**자주 헷갈리는 사례** (반드시 사용자 확인):
- `우기` → `Woogi Shin` (NOT `Ugo Kwon`)
- 영문 이름이 비슷한 동명이인은 후보를 모두 보여주고 컨펌
- 한글로 입력된 이름은 영문/한글 양쪽 검색 시도

개인 설정에 이미 매핑된 담당자는 캐시된 accountId 사용.

---

## Step 5 — 제목 포맷

```
[작업명] (안 구분 >) 구체적 현상 + 요청
```

예시:
- `[글린다 온보딩] B안 > 패키지할인 카드 이미지에 패딩 임베드`
- `[댓글 UI 개선] Three dots 버튼 컬러 디자인과 동일하게 적용`
- `[Context Builder] 검색 결과 리스트 좌우 패딩 디자인과 상이`

자주 쓰는 표현: "디자인과 상이", "수정 필요", "조정 필요", "제거", "노출"

### 제목 prefix는 워크스트림마다 다름 — 반드시 확인

**원칙**: prefix는 워크스트림 단위로 별도. 사용자 약어(예: "콘탭")가 곧 티켓 prefix가 아니다.

**우선순위**:
1. 개인 설정(`~/.claude/skill-prefs/jira-qa-bug.md`)의 해당 워크스트림 행에 "제목 prefix"가 있으면 → **그대로 사용**
2. 없으면 → `searchJiraIssuesUsingJql`로 같은 라벨/에픽의 최근 티켓 제목을 조회해서 prefix 패턴 추출 → 사용자에게 컨펌 후 개인 설정에 박기

**예시 (워크스트림별로 완전히 다름)**:
- 콘탭 Context Builder → `[Context Builder]`
- 글린다 온보딩 → `[글린다 온보딩]`
- 댓글 UI 개선 → `[댓글 UI 개선]`
- 콘텐츠 개편(이전) → `[투탭][콘텐츠 개편]`

새 워크스트림 발행 시 prefix 학습 후 개인 설정 표에 추가하는 것이 필수.

---

## Step 6 — 본문 구조 (markdown)

```
## 현상
(어디서 어떤 현상이 발생하는지 구체적으로)

## 원인 추정
(있을 경우 — 이미지 패딩 임베드, CSS 클래스명, 토큰 누락 등)

---

### [PC]
- 디자인 스펙 (마진/패딩/컬러/폰트 값 등)
- 현재 상태
- 첨부: QA 환경 vs 디자인 비교 이미지

### [Mobile] (또는 iOS / Android)
- 디자인 스펙
- 현재 상태
- 첨부: QA 환경 vs 디자인 비교 이미지

## 기대 동작
(수정 후 어떻게 노출되어야 하는지)

## 관련 에픽
- COMMPO-XXXX (있다면)
```

규칙:
- 영향 없는 플랫폼은 `해당 없음 (정상 노출)` 명시
- PC와 Mobile 마진 값이 다르면 섹션 분리해서 각각 명시
- 마진/패딩 값은 `상 24 / 좌 24 / 우 24 / 하 28` 형식

---

## Step 6.5 — 중복 티켓 확인 (필수)

발행 초안 공유 직후, 같은 워크스트림에 비슷한 active 티켓이 있는지 자동 점검.

### 검색 방식
- 제목에서 핵심 명사 2~3개 추출 (예: `[Context Builder] 피드 중간 Search Pivot 칩 박스 높이...` → `Search Pivot`, `박스 높이`)
- JQL 예시:
  ```jql
  project = OHSIOS 
    AND labels = "ContextBuilde" 
    AND status not in (Verified, Duplicate, "Won't Fix", Closed, Fixed) 
    AND (summary ~ "Search Pivot" OR summary ~ "박스 높이")
  ORDER BY created DESC
  ```

### 결과 처리
- **0건** → Step 7 발행 컨펌 단계로 진행
- **1건 이상** → 사용자에게 매칭 티켓 표로 보여주기:
  - 티켓 키 (markdown 링크) / 제목 / 상태 / 담당자 / 생성일
  - "비슷한 티켓이 있어요. 어떻게 할까요?"
  - 옵션: ① 그대로 발행 (다른 이슈) / ② 발행 취소 / ③ 기존 티켓에 코멘트로 추가

## Step 7 — 발행 워크플로우

1. 정보 수집 (Step 1~4)
2. 개인 설정에서 해당 워크스트림 세부 필드 로드 (Watcher 멤버, Verifier, Fix/Affects Version)
3. **초안을 표 + 코드블록으로 공유**: 필드값 + Description 미리보기 (세부 필드도 포함)
4. **Step 6.5 중복 확인 자동 실행** — 매칭 있으면 사용자 판단 받기
5. 사용자에게 "이대로 발행할까요?" 컨펌 요청 — **컨펌 없이 발행 절대 금지**
6. OK 받으면 `createJiraIssue` 호출:
   - **에픽이 있으면 반드시 `parent: { key: "EPIC-KEY" }` 파라미터 함께 전달** (cross-project도 가능 — 확인됨)
   - `additional_fields`에 워크스트림 세부 필드 포함: `fixVersions`, `versions`, `customfield_10036` (Watcher 관련자 배열), `customfield_10045` (Verifier), `customfield_10312` (Release Date)
7. 발행 후 확인:
   - parent 필드가 비어있으면 `editJiraIssue`로 폴백 시도
8. 발행 후 안내:
   - 티켓 링크 (markdown 링크: `[KEY-XXX](https://ohouse.atlassian.net/browse/KEY-XXX)`)
   - 첨부 이미지는 사용자가 Jira UI에 직접 업로드
   - 누락된 필드 (Story Points, 담당 PO, 기한, accepted at) 입력 의사 확인

---

## Step 8 — 사용 도구

| 도구 | 용도 |
|-----|-----|
| `atlassianUserInfo` | 현재 사용자 확인 |
| `getJiraIssue` | 에픽/유관 티켓 컨텍스트 |
| `lookupJiraAccountId` | 담당자 ID 조회 |
| `searchJiraIssuesUsingJql` | 유사 티켓·기존 패턴 검색, 개인 셋업 추론 |
| `createJiraIssue` | 티켓 발행 (`issueTypeName="Bug"`) |
| `editJiraIssue` | 발행 후 추가 필드 채우기 |

---

## Step 9 — 주의사항

- `issueTypeName`은 반드시 **영문 `Bug`**, 한국어 "버그" 거부됨
- `additional_fields`에 `{"priority": {"name": "P2"}, "labels": [...]}` 형식으로 전달
- **에픽 연결은 `parent: { key: "EPIC-KEY" }`로 자동 처리** — cross-project도 정상 동작 확인됨 (OHSIOS↔CONTPL, COMMWEB↔COMMPO 검증)
- 첨부 이미지는 API 업로드 시도 안 함 (Claude Code 환경에서 멀티모달 이미지의 파일 경로 접근 불가, 사용자 직접 업로드가 빠르고 안정적)
- 같은 이슈가 여러 RC 회차에서 발견되면 라벨에 회차 누적 (예: `RC1`, `RC2`, `RC5`)
- 개인 설정 파일(`~/.claude/skill-prefs/jira-qa-bug.md`)은 git에 올리지 않음
