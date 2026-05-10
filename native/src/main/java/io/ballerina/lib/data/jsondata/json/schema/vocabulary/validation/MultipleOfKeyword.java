package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BDecimal;

import java.math.BigDecimal;

public class MultipleOfKeyword extends Keyword {
    public static final String KEYWORD_NAME = "multipleOf";
    private final Double keywordValue;

    public MultipleOfKeyword(Double keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof Number) && !(instance instanceof BDecimal)) {
            return true;
        }

        boolean valid = true;
        BigDecimal instanceBd = null;

        if (instance instanceof BDecimal) {
            instanceBd = ((BDecimal) instance).decimalValue();
        } else if (instance instanceof Long) {
            instanceBd = BigDecimal.valueOf((Long) instance);
        } else if (instance instanceof Double) {
            instanceBd = BigDecimal.valueOf((Double) instance);
        }

        if (instanceBd != null) {
            BigDecimal divisorBd = BigDecimal.valueOf(keywordValue);
            if (divisorBd.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal remainder = instanceBd.remainder(divisorBd);
                valid = remainder.compareTo(BigDecimal.ZERO) == 0;
            } else {
                valid = false;
            }
        }

        if (!valid) {
            context.addError("multipleOf", "At " + context.getInstanceLocation() +
                    ": [multipleOf] value " + instance + " is not a multiple of " + keywordValue);
        }

        return valid;
    }

    public Object getKeywordValue() {
        return keywordValue;
    }
}
