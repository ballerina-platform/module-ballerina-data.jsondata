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

package io.ballerina.lib.data.jsonpath;

import com.jayway.jsonpath.Configuration;
import com.jayway.jsonpath.JsonPathException;
import com.jayway.jsonpath.PathNotFoundException;
import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BObject;

import static com.jayway.jsonpath.JsonPath.using;
import static io.ballerina.lib.data.jsonpath.Utils.convertRawTemplateToString;

/**
 * Provides function implementations of json-path.
 *
 * @since 0.1.0
 */
public class BJsonPath {
    public static final Configuration BJSON_CONFIGURATION = Configuration
            .builder()
            .jsonProvider(new BJsonProvider())
            .build();

    public static Object readJson(Object json, BObject query) {
        try {
            return using(BJSON_CONFIGURATION)
                    .parse(json)
                    .read(convertRawTemplateToString(query));
        } catch (PathNotFoundException e) {
            BError cause = Utils.createError(e.getMessage());
            return Utils.createError(Utils.getCannotExecuteQueryErrorMessage(StringUtils.
                fromString(convertRawTemplateToString(query))), cause);
        } catch (IllegalArgumentException | JsonPathException e) {
            return Utils.createError(e.getMessage());
        }
    }
}
