package no.pgr301.exam.service;

import no.pgr301.exam.metrics.WishlistMetrics;
import no.pgr301.exam.model.AnalyzeResponse;
import no.pgr301.exam.model.GiftAnalysis;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
public class WishlistService {

    private final S3Service s3;
    private final RekognitionService rekognition;
    private final BedrockService bedrock;
    private final WishlistMetrics metrics;

    public WishlistService(S3Service s3, RekognitionService rekognition,
                           BedrockService bedrock, WishlistMetrics metrics) {
        this.s3 = s3;
        this.rekognition = rekognition;
        this.bedrock = bedrock;
        this.metrics = metrics;
    }

    public AnalyzeResponse process(byte[] bytes, String filename, String contentType) {
        String s3Key = s3.upload(bytes, filename, contentType);
        List<String> labels = metrics.timeRekognition(() -> rekognition.detectLabels(bytes));
        GiftAnalysis analysis = metrics.timeBedrock(() -> bedrock.suggestGifts(labels));

        int suggestionCount = analysis.suggestions() == null ? 0 : analysis.suggestions().size();
        metrics.recordAnalysis(suggestionCount);

        return new AnalyzeResponse(
                s3Key,
                labels,
                analysis.roomAnalysis(),
                analysis.recipientProfile(),
                analysis.suggestions(),
                Instant.now().toString()
        );
    }
}