from fastapi import FastAPI

app = FastAPI(title="test-cicd")


@app.get("/health")
def health():
    return {"status": "ok"}
