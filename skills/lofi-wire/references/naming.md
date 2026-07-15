# File & Component Naming

## 파일명 규칙

```
{project}-{topic}-{kind}{-v?}.html
```

| 부분 | 설명 | 예시 |
|---|---|---|
| `{project}` | 프로젝트 슬러그 (kebab-case) | `onboarding-revamp`, `contents-tab`, `cms` |
| `{topic}` | 무엇에 대한 와이어인지 | `onboarding-brand-curation-plp`, `onboarding-light-structure`, `opt2-logo-carousel` |
| `{kind}` | 출력 모드 시그니처 | `wireframe`, `compare`, `explain`, `fullpage` |
| `{-v?}` | 버전 (v2/v3 등) — v1은 생략 | `-v2`, `-v3` |

### 예시

| 파일명 | 모드 | 의미 |
|---|---|---|
| `onboarding-revamp-brand-curation-plp-wireframe-v3.html` | State 비교 v3 | 온보딩 큐레이션 와이어 3번째 |
| `onboarding-revamp-light-structure.html` | 풀 페이지 v1 | 온보딩 라이트 구조 |
| `onboarding-revamp-opt2-logo-carousel-compare.html` | 컴포넌트 비교 | 옵션 2 로고 카루셀 비교 |
| `onboarding-revamp-u1-u2-explain.html` | 메타포 설명 | 정책 차이 그림 설명 |

### 자동 버전 +1

기존 파일이 있으면 같은 `{project}-{topic}-{kind}` prefix로 검색 → 최고 버전 +1.

```
~/Downloads/onboarding-revamp-brand-curation-plp-wireframe-v3.html  → 다음은 v4
~/Downloads/onboarding-revamp-light-structure.html                  → 다음은 v2
```

## 공유 레포 경로

```
lofi-wire-share/wires/{project}/{filename}.html
```

→ 디렉토리 분리로 프로젝트별 검색·관리 쉬움.

## Figma 컴포넌트 네이밍 추천 (PascalCase)

와이어 만들면 후속 액션으로 *"Figma에선 이렇게 부르는 게 좋아요"* 추천. 실제 컴포넌트 작업과 일관성 위함.

| 와이어 영역 | Figma 컴포넌트 추천명 |
|---|---|
| `.kv` | `KVHero` (전체) / `KVTitle` (카피) / `KVPackageCard` (사회적 증거 카드) |
| `.pcard` | `BundleProductCard` (BUNDLE 모드) / `ProductCard` (일반) |
| `.mod-head` | `BundleModuleHeader` / `ModuleHeader` |
| `.carousel` | `ProductCarousel` (수평 스크롤) |
| `.chip` | `BrandTextChip` (텍스트) / `BrandLogoChip` (로고 with 이미지) |
| `.snackbar` | `Snackbar` / `PackageAddSnackbar` |
| `.step` | `OnboardingStep` (사용법 N단계) |
| `.brand-logo` row | `BrandLogoRow` |
| `.empty-box` | `PackageEmptyState` |

### Variant 가이드

```
BundleModuleHeader
├ / Hook + Title + Logo + Arrow     (Full)
├ / Hook + Title + Arrow            (No Logo)
├ / Title + Arrow                   (Minimal)
└ / No Header
```

```
BundleProductCard
├ / Default
├ / Added                           (이미 담긴 상태, 버튼 비활성)
└ / Sold Out                        (품절)
```

## 프로젝트 슬러그 매핑

`{project}` 슬러그는 각자 쓰는 프로젝트 관리 방식에 맞춰 정한다. `CLAUDE.md`나 개인 프로젝트 워크스페이스에 프로젝트명 ↔ 슬러그 매핑 표가 있다면 그걸 그대로 재사용 — 매번 물어보지 않아도 되게. 없으면 진행 중인 프로젝트/기능명을 kebab-case로 줄여서 새로 정하면 된다 (예: 온보딩 개편 → `onboarding-revamp`).
