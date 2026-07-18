#!/bin/bash
# VPC-3의 nginx 시작 템플릿 (/company 경로의 company.html)

dnf update -y
dnf install nginx -y
systemctl start nginx
systemctl enable nginx

# 회사 소개용 경로 생성
mkdir -p /usr/share/nginx/html/company

# 한글 깨짐 방지
tee /etc/nginx/conf.d/charset.conf << 'EOF'
charset utf-8;
EOF

# 회사 소개 HTML 생성 (세련된 버전)
tee /usr/share/nginx/html/company/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Company Profile - Cloud Infrastructure</title>
    <style>
        :root { --primary-color: #4a90e2; --accent-color: #34c759; --dark-bg: #1e293b; }
        body {
            font-family: 'Pretendard', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #1e293b 0%, #334155 100%);
            color: #fff;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .card {
            background: rgba(255, 255, 255, 0.95);
            color: #333;
            padding: 50px 40px;
            border-radius: 24px;
            max-width: 500px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            backdrop-filter: blur(10px);
            transition: transform 0.3s ease;
        }
        .card:hover { transform: translateY(-5px); }
        .icon-circle {
            width: 80px; height: 80px;
            background: var(--primary-color);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 25px;
            font-size: 2.5rem;
            color: white;
            box-shadow: 0 8px 15px rgba(74, 144, 226, 0.3);
        }
        h1 { font-size: 2rem; margin-bottom: 10px; color: #1e293b; }
        .divider { width: 40px; height: 4px; background: var(--primary-color); margin: 20px auto; border-radius: 2px; }
        p { line-height: 1.7; color: #64748b; font-size: 1.1rem; }
        .status-badge {
            display: inline-block;
            background: #e2e8f0;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            color: #475569;
            margin-top: 15px;
        }
        .back-btn {
            margin-top: 35px;
            display: inline-block;
            text-decoration: none;
            color: #fff;
            background: var(--primary-color);
            padding: 12px 30px;
            border-radius: 12px;
            font-weight: bold;
            transition: all 0.2s;
            box-shadow: 0 4px 10px rgba(74, 144, 226, 0.2);
        }
        .back-btn:hover {
            background: #357abd;
            box-shadow: 0 6px 15px rgba(74, 144, 226, 0.4);
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon-circle">🏢</div>
        <h1>Company Profile</h1>
        <div class="divider"></div>
        <p><b>Cloud Multi-Stack</b>은 차세대 멀티 VPC 환경에서<br>최적화된 인프라 솔루션을 연구하고 제공합니다.</p>
        <div class="status-badge">현재 호스팅 지역: VPC 3 (Sapporo Region)</div>
        <br>
        <a href="/" class="back-btn">메인으로 돌아가기</a>
    </div>
</body>
</html>
EOF

sudo tee /etc/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    charset       utf-8; # 한글 안 깨지게 필수

    server {
        listen       80;
        server_name  _;

        # 1. 메인 (정적 파일 위치)
        location / {
            root   /usr/share/nginx/html;
            index  index.html;
        }

        # 2. 회사 소개 (도메인/company 접속 시)
        location /company {
            alias /usr/share/nginx/html/company;
            index index.html;
        }
    }
}
EOF
systemctl restart nginx
