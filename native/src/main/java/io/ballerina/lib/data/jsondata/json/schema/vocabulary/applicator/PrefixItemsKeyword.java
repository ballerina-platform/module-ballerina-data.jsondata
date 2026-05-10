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
import io.ballerina.runtime.api.values.BArray;

import java.util.List;

public class PrefixItemsKeyword extends Keyword {
    public static final String KEYWORD_NAME = "prefixItems";
    private final List<Object> keywordValue;

    public PrefixItemsKeyword(List<Object> keywordValue) {
        this.keywordValue = keywordValue;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BArray array)) {
            return true;
        }
        long size = Math.min(array.size(), keywordValue.size());
        boolean isValid = true;
        for (long i = 0; i < size; i++) {
            EvaluationContext itemContext = context.createChildContext(String.valueOf(i), "prefixItems/" + i);
            if (!Validator.validate(array.get(i), keywordValue.get((int) i), itemContext)) {
                isValid = false;
            }
        }
        if (isValid) {
            context.setAnnotation("prefixItems", size - 1);
        }
        return isValid;
    }

    @Override
    public List<Object> getKeywordValue() {
        return keywordValue;
    }
}
