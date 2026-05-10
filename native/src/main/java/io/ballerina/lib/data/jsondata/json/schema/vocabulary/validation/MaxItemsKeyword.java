package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BArray;

public class MaxItemsKeyword extends Keyword {
    public static final String KEYWORD_NAME = "maxItems";
    private final Long keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BArray array)) {
            return true;
        }
        boolean valid = array.size() <= keywordValue;
        if (!valid) {
            context.addError(
                    "maxItems",
                    "At " + context.getInstanceLocation() + ": [maxItems] array length " + array.size()
                            + " exceeds maximum " + keywordValue);
        }
        return valid;
    }

    public MaxItemsKeyword(Long keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Long getKeywordValue() {
        return keywordValue;
    }
}
