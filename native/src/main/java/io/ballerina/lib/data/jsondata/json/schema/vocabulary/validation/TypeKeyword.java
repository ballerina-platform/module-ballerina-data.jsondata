package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.utils.SchemaParserUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class TypeKeyword extends Keyword {
    public static final String KEYWORD_NAME = "type";
    public final Set<String> keywordValue;

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        for (String keyword : keywordValue) {
            if (Objects.equals(keyword, "null") && instance == null) {
                return true;
            }
            if (Objects.equals(keyword, "string") && instance instanceof BString) {
                return true;
            }

            if (Objects.equals(keyword, "integer")) {
                if (instance instanceof Long) {
                    return true;
                }
                Long intVal = SchemaParserUtils.toInteger(instance);
                if (intVal != null) {
                    return true;
                }
            }

            if (Objects.equals(keyword, "number")
                    && (instance instanceof Double || instance instanceof Long
                    || instance instanceof BDecimal)) {
                return true;
            }

            if (Objects.equals(keyword, "boolean") && instance instanceof Boolean) {
                return true;
            }

            if (Objects.equals(keyword, "object") && instance instanceof BMap<?, ?>) {
                return true;
            }

            if (Objects.equals(keyword, "array") && instance instanceof BArray) {
                return true;
            }
        }
        String actualType = instance == null ? "null" : instance.getClass().getSimpleName();
        context.addError("type",
                "At " + context.getInstanceLocation() + ": [type] expected " + keywordValue
                        + " but found " + actualType);
        return false;
    }

    public TypeKeyword(Set<String> typeName) {
        this.keywordValue = typeName;
    }

    public TypeKeyword(String typeName) {
        this.keywordValue = new HashSet<>();
        this.keywordValue.add(typeName);
    }

    @Override
    public Set<String> getKeywordValue() {
        return keywordValue;
    }
}
