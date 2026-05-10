package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BString;

public class MinLengthKeyword extends Keyword {
    public static final String KEYWORD_NAME = "minLength";
    private final Long keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BString str)) {
            return true;
        }
        boolean valid = str.length() >= keywordValue;
        if (!valid) {
            context.addError(
                    "minLength",
                    "At " + context.getInstanceLocation() + ": [minLength] string length " + str.length()
                            + " is less than minimum " + keywordValue);
        }
        return valid;
    }

    public MinLengthKeyword(Long keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Long getKeywordValue() {
        return keywordValue;
    }
}
