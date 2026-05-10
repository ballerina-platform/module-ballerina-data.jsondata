package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BString;

public class MaxLengthKeyword extends Keyword {
    public static final String KEYWORD_NAME = "maxLength";
    private final Long keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BString str)) {
            return true;
        }
        boolean valid = str.length() <= keywordValue;
        if (!valid) {
            context.addError(
                    "maxLength",
                    "At " + context.getInstanceLocation() + ": [maxLength] string length " + str.length()
                            + " exceeds maximum " + keywordValue);
        }
        return valid;
    }

    public MaxLengthKeyword(Long keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Long getKeywordValue() {
        return keywordValue;
    }
}
