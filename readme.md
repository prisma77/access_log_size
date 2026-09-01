# Access Log Size Check

Linux 서버의 일별 Access Log 용량을 계산하여
월별 CSV 파일로 기록하는 Bash 스크립트입니다.

## Features

- 당일 Access Log 파일 탐색
- 로그 파일 크기 합산
- Byte → MiB 변환
- 서버별 월간 CSV 파일 생성
- 날짜별 로그 사용량 누적 기록
- 매년 1월 1일 전년도 CSV 자동 삭제

## Log Files

스크립트는 아래 파일을 대상으로 용량을 계산합니다.

```text
access.YYYYMMDD-*
access
```

## Output

결과는 다음 형식의 CSV 파일로 저장됩니다.

```text
YYMM_hostname.csv
```

예시:

```csv
DATE,SIZE_MB
260901,10000
260902,500
```

## Configuration

환경에 맞게 다음 경로를 수정합니다.

```bash
LOG_DIR="/LDAP/log"
SAVE_DIR="/LDAP/size"
```

- `LOG_DIR`: Access Log 디렉터리
- `SAVE_DIR`: CSV 결과 저장 디렉터리

## Usage

실행 권한을 부여합니다.

```bash
chmod +x access_size_check.sh
```

실행:

```bash
./access_size_check.sh
```

## Cron

매일 23:59에 실행하는 경우:

```cron
59 23 * * * /LDAP/access_size_check.sh
```

## Process

```text
Access Log 탐색
      ↓
파일 크기 합산
      ↓
MiB 변환
      ↓
월별 CSV 기록
      ↓
전년도 CSV 정리 (1월 1일)
```