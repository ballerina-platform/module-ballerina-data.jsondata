package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class DependentRequiredKeyword extends Keyword {
    public static final String KEYWORD_NAME = "dependentRequired";
    public final Map<String, List<String>> keywordValue;

    public DependentRequiredKeyword(Map<String, List<String>> keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Object getKeywordValue() {
        return keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BMap<?, ?> bMap)) {
            return true;
        }

        boolean isValid = true;
        ArrayList<String> missingDependentFields = new ArrayList<>();

        for (Map.Entry<String, List<String>> entry : keywordValue.entrySet()) {
            String dependentOn = entry.getKey();
            List<String> requiredFields = entry.getValue();

            BString dependentOnKey = StringUtils.fromString(dependentOn);
            if (bMap.containsKey(dependentOnKey)) {
                for (String requiredField : requiredFields) {
                    BString requiredKey = StringUtils.fromString(requiredField);
                    if (!bMap.containsKey(requiredKey)) {
                        missingDependentFields.add(
                            "'" + dependentOn + "' requires '" + requiredField + "'"
                        );
                        isValid = false;
                    }
                }
            }
        }

        if (!isValid) {
            String missingList = String.join(", ", missingDependentFields);
            context.addError("dependentRequired",
                "At " + context.getInstanceLocation() + ": [dependentRequired] " + missingList);
        }

        return isValid;
    }
}
