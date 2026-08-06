---
name: figma-frame-scaffold
description: 참고 Figma 파일의 프레임 구조 컴포넌트를 재사용해서 새 Figma 파일에 화면 골격(섹션·대주제 라벨·그룹 바·케이스 바·빈 프레임)을 만든다. 프레임 이름과 자리만 잡고 화면 내부는 비워둔다. "피그마에 프레임 만들어줘", "프레임 골격 잡아줘", "구조만 옮겨줘", "OO 파일 구조 그대로 새 파일에", "프레임 자리 잡아줘" 같은 요청에 사용. 실제 화면 UI를 그리는 작업이나 로컬 HTML 와이어(lofi-wire)에는 사용하지 않는다.
---

# Figma Frame Scaffold

이미 쓰고 있는 Figma 배치 체계를 새 파일에 그대로 깔아주는 스킬.
**프레임 이름과 자리만 잡는다. 화면 내부는 반드시 비워둔다.**

## 이 스킬이 하는 일과 안 하는 일

| 한다 | 안 한다 |
|---|---|
| 섹션, 대주제 라벨, 그룹 바, 케이스 바 생성 | 화면 내부 UI 작화 |
| 375×812 빈 프레임을 이름 붙여 배치 | 컴포넌트 신규 제작 |
| 참고 파일의 컴포넌트를 라이브러리 인스턴스로 연결 | 참고 파일 수정 |

내부를 채우는 건 사용자가 Figma에서 직접 한다. 이 스킬은 **자리만 만든다.**

## 안전 규칙 (어기면 안 됨)

1. **참고 파일은 읽기 전용.** `use_figma`를 참고 파일에 쓸 때는 조회와 `return`만. 생성·수정·삭제 코드를 절대 넣지 않는다.
2. **프레임 내부를 채우지 않는다.** 헤더, 텍스트, 버튼 스켈레톤 전부 금지. 빈 흰 프레임만 남긴다.
3. **원본 컴포넌트 스타일을 임의로 바꾸지 않는다.** 폰트 크기, 색, 패딩을 손대지 않는다. 폭 조절과 텍스트 교체까지만.
4. **대상 파일과 페이지를 먼저 확인받는다.** 파일 키와 노드 ID를 사용자에게 받아서 쓴다. 추측하지 않는다.
5. 작업 후 **반드시 `get_screenshot`으로 검증**하고 결과를 보여준다.

## 실행 순서

### STEP 1. 읽기 점검 (참고 파일 + 대상 파일 병렬)

`use_figma`로 **읽기 전용** 스크립트를 두 파일에 각각 보낸다. 한 메시지에 두 개를 같이 보낸다.

참고 파일에서 확인할 것:

```js
// 섹션 배경, 자식 구조
const sec = await figma.getNodeByIdAsync("SECTION_ID");
const secFill = sec.fills !== figma.mixed ? sec.fills : null;
const kids = sec.children.slice(0, 40).map(c => ({ id: c.id, name: c.name, type: c.type,
  x: Math.round(c.x), y: Math.round(c.y), w: Math.round(c.width), h: Math.round(c.height) }));
return { secFill, kids };
```

그 다음 바 컴포넌트의 **key와 variant 목록**을 뽑는다. `INSTANCE`를 하나 잡아서:

```js
const inst = await figma.getNodeByIdAsync("INSTANCE_ID");
const mc = await inst.getMainComponentAsync();
const set = mc.parent;
return { key: mc.key, name: mc.name, remote: mc.remote,
  variants: set.type === "COMPONENT_SET" ? set.children.map(c => ({ name: c.name, key: c.key })) : [] };
```

대상 파일에서 확인할 것: 페이지 목록, 대상 페이지의 기존 노드, 폰트 가용성, 그리고 **컴포넌트 임포트가 되는지**.

```js
try { const c = await figma.importComponentByKeyAsync("KEY"); }
catch (e) { /* 퍼블리시 안 됨 → 사용자에게 알리고 대안 협의 */ }
```

**임포트가 실패하면 멈추고 물어본다.** 컴포넌트를 새로 만들지 말 것.

### STEP 2. 섹션 + 라벨 + 바

