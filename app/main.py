import json
import time
from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/generate-sale")
def generate_sale(item_id: str = "ABC", amount: float = 99.99):
    # This structure matches the BigQuery schema
    log_entry = {
        "event": "sale",
        "timestamp": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
        "item_id": item_id,
        "amount": amount
    }
    # Cloud Run captures print() as a structured log if it's valid JSON
    print(json.dumps(log_entry))
    return {"status": "success", "data": log_entry}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)