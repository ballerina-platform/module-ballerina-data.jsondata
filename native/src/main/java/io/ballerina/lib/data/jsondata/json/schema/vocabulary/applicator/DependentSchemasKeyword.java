package io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.Validator;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.utils.SchemaValidatorUtils;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.Map;

public class DependentSchemasKeyword extends Keyword {
    public static final String KEYWORD_NAME = "dependentSchemas";
    public final Map<String, Object> keywordValue;

    public DependentSchemasKeyword(Map<String, Object> keywordValue) {
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

        for (Map.Entry<String, Object> entry : keywordValue.entrySet()) {
            String dependentOn = entry.getKey();
            Object subschema = entry.getValue();
            EvaluationContext subschemaContext =
                    context.createChildContext(dependentOn, "dependentSchemas/" + dependentOn);

            BString dependentOnKey = StringUtils.fromString(dependentOn);
            if (bMap.containsKey(dependentOnKey)) {
                if (!Validator.validate(instance, subschema, subschemaContext)) {
                    isValid = false;
                } else {
                    if (context.isTrackEvaluatedItems()) {
                        SchemaValidatorUtils.createEvaluatedItemsAnnotation(subschemaContext);
                        subschemaContext.moveToParentContext("evaluatedItems");
                    }
                    if (context.isTrackEvaluatedProperties()) {
                        SchemaValidatorUtils.createEvaluatedPropertiesAnnotation(subschemaContext);
                        subschemaContext.moveToParentContext("evaluatedProperties");
                    }
                }
            }
        }

        return isValid;
    }
}
