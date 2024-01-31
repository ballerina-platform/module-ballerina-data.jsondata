/*
 *  Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com)
 *
 *  WSO2 LLC. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package io.ballerina.stdlib.jsonpath;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Module;
import io.ballerina.runtime.api.creators.ErrorCreator;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * Utility functions of JsonPath module.
 *
 * @since 0.1.0
 */
public class Utils {
    public static final String ERROR = "Error";
    private static Module jsonpathModule;

    public static Module getModule() {
        return jsonpathModule;
    }

    @SuppressWarnings("unused")
    public static void setModule(Environment env) {
        jsonpathModule = env.getCurrentModule();
    }

    public static BError createError(String message, BError cause) {
        return ErrorCreator.createError(getModule(), ERROR, StringUtils.fromString(message), cause, null);
    }

    public static BError createError(String message) {
        return ErrorCreator.createError(getModule(), ERROR, StringUtils.fromString(message), null, null);
    }

    public static String getCanNotExecuteQueryErrorMessage(BString query) {
        return "Unable to execute query '" + query.getValue() + "' on the provided JSON value";
    }

    public static String convertRawTemplateToString(BObject rawTemplate) {
        BArray insertionsArray = rawTemplate.getArrayValue(fromString("insertions"));
        BArray stringsArray = rawTemplate.getArrayValue(fromString("strings"));
        if (stringsArray.size() == 0) {
            return "";
        } else {
            long insertionLength = insertionsArray.getLength();
            String query = stringsArray.getBString(0).getValue();
            for (int i = 1; i < stringsArray.size(); i++) {
                String templatedString = "";
                if (i - 1 < insertionLength) {
                    templatedString = StringUtils.getStringValue(insertionsArray.get(i - 1));
                }
                query += templatedString + stringsArray.getBString(i).getValue();
            }
            return query;
        }
    }
}
