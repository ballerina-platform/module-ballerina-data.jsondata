package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.utils.JsonEqualityUtils;

public class ConstKeyword extends Keyword {
    public static final String KEYWORD_NAME = "const";
    private final Object keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        boolean valid = JsonEqualityUtils.deepEquals(keywordValue, instance);
        if (!valid) {
            context.addError(
                    "const",
                    "At " + context.getInstanceLocation() + ": [const] value must equal "
                            + formatValue(keywordValue) + " but found " + formatValue(instance));
        }
        return valid;
    }

    private String formatValue(Object value) {
        if (value == null) {
            return "null";
        }
        if (value instanceof String) {
            return "\"" + value + "\"";
        }
        return String.valueOf(value);
    }

    public ConstKeyword(Object keywordValue) {
        this.keywordValue = keywordValue;
    }

    public Object getKeywordValue() {
        return keywordValue;
    }
}