한 번의 `use_figma`로 만든다. 아직 프레임은 만들지 않는다.

- **섹션**: 참고 파일과 같은 배경색. `figma.createSection()` + `resizeWithoutConstraints(w, h)`
- **대주제 라벨**: **`template` 컴포넌트 인스턴스를 쓴다.** 텍스트로 직접 만들지 않는다. 내부 TEXT 한 개의 `characters`만 `{번호} {이름}` 한 줄로 교체한다 (예: `01 PDP 진입`)
- **그룹 바 / 케이스 바**: `Title` 컴포넌트 인스턴스. `createInstance()` → `resize(w, 60)` → 내부 TEXT의 `characters`만 교체

#### 컴포넌트를 못 가져올 때

`importComponentByKeyAsync`가 `Component with key ... not found`로 실패하는 경우가 있다. 퍼블리시 상태나 라이브러리 접근 권한 문제다. 이때는 **새로 만들지 말고 순서대로 시도한다.**

1. 대상 파일에 해당 컴포넌트 **인스턴스가 이미 있으면 `clone()`** 한다. 마스터 연결이 그대로 유지된다
   ```js
   const src = await figma.getNodeByIdAsync("INSTANCE_ID");
   const inst = src.clone();
   sec.appendChild(inst);
   inst.x = x; inst.y = y; inst.resize(w, h);
   ```
2. 인스턴스도 없으면 **사용자에게 해당 컴포넌트를 대상 파일에 하나 붙여달라고 요청**한다. 그 인스턴스를 복제 원본으로 쓴다
3. 컴포넌트를 직접 만들어 흉내내지 않는다. 원본과 어긋나고 나중에 동기화도 안 된다

### STEP 3. 빈 프레임

프레임은 **비워서** 만든다.

```js
const f = figma.createFrame();
f.name = "1.1_PDP_기본";   // 프레임명이 곧 전달물
f.resize(375, 812);
f.x = x; f.y = y;
f.fills = [{ type: "SOLID", color: { r: 1, g: 1, b: 1 } }];
sec.appendChild(f);
```

`layoutMode`를 설정하지 않는다. 자식을 넣지 않는다.

### STEP 4. 검증

`get_screenshot`으로 섹션 전체를 찍어 사용자에게 보여준다. 배치가 어긋났으면 그 부분만 고친다.

## 배치 규칙

기존 과업 파일에서 실측한 체계. 참고 파일의 파일 키와 노드 ID는 **대화에서 받는다.**

```
[대주제 라벨]  [AS-IS(회색)]  [Primary 그룹 바 ─────────────────]
 00                            [Default 케이스 바] [케이스 바] ...
 공통 상태      기존 화면        빈 프레임           빈 프레임
```

- **가로 = 케이스 전개, 세로 = 대주제 전환**
- AS-IS 참조는 행 맨 왼쪽. 기존 화면을 쓰는 행에만 둔다
- 케이스가 많은 행은 가로로 길어진다. 그대로 둔다

### 좌표 기준값

**섹션 여백은 상하좌우 모두 200이다.** 콘텐츠를 다 배치한 뒤 마지막에 정규화한다.

| 요소 | 값 | 근거 |
|---|---|---|
| 섹션 여백 | **200** (상하좌우 동일) | 사용자 확정 |
| 대주제 라벨 | x = 200, 폭 375 (`template` 컴포넌트) | 컴포넌트 고정 폭 |
| **라벨 우측 간격** | **200** | 섹션 여백과 같은 리듬 |
| 콘텐츠 시작 x | **775** (200 + 375 + 200) | |
| 프레임 피치 | 560 (프레임 375 + 여백 185) | |
| 그룹 바 y | 행 기준선 | |
| 바 사이 간격 | **28** (케이스 바 y = 그룹 바 + 88) | 참고 파일 실측 |
| **바 → 프레임 간격** | **118** (프레임 y = 그룹 바 + 266) | 참고 파일 실측 중앙값 |
| 라벨 높이 | 그룹 바 top부터 프레임 bottom까지 = **1078** | |
| 행 사이 간격 | 200 (행 피치 **1278**) | 섹션 여백과 같은 리듬 |
| 프레임 | 375 × 812 | |
| 바 높이 | 60 | |

