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
