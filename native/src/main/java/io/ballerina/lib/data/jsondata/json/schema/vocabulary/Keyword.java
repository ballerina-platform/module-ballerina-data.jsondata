package io.ballerina.lib.data.jsondata.json.schema.vocabulary;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;

public abstract class Keyword {
    public abstract Object getKeywordValue();
    public abstract boolean evaluate(Object instance, EvaluationContext context);
}