**세로 계산식** (행 기준선 `y0`):

```
그룹 바      y0
케이스 바    y0 + 88          (바 60 + 간격 28)
프레임       y0 + 266         (케이스 바 60 + 간격 118)
프레임 bottom y0 + 1078
다음 행      y0 + 1278        (행간 200)
```

**바와 프레임 간격을 118보다 좁히지 않는다.** Figma는 프레임 이름 라벨을 프레임 위쪽에 띄우는데, 간격이 좁으면 케이스 바에 가려서 안 보인다.

### 여백 정규화 (마지막에 반드시 실행)

배치가 끝나면 이 스크립트로 여백을 맞추고 섹션 크기를 다시 잡는다. 좌표를 손으로 계산하지 않는다.

```js
const sec = await figma.getNodeByIdAsync("SECTION_ID");
const PAD = 200;
const kids = sec.children;
let minX = Infinity, minY = Infinity;
for (const c of kids) { minX = Math.min(minX, c.x); minY = Math.min(minY, c.y); }
const dx = PAD - minX, dy = PAD - minY;
for (const c of kids) { c.x += dx; c.y += dy; }
let maxX = -Infinity, maxY = -Infinity;
for (const c of kids) { maxX = Math.max(maxX, c.x + c.width); maxY = Math.max(maxY, c.y + c.height); }
sec.resizeWithoutConstraints(Math.round(maxX + PAD), Math.round(maxY + PAD));
return { mutatedNodeIds: kids.map(c => c.id), section: { w: Math.round(maxX + PAD), h: Math.round(maxY + PAD) } };
```

행을 추가할 때마다 다시 돌리면 된다.

### 바 스타일

`Title` 컴포넌트는 variant를 고른 뒤 **fill을 덮어써서** 역할을 구분한다. 색 팔레트가 대상 파일에 참고용으로 깔려 있는 경우가 많으니 먼저 찾는다.

| 역할 | variant | fill | hex |
|---|---|---|---|
| AS-IS 바 | Default | 검정 | `#000000` |
| 케이스 바 (기본) | Primary | 회색 | `#828C94` |
| 그룹 바 | Primary | 보라 | `#4D49FC` |
| 조건 충족 | Primary | 파랑 | `#0079FA` |
| 최대 조건 충족 | Primary | 초록 | `#15B869` |

텍스트는 전부 흰색, Pretendard SemiBold 18.

### 바 텍스트 형식

| 종류 | 형식 | 예 |
|---|---|---|
| Primary (그룹) | `[과업명] {행번호} {대주제}` | `[과업명] 01 진입 화면` |
| Default (케이스) | 프레임명만 | `1.1_PDP_기본` |
| Default (AS-IS) | `AS-IS {화면명}` | `AS-IS PDP` |

가운뎃점, 긴 설명을 바 텍스트에 넣지 않는다. 바 텍스트는 프레임명과 **글자 하나까지 같게** 유지한다.

#### 이름은 스펙 문서에서 가져온다

프레임명을 짓기 전에 **스펙 문서의 해당 항목 제목을 먼저 읽는다.** 요약하거나 줄이지 말고 그 말을 쓴다.

| 층위 | 출처 | 지어내도 되나 |
|---|---|---|
| 스펙 번호 | 스펙 문서 그대로 | 절대 안 됨 |
| 화면명 | 스펙 항목 제목 | 안 됨 |
| 상태명 | 스펙에 대개 없음 | 만들되 아래 규칙 |

**스펙 번호는 재편된다.** 항목이 쪼개지거나 신설되면 뒷번호가 통째로 밀린다. 골격을 만든 뒤 원본이 갱신되면 **번호부터 대조한다** — 이름만 보면 안 틀린 것처럼 보인다.

대조 결과 스펙 문서 쪽 참조가 틀렸으면 고치지 말고 **작성자에게 알린다.** 스펙 문서가 SSOT다.

#### 상태 이름은 조어를 쓰지 않는다

프레임명의 `{상태}` 자리에 시스템어나 법률어를 넣으면 읽는 사람이 멈춘다. **화면에서 실제로 일어나는 일**로 쓴다.

