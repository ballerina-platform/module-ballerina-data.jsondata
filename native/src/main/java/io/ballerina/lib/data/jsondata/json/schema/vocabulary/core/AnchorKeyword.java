package io.ballerina.lib.data.jsondata.json.schema.vocabulary.core;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;

public class AnchorKeyword extends Keyword {
    public static final String KEYWORD_NAME = "$anchor";
    private final Object keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        return true;
    }

    public AnchorKeyword(Object keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Object getKeywordValue() {
        return keywordValue;
    }
}
