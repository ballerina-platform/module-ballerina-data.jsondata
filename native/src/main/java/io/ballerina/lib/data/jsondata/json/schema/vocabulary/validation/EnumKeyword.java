package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.utils.JsonEqualityUtils;

import java.util.Set;

public class EnumKeyword extends Keyword {
    public static final String KEYWORD_NAME = "enum";
    private final Set<Object> keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        for (Object value : keywordValue) {
            if (JsonEqualityUtils.deepEquals(value, instance)) {
                return true;
            }
        }
        context.addError(
                "enum",
                "At " + context.getInstanceLocation() + ": [enum] value must be one of " + keywordValue
                        + " but found " + formatValue(instance));
        return false;
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

    public EnumKeyword(Set<Object> keywordValue) {
        this.keywordValue = keywordValue;
    }

    public Set<Object> getKeywordValue() {
        return keywordValue;
    }
}
