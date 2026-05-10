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

public class ElseKeyword extends Keyword {
    public static final String KEYWORD_NAME = "else";
    private final Object keywordValue;

    public ElseKeyword(Object keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        Object ifResult = context.getAnnotation("if");
        if (ifResult == null) {
            return true;
        }
        if (ifResult instanceof Boolean) {
            boolean ifValid = (Boolean) ifResult;
            if (!ifValid) {
                EvaluationContext elseContext = context.createChildContext("", "else");
                boolean elseValid = Validator.validate(instance, keywordValue, elseContext);
                if (elseValid) {
                    if (context.isTrackEvaluatedItems()) {
                        SchemaValidatorUtils.createEvaluatedItemsAnnotation(elseContext);
                        context.setAnnotation("elseEvaluatedItems", elseContext.getAnnotation("evaluatedItems"));
                    }
                    if (context.isTrackEvaluatedProperties()) {
                        SchemaValidatorUtils.createEvaluatedPropertiesAnnotation(elseContext);
                        context.setAnnotation(
                                "elseEvaluatedProperties",
                                elseContext.getAnnotation("evaluatedProperties"));
                    }
                }
                return elseValid;
            }
        }
        return true;
    }

    @Override
    public Object getKeywordValue() {
        return keywordValue;
    }
}
