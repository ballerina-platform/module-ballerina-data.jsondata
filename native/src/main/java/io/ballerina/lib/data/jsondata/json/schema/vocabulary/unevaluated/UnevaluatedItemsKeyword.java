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
import io.ballerina.runtime.api.values.BArray;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class UnevaluatedItemsKeyword extends Keyword {
    public static final String KEYWORD_NAME = "unevaluatedItems";
    private final Object keywordValue;

    public UnevaluatedItemsKeyword(Object keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public Object getKeywordValue() {
        return this.keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BArray array)) {
            return true;
        }

        if (isAllItemsEvaluated(context)) {
            return true;
        }

        Set<Long> evaluatedIndices = collectEvaluatedIndices(context);
        mergeBranchEvaluatedIndices(context, evaluatedIndices);

        boolean isValid = true;
        for (long i = 0; i < array.size(); i++) {
            if (!evaluatedIndices.contains(i)) {
                Object item = array.get(i);
                EvaluationContext itemContext = context.createChildContext(String.valueOf(i), "unevaluatedItems");
                if (!Validator.validate(item, keywordValue, itemContext)) {
                    context.addError(
                            "unevaluatedItems",
                            "At " + context.getInstanceLocation() + "/" + i
                                    + ": [unevaluatedItems] item at index " + i
                                    + " is not valid against the unevaluatedItems schema");
                    isValid = false;
                }
            }
        }

        if (isValid) {
            context.setAnnotation("evaluatedItems", true);
        }
        return isValid;
    }

    private boolean isAllItemsEvaluated(EvaluationContext context) {
        Object items = context.getAnnotation("items");
        if (items instanceof Boolean && (Boolean) items) {
            return true;
        }

        Object evaluatedItems = context.getAnnotation("evaluatedItems");
        if (evaluatedItems instanceof Boolean && (Boolean) evaluatedItems) {
            return true;
        }

        Object contains = context.getAnnotation("contains");
        if (contains instanceof Boolean && (Boolean) contains) {
            return true;
        }

        Object ifEvaluatedItems = context.getAnnotation("ifEvaluatedItems");
        if (ifEvaluatedItems instanceof Boolean && (Boolean) ifEvaluatedItems) {
            return true;
        }

        Object thenEvaluatedItems = context.getAnnotation("thenEvaluatedItems");
        if (thenEvaluatedItems instanceof Boolean && (Boolean) thenEvaluatedItems) {
            return true;
        }

        Object elseEvaluatedItems = context.getAnnotation("elseEvaluatedItems");
        if (elseEvaluatedItems instanceof Boolean && (Boolean) elseEvaluatedItems) {
            return true;
        }

        return false;
    }

    private Set<Long> collectEvaluatedIndices(EvaluationContext context) {
        Set<Long> indices = new HashSet<>();

        Object prefixItems = context.getAnnotation("prefixItems");
        if (prefixItems instanceof Long lastIndex) {
            for (long i = 0; i <= lastIndex; i++) {
                indices.add(i);
            }
        }

        Object contains = context.getAnnotation("contains");
        if (contains instanceof List) {
            for (Object idx : (List<?>) contains) {
                if (idx instanceof Long) {
                    indices.add((Long) idx);
                }
            }
        }

        Object evaluatedItems = context.getAnnotation("evaluatedItems");
        if (evaluatedItems instanceof List) {
            for (Object idx : (List<?>) evaluatedItems) {
                if (idx instanceof Long) {
                    indices.add((Long) idx);
                }
            }
        }

        return indices;
    }

    private void mergeBranchEvaluatedIndices(EvaluationContext context, Set<Long> indices) {
        Object ifResult = context.getAnnotation("if");
        if (!(ifResult instanceof Boolean)) {
            return;
        }

        boolean ifValid = (Boolean) ifResult;

        Object ifIndices = context.getAnnotation("ifEvaluatedItems");
        if (ifIndices instanceof ArrayList<?>) {
            indices.addAll((ArrayList<Long>) ifIndices);
        }

        if (ifValid) {
            Object thenIndices = context.getAnnotation("thenEvaluatedItems");
            if (thenIndices instanceof ArrayList<?>) {
                indices.addAll((ArrayList<Long>) thenIndices);
            }
        }

        if (!ifValid) {
            Object elseIndices = context.getAnnotation("elseEvaluatedItems");
            if (elseIndices instanceof ArrayList<?>) {
                indices.addAll((ArrayList<Long>) elseIndices);
            }
        }
    }
}
