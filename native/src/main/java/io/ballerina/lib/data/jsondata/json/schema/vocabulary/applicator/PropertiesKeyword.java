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
import java.util.Map;
import java.util.Set;

public class PropertiesKeyword extends Keyword {
    public static final String KEYWORD_NAME = "properties";
    private final Map<String, Object> propertiesMap;

    public PropertiesKeyword(Map<String, Object> propertiesMap) {
        this.propertiesMap = propertiesMap;
    }

    @Override
    public boolean evaluate(Object instance, EvaluationContext context) {
        if (!(instance instanceof BMap<?, ?> bMap)) {
            return true;
        }

        boolean isValid = true;

        Set<String> matchedPropertyNames = new HashSet<>();

        for (BString propertyKey : ((BMap<BString, Object>) bMap).getKeys()) {
            String propertyName = propertyKey.getValue();

            Object schema = propertiesMap.get(propertyName);
            if (schema != null) {
                matchedPropertyNames.add(propertyName);
                EvaluationContext propertyContext =
                        context.createChildContext(propertyName, "properties/" + propertyName);

                if (!Validator.validate(bMap.get(propertyKey), schema, propertyContext)) {
                    isValid = false;
                }
            }
        }

        context.setAnnotation(KEYWORD_NAME, matchedPropertyNames);

        return isValid;
    }

    @Override
    public Object getKeywordValue() {
        return propertiesMap;
    }
}
