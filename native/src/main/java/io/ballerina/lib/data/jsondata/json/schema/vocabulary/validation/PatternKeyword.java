package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BRegexpValue;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.langlib.regexp.Find;
import org.ballerinalang.langlib.regexp.FromString;

public class PatternKeyword extends Keyword {
    public static final String KEYWORD_NAME = "pattern";
    private final BRegexpValue keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BString str)) {
            return true;
        }
        boolean valid = Find.find(keywordValue, str, 0) != null;
        if (!valid) {
            context.addError(
                    "pattern",
                    "At " + context.getInstanceLocation() + ": [pattern] value does not match pattern "
                            + keywordValue);
        }
        return valid;
    }

    public PatternKeyword(BRegexpValue keywordValue) {
        this.keywordValue = keywordValue;
    }

    public PatternKeyword(BString keywordValue) {
        Object regexVal = FromString.fromString(keywordValue);

        if (regexVal instanceof BRegexpValue) {
            this.keywordValue = (BRegexpValue) regexVal;
        } else {
            throw new IllegalArgumentException(
                    "Invalid regular expression pattern: " + keywordValue.getValue() +
                            " | Ballerina internal error: " + regexVal.toString()
            );
        }
    }

    @Override
    public BRegexpValue getKeywordValue() {
        return keywordValue;
    }
}
