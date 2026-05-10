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
import io.ballerina.lib.data.jsondata.utils.DiagnosticLog;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BRegexpValue;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.langlib.regexp.Find;
import org.ballerinalang.langlib.regexp.FromString;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class PatternPropertiesKeyword extends Keyword {
    public static final String KEYWORD_NAME = "patternProperties";
    private final List<PatternEntry> entries;

    private record PatternEntry(String patternStr, BRegexpValue regex, Object schema) { }

    public PatternPropertiesKeyword(Map<String, Object> patternSchemaMap) {
        this.entries = new ArrayList<>();
        for (Map.Entry<String, Object> entry : patternSchemaMap.entrySet()) {
            String patternStr = entry.getKey();
            Object result = FromString.fromString(StringUtils.fromString(patternStr));
            if (result instanceof BRegexpValue regex) {
                this.entries.add(new PatternEntry(patternStr, regex, entry.getValue()));
            } else {
                throw DiagnosticLog.createJsonError("invalid regex pattern: " + patternStr);
            }
        }
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
            Object propertyValue = bMap.get(propertyKey);
            boolean propertyMatched = false;

            for (PatternEntry entry : entries) {
                if (Find.find(entry.regex, propertyKey, 0) != null) {
                    propertyMatched = true;

                    EvaluationContext propertyContext = context.createChildContext(
                        propertyName, "patternProperties/" + entry.patternStr);

                    if (!Validator.validate(propertyValue, entry.schema, propertyContext)) {
                        isValid = false;
                    }
                }
            }

            if (propertyMatched && matchedPropertyNames != null) {
                matchedPropertyNames.add(propertyName);
            }
        }

        if (matchedPropertyNames != null) {
            context.setAnnotation(KEYWORD_NAME, matchedPropertyNames);
        }
        return isValid;
    }

    @Override
    public Object getKeywordValue() {
        return entries;
    }
}
