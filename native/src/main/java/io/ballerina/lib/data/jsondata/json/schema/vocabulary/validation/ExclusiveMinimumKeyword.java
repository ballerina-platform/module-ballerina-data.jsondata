package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BDecimal;

import java.math.BigDecimal;

public class ExclusiveMinimumKeyword extends Keyword {
    public static final String KEYWORD_NAME = "exclusiveMinimum";
    private final BigDecimal keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        boolean valid = true;
        BigDecimal exclusiveMin = keywordValue;
        if (instance instanceof Double d) {
            valid = BigDecimal.valueOf(d).compareTo(exclusiveMin) > 0;
        } else if (instance instanceof Long l) {
            valid = BigDecimal.valueOf(l).compareTo(exclusiveMin) > 0;
        } else if (instance instanceof BDecimal bd) {
            valid = bd.decimalValue().compareTo(exclusiveMin) > 0;
        }
        if (!valid) {
            context.addError(
                    "exclusiveMinimum",
                    "At " + context.getInstanceLocation() + ": [exclusiveMinimum] value " + instance
                            + " must be greater than " + keywordValue);
        }
        return valid;
    }

    public ExclusiveMinimumKeyword(Double keywordValue) {
        this.keywordValue = BigDecimal.valueOf(keywordValue);
    }

    public Object getKeywordValue() {
        return keywordValue;
    }
}
