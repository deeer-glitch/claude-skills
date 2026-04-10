# AI Skill

오늘의집 PD팀 공용 Claude 스킬 모음입니다.

## 스킬 목록

### state-verifier
디자인 단계에서 UI 상태 누락과 엣지케이스를 자동 탐지하는 스킬.

**트리거**: `상태 체크해줘` / `엣지케이스 뽑아줘` / `QA 전 체크`

### spec-policy-handoff
Figma 화면 구조를 읽고 개발 핸드오프용 주석 초안을 생성하는 스킬.

**트리거**: `주석 써줘` / `핸드오프 주석` / `spec 달아줘`

## 사용 순서

```
state-verifier → Figma 보완 → spec-policy-handoff
```

## 설치

각 스킬 폴더를 Claude Code의 skills 디렉토리에 복사하세요.

## 문의 및 개선 제안

Issues에 남겨주세요.
