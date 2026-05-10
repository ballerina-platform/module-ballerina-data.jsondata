package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.utils.JsonEqualityUtils;
import io.ballerina.runtime.api.values.BArray;

public class UniqueItemsKeyword extends Keyword {
    public static final String KEYWORD_NAME = "uniqueItems";
    private final Boolean keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BArray array)) {
            return true;
        }
        if (!keywordValue) {
            return true;
        }
        int size = array.size();
        for (int i = 0; i < size; i++) {
            for (int j = i + 1; j < size; j++) {
                if (JsonEqualityUtils.deepEquals(array.get(i), array.get(j))) {
                    context.addError(
                            "uniqueItems",
                            "At " + context.getInstanceLocation()
                                    + ": [uniqueItems] array contains duplicate items at indices " + i
                                    + " and " + j);
                    return false;
                }
            }
        }
        return true;
    }

    public UniqueItemsKeyword(Boolean keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Boolean getKeywordValue() {
        return keywordValue;
    }
}
