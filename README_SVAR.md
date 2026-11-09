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

## Oppgave 1B

Workflow: `.github/workflows/pipeline.yml`

Grønn kjøring: https://github.com/lilliantraan/pgr301-eksamen-2026/actions/runs/42622640901

ECR-repository: `wishifai-49`

Tagging-strategi: Tagger hvert image med både commit-SHA og "latest". "Latest" flyttes ved hver push, så den ikke alene sier hvilken kode som faktisk kjører. Med commit-SHA, kan jeg spore et image tilbake til nøyaktig den commiten i GitHun, og gå tilbake ved å deploye en eldre tag. Ulempen, er at det blir mange images i ECR over tid, så i et ekte prosjekt ville jeg satt opp autmatisk sletting av gamle images.
