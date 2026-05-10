package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BMap;

public class MinPropertiesKeyword extends Keyword {
    public static final String KEYWORD_NAME = "minProperties";
    private final Long keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BMap bMap)) {
            return true;
        }
        long propertyCount = bMap.size();
        boolean valid = propertyCount >= keywordValue;
        if (!valid) {
            context.addError(
                    "minProperties",
                    "At " + context.getInstanceLocation() + ": [minProperties] object has " + propertyCount
                            + " properties, minimum required is " + keywordValue);
        }
        return valid;
    }

    public MinPropertiesKeyword(Long keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Long getKeywordValue() {
        return keywordValue;
    }
}
