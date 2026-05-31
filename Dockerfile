FROM python:3.12-slim

RUN useradd --create-home appuser

WORKDIR /app

COPY . .

RUN pip install --upgrade pip && if [ -f requirements.txt ]; then pip install -r requirements.txt; else echo "No requirements.txt"; fi

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

CMD ["python", "-m", "app"]
