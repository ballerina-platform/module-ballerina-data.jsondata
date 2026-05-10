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


public class ThenKeyword extends Keyword {
    public static final String KEYWORD_NAME = "then";
    private final Object keywordValue;

    public ThenKeyword(Object keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        Object ifResult = context.getAnnotation("if");
        if (ifResult == null) {
            return true;
        }
        if (ifResult instanceof Boolean ifValid) {
            if (ifValid) {
                EvaluationContext thenContext = context.createChildContext("", "then");
                boolean thenValid = Validator.validate(instance, keywordValue, thenContext);
                if (thenValid) {
                    if (context.isTrackEvaluatedItems()) {
                        SchemaValidatorUtils.createEvaluatedItemsAnnotation(thenContext);
                        context.setAnnotation("thenEvaluatedItems", thenContext.getAnnotation("evaluatedItems"));
                    }
                    if (context.isTrackEvaluatedProperties()) {
                        SchemaValidatorUtils.createEvaluatedPropertiesAnnotation(thenContext);
                        context.setAnnotation(
                                "thenEvaluatedProperties",
                                thenContext.getAnnotation("evaluatedProperties"));
                    }
                }
                return thenValid;
            }
        }
        return true;
    }

    @Override
    public Object getKeywordValue() {
        return keywordValue;
    }
}
