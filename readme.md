# Access Log Size Checker

Linux 서버의 access log 파일 크기를 확인하고,
일자별 로그 사용량을 CSV 파일로 저장하는 Bash 스크립트입니다.

## 📌 Features

- 날짜별 access log 파일 탐색
- 각 로그 파일의 크기(Byte) 확인
- 로그 파일 크기 합산
- 서버별 결과 CSV 저장
- 월 단위 CSV 파일 관리

## 📁 Project Structure

```text
access_log_size/
├── README.md
├── .gitignore
└── scripts/
    ├── access_size_check.sh
    └── readme.txt
```

## ⚙️ Environment

- Linux
- Bash
- GNU coreutils

## 🚀 Usage

스크립트에 실행 권한을 부여합니다.

```bash
chmod +x scripts/access_size_check.sh
```

스크립트를 실행합니다.

```bash
./scripts/access_size_check.sh
```

## 🔧 Configuration

사용 환경에 맞게 아래 경로를 수정합니다.

```bash
LOG_DIR="/path/to/log"
SAVE_DIR="/path/to/output"
```

- `LOG_DIR`: access log 파일이 저장된 경로
- `SAVE_DIR`: 결과 CSV를 저장할 경로

## 📊 Output

실행 결과는 월별 CSV 파일로 저장됩니다.

예시:

```text
202609_server01.csv
```

CSV에는 날짜와 access log 사용량 등의 정보가 기록됩니다.

## 🔄 Process

```mermaid
flowchart LR
    A[Access Log] --> B[파일 크기 확인]
    B --> C[크기 합산]
    C --> D[CSV 생성]
    D --> E[월별 결과 저장]
```

## 📝 Notes

서버 환경에 따라 로그 파일명과 저장 경로가 다를 수 있으므로
스크립트의 설정값을 환경에 맞게 수정해야 합니다.

## Author

GitHub: [prisma77](https://github.com/prisma77)