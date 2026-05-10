package io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.Validator;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.utils.SchemaValidatorUtils;

import java.util.List;

public class OneOfKeyword extends Keyword {
    public static final String KEYWORD_NAME = "oneOf";
    private final List<Object> keywordValue;

    public OneOfKeyword(List<Object> keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        int matchCount = 0;
        EvaluationContext matchedContext = null;
        for (int i = 0; i < keywordValue.size(); i++) {
            EvaluationContext schemaContext =
                    context.createChildContext("", "oneOf/" + i);
            if (Validator.validate(instance, keywordValue.get(i), schemaContext)) {
                matchCount++;
                if (matchCount > 1) {
                    context.addError(
                            "oneOf",
                            "At " + context.getInstanceLocation()
                                    + ": [oneOf] value matches more than one subschema");
                    return false;
                }
                matchedContext = schemaContext;
            }
        }
        if (matchCount == 1) {
            if (context.isTrackEvaluatedItems()) {
                SchemaValidatorUtils.createEvaluatedItemsAnnotation(matchedContext);
                matchedContext.moveToParentContext("evaluatedItems");
            }
            if (context.isTrackEvaluatedProperties()) {
                SchemaValidatorUtils.createEvaluatedPropertiesAnnotation(matchedContext);
                matchedContext.moveToParentContext("evaluatedProperties");
            }
            return true;
        }
        context.addError(
                "oneOf",
                "At " + context.getInstanceLocation() + ": [oneOf] value does not match exactly one subschema");
        return false;
    }

    @Override
    public Object getKeywordValue() {
        return keywordValue;
    }
}
