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
import io.ballerina.lib.data.jsondata.json.schema.vocabulary.Keyword;


public class DynamicAnchorKeyword extends Keyword {
    public static final String KEYWORD_NAME = "$dynamicAnchor";

    private final String anchorName;

    public DynamicAnchorKeyword(String anchorName) {
        this.anchorName = anchorName;
    }

    @Override
    public Object getKeywordValue() {
        return anchorName;
    }

    /**
     * Always returns {@code true}. This keyword is an identifier, not a validator.
     */
    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        return true;
    }
}
