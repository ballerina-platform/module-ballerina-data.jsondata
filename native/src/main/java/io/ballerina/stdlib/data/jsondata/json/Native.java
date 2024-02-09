/*
 * Copyright (c) 2024, WSO2 LLC. (https://www.wso2.com).
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.data.jsondata.json;

import io.ballerina.runtime.api.Environment;
import io.ballerina.runtime.api.Future;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.JsonUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BError;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BStream;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.values.BTypedesc;
import io.ballerina.stdlib.data.jsondata.io.DataReaderTask;
import io.ballerina.stdlib.data.jsondata.io.DataReaderThreadPool;
import io.ballerina.stdlib.data.jsondata.utils.DiagnosticErrorCode;
import io.ballerina.stdlib.data.jsondata.utils.DiagnosticLog;

import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.io.StringReader;

/**
 * Json conversions.
 *
 * @since 0.1.0
 */
public class Native {

    public static Object fromJsonWithType(Object json, BMap<BString, Object> options, BTypedesc typed) {
        try {
            return JsonTraverse.traverse(json, typed.getDescribingType());
        } catch (BError e) {
            return e;
        }
    }

    public static Object fromJsonStringWithType(Environment env, Object json, BMap<BString, Object> options,
                                               BTypedesc typed) {
        try {
            Type expType = typed.getDescribingType();
            if (json instanceof BString) {
                return JsonParser.parse(new StringReader(((BString) json).getValue()), expType);
            } else if (json instanceof BArray) {
                byte[] bytes = ((BArray) json).getBytes();
                return JsonParser.parse(new InputStreamReader(new ByteArrayInputStream(bytes)),
                        typed.getDescribingType());
            } else if (json instanceof BStream) {
                final BObject iteratorObj = ((BStream) json).getIteratorObj();
                final Future future = env.markAsync();
                DataReaderTask task = new DataReaderTask(env, iteratorObj, future, typed);
                DataReaderThreadPool.EXECUTOR_SERVICE.submit(task);
                return null;
            } else {
                return DiagnosticLog.error(DiagnosticErrorCode.UNSUPPORTED_TYPE, expType);
            }
        } catch (BError e) {
            return e;
        } catch (Exception e) {
            return DiagnosticLog.error(DiagnosticErrorCode.JSON_PARSER_EXCEPTION, e.getMessage());
        }
    }

    public static Object toJson(Object value) {
        return JsonUtils.convertToJson(value);
    }
}
