#!/bin/bash
# VPC-1의 nginx 시작 템플릿 (/ 경로의 index.html)

dnf update -y
dnf install nginx -y
systemctl start nginx
systemctl enable nginx

# 한글 깨짐 방지
tee /etc/nginx/conf.d/charset.conf << 'EOF'
charset utf-8;
EOF

# 메인 인덱스 파일 생성
tee /usr/share/nginx/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cloud Multi-Stack Portal</title>
    <style>
        :root { --primary-color: #4a90e2; --secondary-color: #34c759; --bg-color: #f8f9fa; --text-color: #333; --border-radius: 12px; }
        body { font-family: 'Pretendard', sans-serif; background-color: var(--bg-color); color: var(--text-color); margin: 0; padding: 40px 20px; display: flex; flex-direction: column; align-items: center; }
        .container { width: 100%; max-width: 900px; background: white; padding: 30px; border-radius: var(--border-radius); box-shadow: 0 10px 25px rgba(0,0,0,0.05); margin-bottom: 30px; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 15px; width:100%; max-width:900px; }
        h1 { font-size: 1.5rem; color: #2c3e50; margin: 0; }
        h2 { font-size: 1.2rem; color: var(--primary-color); margin-top: 0; }
        .btn { padding: 10px 20px; border-radius: 8px; border: none; cursor: pointer; font-weight: 600; text-decoration: none; font-size: 0.9rem; background-color: #2c3e50; color: white; transition: 0.2s; }
        .btn:hover { background-color: #1a252f; transform: translateY(-2px); }
        table { width: 100%; border-collapse: separate; border-spacing: 0; margin-top: 10px; }
        th { background-color: #fcfcfc; color: #888; font-size: 0.8rem; padding: 12px; border-bottom: 2px solid #f1f1f1; text-align: left; }
        td { padding: 12px; border-bottom: 1px solid #f1f1f1; font-size: 0.9rem; }
        tr:hover td { background-color: #f9fbff; }
        .empty-state { text-align: center; padding: 30px 0; color: #999; font-size: 0.9rem; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Cloud Multi-Stack Portal</h1>
        <a href="/company" class="btn">회사 소개 (VPC 3)</a>
    </div>

    <div class="container">
        <h2>📋 실시간 게시판 (VPC 1 - board 테이블)</h2>
        <table>
            <thead><tr><th>ID</th><th>제목</th><th>내용</th></tr></thead>
            <tbody id="board-list">
                <tr><td colspan="3" class="empty-state">데이터를 불러오는 중...</td></tr>
            </tbody>
        </table>
    </div>

    <div class="container">
        <h2>✍️ 최근 방명록 (VPC 3 - guest 테이블)</h2>
        <table>
            <thead><tr><th>번호</th><th>작성자</th><th>메시지</th></tr></thead>
            <tbody id="guest-list">
                <tr><td colspan="3" class="empty-state">데이터를 불러오는 중...</td></tr>
            </tbody>
        </table>
    </div>

    <script>
        const API_BASE = `${window.location.protocol}//${window.location.hostname}`;

        async function fetchData(path, elementId, templateFunc) {
            try {
                const res = await fetch(`${API_BASE}${path}`);
                const json = await res.json();
                const data = json.data;

                const container = document.getElementById(elementId);
                container.innerHTML = data.length ? data.map(templateFunc).join('') : '<tr><td colspan="10" class="empty-state">데이터가 없습니다.</td></tr>';
            } catch (e) {
                document.getElementById(elementId).innerHTML = `<tr><td colspan="10" class="empty-state" style="color:red;">연결 실패 (${path})</td></tr>`;
            }
        }

        window.onload = () => {
            // 게시판: id, title, content 매칭
            fetchData('/board', 'board-list', item =>
                `<tr><td>#${item.id}</td><td>${item.title}</td><td>${item.content}</td></tr>`
            );

            // 방명록: idx, user_name, content 매칭 (사용자님 DB 기준)
            fetchData('/guest', 'guest-list', item =>
                `<tr><td>${item.idx}</td><td><b>${item.user_name}</b></td><td>${item.content}</td></tr>`
            );
        };
    </script>
</body>
</html>
EOF
systemctl restart nginx
