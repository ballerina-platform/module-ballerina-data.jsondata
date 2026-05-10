package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BDecimal;

import java.math.BigDecimal;

public class ExclusiveMaximumKeyword extends Keyword {
    public static final String KEYWORD_NAME = "exclusiveMaximum";
    private final BigDecimal keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        boolean valid = true;
        BigDecimal exclusiveMax = keywordValue;
        if (instance instanceof Double d) {
            valid = BigDecimal.valueOf(d).compareTo(exclusiveMax) < 0;
        } else if (instance instanceof Long l) {
            valid = BigDecimal.valueOf(l).compareTo(exclusiveMax) < 0;
        } else if (instance instanceof BDecimal bd) {
            valid = bd.decimalValue().compareTo(exclusiveMax) < 0;
        }

        if (!valid) {
            context.addError(
                    "exclusiveMaximum",
                    "At " + context.getInstanceLocation() + ": [exclusiveMaximum] value " + instance
                            + " must be less than " + keywordValue);
        }
        return valid;
    }

    public ExclusiveMaximumKeyword(Double keywordValue) {
        this.keywordValue = BigDecimal.valueOf(keywordValue);
    }

    public Object getKeywordValue() {
        return keywordValue;
    }
}
