package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BDecimal;

import java.math.BigDecimal;

public class MaximumKeyword extends Keyword {
    public static final String KEYWORD_NAME = "maximum";
    private final BigDecimal keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        boolean valid = true;
        BigDecimal maximum = keywordValue;
        if (instance instanceof Double d) {
            valid = BigDecimal.valueOf(d).compareTo(maximum) <= 0;
        } else if (instance instanceof Long l) {
            valid = BigDecimal.valueOf(l).compareTo(maximum) <= 0;
        } else if (instance instanceof BDecimal bd) {
            valid = bd.decimalValue().compareTo(maximum) <= 0;
        }

        if (!valid) {
            context.addError(
                    "maximum",
                    "At " + context.getInstanceLocation() + ": [maximum] value " + instance
                            + " exceeds maximum " + keywordValue);
        }
        return valid;
    }

    public MaximumKeyword(Double keywordValue) {
        this.keywordValue = BigDecimal.valueOf(keywordValue);
    }

    public Object getKeywordValue() {
        return keywordValue;
    }
}
