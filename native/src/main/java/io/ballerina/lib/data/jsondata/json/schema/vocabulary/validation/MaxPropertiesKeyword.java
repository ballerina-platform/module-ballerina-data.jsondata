package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BMap;

public class MaxPropertiesKeyword extends Keyword {
    public static final String KEYWORD_NAME = "maxProperties";
    private final Long keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BMap bMap)) {
            return true;
        }
        long propertyCount = bMap.size();
        boolean valid = propertyCount <= keywordValue;
        if (!valid) {
            context.addError(
                    "maxProperties",
                    "At " + context.getInstanceLocation() + ": [maxProperties] object has " + propertyCount
                            + " properties, maximum allowed is " + keywordValue);
        }
        return valid;
    }

    public MaxPropertiesKeyword(Long keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Long getKeywordValue() {
        return keywordValue;
    }
}
