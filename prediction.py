from fastapi import FastAPI
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import joblib
import numpy as np

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the best model
model = joblib.load("API/best_crime_model.pkl")

# Define input schema with realistic ranges (adjust as needed)
class CrimeInput(BaseModel):
    OffenderStatus: int = Field(..., ge=0, le=10, description="Encoded Offender Status", example=0)
    Offender_Race: int = Field(..., ge=0, le=10, description="Encoded Offender Race", example=4)
    Offender_Gender: int = Field(..., ge=0, le=10, description="Encoded Offender Gender", example=1)
    Offender_Age: float = Field(..., ge=-3, le=5, description="Standardized Offender Age", example=-0.91)
    Victim_Race: int = Field(..., ge=0, le=10, description="Encoded Victim Race", example=4)
    Victim_Gender: int = Field(..., ge=0, le=10, description="Encoded Victim Gender", example=1)
    Victim_Age: float = Field(..., ge=-3, le=5, description="Standardized Victim Age", example=0.03)
    Category: int = Field(..., ge=0, le=10, description="Encoded Crime Category", example=5)

@app.post("/predict")
def predict(input: CrimeInput):
    import pandas as pd
    features = pd.DataFrame([{
        "OffenderStatus": input.OffenderStatus,
        "Offender_Race": input.Offender_Race,
        "Offender_Gender": input.Offender_Gender,
        "Offender_Age": input.Offender_Age,
        "Victim_Race": input.Victim_Race,
        "Victim_Gender": input.Victim_Gender,
        "Victim_Age": input.Victim_Age,
        "Category": input.Category
    }])
    pred = model.predict(features)[0]
    explanation = (
        "1 means the crime is predicted to be fatal. 0 means non-fatal. "
        f"This value is a probability estimate; values close to 1 indicate higher fatality risk, values close to 0 indicate lower risk."
    )
    return {"prediction": float(pred), "explanation": explanation}
