package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BArray;

public class MinItemsKeyword extends Keyword {
    public static final String KEYWORD_NAME = "minItems";
    private final Long keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BArray array)) {
            return true;
        }
        boolean valid = array.size() >= keywordValue;
        if (!valid) {
            context.addError(
                    "minItems",
                    "At " + context.getInstanceLocation() + ": [minItems] array length " + array.size()
                            + " is less than minimum " + keywordValue);
        }
        return valid;
    }

    public MinItemsKeyword(Long keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Long getKeywordValue() {
        return keywordValue;
    }
}
