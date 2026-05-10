// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

package io.ballerina.lib.data.jsondata.json.schema.vocabulary.unevaluated;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.Validator;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashSet;
import java.util.Set;

public class UnevaluatedPropertiesKeyword extends Keyword {
    public static final String KEYWORD_NAME = "unevaluatedProperties";
    private final Object keywordValue;

    public UnevaluatedPropertiesKeyword(Object keywordValue) {
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

        if (isAllPropertiesEvaluated(context, (BMap<BString, Object>) bMap)) {
            return true;
        }

        Set<String> evaluatedProperties = collectEvaluatedProperties(context);
        mergeBranchEvaluatedProperties(context, evaluatedProperties);

        boolean isValid = true;
        for (BString key : ((BMap<BString, Object>) bMap).getKeys()) {
            String propertyName = key.getValue();
            if (evaluatedProperties.contains(propertyName)) {
                continue;
            }

            EvaluationContext propertyContext = context.createChildContext(propertyName, "unevaluatedProperties");
            if (!Validator.validate(bMap.get(key), keywordValue, propertyContext)) {
                context.addError("unevaluatedProperties", "At " + context.getInstanceLocation() + "/" + propertyName +
                        ": [unevaluatedProperties] property '" + propertyName +
                        "' is not valid against the unevaluatedProperties schema");
                isValid = false;
            }
        }

        if (isValid) {
            context.setAnnotation("evaluatedProperties", true);
        }

        return isValid;
    }

    private boolean isAllPropertiesEvaluated(EvaluationContext context, BMap<BString, Object> instance) {
        Object additionalProperties = context.getAnnotation("additionalProperties");

        if (additionalProperties != null) { // everything is evaluated from this
            return true;
        }

        Object existingEvaluatedProperties = context.getAnnotation("evaluatedProperties");
        if (existingEvaluatedProperties instanceof Boolean evaluatedPropertiesBool && evaluatedPropertiesBool) {
            return true;
        }

        Object ifEvaluatedProperties = context.getAnnotation("ifEvaluatedProperties");
        if (ifEvaluatedProperties instanceof Boolean && (Boolean) ifEvaluatedProperties) {
            return true;
        }

        Object thenEvaluatedProperties = context.getAnnotation("thenEvaluatedProperties");
        if (thenEvaluatedProperties instanceof Boolean && (Boolean) thenEvaluatedProperties) {
            return true;
        }

        Object elseEvaluatedProperties = context.getAnnotation("elseEvaluatedProperties");
        if (elseEvaluatedProperties instanceof Boolean && (Boolean) elseEvaluatedProperties) {
            return true;
        }

        Object properties = context.getAnnotation("properties");
        Set<String> propertiesEvaluated = properties instanceof Set ? (Set<String>) properties : null;
        Object patternProperties = context.getAnnotation("patternProperties");
        Set<String> patternPropertiesEvaluated =
                patternProperties instanceof Set ? (Set<String>) patternProperties : null;

        int totalEvaluatedPropertiesCount = (propertiesEvaluated != null ? propertiesEvaluated.size() : 0) +
                (patternPropertiesEvaluated != null ? patternPropertiesEvaluated.size() : 0);

        return totalEvaluatedPropertiesCount == instance.getKeys().length;
    }

    private Set<String> collectEvaluatedProperties(EvaluationContext context) {
        Set<String> evaluatedProperties = new HashSet<>();
        addEvaluatedProperties(evaluatedProperties, context.getAnnotation("properties"));
        addEvaluatedProperties(evaluatedProperties, context.getAnnotation("patternProperties"));
        addEvaluatedProperties(evaluatedProperties, context.getAnnotation("additionalProperties"));
        addEvaluatedProperties(evaluatedProperties, context.getAnnotation("evaluatedProperties"));
        return evaluatedProperties;
    }

    private void addEvaluatedProperties(Set<String> evaluatedProperties, Object annotation) {
        if (!(annotation instanceof Set<?> propertySet)) {
            return;
        }
        for (Object propertyName : propertySet) {
            if (propertyName instanceof String name) {
                evaluatedProperties.add(name);
            }
        }
    }

    private void mergeBranchEvaluatedProperties(EvaluationContext context, Set<String> properties) {
        Object ifResult = context.getAnnotation("if");
        if (!(ifResult instanceof Boolean)) {
            return;
        }

        boolean ifValid = (Boolean) ifResult;

        Object ifProps = context.getAnnotation("ifEvaluatedProperties");
        if (ifProps instanceof Set<?>) {
            properties.addAll((Set<String>) ifProps);
        }

        if (ifValid) {
            Object thenProps = context.getAnnotation("thenEvaluatedProperties");
            if (thenProps instanceof Set<?>) {
                properties.addAll((Set<String>) thenProps);
            }
        }

        if (!ifValid) {
            Object elseProps = context.getAnnotation("elseEvaluatedProperties");
            if (elseProps instanceof Set<?>) {
                properties.addAll((Set<String>) elseProps);
            }
        }
    }
}
