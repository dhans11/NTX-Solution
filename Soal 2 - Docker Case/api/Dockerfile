# Gunakan `python:3.11.4` sebagai base image
FROM python:3.11.4

# Set kerja direktori ke /app
WORKDIR /app

# Salin file requirements.txt ke dalam kontainer
COPY requirements.txt .

# Install dependensi yang diperlukan
RUN pip install --no-cache-dir -r requirements.txt

# Salin seluruh isi folder api ke dalam kontainer di direktori /app
COPY . .

# Jalankan server FastAPI dengan uvicorn ketika kontainer berjalan
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "6000"]