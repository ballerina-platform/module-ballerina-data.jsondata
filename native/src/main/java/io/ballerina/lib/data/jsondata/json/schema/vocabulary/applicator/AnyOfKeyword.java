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
import io.ballerina.lib.data.jsondata.utils.SchemaValidatorUtils;

import java.util.List;

public class AnyOfKeyword extends Keyword {
    public static final String KEYWORD_NAME = "anyOf";
    private final List<Object> keywordValue;

    public AnyOfKeyword(List<Object> keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        boolean isValid = false;
        for (int i = 0; i < keywordValue.size(); i++) {
            EvaluationContext schemaContext = context.createChildContext("", "anyOf/" + i);

            if (Validator.validate(instance, keywordValue.get(i), schemaContext)) {
                isValid = true;
                if (context.isTrackEvaluatedItems()) {
                    SchemaValidatorUtils.createEvaluatedItemsAnnotation(schemaContext);
                    schemaContext.moveToParentContext("evaluatedItems");
                }
                if (context.isTrackEvaluatedProperties()) {
                    SchemaValidatorUtils.createEvaluatedPropertiesAnnotation(schemaContext);
                    schemaContext.moveToParentContext("evaluatedProperties");
                }
                if (!context.isTrackEvaluatedItems() && !context.isTrackEvaluatedProperties()) {
                    return isValid;
                }
            }
        }
        if (!isValid) {
            context.addError(
                    "anyOf",
                    "At " + context.getInstanceLocation() + ": [anyOf] value does not match any of the subschemas");
        }
        return isValid;
    }

    @Override
    public Object getKeywordValue() {
        return keywordValue;
    }
}