| 쓰지 않는다 | 대신 |
|---|---|
| `체류중도과` (분석어 + 법률어) | `입력중만료` |
| `체류중변동` | `작성중변동` |
| `모듈해제` (시스템어) | `모듈전환` |
| `병존` (조어) | 결정 문구를 그대로 — 예: `패키지담기유지` |

**결정 문서에 문장이 있으면 그 표현을 가져온다.** 프레임명으로 결정을 검색할 수 있어야 추적이 된다.

### 프레임 네이밍

기존 과업에서 확정한 언더바 규칙을 따른다. 자세한 건 `~/.claude/memory/work/feedback/feedback_wireframe-style.md`.

```
00_스펙보드              페이지마다 하나, 최좌상단
1.4_주문서_기본          {스펙#}_{화면}_{상태}, 공백 없음
2.5_배송지_A             택1 비교안은 접미 _A _B _C
2.10_만료화면_TBD        미결은 접미 _TBD
1.7_공유_iOS             플랫폼 분기는 접미
StatusBadge/Wait         컴포넌트만 PascalCase + 슬래시
```

## 함정

`use_figma` 호출 전에 반드시 `figma-use` 스킬을 로드한다. 그 외 이 작업에서 실제로 밟은 것들:

- **`layoutSizingHorizontal = "FILL"`은 부모가 auto-layout일 때만 된다.** 부모를 먼저 auto-layout으로 만들고 `appendChild` 뒤에 설정한다. 이 스킬은 프레임을 비우므로 대부분 불필요하다
- **`use_figma`는 원자적이다.** 실패하면 아무것도 생성되지 않는다. 에러를 읽고 고친 뒤 다시 보낸다. 중복 생성 걱정은 없다
- **`figma.currentPage`는 호출마다 첫 페이지로 초기화된다.** 매 호출 시작에 `await figma.setCurrentPageAsync(page)`
- **텍스트를 건드리기 전에 그 노드의 현재 폰트를 로드한다.** `await figma.loadFontAsync(t.fontName)`. 하드코딩한 기본 폰트로 로드하면 실패한다
- **`get_metadata`는 큰 섹션에서 응답이 잘린다.** 노드가 많으면 `use_figma` 읽기 스크립트로 필요한 필드만 뽑는다
- **`importComponentByKeyAsync`는 키가 맞아도 실패할 수 있다.** 참고 파일에서 뽑은 키가 대상 파일에서 안 잡히면 퍼블리시·권한 문제다. 위 `컴포넌트를 못 가져올 때` 순서를 따른다
- **라벨 폭을 빼먹고 콘텐츠를 배치하면 겹친다.** `template`은 375 폭이다. 콘텐츠 시작 x를 775로 잡거나, 배치 후 여백 정규화로 밀어낸다
- **`setProperties`로 variant를 바꾸면 텍스트 오버라이드가 날아간다.** variant마다 텍스트 레이어 이름이 달라서 오버라이드가 매칭되지 않는다. **순서를 지킨다: variant 먼저, 텍스트 나중.** 이미 텍스트를 넣은 인스턴스의 variant를 바꿨다면 텍스트를 다시 넣어야 한다
- **fill을 덮어쓸 때 텍스트 색도 같이 확인한다.** 검정 fill에 어두운 기본 텍스트가 얹히면 안 보인다. 바 텍스트는 흰색으로 통일한다

## 연계

- **`lofi-wire`** — HTML 와이어를 먼저 만들고 그 구조를 Figma로 옮길 때 이 스킬로 넘어온다
- **`spec-policy-handoff`** — 프레임 골격이 서고 화면을 채운 뒤 주석 단계에서 사용
- 프레임 목록과 네이밍의 출처는 과업 프로젝트 폴더 (`~/agent-workspace/projects/<slug>/references.md`)

## 사용 예

```
"기존 A 파일 구조 그대로 새 B 파일에 00행이랑 01행 프레임 잡아줘"
→ 참고 파일 URL + 대상 파일 URL을 받는다
→ STEP 1 읽기 점검 (컴포넌트 키 확보, 임포트 가능 확인)
→ STEP 2 섹션·라벨·바
→ STEP 3 빈 프레임
→ STEP 4 스크린샷 보고
```
