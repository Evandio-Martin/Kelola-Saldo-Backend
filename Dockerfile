FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput --clear

# Create non-root user for Hugging Face
RUN useradd -m -u 1000 user
USER user

ENV HOME=/home/user
ENV PATH=/home/user/.local/bin:$PATH

# Hugging Face uses dynamic port
EXPOSE $PORT

CMD ["sh", "-c", "gunicorn capstone.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 120 --keep-alive 5"]