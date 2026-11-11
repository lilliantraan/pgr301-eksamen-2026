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

Tagging-strategi: Tagger hvert image med både commit-SHA og "latest". "Latest" flyttes ved hver push, så den ikke alene sier hvilken kode som faktisk kjører. Med commit-SHA, kan jeg spore et image tilbake til nøyaktig den commiten i GitHub, og gå tilbake ved å deploye en eldre tag. Ulempen, er at det blir mange images i ECR over tid, så i et ekte prosjekt ville jeg satt opp automatisk sletting av gamle images.

## Oppgave 2A

Terraform-koden ligger i infra/.

Offentlig URL: https://wi-ecb34eb33cfb49f3b9d72039de9b66f0.ecs.eu-west-1.on.aws

Test:

    curl https://wi-ecb34eb33cfb49f3b9d72039de9b66f0.ecs.eu-west-1.on.aws/api/health
    curl -F "image=@samples/sample_image.png" https://wi-ecb34eb33cfb49f3b9d72039de9b66f0.ecs.eu-west-1.on.aws/api/analyze

## Oppgave 2B

State lagres i bucketen pgr301-terraform-state med nøkkelen wishifai/49/terraform.tfstate.

## Oppgave 2C

Grønn kjøring:  https://github.com/lilliantraan/pgr301-eksamen-2026/actions/runs/42718022909

Terraform-jobben kjører i rekkefølgen `fmt-check`, `init` og `apply`.fmt-check` og `validate` stopper pipelinen tidlig, dersom koden er feil formatert eller ugyldig, før noe endres i AWS. AWS-nøklene hentes fra GitHub secrets, på lik måte som i oppgave 1B. 

Jeg har satt `wait_for_steady_state = true`, slik at Terraform venter til den nye versjonen faktisk er oppe og fungerer. Uten dette, ville piplinen vært grønn selv om den nye containeren kræsjet. ECS express ruller ut med en ny canary-deploy, så den gamle versjonen fortsetter å svare brukere, til den nye har bestått helsesjekkene. Jeg så dette under utrullingen, der den gamle og nye versjonen kjørte samtidig. `concurrency` sørger for at to push rett etter hverandre ikke kjører `apply` mot den samme infrastrukturen samtidig.

En svakhet er at `apply` kjører med `-auto-approve`, uten at noen ser over endringene først. I et team, ville jeg latt `terraform plan` kjøre pull requests, slik at endringene blir vurdert før de merges og eventuelt krevd manuell godkjenning før produksjon. 

## Oppgave 3A
Grunderen opplevde at tjenesten responderte treigt, så første målet var å finne ut av hvor tiden blir av. Jeg la til en egen klasse, WishlistMetrics, som samler alle metrikkene på et sted istedenfor å spre dem utover forretningslogikken. Alle metrikkene publiseres til CloudWatch under namespace wishifai-49.

Timers for Rekognition og Bedrock (wishifai.rekognition og wishifai.bedrock.duration):
En request gjør tre kall etter hverandre: S3, Rekognition og Bedrock. Dersom jeg bare målte hele requesten, ville jeg visst at den er treg, men ikke hvorfor. Ved å måle Rekognition-kallet og Bedrock-kallet hver for seg, så ser jeg hvilket steg som er "the bottleneck". Da jeg testet lokalt, tok Rekognition i snitt 0,9 sekunder og Bedrock 14,2 sekunder, så det er tydelig at Bedrock bruker mest tid. Jeg brukte en Timer direkte istedenfor @Times, fordi @Timed krever ekstra oppsett (AOP), som prosjektet ikke har. En Timer registrrer antall, sum og maks. I tillegg, CloudWatch regner ut snittet fra disse, slik at jeg ser både vanlig og verst mulig responstid. 

Analyserte bilder (wishifai.images.analyzed, Counter):
Dette er en business-metrikk. Den viser hvor mye tjenesten faktisk brukes, ikke den tekniske tilstanden. Den øker bare når en analyse er fullført, så den teller reell verdi til brukerne. En Counter går bare oppover, så Sum per periode er riktig statistikk for den.

Gaveforslag per analyse (wishifai.suggestions.per.analysis, DistributionSummary):
Dette er min andre business-metrikk, og i motsetning til timerne, måler den innholdet i svarene, ikke responstiden. Bedrock er ikke-deterministisk , og kan gi dårlige svar uten at det oppstår noen feil: forespørselen returnerer fortsatt 200, men med færre eller ingen forslag. For eksempel, hvis svaret fra modellen ikke kan tolkes. Det som ville avslørt dette, er et fall i gjennomsnittlig antall forslag, selv om ingen feil blir logget. 
