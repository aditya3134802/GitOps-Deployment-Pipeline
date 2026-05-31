# ── Stage 1: Builder ─────────────────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /app

# Install dependencies into a separate layer for caching
COPY requirements.txt* ./
RUN pip install --upgrade pip && \
    if [ -f requirements.txt ]; then \
      pip install --prefix=/install -r requirements.txt; \
    else \
      echo "No requirements.txt — skipping"; \
    fi

# Copy application source
COPY . .

# ── Stage 2: Runtime (minimal, no build tools) ───────────────────────────────
FROM python:3.12-slim AS runtime

# Security: run as non-root user
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local
COPY --from=builder /app /app

# Set ownership
RUN chown -R appuser:appuser /app

USER appuser

# Default port — override with ENV if needed
EXPOSE 8000

# Health check — works for any HTTP app on port 8000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Default entrypoint — update this to match your app's entry point
CMD ["python", "-m", "app"]