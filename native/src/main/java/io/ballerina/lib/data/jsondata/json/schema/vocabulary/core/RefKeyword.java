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

package io.ballerina.lib.data.jsondata.json.schema.vocabulary.core;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.SchemaRegistry;
import io.ballerina.lib.data.jsondata.json.schema.Validator;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.lib.data.jsondata.utils.SchemaValidatorUtils;

import java.net.URI;

public class RefKeyword extends Keyword {

    public static final String KEYWORD_NAME = "$ref";

    private final URI refUri;

    public RefKeyword(URI refUri) {
        this.refUri = refUri;
    }

    @Override
    public URI getKeywordValue() {
        return refUri;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        SchemaRegistry registry = context.getSchemaRegistry();
        if (registry == null) {
            context.addError(KEYWORD_NAME,
                    "At " + context.getInstanceLocation()
                            + ": schema registry is required for $ref resolution");
            return false;
        }

        Object target = registry.resolveReference(refUri);
        if (target == null) {
            context.addError(KEYWORD_NAME,
                    "At " + context.getInstanceLocation()
                            + ": unresolved $ref '" + refUri + "'");
            return false;
        }

        context.pushDynamicScope(refUri);
        try {
            EvaluationContext refContext = context.createChildContext("", KEYWORD_NAME);
            boolean isValid = Validator.validate(instance, target, refContext);
            if (isValid) {
                if (context.isTrackEvaluatedProperties()) {
                    SchemaValidatorUtils.createEvaluatedPropertiesAnnotation(refContext);
                    refContext.moveToParentContext("evaluatedProperties");
                }
                if (context.isTrackEvaluatedItems()) {
                    SchemaValidatorUtils.createEvaluatedItemsAnnotation(refContext);
                    refContext.moveToParentContext("evaluatedItems");
                }
            }
            return isValid;
        } finally {
            context.popDynamicScope();
        }
    }
}

