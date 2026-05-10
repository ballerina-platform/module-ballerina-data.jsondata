package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BDecimal;

import java.math.BigDecimal;

public class MinimumKeyword extends Keyword {
    public static final String KEYWORD_NAME = "minimum";
    private final BigDecimal keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        boolean valid = true;
        BigDecimal minimum = keywordValue;
        if (instance instanceof Double d) {
            valid = BigDecimal.valueOf(d).compareTo(minimum) >= 0;
        } else if (instance instanceof Long l) {
            valid = BigDecimal.valueOf(l).compareTo(minimum) >= 0;
        }  else if (instance instanceof BDecimal bd) {
            valid = bd.decimalValue().compareTo(minimum) >= 0;
        }

        if (!valid) {
            context.addError(
                    "minimum",
                    "At " + context.getInstanceLocation() + ": [minimum] value " + instance
                            + " is less than minimum " + keywordValue);
        }
        return valid;
    }

    public MinimumKeyword(Double keywordValue) {
        this.keywordValue = BigDecimal.valueOf(keywordValue);
    }

    public Object getKeywordValue() {
        return keywordValue;
    }
}
