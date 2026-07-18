#!/bin/bash
# VPC-1의 FASTAPI 시작템플릿 userdata (게시판 /board)
# 참고: main.py, fastapi.service는 이 폴더에 별도 파일로도 분리되어 있음.
#       실제 EC2 시작 템플릿에서는 아래처럼 tee로 파일을 직접 생성함.

# 1. 시스템 업데이트 및 필수 패키지 설치
dnf update -y
dnf install python3-pip -y
pip install fastapi uvicorn jinja2 pymysql
pip3 install boto3

# 2. 앱 디렉토리 생성 및 권한 설정
mkdir -p /home/ec2-user/app

# 3. FastAPI 소스 코드 생성 (tee 사용)
tee /home/ec2-user/app/main.py <<EOF
from fastapi import FastAPI
import pymysql
import boto3
import json

app = FastAPI()

# AWS 설정 (본인 환경에 맞는지 확인)
secret_name = "std5-vpc2-multli-mysql"
region_name = "ap-south-1"

def get_db():
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    res = client.get_secret_value(SecretId=secret_name)
    secrets = json.loads(res['SecretString'])

    return pymysql.connect(
        host='std5-vp2-db-mysql.cluster-czeisiaqybrb.ap-south-1.rds.amazonaws.com',
        user=secrets['username'],
        password=secrets['password'],
        db='std5-db-mysql',
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor  # 딕셔너리 형태로 출력!
    )

@app.get("/board")
async def board():
    conn = get_db()
    try:
        with conn.cursor() as cursor:
            sql = "SELECT id, title, content, created_at FROM board ORDER BY id DESC"
            cursor.execute(sql)
            return {"status": "success", "data": cursor.fetchall()}
    finally:
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

# 4. Systemd 서비스 파일 생성 (tee 사용)
tee /etc/systemd/system/fastapi.service <<EOF
[Unit]
Description=FastAPI Application
After=network.target

[Service]
User=ec2-user
Group=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/main.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 5. 서비스 리로드 및 시작
systemctl daemon-reload
systemctl enable fastapi
systemctl start fastapi
