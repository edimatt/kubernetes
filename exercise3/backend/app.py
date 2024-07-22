from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class DataResponse(BaseModel):
    message: str

@app.get("/api/data", response_model=DataResponse)
async def get_data():
    return DataResponse(message="Hello from FastAPI backend")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=80)

