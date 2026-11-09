# PGR301 Eksamen 2026 - Besvarelse

## Oppgave 1A

Bygg og start containeren:

    docker build -t wishifai .
    docker run --rm -p 9999:8080 \
      -e AWS_ACCESS_KEY_ID=<din-nøkkel> \
      -e AWS_SECRET_ACCESS_KEY=<din-hemmelighet> \
      -e S3_BUCKET=<bucket-navn> \
      wishifai

Test:

    curl http://localhost:9999/api/health
    curl -F "image=@samples/sample_image.png" http://localhost:9999/api/analyze
