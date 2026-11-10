package no.pgr301.exam.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.stereotype.Component;

import java.util.function.Supplier;

@Component
public class WishlistMetrics {

    private final Timer rekognitionTimer;
    private final Timer bedrockTimer;
    private final Counter imagesAnalyzed;
    private final DistributionSummary suggestionsPerAnalysis;

    public WishlistMetrics(MeterRegistry registry) {
        this.rekognitionTimer = Timer.builder("wishifai.rekognition.duration")
                .description("Tid brukt på kall til AWS Rekognition")
                .register(registry);

        this.bedrockTimer = Timer.builder("wishifai.bedrock.duration")
                .description("Tid brukt på kall til AWS Bedrock")
                .register(registry);

        this.imagesAnalyzed = Counter.builder("wishifai.images.analyzed")
                .description("Antall bilder som er ferdig analysert")
                .register(registry);

        this.suggestionsPerAnalysis = DistributionSummary.builder("wishifai.suggestions.per.analysis")
                .description("Antall gaveforslag Bedrock returnerer per bilde")
                .register(registry);
    }

    public <T> T timeRekognition(Supplier<T> call) {
        return rekognitionTimer.record(call);
    }

    public <T> T timeBedrock(Supplier<T> call) {
        return bedrockTimer.record(call);
    }

    public void recordAnalysis(int suggestionCount) {
        imagesAnalyzed.increment();
        suggestionsPerAnalysis.record(suggestionCount);
    }
}
