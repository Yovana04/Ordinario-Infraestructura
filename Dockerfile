# ============================
# Stage 1: Builder – Install dependencies
# ============================
FROM python:3.11-slim AS builder

LABEL maintainer="tu_correo@ejemplo.com"
LABEL description="DogMatch Backend - Builder Stage (CI/CD con GHCR y Render)"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install build dependencies (compiladores, cliente MySQL, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    default-libmysqlclient-dev \
    pkg-config \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install Python deps in a virtualenv
COPY requirements.txt .
RUN python -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade pip && \
    /app/venv/bin/pip install --no-cache-dir -r requirements.txt


# ============================
# Stage 2: Runtime – Final image with app and gunicorn only
# ============================
FROM python:3.11-slim

LABEL maintainer="yovanas618@gmail.com"
LABEL description="DogMatch Backend - Production Runtime (Despliegue automático en Render)"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/venv/bin:$PATH" \
    PORT=8000

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy virtualenv and app code from builder
COPY --from=builder /app/venv /app/venv
COPY . .

# Expose port used by gunicorn
EXPOSE 8000

# ============================
# ============================
CMD ["gunicorn", "--config", "gunicorn.conf.py", "wsgi:app"]
