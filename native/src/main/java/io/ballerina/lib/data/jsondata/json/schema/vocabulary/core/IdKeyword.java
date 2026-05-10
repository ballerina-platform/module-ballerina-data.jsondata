package io.ballerina.lib.data.jsondata.json.schema.vocabulary.core;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;

import java.net.URI;

public class IdKeyword extends Keyword {
    public static final String KEYWORD_NAME = "$id";
    private final URI keywordValue;


    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        return true;
    }

    public IdKeyword(URI keywordValue) {
        this.keywordValue = keywordValue;
    }

    public URI getKeywordValue() {
        return keywordValue;
    }

}
