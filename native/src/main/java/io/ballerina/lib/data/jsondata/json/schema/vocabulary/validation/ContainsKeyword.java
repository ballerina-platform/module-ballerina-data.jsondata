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

package io.ballerina.lib.data.jsondata.json.schema.vocabulary.validation;

import io.ballerina.lib.data.jsondata.json.schema.EvaluationContext;
import io.ballerina.lib.data.jsondata.json.schema.Validator;
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;
import io.ballerina.runtime.api.values.BArray;

import java.util.ArrayList;
import java.util.List;

public class ContainsKeyword extends Keyword {
    public static final String KEYWORD_NAME = "contains";
    private final Long minContains;
    private final Long maxContains;
    private final Object containsSchema;

    public ContainsKeyword(Long minContains, Long maxContains, Object containsSchema) {
        this.minContains = minContains != null ? minContains : 1L;
        this.maxContains = maxContains;
        this.containsSchema = containsSchema;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BArray array)) {
            return true;
        }

        List<Long> matchingIndices = new ArrayList<>();
        for (long i = 0; i < array.size(); i++) {
            EvaluationContext itemContext = context.createChildContext(String.valueOf(i), "contains/" + i);
            if (Validator.validate(array.get(i), containsSchema, itemContext)) {
                matchingIndices.add(i);
            }
        }

        long matchCount = matchingIndices.size();

        boolean valid = matchCount >= minContains;
        if (maxContains != null) {
            valid = valid && (matchCount <= maxContains);
        }

        if (!valid) {
            if (maxContains != null) {
                context.addError("contains", "At " + context.getInstanceLocation() + 
                    ": [contains] expected " + minContains + " to " + maxContains + 
                    " matches, found " + matchCount);
            } else {
                context.addError("contains", "At " + context.getInstanceLocation() + 
                    ": [contains] expected at least " + minContains + 
                    " matches, found " + matchCount);
            }
        }

        if (matchCount == array.size() && !array.isEmpty()) {
            context.setAnnotation("contains", true);
        } else {
            context.setAnnotation("contains", matchingIndices);
        }

        return valid;
    }

    @Override
    public Object getKeywordValue() {
        return containsSchema;
    }

    public Long getMinContains() {
        return minContains;
    }

    public Long getMaxContains() {
        return maxContains;
    }
}
