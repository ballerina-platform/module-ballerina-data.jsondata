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

package io.ballerina.lib.data.jsondata.json.schema.vocabulary.applicator;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.Validator;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import java.util.HashSet;
import java.util.Set;

public class AdditionalPropertiesKeyword extends Keyword {
    public static final String KEYWORD_NAME = "additionalProperties";
    private final Object additionalSchema;

    public AdditionalPropertiesKeyword(Object additionalSchema) {
        this.additionalSchema = additionalSchema;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BMap<?, ?> bMap)) {
            return true;
        }

        Set<String> propertiesMatched = null;
        Object propertiesAnnotation = context.getAnnotation(PropertiesKeyword.KEYWORD_NAME);
        if (propertiesAnnotation instanceof Set) {
            propertiesMatched = (Set<String>) propertiesAnnotation;
        }

        Set<String> patternPropertiesMatched = null;
        Object patternPropertiesAnnotation = context.getAnnotation("patternProperties");
        if (patternPropertiesAnnotation instanceof Set) {
            patternPropertiesMatched = (Set<String>) patternPropertiesAnnotation;
        }

        if (additionalSchema instanceof Boolean) {
            if (!(boolean) additionalSchema) {
                boolean isValid = true;
                for (BString key : ((BMap<BString, Object>) bMap).getKeys()) {
                    String propertyName = key.getValue();

                    boolean isDefinedProperty = propertiesMatched != null &&
                                          propertiesMatched.contains(propertyName);
                    boolean isPatternProperty = patternPropertiesMatched != null &&
                                          patternPropertiesMatched.contains(propertyName);

                    if (!isDefinedProperty && !isPatternProperty) {
                        context.addError("additionalProperties",
                            "At " + context.getInstanceLocation() + "/" + propertyName +
                            ": [additionalProperties=false] property '" + propertyName +
                            "' is not allowed");
                        isValid = false;
                    }
                }
                return isValid;
            }
        }

        boolean isValid = true;

        Set<String> validatedPropertyNames = new HashSet<>();

        for (BString key : ((BMap<BString, Object>) bMap).getKeys()) {
            String propertyName = key.getValue();

            if (propertiesMatched != null && propertiesMatched.contains(propertyName)) {
                continue;
            }
            if (patternPropertiesMatched != null && patternPropertiesMatched.contains(propertyName)) {
                continue;
            }

            EvaluationContext propertyContext = context.createChildContext(
                propertyName, "additionalProperties/" + propertyName);

            if (Validator.validate(bMap.get(key), additionalSchema, propertyContext)) {
                if (validatedPropertyNames != null) {
                    validatedPropertyNames.add(propertyName);
                }
            } else {
                isValid = false;
            }
        }

        if (isValid && validatedPropertyNames != null) {
            context.setAnnotation(KEYWORD_NAME, validatedPropertyNames);
        }

        return isValid;
    }

    @Override
    public Object getKeywordValue() {
        return additionalSchema;
    }
}
