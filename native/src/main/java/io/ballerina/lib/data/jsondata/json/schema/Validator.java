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

package io.ballerina.lib.data.jsondata.json.schema;

import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;

import java.net.URI;

public class Validator {
    public static boolean validate(Object instance, Object schema, EvaluationContext context) {
        return validate(instance, schema, context, false);
    }

    public static boolean validate(Object instance, Object schema, EvaluationContext context, boolean failFast) {
        if (schema instanceof Boolean boolSchema) {
            if (!boolSchema) {
                context.addError(
                        "schema",
                        "At " + context.getInstanceLocation() + ": value is not allowed (false schema)");
            }
            return boolSchema;
        }

        Schema s = (Schema) schema;
        boolean isValid = true;
        boolean pushedScope = false;

        URI resourceUri = s.getResourceUri();
        if (resourceUri != null) {
            context.pushDynamicScope(resourceUri);
            pushedScope = true;
        } else if (context.getDynamicScope().isEmpty()) {
            context.pushDynamicScope(Schema.DEFAULT_SCOPE_URI);
            pushedScope = true;
        }

        boolean prevTrackItems = context.isTrackEvaluatedItems();
        boolean prevTrackProperties = context.isTrackEvaluatedProperties();
        if (s.hasUnevaluatedItems()) {
            context.setTrackEvaluatedItems(true);
        }
        if (s.hasUnevaluatedProperties()) {
            context.setTrackEvaluatedProperties(true);
        }

        try {
            for (String key : s.getOrderedKeys()) {
                Keyword keyword = s.getKeyword(key);
                if (keyword != null) {
                    boolean keywordResult = keyword.evaluate(instance, context);
                    if (!keywordResult) {
                        isValid = false;
                        if (failFast) {
                            return false;
                        }
                    }
                }
            }
        } finally {
            context.setTrackEvaluatedItems(prevTrackItems);
            context.setTrackEvaluatedProperties(prevTrackProperties);
            if (pushedScope) {
                context.popDynamicScope();
            }
        }
        return isValid;
    }
}
