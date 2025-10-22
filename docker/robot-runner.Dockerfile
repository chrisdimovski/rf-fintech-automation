# syntax=docker/dockerfile:1.7

FROM python:3.11-slim AS base

ENV POETRY_VIRTUALENVS_CREATE=false \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PLAYWRIGHT_BROWSERS_PATH=/opt/.playwright \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

WORKDIR /opt/project

# Install system deps + Node.js for Playwright / robotframework-browser
RUN apt-get update && apt-get install -y --no-install-recommends \
        wget gnupg ca-certificates curl \
        xvfb libnss3 libgtk-3-0 libxkbfile1 libxcomposite1 libxdamage1 \
        libxrandr2 libgbm1 libasound2 fonts-liberation libpango-1.0-0 \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@latest \
    && apt-get purge -y curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt ./requirements.txt
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && PLAYWRIGHT_BROWSERS_PATH=${PLAYWRIGHT_BROWSERS_PATH} rfbrowser init chromium \
    && rm -rf /root/.cache/pip

# Provide a non-root user for CI safety
RUN useradd -ms /bin/bash robot
USER robot
ENV PATH="/home/robot/.local/bin:${PATH}"

COPY --chown=robot:robot . /opt/project

ENTRYPOINT ["bash"]
